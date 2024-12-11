--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2024-12-11 22:30:56

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 298 (class 1255 OID 26496)
-- Name: check_rental_duration(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_rental_duration() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- We check that the difference between the start and end dates of the lease does not exceed 12 months
    
    IF EXTRACT(YEAR FROM AGE(NEW.period_end, NEW.period_start)) * 12 + EXTRACT(MONTH FROM AGE(NEW.period_end, NEW.period_start)) > 12 THEN
        RAISE EXCEPTION 'Rental period cannot exceed 12 months.';
    END IF;


	
	
    -- If the check is passed, return NEW (data to insert or update)
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_rental_duration() OWNER TO postgres;

--
-- TOC entry 302 (class 1255 OID 26762)
-- Name: renting_check2(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.renting_check2() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    active_rentals_count INT;
BEGIN
    -- Calculate the number of active rentals for a new instrument
    SELECT COUNT(*) INTO active_rentals_count
    FROM renting_instruments
    WHERE instrum_id = NEW.instrum_id AND period_end >= CURRENT_DATE;

    -- Check limit
    IF active_rentals_count >= 2 THEN
        RAISE EXCEPTION 'You need to specify the number of musical instruments from 0 to 2';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.renting_check2() OWNER TO postgres;

--
-- TOC entry 301 (class 1255 OID 26761)
-- Name: renting_check2(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.renting_check2(instrum_id integer, student_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    active_rentals_count INT;
BEGIN
    -- Подсчитать количество активных аренд для данного инструмента
    SELECT COUNT(*) INTO active_rentals_count
    FROM renting_instruments
    WHERE instrum_id = instrum_id AND period_end >= CURRENT_DATE;

    -- Проверить лимит
    IF active_rentals_count >= 2 THEN
        RAISE EXCEPTION 'You need to specify the number of musical instruments from 0 to 2';
    END IF;

    -- Дополнительные проверки для студента, если требуется
END;
$$;


ALTER FUNCTION public.renting_check2(instrum_id integer, student_id integer) OWNER TO postgres;

--
-- TOC entry 299 (class 1255 OID 26511)
-- Name: update_price_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_price_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Checking if the value needs to be updated
    IF NEW.price_id <> OLD.price_id THEN
        UPDATE complet_lessons
        SET price_id = (
            SELECT b.price_id
            FROM price a
            JOIN complet_lessons b ON a.lessons_id = b.lessons_id AND a.levels_id = b.levels_id
            WHERE a.price_finish = b.period_start
            LIMIT 1  -- Limit the result to just one line
        )
        WHERE price_id <> NEW.price_id;
		RAISE EXCEPTION '% The student must pay the fee on the date the lesson was taken!', OLD.price_id;
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.update_price_id() OWNER TO postgres;

--
-- TOC entry 300 (class 1255 OID 25932)
-- Name: update_total_paid(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_total_paid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	price_id_stud INT;			-- Local variable to identify the cost of the service
    service_price NUMERIC;      -- Local variable for storing the cost of the service
    sibling_count INT;          -- Local variable for number of siblings
	class_count INT;			-- Local variable to count the number of lessons
    sibling_discount NUMERIC;   -- Local variable for discount
BEGIN

	-- Get the cost of the service from the price table
    SELECT price_id INTO price_id_stud
    FROM price
    WHERE lessons_id = NEW.lessons_id 
		AND levels_id = NEW.levels_id
		AND price_finish <= NEW.period_end;

		-- Update price_id 
    NEW.price_id := price_id_stud;
		
	
	-- Get the cost of the service from the price table
    SELECT price_service INTO service_price
    FROM price
    WHERE lessons_id = NEW.lessons_id 
		AND levels_id = NEW.levels_id
		AND price_finish <= NEW.period_end;

		

    -- Count the number of brothers and sisters
    SELECT COUNT(*) INTO sibling_count
    FROM sibling
    WHERE student_numb = NEW.student_numb 
		 OR person_sibling = NEW.student_numb;

		 -- Update sibling_price_id
    NEW.sibling_price_id := sibling_count;
	
	 -- If there are brothers/sisters, set a discount
    IF NEW.sibling_price_id > 0 THEN
        sibling_discount := 0.05; -- 5% discount
    ELSE
        sibling_discount := 0; -- No discount
    END IF;

		 

-- Calculate the number of lessons
SELECT COUNT(*) INTO class_count
FROM complet_lessons
WHERE lessons_id = NEW.lessons_id
  AND levels_id = NEW.levels_id 
  AND student_id = NEW.student_numb
  AND period_start >= NEW.period_start
  AND period_end <= NEW.period_end;

-- Make sure class_count is correct
IF class_count IS NULL THEN
    class_count := 0;
END IF;

-- Update total_numb_classes
NEW.total_numb_classes := class_count;

	

   
    -- Calculate total_paid
    NEW.total_paid := class_count * service_price * (1 + sibling_count * (1 - sibling_discount));

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_total_paid() OWNER TO postgres;

--
-- TOC entry 297 (class 1255 OID 25934)
-- Name: update_total_received(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_total_received() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	payment_id_ins INT;			-- Local variable to identify the cost of the service
    service_price NUMERIC;      -- Local variable for storing the cost of the service
   	class_count INT;			-- Local variable to count the number of lessons
    
BEGIN

	-- Get the cost of the service from the price table
    SELECT price_id INTO payment_id_ins
    FROM price
    WHERE lessons_id = NEW.lessons_id 
		AND levels_id = NEW.levels_id
		AND price_finish <= NEW.period_end;

		-- Update price_id 
    NEW.price_id := payment_id_ins;
		
	
	-- Get the cost of the service from the price table
    SELECT price_service INTO service_price
    FROM price
    WHERE lessons_id = NEW.lessons_id 
		AND levels_id = NEW.levels_id
		AND price_finish <= NEW.period_end;

	
		 

-- Calculate the number of lessons
SELECT COUNT(*) INTO class_count
FROM complet_lessons
WHERE lessons_id = NEW.lessons_id
  AND levels_id = NEW.levels_id 
  AND instructor_id = NEW.instruktor_numb
  AND period_start >= NEW.period_start
  AND period_end <= NEW.period_end;

-- Make sure class_count is correct
IF class_count IS NULL THEN
    class_count := 0;
END IF;

-- Update total_number_classes
NEW.total_number_classes := class_count; 

	

   
    -- Calculate total_received
    NEW.total_received := NEW.total_number_classes * service_price;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_total_received() OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 17511)
-- Name: reservations_reserv_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservations_reserv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2343546326
    CACHE 1;


ALTER SEQUENCE public.reservations_reserv_id_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 270 (class 1259 OID 17512)
-- Name: actual_seats_ensemble; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.actual_seats_ensemble (
    reserv_id integer DEFAULT nextval('public.reservations_reserv_id_seq'::regclass) NOT NULL,
    ensemble_id integer NOT NULL,
    actual_seats integer NOT NULL
);


ALTER TABLE public.actual_seats_ensemble OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 17546)
-- Name: reservations_reserv_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservations_reserv_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 456253768
    CACHE 1;


ALTER SEQUENCE public.reservations_reserv_group_id_seq OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 17540)
-- Name: actual_seats_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.actual_seats_group (
    reserv_id integer DEFAULT nextval('public.reservations_reserv_group_id_seq'::regclass) NOT NULL,
    group_lessons_id integer NOT NULL,
    actual_seats integer NOT NULL
);


ALTER TABLE public.actual_seats_group OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16507)
-- Name: address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.address (
    address_id integer NOT NULL,
    postal_code integer NOT NULL,
    city character varying(100) NOT NULL,
    street character varying(100) NOT NULL,
    home integer NOT NULL,
    room integer
);


ALTER TABLE public.address OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16506)
-- Name: address_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.address_address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.address_address_id_seq OWNER TO postgres;

--
-- TOC entry 5203 (class 0 OID 0)
-- Dependencies: 231
-- Name: address_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.address_address_id_seq OWNED BY public.address.address_id;


--
-- TOC entry 265 (class 1259 OID 17339)
-- Name: admin_staff_admin_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admin_staff_admin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER SEQUENCE public.admin_staff_admin_id_seq OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16459)
-- Name: attend_student; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attend_student (
    attend_id integer NOT NULL,
    name character varying(100) NOT NULL,
    surname character varying(100) NOT NULL,
    telephone character varying(10) NOT NULL,
    e_mail character varying(150),
    instrument_id integer NOT NULL,
    level_id integer NOT NULL
);


ALTER TABLE public.attend_student OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16458)
-- Name: app_attend_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_attend_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_attend_app_id_seq OWNER TO postgres;

--
-- TOC entry 5204 (class 0 OID 0)
-- Dependencies: 227
-- Name: app_attend_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_attend_app_id_seq OWNED BY public.attend_student.attend_id;


--
-- TOC entry 254 (class 1259 OID 16936)
-- Name: booking_individual_indiv_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.booking_individual_indiv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER SEQUENCE public.booking_individual_indiv_id_seq OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 16938)
-- Name: booking_individual; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.booking_individual (
    indiv_id integer DEFAULT nextval('public.booking_individual_indiv_id_seq'::regclass) NOT NULL,
    student_numb integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    numb_lessons integer NOT NULL,
    instrument_id integer NOT NULL,
    lessons_id integer NOT NULL,
    level_id integer NOT NULL,
    instructor_id integer NOT NULL
);


ALTER TABLE public.booking_individual OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16410)
-- Name: brands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.brands (
    brand_id integer NOT NULL,
    brand character varying(300) NOT NULL
);


ALTER TABLE public.brands OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16409)
-- Name: brands_brand_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.brands_brand_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.brands_brand_id_seq OWNER TO postgres;

--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 223
-- Name: brands_brand_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.brands_brand_id_seq OWNED BY public.brands.brand_id;


--
-- TOC entry 266 (class 1259 OID 17341)
-- Name: complet_lessons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.complet_lessons (
    admin_id integer DEFAULT nextval('public.admin_staff_admin_id_seq'::regclass) NOT NULL,
    lessons_id integer NOT NULL,
    levels_id integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    slot_id integer NOT NULL,
    student_id integer NOT NULL,
    instructor_id integer NOT NULL,
    note character varying(500) NOT NULL,
    price_id integer NOT NULL
);


ALTER TABLE public.complet_lessons OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 17563)
-- Name: conditions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conditions (
    condition_id integer NOT NULL,
    instrument_id integer NOT NULL,
    data_start date NOT NULL,
    data_end date NOT NULL,
    storage_places_id integer NOT NULL,
    "unique serial number" uuid NOT NULL,
    cost numeric NOT NULL
);


ALTER TABLE public.conditions OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 17562)
-- Name: conditions_condition_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conditions_condition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.conditions_condition_id_seq OWNER TO postgres;

--
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 275
-- Name: conditions_condition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conditions_condition_id_seq OWNED BY public.conditions.condition_id;


--
-- TOC entry 250 (class 1259 OID 16865)
-- Name: contact_detail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contact_detail (
    contact_id integer NOT NULL,
    telephone character varying(20) NOT NULL,
    e_mail character varying(100)
);


ALTER TABLE public.contact_detail OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 16864)
-- Name: contactsdetail_contactdet_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contactsdetail_contactdet_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contactsdetail_contactdet_id_seq OWNER TO postgres;

--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 249
-- Name: contactsdetail_contactdet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contactsdetail_contactdet_id_seq OWNED BY public.contact_detail.contact_id;


--
-- TOC entry 256 (class 1259 OID 16969)
-- Name: ensemble_ensem_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ensemble_ensem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER SEQUENCE public.ensemble_ensem_id_seq OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 17019)
-- Name: ensemble; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ensemble (
    ensem_id integer DEFAULT nextval('public.ensemble_ensem_id_seq'::regclass) NOT NULL,
    students_numb integer NOT NULL,
    ensembles_id integer NOT NULL,
    data_ensem date NOT NULL,
    time_slot_id integer NOT NULL,
    min_students integer NOT NULL,
    max_students integer NOT NULL,
    lessons_id integer NOT NULL,
    instructor_id integer NOT NULL
);


ALTER TABLE public.ensemble OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16403)
-- Name: ensemble_genre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ensemble_genre (
    ensembles_id integer NOT NULL,
    gentre_ensembles character varying(100) NOT NULL
);


ALTER TABLE public.ensemble_genre OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16402)
-- Name: ensembles_ensembles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ensembles_ensembles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER SEQUENCE public.ensembles_ensembles_id_seq OWNER TO postgres;

--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 221
-- Name: ensembles_ensembles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ensembles_ensembles_id_seq OWNED BY public.ensemble_genre.ensembles_id;


--
-- TOC entry 258 (class 1259 OID 17060)
-- Name: group_lessons_grouplesson_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.group_lessons_grouplesson_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER SEQUENCE public.group_lessons_grouplesson_id_seq OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 17062)
-- Name: group_lessons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_lessons (
    grouplesson_id integer DEFAULT nextval('public.group_lessons_grouplesson_id_seq'::regclass) NOT NULL,
    students_numb integer NOT NULL,
    data_group date NOT NULL,
    time_slot_id integer NOT NULL,
    min_places_id integer NOT NULL,
    max_places_id integer NOT NULL,
    instrument_id integer NOT NULL,
    lessons_id integer NOT NULL,
    instructor_id integer NOT NULL
);


ALTER TABLE public.group_lessons OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 26499)
-- Name: historical_lessons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historical_lessons (
    lesson_id integer NOT NULL,
    lesson_date date NOT NULL,
    lesson_type character varying(20) NOT NULL,
    genre character varying(50),
    instrument character varying(50),
    lesson_price numeric(10,2) NOT NULL,
    student_firstname character varying(100) NOT NULL,
    student_surname character varying(100) NOT NULL,
    student_email character varying(100) NOT NULL
);


ALTER TABLE public.historical_lessons OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 26498)
-- Name: historical_lessons_lesson_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.historical_lessons_lesson_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historical_lessons_lesson_id_seq OWNER TO postgres;

--
-- TOC entry 5209 (class 0 OID 0)
-- Dependencies: 280
-- Name: historical_lessons_lesson_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.historical_lessons_lesson_id_seq OWNED BY public.historical_lessons.lesson_id;


--
-- TOC entry 252 (class 1259 OID 16913)
-- Name: hold_instrument_hold_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hold_instrument_hold_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER SEQUENCE public.hold_instrument_hold_id_seq OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 16915)
-- Name: hold_instrument; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hold_instrument (
    hold_id integer DEFAULT nextval('public.hold_instrument_hold_id_seq'::regclass) NOT NULL,
    inst_stud_id integer NOT NULL,
    instrument_id integer NOT NULL,
    level_id integer NOT NULL
);


ALTER TABLE public.hold_instrument OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 16595)
-- Name: instructor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.instructor (
    instruktor_numb integer NOT NULL,
    name_inst character varying(150) NOT NULL,
    surname_inst character varying(150) NOT NULL,
    address_id integer NOT NULL,
    contact_id integer NOT NULL
);


ALTER TABLE public.instructor OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16594)
-- Name: instructor_instruktor_numb_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.instructor_instruktor_numb_seq
    AS integer
    START WITH 1000
    INCREMENT BY 1
    MINVALUE 1000
    MAXVALUE 4999
    CACHE 1;


ALTER SEQUENCE public.instructor_instruktor_numb_seq OWNER TO postgres;

--
-- TOC entry 5210 (class 0 OID 0)
-- Dependencies: 239
-- Name: instructor_instruktor_numb_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.instructor_instruktor_numb_seq OWNED BY public.instructor.instruktor_numb;


--
-- TOC entry 262 (class 1259 OID 17175)
-- Name: instructor_payment_ins_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.instructor_payment_ins_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER SEQUENCE public.instructor_payment_ins_payment_id_seq OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 17468)
-- Name: instructor_payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.instructor_payment (
    ins_payment_id integer DEFAULT nextval('public.instructor_payment_ins_payment_id_seq'::regclass) NOT NULL,
    instruktor_numb integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    lessons_id integer NOT NULL,
    levels_id integer NOT NULL,
    price_id integer NOT NULL,
    total_number_classes integer NOT NULL,
    total_received numeric NOT NULL
);


ALTER TABLE public.instructor_payment OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 16626)
-- Name: invitations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invitations (
    invitation_id integer NOT NULL,
    student_numb integer NOT NULL,
    instrument_id integer NOT NULL
);


ALTER TABLE public.invitations OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16625)
-- Name: invitations_invitation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invitations_invitation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invitations_invitation_id_seq OWNER TO postgres;

--
-- TOC entry 5211 (class 0 OID 0)
-- Dependencies: 243
-- Name: invitations_invitation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invitations_invitation_id_seq OWNED BY public.invitations.invitation_id;


--
-- TOC entry 220 (class 1259 OID 16396)
-- Name: lessons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lessons (
    lessons_id integer NOT NULL,
    type_lessons character varying(50) NOT NULL
);


ALTER TABLE public.lessons OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16395)
-- Name: lessons_lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lessons_lessons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lessons_lessons_id_seq OWNER TO postgres;

--
-- TOC entry 5212 (class 0 OID 0)
-- Dependencies: 219
-- Name: lessons_lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lessons_lessons_id_seq OWNED BY public.lessons.lessons_id;


--
-- TOC entry 282 (class 1259 OID 26513)
-- Name: lessons_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.lessons_summary AS
 SELECT to_char((period_start)::timestamp with time zone, 'Mon'::text) AS month,
    sum(count(*) FILTER (WHERE (lessons_id = 1))) OVER () AS individual,
    sum(count(*) FILTER (WHERE (lessons_id = 2))) OVER () AS group_lessons,
    sum(count(*) FILTER (WHERE (lessons_id = 3))) OVER () AS ensemble,
    sum(count(*)) OVER () AS total
   FROM public.complet_lessons
  WHERE (EXTRACT(year FROM period_start) = (2024)::numeric)
  GROUP BY (to_char((period_start)::timestamp with time zone, 'Mon'::text)), (EXTRACT(month FROM period_start))
  ORDER BY (EXTRACT(month FROM period_start));


ALTER VIEW public.lessons_summary OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16389)
-- Name: levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.levels (
    level_id integer NOT NULL,
    level_stud character varying(50) NOT NULL
);


ALTER TABLE public.levels OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16388)
-- Name: levels_level_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.levels_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9223372036
    CACHE 1;


ALTER SEQUENCE public.levels_level_id_seq OWNER TO postgres;

--
-- TOC entry 5213 (class 0 OID 0)
-- Dependencies: 217
-- Name: levels_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.levels_level_id_seq OWNED BY public.levels.level_id;


--
-- TOC entry 285 (class 1259 OID 26527)
-- Name: list_ensembles; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.list_ensembles AS
SELECT
    NULL::text AS day_of_week,
    NULL::character varying(100) AS genre,
    NULL::text AS available_seats;


ALTER VIEW public.list_ensembles OWNER TO postgres;

--
-- TOC entry 284 (class 1259 OID 26522)
-- Name: list_instructors; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.list_instructors AS
 SELECT i.instruktor_numb,
    i.name_inst,
    i.surname_inst,
    count(a.lessons_id) AS lesson_count
   FROM (public.instructor i
     LEFT JOIN public.complet_lessons a ON (((i.instruktor_numb = a.instructor_id) AND (EXTRACT(month FROM a.period_start) = EXTRACT(month FROM CURRENT_DATE)) AND (EXTRACT(year FROM a.period_start) = EXTRACT(year FROM CURRENT_DATE)))))
  GROUP BY i.instruktor_numb, i.name_inst, i.surname_inst
 HAVING (count(a.lessons_id) > 3)
  ORDER BY (count(a.lessons_id)) DESC;


ALTER VIEW public.list_instructors OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 16647)
-- Name: numb_places; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.numb_places (
    place_id integer NOT NULL,
    numb_places integer NOT NULL
);


ALTER TABLE public.numb_places OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 16646)
-- Name: maxsimum_places_max_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.maxsimum_places_max_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.maxsimum_places_max_id_seq OWNER TO postgres;

--
-- TOC entry 5214 (class 0 OID 0)
-- Dependencies: 245
-- Name: maxsimum_places_max_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.maxsimum_places_max_id_seq OWNED BY public.numb_places.place_id;


--
-- TOC entry 230 (class 1259 OID 16466)
-- Name: mus_instruments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mus_instruments (
    instrument_id integer NOT NULL,
    instruments character varying(100) NOT NULL,
    quantities integer NOT NULL,
    brand_id integer NOT NULL,
    type_id integer NOT NULL
);


ALTER TABLE public.mus_instruments OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16465)
-- Name: mus_instruments_instrument_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mus_instruments_instrument_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mus_instruments_instrument_id_seq OWNER TO postgres;

--
-- TOC entry 5215 (class 0 OID 0)
-- Dependencies: 229
-- Name: mus_instruments_instrument_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mus_instruments_instrument_id_seq OWNED BY public.mus_instruments.instrument_id;


--
-- TOC entry 237 (class 1259 OID 16579)
-- Name: persons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persons (
    person_id integer NOT NULL,
    name_per character varying(150) NOT NULL,
    surname_per character varying(150) NOT NULL,
    student_numb integer NOT NULL,
    contact_id integer NOT NULL,
    address_id integer NOT NULL,
    relativ_id integer NOT NULL
);


ALTER TABLE public.persons OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16578)
-- Name: person_contact_person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_contact_person_id_seq
    AS integer
    START WITH 5000
    INCREMENT BY 1
    MINVALUE 5000
    MAXVALUE 9000
    CACHE 1;


ALTER SEQUENCE public.person_contact_person_id_seq OWNER TO postgres;

--
-- TOC entry 5216 (class 0 OID 0)
-- Dependencies: 236
-- Name: person_contact_person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.person_contact_person_id_seq OWNED BY public.persons.person_id;


--
-- TOC entry 278 (class 1259 OID 17624)
-- Name: personin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personin (
    person_id integer NOT NULL,
    name character varying(50) NOT NULL,
    surname character varying(50) NOT NULL,
    address_id integer NOT NULL,
    contact_id integer NOT NULL
);


ALTER TABLE public.personin OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 17623)
-- Name: personin_person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personin_person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personin_person_id_seq OWNER TO postgres;

--
-- TOC entry 5217 (class 0 OID 0)
-- Dependencies: 277
-- Name: personin_person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personin_person_id_seq OWNED BY public.personin.person_id;


--
-- TOC entry 251 (class 1259 OID 16898)
-- Name: price_price_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.price_price_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER SEQUENCE public.price_price_id_seq OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 17331)
-- Name: price; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price (
    price_id integer DEFAULT nextval('public.price_price_id_seq'::regclass) NOT NULL,
    price_start date NOT NULL,
    price_finish date NOT NULL,
    lessons_id integer NOT NULL,
    levels_id integer NOT NULL,
    type_service character varying NOT NULL,
    price_service numeric NOT NULL,
    unit_measur character varying NOT NULL
);


ALTER TABLE public.price OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 16819)
-- Name: relatives; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.relatives (
    relativ_id integer NOT NULL,
    relationship character varying(50) NOT NULL
);


ALTER TABLE public.relatives OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 16818)
-- Name: relatives_relativ_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.relatives_relativ_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.relatives_relativ_id_seq OWNER TO postgres;

--
-- TOC entry 5218 (class 0 OID 0)
-- Dependencies: 247
-- Name: relatives_relativ_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.relatives_relativ_id_seq OWNED BY public.relatives.relativ_id;


--
-- TOC entry 260 (class 1259 OID 17150)
-- Name: renting_instruments_renting_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.renting_instruments_renting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER SEQUENCE public.renting_instruments_renting_id_seq OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 17152)
-- Name: renting_instruments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.renting_instruments (
    renting_id integer DEFAULT nextval('public.renting_instruments_renting_id_seq'::regclass) NOT NULL,
    student_numb integer NOT NULL,
    instrum_id integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    quantity_instruments integer NOT NULL,
    price_id integer NOT NULL
);


ALTER TABLE public.renting_instruments OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 16588)
-- Name: sibling; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sibling (
    student_numb integer NOT NULL,
    person_sibling integer NOT NULL
);


ALTER TABLE public.sibling OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 25927)
-- Name: sibling_count; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sibling_count (
    count bigint
);


ALTER TABLE public.sibling_count OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16542)
-- Name: student; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student (
    student_numb integer NOT NULL,
    firstname character varying NOT NULL,
    surname character varying NOT NULL,
    address_id integer NOT NULL,
    details_id integer NOT NULL,
    person_id integer NOT NULL
);


ALTER TABLE public.student OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 26518)
-- Name: siblings_students; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.siblings_students AS
 SELECT no_of_siblings,
    count(*) AS number_of_students
   FROM ( SELECT s1.student_numb,
            count(s2.person_sibling) AS no_of_siblings
           FROM (public.student s1
             LEFT JOIN public.sibling s2 ON (((s1.student_numb = s2.student_numb) OR (s2.person_sibling = s1.student_numb))))
          GROUP BY s1.student_numb) sibling_counts
  GROUP BY no_of_siblings
  ORDER BY no_of_siblings;


ALTER VIEW public.siblings_students OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 17554)
-- Name: storage_places; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.storage_places (
    place_id integer NOT NULL,
    storage_places character varying NOT NULL
);


ALTER TABLE public.storage_places OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 17553)
-- Name: storage_places_place_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.storage_places_place_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.storage_places_place_id_seq OWNER TO postgres;

--
-- TOC entry 5219 (class 0 OID 0)
-- Dependencies: 273
-- Name: storage_places_place_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.storage_places_place_id_seq OWNED BY public.storage_places.place_id;


--
-- TOC entry 263 (class 1259 OID 17223)
-- Name: student_payment_st_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_payment_st_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER SEQUENCE public.student_payment_st_payment_id_seq OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 17434)
-- Name: student_payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_payment (
    st_payment_id integer DEFAULT nextval('public.student_payment_st_payment_id_seq'::regclass) NOT NULL,
    student_numb integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    lessons_id integer NOT NULL,
    levels_id integer NOT NULL,
    price_id integer NOT NULL,
    sibling_price_id integer,
    total_numb_classes integer NOT NULL,
    total_paid numeric NOT NULL
);


ALTER TABLE public.student_payment OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16539)
-- Name: student_student_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_student_id_seq
    START WITH 100
    INCREMENT BY 1
    MINVALUE 100
    MAXVALUE 999
    CACHE 1;


ALTER SEQUENCE public.student_student_id_seq OWNER TO postgres;

--
-- TOC entry 5220 (class 0 OID 0)
-- Dependencies: 233
-- Name: student_student_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_student_id_seq OWNED BY public.student.student_numb;


--
-- TOC entry 234 (class 1259 OID 16541)
-- Name: student_student_numb_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_student_numb_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_student_numb_seq OWNER TO postgres;

--
-- TOC entry 5221 (class 0 OID 0)
-- Dependencies: 234
-- Name: student_student_numb_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_student_numb_seq OWNED BY public.student.student_numb;


--
-- TOC entry 242 (class 1259 OID 16609)
-- Name: time_slot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.time_slot (
    time_slot_id integer NOT NULL,
    start_time integer NOT NULL,
    end_time integer NOT NULL
);


ALTER TABLE public.time_slot OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16608)
-- Name: time_slot_slot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.time_slot_slot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.time_slot_slot_id_seq OWNER TO postgres;

--
-- TOC entry 5222 (class 0 OID 0)
-- Dependencies: 241
-- Name: time_slot_slot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.time_slot_slot_id_seq OWNED BY public.time_slot.time_slot_id;


--
-- TOC entry 226 (class 1259 OID 16417)
-- Name: types_instruments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.types_instruments (
    type_id integer NOT NULL,
    types_instrum character varying(150) NOT NULL
);


ALTER TABLE public.types_instruments OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16416)
-- Name: types_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.types_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.types_type_id_seq OWNER TO postgres;

--
-- TOC entry 5223 (class 0 OID 0)
-- Dependencies: 225
-- Name: types_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.types_type_id_seq OWNED BY public.types_instruments.type_id;


--
-- TOC entry 4829 (class 2604 OID 25167)
-- Name: address address_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address ALTER COLUMN address_id SET DEFAULT nextval('public.address_address_id_seq'::regclass);


--
-- TOC entry 4827 (class 2604 OID 25168)
-- Name: attend_student attend_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student ALTER COLUMN attend_id SET DEFAULT nextval('public.app_attend_app_id_seq'::regclass);


--
-- TOC entry 4825 (class 2604 OID 25169)
-- Name: brands brand_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands ALTER COLUMN brand_id SET DEFAULT nextval('public.brands_brand_id_seq'::regclass);


--
-- TOC entry 4850 (class 2604 OID 25170)
-- Name: conditions condition_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions ALTER COLUMN condition_id SET DEFAULT nextval('public.conditions_condition_id_seq'::regclass);


--
-- TOC entry 4837 (class 2604 OID 25171)
-- Name: contact_detail contact_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_detail ALTER COLUMN contact_id SET DEFAULT nextval('public.contactsdetail_contactdet_id_seq'::regclass);


--
-- TOC entry 4824 (class 2604 OID 25172)
-- Name: ensemble_genre ensembles_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble_genre ALTER COLUMN ensembles_id SET DEFAULT nextval('public.ensembles_ensembles_id_seq'::regclass);


--
-- TOC entry 4852 (class 2604 OID 26502)
-- Name: historical_lessons lesson_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historical_lessons ALTER COLUMN lesson_id SET DEFAULT nextval('public.historical_lessons_lesson_id_seq'::regclass);


--
-- TOC entry 4832 (class 2604 OID 25173)
-- Name: instructor instruktor_numb; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor ALTER COLUMN instruktor_numb SET DEFAULT nextval('public.instructor_instruktor_numb_seq'::regclass);


--
-- TOC entry 4834 (class 2604 OID 25174)
-- Name: invitations invitation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitations ALTER COLUMN invitation_id SET DEFAULT nextval('public.invitations_invitation_id_seq'::regclass);


--
-- TOC entry 4823 (class 2604 OID 25175)
-- Name: lessons lessons_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons ALTER COLUMN lessons_id SET DEFAULT nextval('public.lessons_lessons_id_seq'::regclass);


--
-- TOC entry 4822 (class 2604 OID 25176)
-- Name: levels level_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels ALTER COLUMN level_id SET DEFAULT nextval('public.levels_level_id_seq'::regclass);


--
-- TOC entry 4828 (class 2604 OID 25177)
-- Name: mus_instruments instrument_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments ALTER COLUMN instrument_id SET DEFAULT nextval('public.mus_instruments_instrument_id_seq'::regclass);


--
-- TOC entry 4835 (class 2604 OID 25178)
-- Name: numb_places place_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.numb_places ALTER COLUMN place_id SET DEFAULT nextval('public.maxsimum_places_max_id_seq'::regclass);


--
-- TOC entry 4851 (class 2604 OID 25179)
-- Name: personin person_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin ALTER COLUMN person_id SET DEFAULT nextval('public.personin_person_id_seq'::regclass);


--
-- TOC entry 4831 (class 2604 OID 25180)
-- Name: persons person_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons ALTER COLUMN person_id SET DEFAULT nextval('public.person_contact_person_id_seq'::regclass);


--
-- TOC entry 4836 (class 2604 OID 25181)
-- Name: relatives relativ_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relatives ALTER COLUMN relativ_id SET DEFAULT nextval('public.relatives_relativ_id_seq'::regclass);


--
-- TOC entry 4849 (class 2604 OID 25182)
-- Name: storage_places place_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storage_places ALTER COLUMN place_id SET DEFAULT nextval('public.storage_places_place_id_seq'::regclass);


--
-- TOC entry 4830 (class 2604 OID 25183)
-- Name: student student_numb; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student ALTER COLUMN student_numb SET DEFAULT nextval('public.student_student_id_seq'::regclass);


--
-- TOC entry 4833 (class 2604 OID 25184)
-- Name: time_slot time_slot_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_slot ALTER COLUMN time_slot_id SET DEFAULT nextval('public.time_slot_slot_id_seq'::regclass);


--
-- TOC entry 4826 (class 2604 OID 25185)
-- Name: types_instruments type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_instruments ALTER COLUMN type_id SET DEFAULT nextval('public.types_type_id_seq'::regclass);


--
-- TOC entry 5186 (class 0 OID 17512)
-- Dependencies: 270
-- Data for Name: actual_seats_ensemble; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.actual_seats_ensemble VALUES (1, 1, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (2, 2, 8) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (3, 3, 4) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (4, 4, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (5, 5, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (6, 6, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (7, 7, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (8, 8, 7) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (9, 9, 6) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (10, 10, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (11, 11, 8) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (12, 12, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (13, 13, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (14, 14, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (15, 15, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (16, 16, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (17, 17, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (18, 18, 7) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (19, 19, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_ensemble VALUES (20, 20, 5) ON CONFLICT DO NOTHING;


--
-- TOC entry 5187 (class 0 OID 17540)
-- Dependencies: 271
-- Data for Name: actual_seats_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.actual_seats_group VALUES (1, 1, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (2, 2, 8) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (3, 3, 4) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (4, 4, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (5, 5, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (6, 6, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (7, 7, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (8, 8, 7) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (9, 9, 6) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (10, 10, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (11, 11, 8) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (12, 12, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (13, 13, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (14, 14, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (15, 15, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (16, 16, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (17, 17, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (18, 18, 7) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (19, 19, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.actual_seats_group VALUES (20, 20, 5) ON CONFLICT DO NOTHING;


--
-- TOC entry 5148 (class 0 OID 16507)
-- Dependencies: 232
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.address VALUES (1, 8351, 'Vladimir', 'P.O. Box 385, 892 Enim. Ave', 55, 101) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (2, 5241447, 'Portland', '1264 Suspendisse Street', 30, 8) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (3, 3369, 'Balfour', 'Ap #981-2375 Vitae Rd.', 36, 183) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (4, 7671, 'Tam dảo', 'Ap #875-6855 At Ave', 70, 156) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (5, 221257621, 'Kettering', '172-6634 Risus Avenue', 52, 47) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (6, 464480, 'Dieppe', 'P.O. Box 961, 7719 Vulputate Rd.', 65, 78) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (7, 18291, 'Montes Claros', '5071 Amet Rd.', 91, 60) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (8, 74026, 'Chuncheon', 'Ap #932-6217 Nonummy Ave', 49, 19) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (9, 819151, 'Malakand', '721 Quam. St.', 55, 4) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (10, 6196, 'Lozova', 'Tellus. Ave', 87, 195) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (11, 12354, 'Stockhom', 'Nibh. Av', 1, 46) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (12, 99856, 'Stockhom', 'Egestas. St.', 55, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (13, 3457, 'Stockhom', 'Penatibus Rd. St.', 34, 15) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (14, 6347, 'Stockhom', 'Metus Street', 208, 85) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (15, 887533, 'Stockhom', '9306 Dis Road', 99, 32) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (16, 645673, 'Stockhom', 'Vulputate, Ave', 345, 976) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (17, 453, 'Stockhom', 'Viverra. St.', 7, 6) ON CONFLICT DO NOTHING;
INSERT INTO public.address VALUES (18, 238609, 'Stockhom', 'Tellus Road', 9, 111) ON CONFLICT DO NOTHING;


--
-- TOC entry 5144 (class 0 OID 16459)
-- Dependencies: 228
-- Data for Name: attend_student; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5171 (class 0 OID 16938)
-- Dependencies: 255
-- Data for Name: booking_individual; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.booking_individual VALUES (1, 100, '2024-09-01', '2004-09-30', 10, 2, 1, 1, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (2, 101, '2024-09-01', '2004-09-30', 9, 1, 1, 1, 1003) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (3, 102, '2024-09-01', '2004-09-30', 11, 3, 1, 1, 1002) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (4, 103, '2024-09-10', '2004-09-10', 3, 4, 1, 1, 1004) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (5, 103, '2024-09-01', '2004-09-30', 5, 4, 1, 1, 1004) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (6, 104, '2024-09-01', '2004-09-30', 10, 5, 1, 1, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (7, 105, '2024-09-01', '2004-09-30', 4, 6, 1, 2, 1002) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (8, 106, '2024-09-01', '2004-09-30', 8, 7, 1, 1, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (9, 107, '2024-09-01', '2004-09-30', 9, 8, 1, 2, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (10, 108, '2024-09-01', '2004-09-30', 9, 7, 1, 1, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (11, 109, '2024-09-01', '2004-09-30', 4, 1, 1, 2, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (12, 109, '2024-09-01', '2004-09-30', 5, 2, 1, 2, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (13, 100, '2024-10-01', '2004-10-31', 6, 2, 1, 1, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (14, 101, '2024-10-01', '2004-10-31', 8, 1, 1, 1, 1003) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (15, 102, '2024-10-01', '2004-10-31', 9, 3, 1, 1, 1002) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (16, 103, '2024-10-10', '2004-10-31', 3, 4, 1, 1, 1004) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (17, 104, '2024-10-01', '2004-10-31', 5, 5, 1, 1, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (18, 105, '2024-10-01', '2004-10-31', 10, 6, 1, 2, 1002) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (19, 106, '2024-10-01', '2004-10-31', 13, 7, 1, 1, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (20, 107, '2024-10-01', '2004-10-31', 8, 8, 1, 2, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (21, 108, '2024-10-01', '2004-10-31', 9, 7, 1, 1, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (22, 109, '2024-10-01', '2004-10-15', 7, 1, 1, 2, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.booking_individual VALUES (23, 109, '2024-10-16', '2004-10-31', 5, 2, 1, 2, 1001) ON CONFLICT DO NOTHING;


--
-- TOC entry 5140 (class 0 OID 16410)
-- Dependencies: 224
-- Data for Name: brands; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.brands VALUES (1, 'Gibson') ON CONFLICT DO NOTHING;
INSERT INTO public.brands VALUES (2, 'Harman Professional') ON CONFLICT DO NOTHING;
INSERT INTO public.brands VALUES (3, 'Shure') ON CONFLICT DO NOTHING;
INSERT INTO public.brands VALUES (4, 'Yamaha') ON CONFLICT DO NOTHING;
INSERT INTO public.brands VALUES (5, 'Fender Musical Instruments') ON CONFLICT DO NOTHING;
INSERT INTO public.brands VALUES (6, 'Steinway Musical Instruments') ON CONFLICT DO NOTHING;
INSERT INTO public.brands VALUES (7, 'Sennheiser') ON CONFLICT DO NOTHING;
INSERT INTO public.brands VALUES (8, 'Roland') ON CONFLICT DO NOTHING;


--
-- TOC entry 5182 (class 0 OID 17341)
-- Dependencies: 266
-- Data for Name: complet_lessons; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.complet_lessons VALUES (109, 1, 1, '2024-09-25', '2024-09-26', 3, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (110, 1, 1, '2024-09-01', '2024-09-30', 1, 104, 1000, 'dfgh', 3) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (9, 1, 1, '2024-09-01', '2024-09-01', 3, 100, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (1, 3, 0, '2024-09-01', '2024-09-01', 1, 100, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (35, 1, 1, '2024-09-22', '2024-09-22', 3, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (36, 1, 1, '2024-09-25', '2024-09-25', 3, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (37, 1, 1, '2024-09-27', '2024-09-27', 3, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (38, 1, 1, '2024-09-27', '2024-09-27', 3, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (39, 1, 1, '2024-09-10', '2024-09-10', 4, 103, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (40, 1, 1, '2024-09-10', '2024-09-10', 5, 103, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (41, 1, 1, '2024-09-10', '2024-09-10', 6, 103, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (42, 1, 1, '2024-09-15', '2024-09-15', 4, 103, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (43, 1, 1, '2024-09-18', '2024-09-18', 4, 103, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (44, 1, 1, '2024-09-20', '2024-09-20', 4, 103, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (45, 1, 1, '2024-09-22', '2024-09-22', 4, 103, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (46, 1, 1, '2024-09-25', '2024-09-25', 4, 103, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (47, 1, 1, '2024-09-01', '2024-09-01', 7, 104, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (48, 1, 1, '2024-09-04', '2024-09-04', 5, 104, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (49, 1, 1, '2024-09-10', '2024-09-10', 5, 104, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (50, 1, 1, '2024-09-15', '2024-09-15', 5, 104, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (51, 1, 1, '2024-09-18', '2024-09-18', 5, 104, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (52, 1, 1, '2024-09-20', '2024-09-20', 5, 104, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (53, 1, 1, '2024-09-22', '2024-09-22', 5, 104, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (54, 1, 1, '2024-09-25', '2024-09-25', 5, 104, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (55, 1, 1, '2024-09-27', '2024-09-27', 5, 104, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (56, 1, 1, '2024-09-29', '2024-09-29', 5, 104, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (57, 1, 2, '2024-09-01', '2024-09-01', 8, 105, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (58, 1, 2, '2024-09-04', '2024-09-04', 6, 105, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (59, 1, 2, '2024-09-10', '2024-09-10', 6, 105, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (60, 1, 2, '2024-09-15', '2024-09-15', 6, 105, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (61, 1, 1, '2024-09-01', '2024-09-01', 9, 106, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (62, 1, 1, '2024-09-04', '2024-09-04', 7, 106, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (63, 1, 1, '2024-09-10', '2024-09-10', 7, 106, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (64, 1, 1, '2024-09-15', '2024-09-15', 7, 106, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (65, 1, 1, '2024-09-18', '2024-09-18', 7, 106, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (66, 1, 1, '2024-09-20', '2024-09-20', 7, 106, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (67, 1, 1, '2024-09-22', '2024-09-22', 7, 106, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (68, 1, 1, '2024-09-25', '2024-09-25', 7, 106, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (69, 1, 2, '2024-09-01', '2024-09-01', 10, 107, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (70, 1, 2, '2024-09-04', '2024-09-04', 8, 107, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (71, 1, 2, '2024-09-10', '2024-09-10', 8, 107, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (72, 1, 2, '2024-09-15', '2024-09-15', 8, 107, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (73, 1, 2, '2024-09-18', '2024-09-18', 8, 107, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (74, 1, 2, '2024-09-20', '2024-09-20', 8, 107, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (75, 1, 2, '2024-09-22', '2024-09-22', 8, 107, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (76, 1, 2, '2024-09-25', '2024-09-25', 8, 107, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (77, 1, 2, '2024-09-27', '2024-09-27', 8, 107, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (78, 1, 1, '2024-09-01', '2024-09-01', 11, 108, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (79, 1, 1, '2024-09-04', '2024-09-04', 9, 108, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (80, 1, 1, '2024-09-10', '2024-09-10', 9, 108, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (81, 1, 1, '2024-09-15', '2024-09-15', 9, 108, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (82, 1, 1, '2024-09-18', '2024-09-18', 9, 108, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (83, 1, 1, '2024-09-20', '2024-09-20', 9, 108, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (84, 1, 1, '2024-09-22', '2024-09-22', 9, 108, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (85, 1, 1, '2024-09-25', '2024-09-25', 9, 108, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (86, 1, 1, '2024-09-27', '2024-09-27', 9, 108, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (87, 1, 2, '2024-09-02', '2024-09-02', 1, 109, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (2, 3, 0, '2024-09-01', '2024-09-01', 1, 101, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (3, 3, 0, '2024-09-01', '2024-09-01', 1, 102, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (4, 3, 0, '2024-09-01', '2024-09-01', 1, 103, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (5, 2, 0, '2024-09-01', '2024-09-01', 2, 100, 1005, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (6, 2, 0, '2024-09-01', '2024-09-01', 2, 101, 1005, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (7, 2, 0, '2024-09-01', '2024-09-01', 2, 102, 1005, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (8, 2, 0, '2024-09-01', '2024-09-01', 2, 103, 1005, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (10, 1, 1, '2024-09-04', '2024-09-04', 1, 100, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (11, 1, 1, '2024-09-10', '2024-09-10', 1, 100, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (12, 1, 1, '2024-09-15', '2024-09-15', 1, 100, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (13, 1, 1, '2024-09-18', '2024-09-18', 1, 100, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (14, 1, 1, '2024-09-20', '2024-09-20', 1, 100, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (15, 1, 1, '2024-09-22', '2024-09-22', 1, 100, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (16, 1, 1, '2024-09-25', '2024-09-25', 1, 100, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (17, 1, 1, '2024-09-27', '2024-09-27', 1, 100, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (18, 1, 1, '2024-09-29', '2024-09-29', 1, 100, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (19, 1, 1, '2024-09-01', '2024-09-01', 4, 101, 1003, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (20, 1, 1, '2024-09-04', '2024-09-04', 2, 101, 1003, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (21, 1, 1, '2024-09-10', '2024-09-10', 2, 101, 1003, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (22, 1, 1, '2024-09-15', '2024-09-15', 2, 101, 1003, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (23, 1, 1, '2024-09-18', '2024-09-18', 2, 101, 1003, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (24, 1, 1, '2024-09-20', '2024-09-20', 2, 101, 1003, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (25, 1, 1, '2024-09-22', '2024-09-22', 2, 101, 1003, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (26, 1, 1, '2024-09-25', '2024-09-25', 2, 101, 1003, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (27, 1, 1, '2024-09-27', '2024-09-27', 2, 101, 1003, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (28, 1, 1, '2024-09-01', '2024-09-01', 5, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (29, 1, 1, '2024-09-01', '2024-09-01', 6, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (30, 1, 1, '2024-09-04', '2024-09-04', 3, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (31, 1, 1, '2024-09-10', '2024-09-10', 3, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (32, 1, 1, '2024-09-15', '2024-09-15', 3, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (33, 1, 1, '2024-09-18', '2024-09-18', 3, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (34, 1, 1, '2024-09-20', '2024-09-20', 3, 102, 1002, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (88, 1, 2, '2024-09-04', '2024-09-04', 9, 109, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (89, 1, 2, '2024-09-10', '2024-09-10', 9, 109, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (90, 1, 2, '2024-09-15', '2024-09-15', 9, 109, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (91, 1, 2, '2024-09-18', '2024-09-18', 9, 109, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (92, 1, 2, '2024-09-20', '2024-09-20', 9, 109, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (93, 1, 2, '2024-09-22', '2024-09-22', 9, 109, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (94, 1, 2, '2024-09-25', '2024-09-25', 9, 109, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (95, 1, 2, '2024-09-27', '2024-09-27', 9, 109, 1000, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (96, 3, 0, '2024-09-08', '2024-09-08', 2, 104, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (97, 3, 0, '2024-09-08', '2024-09-08', 2, 105, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (98, 3, 0, '2024-09-08', '2024-09-08', 2, 106, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (99, 3, 0, '2024-09-16', '2024-09-16', 3, 107, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (100, 3, 0, '2024-09-16', '2024-09-16', 3, 108, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (101, 3, 0, '2024-09-16', '2024-09-16', 3, 109, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (102, 2, 0, '2024-09-08', '2024-09-08', 3, 104, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (103, 2, 0, '2024-09-08', '2024-09-08', 3, 105, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (104, 2, 0, '2024-09-08', '2024-09-08', 3, 106, 1001, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (105, 2, 0, '2024-09-16', '2024-09-16', 4, 107, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (106, 2, 0, '2024-09-16', '2024-09-16', 4, 108, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (107, 2, 0, '2024-09-16', '2024-09-16', 4, 109, 1004, 'was carried out', 9) ON CONFLICT DO NOTHING;
INSERT INTO public.complet_lessons VALUES (108, 3, 1, '2024-09-01', '2024-09-02', 1, 100, 1000, 'dfgh', 9) ON CONFLICT DO NOTHING;


--
-- TOC entry 5192 (class 0 OID 17563)
-- Dependencies: 276
-- Data for Name: conditions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.conditions VALUES (1, 1, '2024-09-01', '2025-06-30', 1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.conditions VALUES (2, 2, '2024-09-01', '2024-12-31', 1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 50000) ON CONFLICT DO NOTHING;
INSERT INTO public.conditions VALUES (3, 3, '2024-09-01', '2025-02-28', 1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 5000) ON CONFLICT DO NOTHING;
INSERT INTO public.conditions VALUES (4, 3, '2024-09-01', '2025-02-28', 1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 5000) ON CONFLICT DO NOTHING;
INSERT INTO public.conditions VALUES (5, 3, '2024-09-01', '2025-10-31', 3, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 5000) ON CONFLICT DO NOTHING;
INSERT INTO public.conditions VALUES (6, 3, '2024-09-01', '2025-09-30', 2, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a16', 5000) ON CONFLICT DO NOTHING;
INSERT INTO public.conditions VALUES (7, 3, '2024-09-01', '2025-09-01', 4, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a17', 5000) ON CONFLICT DO NOTHING;
INSERT INTO public.conditions VALUES (8, 3, '2024-09-01', '2025-12-01', 2, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a18', 5000) ON CONFLICT DO NOTHING;
INSERT INTO public.conditions VALUES (9, 2, '2024-09-01', '2025-12-31', 2, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a19', 50000) ON CONFLICT DO NOTHING;


--
-- TOC entry 5166 (class 0 OID 16865)
-- Dependencies: 250
-- Data for Name: contact_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.contact_detail VALUES (1, '(205) 543-2518', 'venenatis.vel.faucibus@protonmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (2, '(573) 214-0115', 'nunc@aol.com') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (3, '1-518-618-4727', 'faucibus.orci@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (4, '(748) 845-1422', 'sed.dolor@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (5, '1-911-414-1024', 'pellentesque.massa.lobortis@icloud.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (6, '(614) 361-7317', 'commodo.ipsum.suspendisse@google.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (7, '1-317-718-4777', 'molestie.orci@hotmail.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (8, '1-745-878-0357', 'magna.sed.dui@hotmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (9, '(310) 265-7931', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (10, '1-625-358-2289', 'tincidunt.neque@yahoo.org') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (11, '1-367-646-4810', 'penatibus.et@protonmail.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (12, '(212) 908-6557', 'tempus.eu@outlook.org') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (13, '1-175-876-6642', 'fames.ac@hotmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (14, '(+46) 265-885421', 'sed@google.com') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (15, '(+10) 345-79781', 'amet.metus@aol.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (16, '(355) 707-6026', 'orci@icloud.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (17, '(718) 866-9733', 'tempor@hotmail.edu') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (18, '(582) 607-8922', 'idrty@yahoo.edu') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (19, '(+46) 346-3564', 'magna.cras@aol.edu') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (20, '1-666-315-6032', 'elementum.dui@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (21, '(236) 256-5121', 'egestas@outlook.org') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (22, '1-214-662-8621', 'orrewci.adipiscing@hotmail.org') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (23, '(495) 937-6437', 'ullamcorper.duis@outlook.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (24, '(666) 954-2361', 'mauris.suspendisse@yahoo.org') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (25, '(161) 464-9536', 'lacinia.vitae@outlook.edu') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (26, '(+46) 566-34655', 'uyew@outlook.edu') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (27, '(+46) 456-23156', 'phasellus@protonmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (28, '(+46) 642-33469', 'placerat.cras@hotmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (29, '(+10) 097-98743', 'natoque@outlook.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.contact_detail VALUES (30, '(+10) 245-67423', 'enim@google.org') ON CONFLICT DO NOTHING;


--
-- TOC entry 5173 (class 0 OID 17019)
-- Dependencies: 257
-- Data for Name: ensemble; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ensemble VALUES (1, 100, 1, '2024-09-01', 1, 1, 9, 3, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (2, 101, 1, '2024-09-01', 1, 1, 9, 3, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (3, 102, 1, '2024-09-01', 1, 1, 9, 3, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (4, 103, 1, '2024-09-01', 1, 1, 9, 3, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (5, 104, 2, '2024-09-08', 2, 1, 5, 3, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (6, 105, 2, '2024-09-08', 2, 1, 5, 3, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (7, 106, 2, '2024-09-08', 2, 1, 5, 3, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (8, 107, 3, '2024-09-16', 3, 1, 7, 3, 1004) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (9, 108, 3, '2024-09-16', 3, 1, 7, 3, 1004) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (11, 100, 1, '2024-10-01', 1, 1, 9, 3, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (12, 101, 1, '2024-10-01', 1, 1, 9, 3, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (13, 102, 1, '2024-10-01', 1, 1, 9, 3, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (14, 103, 1, '2024-10-01', 1, 1, 9, 3, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (15, 104, 2, '2024-10-08', 2, 1, 5, 3, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (16, 105, 2, '2024-10-08', 2, 1, 5, 3, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (17, 106, 2, '2024-10-08', 2, 1, 5, 3, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (18, 107, 3, '2024-10-16', 3, 1, 7, 3, 1004) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (19, 108, 3, '2024-10-16', 3, 1, 7, 3, 1004) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (20, 108, 3, '2024-10-16', 3, 1, 7, 3, 1004) ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble VALUES (10, 109, 3, '2024-09-16', 3, 1, 7, 3, 1004) ON CONFLICT DO NOTHING;


--
-- TOC entry 5138 (class 0 OID 16403)
-- Dependencies: 222
-- Data for Name: ensemble_genre; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ensemble_genre VALUES (1, 'punk rock') ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble_genre VALUES (2, 'gospel band') ON CONFLICT DO NOTHING;
INSERT INTO public.ensemble_genre VALUES (3, 'сlassical music') ON CONFLICT DO NOTHING;


--
-- TOC entry 5175 (class 0 OID 17062)
-- Dependencies: 259
-- Data for Name: group_lessons; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.group_lessons VALUES (1, 100, '2024-09-01', 2, 1, 7, 1, 2, 1005) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (2, 101, '2024-09-01', 2, 1, 7, 2, 2, 1005) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (3, 102, '2024-09-01', 2, 1, 7, 1, 2, 1005) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (4, 103, '2024-09-01', 2, 1, 7, 2, 2, 1005) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (5, 104, '2024-09-08', 3, 1, 6, 3, 2, 1002) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (6, 105, '2024-09-08', 3, 1, 6, 4, 2, 1002) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (7, 106, '2024-09-08', 3, 1, 6, 3, 2, 1002) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (8, 107, '2024-09-16', 4, 1, 7, 5, 2, 1003) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (9, 108, '2024-09-16', 4, 1, 7, 6, 2, 1003) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (10, 108, '2024-09-16', 4, 1, 7, 5, 2, 1003) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (11, 100, '2024-10-01', 2, 1, 9, 1, 2, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (12, 101, '2024-10-01', 2, 1, 9, 2, 2, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (13, 102, '2024-10-01', 2, 1, 9, 1, 2, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (14, 103, '2024-10-01', 2, 1, 9, 2, 2, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (15, 104, '2024-10-08', 3, 1, 5, 3, 2, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (16, 105, '2024-10-08', 3, 1, 5, 4, 2, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (17, 106, '2024-10-08', 3, 1, 5, 3, 2, 1001) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (18, 107, '2024-10-16', 4, 1, 7, 5, 2, 1004) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (19, 108, '2024-10-16', 4, 1, 7, 6, 2, 1004) ON CONFLICT DO NOTHING;
INSERT INTO public.group_lessons VALUES (20, 108, '2024-10-16', 4, 1, 7, 5, 2, 1004) ON CONFLICT DO NOTHING;


--
-- TOC entry 5197 (class 0 OID 26499)
-- Dependencies: 281
-- Data for Name: historical_lessons; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.historical_lessons VALUES (1, '2024-09-01', 'Individual', 'No genre', 'Piano', 100.00, 'Austin', 'Morrison', 'venenatis.vel.faucibus@protonmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (2, '2024-09-01', 'Individual', 'No genre', 'Piano', 500.00, 'Austin', 'Morrison', 'venenatis.vel.faucibus@protonmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (3, '2024-09-01', 'Individual', 'No genre', 'Violin', 100.00, 'Mccarty', 'Morrison', 'nunc@aol.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (4, '2024-09-01', 'Individual', 'No genre', 'Violin', 500.00, 'Mccarty', 'Morrison', 'nunc@aol.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (5, '2024-09-01', 'Individual', 'No genre', 'Guitar', 100.00, 'Allegra', 'Velasquez', 'faucibus.orci@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (6, '2024-09-01', 'Individual', 'No genre', 'Guitar', 500.00, 'Allegra', 'Velasquez', 'faucibus.orci@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (7, '2024-09-10', 'Individual', 'No genre', 'Drums', 100.00, 'Walker', 'Mason', 'sed.dolor@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (8, '2024-09-10', 'Individual', 'No genre', 'Drums', 500.00, 'Walker', 'Mason', 'sed.dolor@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (9, '2024-09-01', 'Individual', 'No genre', 'Drums', 100.00, 'Walker', 'Mason', 'sed.dolor@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (10, '2024-09-01', 'Individual', 'No genre', 'Drums', 500.00, 'Walker', 'Mason', 'sed.dolor@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (11, '2024-09-01', 'Individual', 'No genre', 'cello', 100.00, 'Indira', 'Holland', 'pellentesque.massa.lobortis@icloud.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (12, '2024-09-01', 'Individual', 'No genre', 'cello', 500.00, 'Indira', 'Holland', 'pellentesque.massa.lobortis@icloud.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (13, '2024-09-01', 'Individual', 'No genre', 'electric guitar', 100.00, 'Page', 'Holland', 'commodo.ipsum.suspendisse@google.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (14, '2024-09-01', 'Individual', 'No genre', 'Trumpet', 100.00, 'Yoshio', 'Holland', 'molestie.orci@hotmail.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (15, '2024-09-01', 'Individual', 'No genre', 'Trumpet', 500.00, 'Yoshio', 'Holland', 'molestie.orci@hotmail.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (16, '2024-09-01', 'Individual', 'No genre', 'Flutes', 100.00, 'Henry', 'Zamora', 'magna.sed.dui@hotmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (17, '2024-09-01', 'Individual', 'No genre', 'Trumpet', 100.00, 'Sopoline', 'Hood', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (18, '2024-09-01', 'Individual', 'No genre', 'Trumpet', 500.00, 'Sopoline', 'Hood', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (19, '2024-09-01', 'Individual', 'No genre', 'Violin', 100.00, 'Reuben', 'Ray', 'tincidunt.neque@yahoo.org') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (20, '2024-09-01', 'Individual', 'No genre', 'Piano', 100.00, 'Reuben', 'Ray', 'tincidunt.neque@yahoo.org') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (21, '2024-10-01', 'Individual', 'No genre', 'Piano', 100.00, 'Austin', 'Morrison', 'venenatis.vel.faucibus@protonmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (22, '2024-10-01', 'Individual', 'No genre', 'Piano', 500.00, 'Austin', 'Morrison', 'venenatis.vel.faucibus@protonmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (23, '2024-10-01', 'Individual', 'No genre', 'Violin', 100.00, 'Mccarty', 'Morrison', 'nunc@aol.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (24, '2024-10-01', 'Individual', 'No genre', 'Violin', 500.00, 'Mccarty', 'Morrison', 'nunc@aol.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (25, '2024-10-01', 'Individual', 'No genre', 'Guitar', 100.00, 'Allegra', 'Velasquez', 'faucibus.orci@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (26, '2024-10-01', 'Individual', 'No genre', 'Guitar', 500.00, 'Allegra', 'Velasquez', 'faucibus.orci@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (27, '2024-10-10', 'Individual', 'No genre', 'Drums', 100.00, 'Walker', 'Mason', 'sed.dolor@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (28, '2024-10-10', 'Individual', 'No genre', 'Drums', 500.00, 'Walker', 'Mason', 'sed.dolor@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (29, '2024-10-01', 'Individual', 'No genre', 'cello', 100.00, 'Indira', 'Holland', 'pellentesque.massa.lobortis@icloud.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (30, '2024-10-01', 'Individual', 'No genre', 'cello', 500.00, 'Indira', 'Holland', 'pellentesque.massa.lobortis@icloud.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (31, '2024-10-01', 'Individual', 'No genre', 'electric guitar', 100.00, 'Page', 'Holland', 'commodo.ipsum.suspendisse@google.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (32, '2024-10-01', 'Individual', 'No genre', 'Trumpet', 100.00, 'Yoshio', 'Holland', 'molestie.orci@hotmail.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (33, '2024-10-01', 'Individual', 'No genre', 'Trumpet', 500.00, 'Yoshio', 'Holland', 'molestie.orci@hotmail.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (34, '2024-10-01', 'Individual', 'No genre', 'Flutes', 100.00, 'Henry', 'Zamora', 'magna.sed.dui@hotmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (35, '2024-10-01', 'Individual', 'No genre', 'Trumpet', 100.00, 'Sopoline', 'Hood', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (36, '2024-10-01', 'Individual', 'No genre', 'Trumpet', 500.00, 'Sopoline', 'Hood', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (37, '2024-10-01', 'Individual', 'No genre', 'Violin', 100.00, 'Reuben', 'Ray', 'tincidunt.neque@yahoo.org') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (38, '2024-10-16', 'Individual', 'No genre', 'Piano', 100.00, 'Reuben', 'Ray', 'tincidunt.neque@yahoo.org') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (39, '2024-10-01', 'Group', 'No genre', 'Violin', 50.00, 'Allegra', 'Velasquez', 'faucibus.orci@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (40, '2024-10-01', 'Group', 'No genre', 'Violin', 50.00, 'Austin', 'Morrison', 'venenatis.vel.faucibus@protonmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (41, '2024-09-01', 'Group', 'No genre', 'Violin', 50.00, 'Allegra', 'Velasquez', 'faucibus.orci@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (42, '2024-09-01', 'Group', 'No genre', 'Violin', 50.00, 'Austin', 'Morrison', 'venenatis.vel.faucibus@protonmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (43, '2024-10-01', 'Group', 'No genre', 'Piano', 50.00, 'Walker', 'Mason', 'sed.dolor@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (44, '2024-10-01', 'Group', 'No genre', 'Piano', 50.00, 'Mccarty', 'Morrison', 'nunc@aol.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (45, '2024-09-01', 'Group', 'No genre', 'Piano', 50.00, 'Walker', 'Mason', 'sed.dolor@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (46, '2024-09-01', 'Group', 'No genre', 'Piano', 50.00, 'Mccarty', 'Morrison', 'nunc@aol.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (47, '2024-10-08', 'Group', 'No genre', 'Guitar', 50.00, 'Yoshio', 'Holland', 'molestie.orci@hotmail.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (48, '2024-10-08', 'Group', 'No genre', 'Guitar', 50.00, 'Indira', 'Holland', 'pellentesque.massa.lobortis@icloud.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (49, '2024-09-08', 'Group', 'No genre', 'Guitar', 50.00, 'Yoshio', 'Holland', 'molestie.orci@hotmail.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (50, '2024-09-08', 'Group', 'No genre', 'Guitar', 50.00, 'Indira', 'Holland', 'pellentesque.massa.lobortis@icloud.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (51, '2024-10-08', 'Group', 'No genre', 'Drums', 50.00, 'Page', 'Holland', 'commodo.ipsum.suspendisse@google.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (52, '2024-09-08', 'Group', 'No genre', 'Drums', 50.00, 'Page', 'Holland', 'commodo.ipsum.suspendisse@google.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (53, '2024-10-16', 'Group', 'No genre', 'cello', 50.00, 'Sopoline', 'Hood', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (54, '2024-10-16', 'Group', 'No genre', 'cello', 50.00, 'Henry', 'Zamora', 'magna.sed.dui@hotmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (55, '2024-09-16', 'Group', 'No genre', 'cello', 50.00, 'Sopoline', 'Hood', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (56, '2024-09-16', 'Group', 'No genre', 'cello', 50.00, 'Henry', 'Zamora', 'magna.sed.dui@hotmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (57, '2024-10-16', 'Group', 'No genre', 'electric guitar', 50.00, 'Sopoline', 'Hood', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (58, '2024-09-16', 'Group', 'No genre', 'electric guitar', 50.00, 'Sopoline', 'Hood', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (59, '2024-09-01', 'Ensemble', 'punk rock', 'Different musical instruments', 60.00, 'Austin', 'Morrison', 'venenatis.vel.faucibus@protonmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (60, '2024-09-01', 'Ensemble', 'punk rock', 'Different musical instruments', 60.00, 'Mccarty', 'Morrison', 'nunc@aol.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (61, '2024-09-01', 'Ensemble', 'punk rock', 'Different musical instruments', 60.00, 'Allegra', 'Velasquez', 'faucibus.orci@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (62, '2024-09-01', 'Ensemble', 'punk rock', 'Different musical instruments', 60.00, 'Walker', 'Mason', 'sed.dolor@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (63, '2024-09-08', 'Ensemble', 'gospel band', 'Different musical instruments', 60.00, 'Indira', 'Holland', 'pellentesque.massa.lobortis@icloud.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (64, '2024-09-08', 'Ensemble', 'gospel band', 'Different musical instruments', 60.00, 'Page', 'Holland', 'commodo.ipsum.suspendisse@google.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (65, '2024-09-08', 'Ensemble', 'gospel band', 'Different musical instruments', 60.00, 'Yoshio', 'Holland', 'molestie.orci@hotmail.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (66, '2024-09-16', 'Ensemble', 'сlassical music', 'Different musical instruments', 60.00, 'Henry', 'Zamora', 'magna.sed.dui@hotmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (67, '2024-09-16', 'Ensemble', 'сlassical music', 'Different musical instruments', 60.00, 'Sopoline', 'Hood', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (68, '2024-10-01', 'Ensemble', 'punk rock', 'Different musical instruments', 60.00, 'Austin', 'Morrison', 'venenatis.vel.faucibus@protonmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (69, '2024-10-01', 'Ensemble', 'punk rock', 'Different musical instruments', 60.00, 'Mccarty', 'Morrison', 'nunc@aol.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (70, '2024-10-01', 'Ensemble', 'punk rock', 'Different musical instruments', 60.00, 'Allegra', 'Velasquez', 'faucibus.orci@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (71, '2024-10-01', 'Ensemble', 'punk rock', 'Different musical instruments', 60.00, 'Walker', 'Mason', 'sed.dolor@icloud.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (72, '2024-10-08', 'Ensemble', 'gospel band', 'Different musical instruments', 60.00, 'Indira', 'Holland', 'pellentesque.massa.lobortis@icloud.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (73, '2024-10-08', 'Ensemble', 'gospel band', 'Different musical instruments', 60.00, 'Page', 'Holland', 'commodo.ipsum.suspendisse@google.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (74, '2024-10-08', 'Ensemble', 'gospel band', 'Different musical instruments', 60.00, 'Yoshio', 'Holland', 'molestie.orci@hotmail.ca') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (75, '2024-10-16', 'Ensemble', 'сlassical music', 'Different musical instruments', 60.00, 'Henry', 'Zamora', 'magna.sed.dui@hotmail.com') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (76, '2024-10-16', 'Ensemble', 'сlassical music', 'Different musical instruments', 60.00, 'Sopoline', 'Hood', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (77, '2024-10-16', 'Ensemble', 'сlassical music', 'Different musical instruments', 60.00, 'Sopoline', 'Hood', 'vel.est@google.couk') ON CONFLICT DO NOTHING;
INSERT INTO public.historical_lessons VALUES (78, '2024-09-16', 'Ensemble', 'сlassical music', 'Different musical instruments', 60.00, 'Reuben', 'Ray', 'tincidunt.neque@yahoo.org') ON CONFLICT DO NOTHING;


--
-- TOC entry 5169 (class 0 OID 16915)
-- Dependencies: 253
-- Data for Name: hold_instrument; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.hold_instrument VALUES (1, 1000, 1, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (2, 1000, 5, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (3, 1001, 7, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (4, 1001, 8, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (5, 1001, 2, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (6, 1002, 3, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (7, 1002, 6, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (8, 1003, 1, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (9, 1004, 4, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (10, 100, 2, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (11, 101, 1, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (12, 102, 3, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (13, 103, 4, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (14, 104, 5, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (15, 105, 6, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (16, 106, 7, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (17, 107, 8, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (18, 108, 7, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (19, 109, 1, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.hold_instrument VALUES (20, 109, 2, 2) ON CONFLICT DO NOTHING;


--
-- TOC entry 5156 (class 0 OID 16595)
-- Dependencies: 240
-- Data for Name: instructor; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.instructor VALUES (1000, 'Charde', 'Benjamin', 7, 20) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor VALUES (1001, 'Rhoda', 'Francis', 8, 21) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor VALUES (1002, 'Freya', 'Ferguson', 9, 22) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor VALUES (1003, 'Madeline', 'Pittman', 10, 23) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor VALUES (1004, 'Kevyn', 'Erickson', 11, 24) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor VALUES (1005, 'Elmo', 'Carr', 12, 25) ON CONFLICT DO NOTHING;


--
-- TOC entry 5184 (class 0 OID 17468)
-- Dependencies: 268
-- Data for Name: instructor_payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.instructor_payment VALUES (1, 1000, '2024-09-01', '2024-09-30', 1, 1, 3, 10, 1000) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (2, 1001, '2024-09-01', '2024-09-30', 1, 1, 3, 27, 2700) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (3, 1002, '2024-09-01', '2024-09-30', 1, 1, 3, 11, 1100) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (4, 1003, '2024-09-01', '2024-09-30', 1, 1, 3, 9, 900) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (5, 1004, '2024-09-01', '2024-09-30', 1, 1, 3, 8, 800) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (6, 1005, '2024-09-01', '2024-09-30', 1, 1, 3, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (7, 1000, '2024-09-01', '2024-09-30', 1, 2, 4, 9, 900) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (8, 1001, '2024-09-01', '2024-09-30', 1, 2, 4, 9, 900) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (9, 1002, '2024-09-01', '2024-09-30', 1, 2, 4, 4, 400) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (10, 1003, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (11, 1004, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (12, 1005, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (13, 1000, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (14, 1001, '2024-09-01', '2024-09-30', 2, 0, 6, 3, 150) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (15, 1002, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (16, 1003, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (17, 1004, '2024-09-01', '2024-09-30', 2, 0, 6, 3, 150) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (18, 1005, '2024-09-01', '2024-09-30', 2, 0, 6, 4, 200) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (19, 1000, '2024-09-01', '2024-09-30', 3, 0, 7, 4, 240) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (20, 1001, '2024-09-01', '2024-09-30', 3, 0, 7, 3, 180) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (21, 1002, '2024-09-01', '2024-09-30', 3, 0, 7, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (22, 1003, '2024-09-01', '2024-09-30', 3, 0, 7, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (23, 1004, '2024-09-01', '2024-09-30', 3, 0, 7, 3, 180) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (24, 1005, '2024-09-01', '2024-09-30', 3, 0, 7, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.instructor_payment VALUES (25, 1000, '2024-09-01', '2024-09-30', 1, 1, 3, 11, 1100) ON CONFLICT DO NOTHING;


--
-- TOC entry 5160 (class 0 OID 16626)
-- Dependencies: 244
-- Data for Name: invitations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5136 (class 0 OID 16396)
-- Dependencies: 220
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.lessons VALUES (1, 'individual') ON CONFLICT DO NOTHING;
INSERT INTO public.lessons VALUES (2, 'group') ON CONFLICT DO NOTHING;
INSERT INTO public.lessons VALUES (3, 'ensemble') ON CONFLICT DO NOTHING;
INSERT INTO public.lessons VALUES (0, 'no lessons type') ON CONFLICT DO NOTHING;


--
-- TOC entry 5134 (class 0 OID 16389)
-- Dependencies: 218
-- Data for Name: levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.levels VALUES (1, 'beginner') ON CONFLICT DO NOTHING;
INSERT INTO public.levels VALUES (2, 'intermediate') ON CONFLICT DO NOTHING;
INSERT INTO public.levels VALUES (3, 'advanced') ON CONFLICT DO NOTHING;
INSERT INTO public.levels VALUES (0, 'no level') ON CONFLICT DO NOTHING;


--
-- TOC entry 5146 (class 0 OID 16466)
-- Dependencies: 230
-- Data for Name: mus_instruments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.mus_instruments VALUES (1, 'Violin', 10, 2, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.mus_instruments VALUES (2, 'Piano', 6, 1, 6) ON CONFLICT DO NOTHING;
INSERT INTO public.mus_instruments VALUES (3, 'Guitar', 8, 4, 7) ON CONFLICT DO NOTHING;
INSERT INTO public.mus_instruments VALUES (4, 'Drums', 4, 5, 4) ON CONFLICT DO NOTHING;
INSERT INTO public.mus_instruments VALUES (5, 'cello', 10, 3, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.mus_instruments VALUES (6, 'electric guitar', 7, 6, 8) ON CONFLICT DO NOTHING;
INSERT INTO public.mus_instruments VALUES (7, 'Trumpet', 9, 7, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.mus_instruments VALUES (8, 'Flutes', 6, 8, 3) ON CONFLICT DO NOTHING;


--
-- TOC entry 5162 (class 0 OID 16647)
-- Dependencies: 246
-- Data for Name: numb_places; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.numb_places VALUES (1, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.numb_places VALUES (2, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.numb_places VALUES (3, 3) ON CONFLICT DO NOTHING;
INSERT INTO public.numb_places VALUES (4, 4) ON CONFLICT DO NOTHING;
INSERT INTO public.numb_places VALUES (5, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.numb_places VALUES (6, 6) ON CONFLICT DO NOTHING;
INSERT INTO public.numb_places VALUES (7, 7) ON CONFLICT DO NOTHING;
INSERT INTO public.numb_places VALUES (8, 8) ON CONFLICT DO NOTHING;
INSERT INTO public.numb_places VALUES (9, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.numb_places VALUES (10, 10) ON CONFLICT DO NOTHING;


--
-- TOC entry 5194 (class 0 OID 17624)
-- Dependencies: 278
-- Data for Name: personin; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5153 (class 0 OID 16579)
-- Dependencies: 237
-- Data for Name: persons; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.persons VALUES (5000, 'Eaton', 'Holland', 104, 11, 2, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.persons VALUES (5001, 'Christopher', 'Holland', 105, 12, 2, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.persons VALUES (5002, 'Keefe', 'Morrison', 100, 13, 1, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.persons VALUES (5003, 'Tana', 'Velasquez', 102, 14, 4, 2) ON CONFLICT DO NOTHING;
INSERT INTO public.persons VALUES (5004, 'Zelenia', 'Mason', 103, 15, 6, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.persons VALUES (5005, 'Chancellor', 'Morrison', 101, 16, 1, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.persons VALUES (5006, 'Octavius', 'Nunez', 107, 17, 4, 7) ON CONFLICT DO NOTHING;
INSERT INTO public.persons VALUES (5007, 'Tucker', 'Mcguire', 109, 18, 3, 5) ON CONFLICT DO NOTHING;
INSERT INTO public.persons VALUES (5008, 'Christopher', 'Callahan', 108, 19, 6, 7) ON CONFLICT DO NOTHING;
INSERT INTO public.persons VALUES (5009, 'Lane', 'Holland', 106, 20, 2, 2) ON CONFLICT DO NOTHING;


--
-- TOC entry 5180 (class 0 OID 17331)
-- Dependencies: 264
-- Data for Name: price; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.price VALUES (1, '2000-01-01', '2050-01-01', 0, 0, 'Rent instruments', 100, 'SWK') ON CONFLICT DO NOTHING;
INSERT INTO public.price VALUES (2, '2000-01-01', '2050-01-01', 0, 0, 'Home delivery', 0, 'SWK') ON CONFLICT DO NOTHING;
INSERT INTO public.price VALUES (4, '2000-01-01', '2050-01-01', 1, 2, 'Individual intermedia', 100, 'SWK') ON CONFLICT DO NOTHING;
INSERT INTO public.price VALUES (5, '2000-01-01', '2050-01-01', 1, 3, 'Individual advanced', 200, 'SWK') ON CONFLICT DO NOTHING;
INSERT INTO public.price VALUES (6, '2000-01-01', '2050-01-01', 2, 0, 'Group lessons', 50, 'SWK') ON CONFLICT DO NOTHING;
INSERT INTO public.price VALUES (7, '2000-01-01', '2050-01-01', 3, 0, 'Ensembles', 60, 'SWK') ON CONFLICT DO NOTHING;
INSERT INTO public.price VALUES (8, '2000-01-01', '2050-01-01', 0, 0, 'Sibling discounts', 5, '%') ON CONFLICT DO NOTHING;
INSERT INTO public.price VALUES (3, '2000-01-01', '2024-09-30', 1, 1, 'Individual beginner', 100, 'SWK') ON CONFLICT DO NOTHING;
INSERT INTO public.price VALUES (9, '2024-10-01', '2050-01-02', 1, 1, 'Individual beginner', 500, 'SWK') ON CONFLICT DO NOTHING;


--
-- TOC entry 5164 (class 0 OID 16819)
-- Dependencies: 248
-- Data for Name: relatives; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.relatives VALUES (1, 'Father') ON CONFLICT DO NOTHING;
INSERT INTO public.relatives VALUES (2, 'Mother') ON CONFLICT DO NOTHING;
INSERT INTO public.relatives VALUES (3, 'Grandfather') ON CONFLICT DO NOTHING;
INSERT INTO public.relatives VALUES (4, 'Grandmother') ON CONFLICT DO NOTHING;
INSERT INTO public.relatives VALUES (5, 'Great-grandfather') ON CONFLICT DO NOTHING;
INSERT INTO public.relatives VALUES (6, 'Uncle') ON CONFLICT DO NOTHING;
INSERT INTO public.relatives VALUES (7, 'Aunt') ON CONFLICT DO NOTHING;
INSERT INTO public.relatives VALUES (8, 'Cousins') ON CONFLICT DO NOTHING;


--
-- TOC entry 5177 (class 0 OID 17152)
-- Dependencies: 261
-- Data for Name: renting_instruments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.renting_instruments VALUES (1, 100, 1, '2024-09-01', '2025-06-30', 1, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.renting_instruments VALUES (2, 101, 2, '2024-09-01', '2024-12-30', 1, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.renting_instruments VALUES (3, 103, 3, '2024-09-01', '2025-02-28', 2, 1) ON CONFLICT DO NOTHING;
INSERT INTO public.renting_instruments VALUES (4, 107, 1, '2024-01-09', '2024-12-09', 2, 1) ON CONFLICT DO NOTHING;


--
-- TOC entry 5154 (class 0 OID 16588)
-- Dependencies: 238
-- Data for Name: sibling; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sibling VALUES (100, 101) ON CONFLICT DO NOTHING;
INSERT INTO public.sibling VALUES (104, 105) ON CONFLICT DO NOTHING;
INSERT INTO public.sibling VALUES (105, 104) ON CONFLICT DO NOTHING;


--
-- TOC entry 5195 (class 0 OID 25927)
-- Dependencies: 279
-- Data for Name: sibling_count; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sibling_count VALUES (1) ON CONFLICT DO NOTHING;


--
-- TOC entry 5190 (class 0 OID 17554)
-- Dependencies: 274
-- Data for Name: storage_places; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.storage_places VALUES (1, 'lease agreement') ON CONFLICT DO NOTHING;
INSERT INTO public.storage_places VALUES (2, 'balance in stock') ON CONFLICT DO NOTHING;
INSERT INTO public.storage_places VALUES (3, 'under repair') ON CONFLICT DO NOTHING;
INSERT INTO public.storage_places VALUES (4, 'written off the balance sheet') ON CONFLICT DO NOTHING;


--
-- TOC entry 5151 (class 0 OID 16542)
-- Dependencies: 235
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.student VALUES (100, 'Austin', 'Morrison', 1, 1, 5000) ON CONFLICT DO NOTHING;
INSERT INTO public.student VALUES (101, 'Mccarty', 'Morrison', 1, 2, 5000) ON CONFLICT DO NOTHING;
INSERT INTO public.student VALUES (102, 'Allegra', 'Velasquez', 3, 3, 5003) ON CONFLICT DO NOTHING;
INSERT INTO public.student VALUES (103, 'Walker', 'Mason', 6, 4, 5004) ON CONFLICT DO NOTHING;
INSERT INTO public.student VALUES (104, 'Indira', 'Holland', 2, 5, 5005) ON CONFLICT DO NOTHING;
INSERT INTO public.student VALUES (105, 'Page', 'Holland', 2, 6, 5005) ON CONFLICT DO NOTHING;
INSERT INTO public.student VALUES (106, 'Yoshio', 'Holland', 2, 7, 5007) ON CONFLICT DO NOTHING;
INSERT INTO public.student VALUES (107, 'Henry', 'Zamora', 4, 8, 5008) ON CONFLICT DO NOTHING;
INSERT INTO public.student VALUES (108, 'Sopoline', 'Hood', 5, 9, 5009) ON CONFLICT DO NOTHING;
INSERT INTO public.student VALUES (109, 'Reuben', 'Ray', 6, 10, 5001) ON CONFLICT DO NOTHING;


--
-- TOC entry 5183 (class 0 OID 17434)
-- Dependencies: 267
-- Data for Name: student_payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.student_payment VALUES (36, 104, '2024-09-01', '2024-09-30', 1, 1, 3, 2, 11, 3190.00) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (1, 100, '2024-09-01', '2024-09-30', 1, 1, 3, 0, 10, 950) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (2, 101, '2024-09-01', '2024-09-30', 1, 1, 3, 0, 9, 855) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (3, 102, '2024-09-01', '2024-09-30', 1, 1, 3, 0, 11, 1100) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (4, 103, '2024-09-01', '2024-09-30', 1, 1, 3, 0, 8, 800) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (5, 104, '2024-09-01', '2024-09-30', 1, 1, 3, 0, 10, 900) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (6, 105, '2024-09-01', '2024-09-30', 1, 1, 3, 0, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (7, 106, '2024-09-01', '2024-09-30', 1, 1, 3, 0, 8, 720) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (8, 107, '2024-09-01', '2024-09-30', 1, 1, 3, 0, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (9, 108, '2024-09-01', '2024-09-30', 1, 1, 3, 0, 9, 900) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (10, 109, '2024-09-01', '2024-09-30', 1, 1, 3, 0, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (11, 100, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (12, 101, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (13, 102, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (14, 103, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (15, 104, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (16, 105, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 4, 360) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (17, 106, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (18, 107, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 9, 900) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (19, 108, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 0, 0) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (20, 109, '2024-09-01', '2024-09-30', 1, 2, 4, 0, 9, 900) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (21, 100, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 1, 47.5) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (22, 101, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 1, 47.5) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (23, 102, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 1, 50) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (24, 103, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 1, 50) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (25, 104, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 1, 45) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (26, 105, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 1, 45) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (27, 106, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 1, 45) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (28, 107, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 1, 50) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (29, 108, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 1, 50) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (30, 109, '2024-09-01', '2024-09-30', 2, 0, 6, 0, 1, 50) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (31, 100, '2024-09-01', '2024-09-30', 3, 0, 7, 0, 1, 57) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (32, 101, '2024-09-01', '2024-09-30', 3, 0, 7, 0, 1, 57) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (33, 102, '2024-09-01', '2024-09-30', 3, 0, 7, 0, 1, 60) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (34, 103, '2024-09-01', '2024-09-30', 3, 0, 7, 0, 1, 60) ON CONFLICT DO NOTHING;
INSERT INTO public.student_payment VALUES (35, 104, '2024-09-01', '2024-09-30', 3, 0, 7, 0, 1, 53) ON CONFLICT DO NOTHING;


--
-- TOC entry 5158 (class 0 OID 16609)
-- Dependencies: 242
-- Data for Name: time_slot; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.time_slot VALUES (1, 8, 9) ON CONFLICT DO NOTHING;
INSERT INTO public.time_slot VALUES (2, 9, 10) ON CONFLICT DO NOTHING;
INSERT INTO public.time_slot VALUES (3, 10, 11) ON CONFLICT DO NOTHING;
INSERT INTO public.time_slot VALUES (4, 11, 12) ON CONFLICT DO NOTHING;
INSERT INTO public.time_slot VALUES (5, 12, 13) ON CONFLICT DO NOTHING;
INSERT INTO public.time_slot VALUES (6, 13, 14) ON CONFLICT DO NOTHING;
INSERT INTO public.time_slot VALUES (7, 14, 15) ON CONFLICT DO NOTHING;
INSERT INTO public.time_slot VALUES (8, 15, 16) ON CONFLICT DO NOTHING;
INSERT INTO public.time_slot VALUES (9, 16, 17) ON CONFLICT DO NOTHING;
INSERT INTO public.time_slot VALUES (10, 17, 18) ON CONFLICT DO NOTHING;
INSERT INTO public.time_slot VALUES (11, 18, 19) ON CONFLICT DO NOTHING;


--
-- TOC entry 5142 (class 0 OID 16417)
-- Dependencies: 226
-- Data for Name: types_instruments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.types_instruments VALUES (1, 'Strings') ON CONFLICT DO NOTHING;
INSERT INTO public.types_instruments VALUES (2, 'Wind') ON CONFLICT DO NOTHING;
INSERT INTO public.types_instruments VALUES (3, 'Reed') ON CONFLICT DO NOTHING;
INSERT INTO public.types_instruments VALUES (4, 'Drums') ON CONFLICT DO NOTHING;
INSERT INTO public.types_instruments VALUES (5, 'Percussion') ON CONFLICT DO NOTHING;
INSERT INTO public.types_instruments VALUES (6, 'Keyboards') ON CONFLICT DO NOTHING;
INSERT INTO public.types_instruments VALUES (7, 'Mechanical') ON CONFLICT DO NOTHING;
INSERT INTO public.types_instruments VALUES (8, 'Electronic') ON CONFLICT DO NOTHING;


--
-- TOC entry 5224 (class 0 OID 0)
-- Dependencies: 231
-- Name: address_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.address_address_id_seq', 1, false);


--
-- TOC entry 5225 (class 0 OID 0)
-- Dependencies: 265
-- Name: admin_staff_admin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_staff_admin_id_seq', 1, false);


--
-- TOC entry 5226 (class 0 OID 0)
-- Dependencies: 227
-- Name: app_attend_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_attend_app_id_seq', 1, false);


--
-- TOC entry 5227 (class 0 OID 0)
-- Dependencies: 254
-- Name: booking_individual_indiv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.booking_individual_indiv_id_seq', 1, false);


--
-- TOC entry 5228 (class 0 OID 0)
-- Dependencies: 223
-- Name: brands_brand_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.brands_brand_id_seq', 8, true);


--
-- TOC entry 5229 (class 0 OID 0)
-- Dependencies: 275
-- Name: conditions_condition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conditions_condition_id_seq', 1, false);


--
-- TOC entry 5230 (class 0 OID 0)
-- Dependencies: 249
-- Name: contactsdetail_contactdet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contactsdetail_contactdet_id_seq', 1, false);


--
-- TOC entry 5231 (class 0 OID 0)
-- Dependencies: 256
-- Name: ensemble_ensem_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ensemble_ensem_id_seq', 1, false);


--
-- TOC entry 5232 (class 0 OID 0)
-- Dependencies: 221
-- Name: ensembles_ensembles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ensembles_ensembles_id_seq', 3, true);


--
-- TOC entry 5233 (class 0 OID 0)
-- Dependencies: 258
-- Name: group_lessons_grouplesson_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.group_lessons_grouplesson_id_seq', 1, false);


--
-- TOC entry 5234 (class 0 OID 0)
-- Dependencies: 280
-- Name: historical_lessons_lesson_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historical_lessons_lesson_id_seq', 78, true);


--
-- TOC entry 5235 (class 0 OID 0)
-- Dependencies: 252
-- Name: hold_instrument_hold_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hold_instrument_hold_id_seq', 1, false);


--
-- TOC entry 5236 (class 0 OID 0)
-- Dependencies: 239
-- Name: instructor_instruktor_numb_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.instructor_instruktor_numb_seq', 1000, true);


--
-- TOC entry 5237 (class 0 OID 0)
-- Dependencies: 262
-- Name: instructor_payment_ins_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.instructor_payment_ins_payment_id_seq', 1, false);


--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 243
-- Name: invitations_invitation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invitations_invitation_id_seq', 1, false);


--
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 219
-- Name: lessons_lessons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lessons_lessons_id_seq', 3, true);


--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 217
-- Name: levels_level_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.levels_level_id_seq', 1, true);


--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 245
-- Name: maxsimum_places_max_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.maxsimum_places_max_id_seq', 1, false);


--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 229
-- Name: mus_instruments_instrument_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mus_instruments_instrument_id_seq', 1, false);


--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 236
-- Name: person_contact_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.person_contact_person_id_seq', 5000, true);


--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 277
-- Name: personin_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personin_person_id_seq', 1, false);


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 251
-- Name: price_price_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.price_price_id_seq', 1, false);


--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 247
-- Name: relatives_relativ_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.relatives_relativ_id_seq', 1, false);


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 260
-- Name: renting_instruments_renting_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renting_instruments_renting_id_seq', 1, true);


--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 272
-- Name: reservations_reserv_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservations_reserv_group_id_seq', 1, false);


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 269
-- Name: reservations_reserv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservations_reserv_id_seq', 1, false);


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 273
-- Name: storage_places_place_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.storage_places_place_id_seq', 1, false);


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 263
-- Name: student_payment_st_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_payment_st_payment_id_seq', 8, true);


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 233
-- Name: student_student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_student_id_seq', 100, true);


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 234
-- Name: student_student_numb_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_student_numb_seq', 1, true);


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 241
-- Name: time_slot_slot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.time_slot_slot_id_seq', 1, false);


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 225
-- Name: types_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.types_type_id_seq', 8, true);


--
-- TOC entry 4868 (class 2606 OID 16512)
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);


--
-- TOC entry 4900 (class 2606 OID 17348)
-- Name: complet_lessons admin_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT admin_staff_pkey PRIMARY KEY (admin_id);


--
-- TOC entry 4864 (class 2606 OID 16484)
-- Name: attend_student app_attend_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student
    ADD CONSTRAINT app_attend_pkey PRIMARY KEY (attend_id);


--
-- TOC entry 4890 (class 2606 OID 16943)
-- Name: booking_individual booking_individual_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT booking_individual_pkey PRIMARY KEY (indiv_id);


--
-- TOC entry 4860 (class 2606 OID 16453)
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (brand_id);


--
-- TOC entry 4912 (class 2606 OID 17570)
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (condition_id);


--
-- TOC entry 4886 (class 2606 OID 16870)
-- Name: contact_detail contactsdetail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_detail
    ADD CONSTRAINT contactsdetail_pkey PRIMARY KEY (contact_id);


--
-- TOC entry 4892 (class 2606 OID 17024)
-- Name: ensemble ensemble_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT ensemble_pkey PRIMARY KEY (ensem_id);


--
-- TOC entry 4858 (class 2606 OID 16446)
-- Name: ensemble_genre ensembles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble_genre
    ADD CONSTRAINT ensembles_pkey PRIMARY KEY (ensembles_id);


--
-- TOC entry 4894 (class 2606 OID 17067)
-- Name: group_lessons group_lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT group_lessons_pkey PRIMARY KEY (grouplesson_id);


--
-- TOC entry 4916 (class 2606 OID 26504)
-- Name: historical_lessons historical_lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historical_lessons
    ADD CONSTRAINT historical_lessons_pkey PRIMARY KEY (lesson_id);


--
-- TOC entry 4888 (class 2606 OID 16920)
-- Name: hold_instrument hold_instrument_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT hold_instrument_pkey PRIMARY KEY (hold_id);


--
-- TOC entry 4904 (class 2606 OID 17475)
-- Name: instructor_payment instructor_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT instructor_payment_pkey PRIMARY KEY (ins_payment_id);


--
-- TOC entry 4876 (class 2606 OID 16600)
-- Name: instructor instructor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT instructor_pkey PRIMARY KEY (instruktor_numb);


--
-- TOC entry 4880 (class 2606 OID 16631)
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (invitation_id);


--
-- TOC entry 4856 (class 2606 OID 16439)
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (lessons_id);


--
-- TOC entry 4854 (class 2606 OID 16432)
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (level_id);


--
-- TOC entry 4882 (class 2606 OID 16652)
-- Name: numb_places maxsimum_places_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.numb_places
    ADD CONSTRAINT maxsimum_places_pkey PRIMARY KEY (place_id);


--
-- TOC entry 4866 (class 2606 OID 16471)
-- Name: mus_instruments mus_instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments
    ADD CONSTRAINT mus_instruments_pkey PRIMARY KEY (instrument_id);


--
-- TOC entry 4914 (class 2606 OID 17629)
-- Name: personin personin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin
    ADD CONSTRAINT personin_pkey PRIMARY KEY (person_id);


--
-- TOC entry 4872 (class 2606 OID 16882)
-- Name: persons persons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT persons_pkey PRIMARY KEY (person_id);


--
-- TOC entry 4898 (class 2606 OID 17338)
-- Name: price price_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_pkey PRIMARY KEY (price_id);


--
-- TOC entry 4884 (class 2606 OID 16824)
-- Name: relatives relatives_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relatives
    ADD CONSTRAINT relatives_pkey PRIMARY KEY (relativ_id);


--
-- TOC entry 4896 (class 2606 OID 17159)
-- Name: renting_instruments renting_instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT renting_instruments_pkey PRIMARY KEY (renting_id);


--
-- TOC entry 4908 (class 2606 OID 17545)
-- Name: actual_seats_group reservat_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_group
    ADD CONSTRAINT reservat_group_pkey PRIMARY KEY (reserv_id);


--
-- TOC entry 4906 (class 2606 OID 17517)
-- Name: actual_seats_ensemble reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_ensemble
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (reserv_id);


--
-- TOC entry 4874 (class 2606 OID 17584)
-- Name: sibling sibling_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sibling
    ADD CONSTRAINT sibling_pkey PRIMARY KEY (student_numb, person_sibling);


--
-- TOC entry 4910 (class 2606 OID 17561)
-- Name: storage_places storage_places_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storage_places
    ADD CONSTRAINT storage_places_pkey PRIMARY KEY (place_id);


--
-- TOC entry 4902 (class 2606 OID 17441)
-- Name: student_payment student_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT student_payment_pkey PRIMARY KEY (st_payment_id);


--
-- TOC entry 4870 (class 2606 OID 16577)
-- Name: student student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (student_numb);


--
-- TOC entry 4878 (class 2606 OID 16614)
-- Name: time_slot time_slot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_slot
    ADD CONSTRAINT time_slot_pkey PRIMARY KEY (time_slot_id);


--
-- TOC entry 4862 (class 2606 OID 16425)
-- Name: types_instruments types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_instruments
    ADD CONSTRAINT types_pkey PRIMARY KEY (type_id);


--
-- TOC entry 5132 (class 2618 OID 26530)
-- Name: list_ensembles _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.list_ensembles AS
 SELECT to_char((e.data_ensem)::timestamp with time zone, 'Day'::text) AS day_of_week,
    g.gentre_ensembles AS genre,
        CASE
            WHEN ((e.max_students - COALESCE(sum(r.actual_seats), (0)::bigint)) = 0) THEN 'No seats available'::text
            WHEN ((e.max_students - COALESCE(sum(r.actual_seats), (0)::bigint)) <= 2) THEN '1 or 2 places'::text
            ELSE 'Lots of places'::text
        END AS available_seats
   FROM ((public.ensemble e
     LEFT JOIN public.actual_seats_ensemble r ON ((e.ensem_id = r.reserv_id)))
     LEFT JOIN public.ensemble_genre g ON ((e.ensembles_id = g.ensembles_id)))
  WHERE ((e.data_ensem <= (CURRENT_DATE + '1 day'::interval)) AND (e.data_ensem < (CURRENT_DATE + '8 days'::interval)))
  GROUP BY e.ensem_id, g.gentre_ensembles, e.data_ensem
  ORDER BY g.gentre_ensembles, (to_char((e.data_ensem)::timestamp with time zone, 'D'::text));


--
-- TOC entry 4979 (class 2620 OID 26497)
-- Name: renting_instruments rental_duration_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rental_duration_check BEFORE INSERT OR UPDATE ON public.renting_instruments FOR EACH ROW EXECUTE FUNCTION public.check_rental_duration();


--
-- TOC entry 4980 (class 2620 OID 26763)
-- Name: renting_instruments renting_check2; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER renting_check2 BEFORE INSERT OR UPDATE ON public.renting_instruments FOR EACH ROW EXECUTE FUNCTION public.renting_check2();


--
-- TOC entry 4982 (class 2620 OID 25933)
-- Name: student_payment trg_update_total_paid; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_total_paid BEFORE INSERT OR UPDATE ON public.student_payment FOR EACH ROW EXECUTE FUNCTION public.update_total_paid();


--
-- TOC entry 4983 (class 2620 OID 25935)
-- Name: instructor_payment trg_update_total_received; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_total_received BEFORE INSERT OR UPDATE ON public.instructor_payment FOR EACH ROW EXECUTE FUNCTION public.update_total_received();


--
-- TOC entry 4981 (class 2620 OID 26512)
-- Name: complet_lessons update_price_id_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_price_id_trigger AFTER INSERT OR UPDATE ON public.complet_lessons FOR EACH ROW EXECUTE FUNCTION public.update_price_id();


--
-- TOC entry 4924 (class 2606 OID 17384)
-- Name: persons address_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT address_fk FOREIGN KEY (address_id) REFERENCES public.address(address_id) NOT VALID;


--
-- TOC entry 4921 (class 2606 OID 16703)
-- Name: student address_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT address_id FOREIGN KEY (address_id) REFERENCES public.address(address_id) NOT VALID;


--
-- TOC entry 4930 (class 2606 OID 16730)
-- Name: instructor address_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT address_id_fk FOREIGN KEY (address_id) REFERENCES public.address(address_id) NOT VALID;


--
-- TOC entry 4919 (class 2606 OID 16559)
-- Name: mus_instruments brand_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments
    ADD CONSTRAINT brand_id_fk FOREIGN KEY (brand_id) REFERENCES public.brands(brand_id) NOT VALID;


--
-- TOC entry 4931 (class 2606 OID 17269)
-- Name: instructor contact_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT contact_fk FOREIGN KEY (contact_id) REFERENCES public.contact_detail(contact_id) NOT VALID;


--
-- TOC entry 4925 (class 2606 OID 17379)
-- Name: persons contact_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT contact_fk FOREIGN KEY (contact_id) REFERENCES public.contact_detail(contact_id) NOT VALID;


--
-- TOC entry 4922 (class 2606 OID 16888)
-- Name: student details_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT details_fk FOREIGN KEY (details_id) REFERENCES public.contact_detail(contact_id) NOT VALID;


--
-- TOC entry 4973 (class 2606 OID 17535)
-- Name: actual_seats_ensemble ensemble_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_ensemble
    ADD CONSTRAINT ensemble_fk FOREIGN KEY (reserv_id) REFERENCES public.ensemble(ensem_id) NOT VALID;


--
-- TOC entry 4941 (class 2606 OID 17025)
-- Name: ensemble ensembles_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT ensembles_fk FOREIGN KEY (ensembles_id) REFERENCES public.ensemble_genre(ensembles_id);


--
-- TOC entry 4974 (class 2606 OID 17548)
-- Name: actual_seats_group group_lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_group
    ADD CONSTRAINT group_lessons_fk FOREIGN KEY (group_lessons_id) REFERENCES public.group_lessons(grouplesson_id) NOT VALID;


--
-- TOC entry 4932 (class 2606 OID 17285)
-- Name: hold_instrument inst_stud_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT inst_stud_fk FOREIGN KEY (inst_stud_id) REFERENCES public.instructor(instruktor_numb) NOT VALID;


--
-- TOC entry 4933 (class 2606 OID 17290)
-- Name: hold_instrument inst_stud_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT inst_stud_fk2 FOREIGN KEY (inst_stud_id) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4936 (class 2606 OID 16964)
-- Name: booking_individual instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb) NOT VALID;


--
-- TOC entry 4942 (class 2606 OID 17030)
-- Name: ensemble instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb);


--
-- TOC entry 4948 (class 2606 OID 17098)
-- Name: group_lessons instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb) NOT VALID;


--
-- TOC entry 4960 (class 2606 OID 17349)
-- Name: complet_lessons instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb);


--
-- TOC entry 4970 (class 2606 OID 17476)
-- Name: instructor_payment instruktor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT instruktor_fk FOREIGN KEY (instruktor_numb) REFERENCES public.instructor(instruktor_numb);


--
-- TOC entry 4955 (class 2606 OID 17160)
-- Name: renting_instruments instrum_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT instrum_fk FOREIGN KEY (instrum_id) REFERENCES public.mus_instruments(instrument_id);


--
-- TOC entry 4937 (class 2606 OID 16949)
-- Name: booking_individual instrument_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT instrument_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4949 (class 2606 OID 17088)
-- Name: group_lessons instrument_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT instrument_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4975 (class 2606 OID 17571)
-- Name: conditions instrument_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT instrument_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4934 (class 2606 OID 16921)
-- Name: hold_instrument instrument_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT instrument_id_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id);


--
-- TOC entry 4917 (class 2606 OID 16489)
-- Name: attend_student instrument_idfk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student
    ADD CONSTRAINT instrument_idfk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4938 (class 2606 OID 16954)
-- Name: booking_individual lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id) NOT VALID;


--
-- TOC entry 4943 (class 2606 OID 17035)
-- Name: ensemble lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4950 (class 2606 OID 17093)
-- Name: group_lessons lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id) NOT VALID;


--
-- TOC entry 4958 (class 2606 OID 17394)
-- Name: price lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id) NOT VALID;


--
-- TOC entry 4966 (class 2606 OID 17442)
-- Name: student_payment lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4971 (class 2606 OID 17481)
-- Name: instructor_payment lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4961 (class 2606 OID 17354)
-- Name: complet_lessons lessons_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT lessons_id FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4935 (class 2606 OID 16931)
-- Name: hold_instrument level_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT level_fk FOREIGN KEY (level_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4939 (class 2606 OID 16959)
-- Name: booking_individual level_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT level_fk FOREIGN KEY (level_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4918 (class 2606 OID 16494)
-- Name: attend_student level_idfk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student
    ADD CONSTRAINT level_idfk FOREIGN KEY (level_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4959 (class 2606 OID 17399)
-- Name: price levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4962 (class 2606 OID 17404)
-- Name: complet_lessons levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4967 (class 2606 OID 17447)
-- Name: student_payment levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id);


--
-- TOC entry 4972 (class 2606 OID 17486)
-- Name: instructor_payment levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id);


--
-- TOC entry 4951 (class 2606 OID 17083)
-- Name: group_lessons max_places_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT max_places_fk FOREIGN KEY (max_places_id) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4944 (class 2606 OID 17055)
-- Name: ensemble max_students_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT max_students_fk FOREIGN KEY (max_students) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4952 (class 2606 OID 17078)
-- Name: group_lessons min_places_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT min_places_fk FOREIGN KEY (min_places_id) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4945 (class 2606 OID 17050)
-- Name: ensemble min_students_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT min_students_fk FOREIGN KEY (min_students) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4923 (class 2606 OID 16883)
-- Name: student person_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT person_fk FOREIGN KEY (person_id) REFERENCES public.persons(person_id) NOT VALID;


--
-- TOC entry 4928 (class 2606 OID 16725)
-- Name: sibling person_sibling_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sibling
    ADD CONSTRAINT person_sibling_id_fk FOREIGN KEY (person_sibling) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4977 (class 2606 OID 17630)
-- Name: personin personin_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin
    ADD CONSTRAINT personin_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id);


--
-- TOC entry 4978 (class 2606 OID 17635)
-- Name: personin personin_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin
    ADD CONSTRAINT personin_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.contact_detail(contact_id);


--
-- TOC entry 4963 (class 2606 OID 17359)
-- Name: complet_lessons price_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT price_fk FOREIGN KEY (price_id) REFERENCES public.price(price_id);


--
-- TOC entry 4956 (class 2606 OID 17414)
-- Name: renting_instruments price_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT price_fk FOREIGN KEY (price_id) REFERENCES public.price(price_id) NOT VALID;


--
-- TOC entry 4968 (class 2606 OID 17452)
-- Name: student_payment price_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT price_fk FOREIGN KEY (price_id) REFERENCES public.price(price_id);


--
-- TOC entry 4926 (class 2606 OID 17389)
-- Name: persons relativ_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT relativ_fk FOREIGN KEY (relativ_id) REFERENCES public.relatives(relativ_id) NOT VALID;


--
-- TOC entry 4964 (class 2606 OID 17364)
-- Name: complet_lessons slot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT slot_fk FOREIGN KEY (slot_id) REFERENCES public.time_slot(time_slot_id);


--
-- TOC entry 4976 (class 2606 OID 17576)
-- Name: conditions storage_places_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT storage_places_fk FOREIGN KEY (storage_places_id) REFERENCES public.storage_places(place_id) NOT VALID;


--
-- TOC entry 4940 (class 2606 OID 16944)
-- Name: booking_individual student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT student_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4957 (class 2606 OID 17170)
-- Name: renting_instruments student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT student_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb);


--
-- TOC entry 4965 (class 2606 OID 17369)
-- Name: complet_lessons student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT student_fk FOREIGN KEY (student_id) REFERENCES public.student(student_numb);


--
-- TOC entry 4969 (class 2606 OID 17462)
-- Name: student_payment student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT student_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb);


--
-- TOC entry 4929 (class 2606 OID 16720)
-- Name: sibling student_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sibling
    ADD CONSTRAINT student_numb_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4927 (class 2606 OID 17374)
-- Name: persons student_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT student_numb_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4946 (class 2606 OID 17045)
-- Name: ensemble students_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT students_numb_fk FOREIGN KEY (students_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4953 (class 2606 OID 17068)
-- Name: group_lessons students_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT students_numb_fk FOREIGN KEY (students_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4947 (class 2606 OID 17040)
-- Name: ensemble time_slot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT time_slot_fk FOREIGN KEY (time_slot_id) REFERENCES public.time_slot(time_slot_id);


--
-- TOC entry 4954 (class 2606 OID 17073)
-- Name: group_lessons time_slot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT time_slot_fk FOREIGN KEY (time_slot_id) REFERENCES public.time_slot(time_slot_id) NOT VALID;


--
-- TOC entry 4920 (class 2606 OID 16564)
-- Name: mus_instruments type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments
    ADD CONSTRAINT type_id_fk FOREIGN KEY (type_id) REFERENCES public.types_instruments(type_id) NOT VALID;


-- Completed on 2024-12-11 22:30:57

--
-- PostgreSQL database dump complete
--

