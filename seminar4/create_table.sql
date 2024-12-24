--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2024-12-24 20:58:21

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
-- TOC entry 301 (class 1255 OID 26762)
-- Name: renting_check2(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.renting_check2() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    active_rentals_count INT;
BEGIN
    -- Only check the active rentals for new insertions, not updates
    IF TG_OP = 'INSERT' THEN
        -- Calculate the number of active rentals for a new instrument
        SELECT COUNT(*) INTO active_rentals_count
        FROM renting_instruments
        WHERE instrum_id = NEW.instrum_id
        AND (period_end IS NULL OR period_end >= CURRENT_DATE);  -- Consider only active rentals

        -- Check limit: if there are already 2 active rentals, raise an exception
        IF active_rentals_count >= 2 THEN
            RAISE EXCEPTION 'You need to specify the number of musical instruments from 0 to 2';
        END IF;
    END IF;

    RETURN NEW;
END;

$$;


ALTER FUNCTION public.renting_check2() OWNER TO postgres;

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
-- TOC entry 5137 (class 0 OID 0)
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
-- TOC entry 5138 (class 0 OID 0)
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
-- TOC entry 5139 (class 0 OID 0)
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
-- TOC entry 5140 (class 0 OID 0)
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
-- TOC entry 5141 (class 0 OID 0)
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
-- TOC entry 5142 (class 0 OID 0)
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
-- TOC entry 5143 (class 0 OID 0)
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
-- TOC entry 5144 (class 0 OID 0)
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
-- TOC entry 5145 (class 0 OID 0)
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
-- TOC entry 5146 (class 0 OID 0)
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
-- TOC entry 5147 (class 0 OID 0)
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
-- TOC entry 5148 (class 0 OID 0)
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
-- TOC entry 5149 (class 0 OID 0)
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
-- TOC entry 5150 (class 0 OID 0)
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
-- TOC entry 5151 (class 0 OID 0)
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
-- TOC entry 5152 (class 0 OID 0)
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
-- TOC entry 5153 (class 0 OID 0)
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
-- TOC entry 5154 (class 0 OID 0)
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
-- TOC entry 5155 (class 0 OID 0)
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
-- TOC entry 5156 (class 0 OID 0)
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
-- TOC entry 5157 (class 0 OID 0)
-- Dependencies: 225
-- Name: types_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.types_type_id_seq OWNED BY public.types_instruments.type_id;


--
-- TOC entry 4828 (class 2604 OID 25167)
-- Name: address address_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address ALTER COLUMN address_id SET DEFAULT nextval('public.address_address_id_seq'::regclass);


--
-- TOC entry 4826 (class 2604 OID 25168)
-- Name: attend_student attend_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student ALTER COLUMN attend_id SET DEFAULT nextval('public.app_attend_app_id_seq'::regclass);


--
-- TOC entry 4824 (class 2604 OID 25169)
-- Name: brands brand_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands ALTER COLUMN brand_id SET DEFAULT nextval('public.brands_brand_id_seq'::regclass);


--
-- TOC entry 4849 (class 2604 OID 25170)
-- Name: conditions condition_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions ALTER COLUMN condition_id SET DEFAULT nextval('public.conditions_condition_id_seq'::regclass);


--
-- TOC entry 4836 (class 2604 OID 25171)
-- Name: contact_detail contact_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_detail ALTER COLUMN contact_id SET DEFAULT nextval('public.contactsdetail_contactdet_id_seq'::regclass);


--
-- TOC entry 4823 (class 2604 OID 25172)
-- Name: ensemble_genre ensembles_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble_genre ALTER COLUMN ensembles_id SET DEFAULT nextval('public.ensembles_ensembles_id_seq'::regclass);


--
-- TOC entry 4851 (class 2604 OID 26502)
-- Name: historical_lessons lesson_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historical_lessons ALTER COLUMN lesson_id SET DEFAULT nextval('public.historical_lessons_lesson_id_seq'::regclass);


--
-- TOC entry 4831 (class 2604 OID 25173)
-- Name: instructor instruktor_numb; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor ALTER COLUMN instruktor_numb SET DEFAULT nextval('public.instructor_instruktor_numb_seq'::regclass);


--
-- TOC entry 4833 (class 2604 OID 25174)
-- Name: invitations invitation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitations ALTER COLUMN invitation_id SET DEFAULT nextval('public.invitations_invitation_id_seq'::regclass);


--
-- TOC entry 4822 (class 2604 OID 25175)
-- Name: lessons lessons_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons ALTER COLUMN lessons_id SET DEFAULT nextval('public.lessons_lessons_id_seq'::regclass);


--
-- TOC entry 4821 (class 2604 OID 25176)
-- Name: levels level_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels ALTER COLUMN level_id SET DEFAULT nextval('public.levels_level_id_seq'::regclass);


--
-- TOC entry 4827 (class 2604 OID 25177)
-- Name: mus_instruments instrument_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments ALTER COLUMN instrument_id SET DEFAULT nextval('public.mus_instruments_instrument_id_seq'::regclass);


--
-- TOC entry 4834 (class 2604 OID 25178)
-- Name: numb_places place_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.numb_places ALTER COLUMN place_id SET DEFAULT nextval('public.maxsimum_places_max_id_seq'::regclass);


--
-- TOC entry 4850 (class 2604 OID 25179)
-- Name: personin person_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin ALTER COLUMN person_id SET DEFAULT nextval('public.personin_person_id_seq'::regclass);


--
-- TOC entry 4830 (class 2604 OID 25180)
-- Name: persons person_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons ALTER COLUMN person_id SET DEFAULT nextval('public.person_contact_person_id_seq'::regclass);


--
-- TOC entry 4835 (class 2604 OID 25181)
-- Name: relatives relativ_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relatives ALTER COLUMN relativ_id SET DEFAULT nextval('public.relatives_relativ_id_seq'::regclass);


--
-- TOC entry 4848 (class 2604 OID 25182)
-- Name: storage_places place_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storage_places ALTER COLUMN place_id SET DEFAULT nextval('public.storage_places_place_id_seq'::regclass);


--
-- TOC entry 4829 (class 2604 OID 25183)
-- Name: student student_numb; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student ALTER COLUMN student_numb SET DEFAULT nextval('public.student_student_id_seq'::regclass);


--
-- TOC entry 4832 (class 2604 OID 25184)
-- Name: time_slot time_slot_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_slot ALTER COLUMN time_slot_id SET DEFAULT nextval('public.time_slot_slot_id_seq'::regclass);


--
-- TOC entry 4825 (class 2604 OID 25185)
-- Name: types_instruments type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_instruments ALTER COLUMN type_id SET DEFAULT nextval('public.types_type_id_seq'::regclass);


--
-- TOC entry 4867 (class 2606 OID 16512)
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);


--
-- TOC entry 4899 (class 2606 OID 17348)
-- Name: complet_lessons admin_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT admin_staff_pkey PRIMARY KEY (admin_id);


--
-- TOC entry 4863 (class 2606 OID 16484)
-- Name: attend_student app_attend_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student
    ADD CONSTRAINT app_attend_pkey PRIMARY KEY (attend_id);


--
-- TOC entry 4889 (class 2606 OID 16943)
-- Name: booking_individual booking_individual_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT booking_individual_pkey PRIMARY KEY (indiv_id);


--
-- TOC entry 4859 (class 2606 OID 16453)
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (brand_id);


--
-- TOC entry 4911 (class 2606 OID 17570)
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (condition_id);


--
-- TOC entry 4885 (class 2606 OID 16870)
-- Name: contact_detail contactsdetail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_detail
    ADD CONSTRAINT contactsdetail_pkey PRIMARY KEY (contact_id);


--
-- TOC entry 4891 (class 2606 OID 17024)
-- Name: ensemble ensemble_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT ensemble_pkey PRIMARY KEY (ensem_id);


--
-- TOC entry 4857 (class 2606 OID 16446)
-- Name: ensemble_genre ensembles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble_genre
    ADD CONSTRAINT ensembles_pkey PRIMARY KEY (ensembles_id);


--
-- TOC entry 4893 (class 2606 OID 17067)
-- Name: group_lessons group_lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT group_lessons_pkey PRIMARY KEY (grouplesson_id);


--
-- TOC entry 4915 (class 2606 OID 26504)
-- Name: historical_lessons historical_lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historical_lessons
    ADD CONSTRAINT historical_lessons_pkey PRIMARY KEY (lesson_id);


--
-- TOC entry 4887 (class 2606 OID 16920)
-- Name: hold_instrument hold_instrument_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT hold_instrument_pkey PRIMARY KEY (hold_id);


--
-- TOC entry 4903 (class 2606 OID 17475)
-- Name: instructor_payment instructor_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT instructor_payment_pkey PRIMARY KEY (ins_payment_id);


--
-- TOC entry 4875 (class 2606 OID 16600)
-- Name: instructor instructor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT instructor_pkey PRIMARY KEY (instruktor_numb);


--
-- TOC entry 4879 (class 2606 OID 16631)
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (invitation_id);


--
-- TOC entry 4855 (class 2606 OID 16439)
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (lessons_id);


--
-- TOC entry 4853 (class 2606 OID 16432)
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (level_id);


--
-- TOC entry 4881 (class 2606 OID 16652)
-- Name: numb_places maxsimum_places_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.numb_places
    ADD CONSTRAINT maxsimum_places_pkey PRIMARY KEY (place_id);


--
-- TOC entry 4865 (class 2606 OID 16471)
-- Name: mus_instruments mus_instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments
    ADD CONSTRAINT mus_instruments_pkey PRIMARY KEY (instrument_id);


--
-- TOC entry 4913 (class 2606 OID 17629)
-- Name: personin personin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin
    ADD CONSTRAINT personin_pkey PRIMARY KEY (person_id);


--
-- TOC entry 4871 (class 2606 OID 16882)
-- Name: persons persons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT persons_pkey PRIMARY KEY (person_id);


--
-- TOC entry 4897 (class 2606 OID 17338)
-- Name: price price_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_pkey PRIMARY KEY (price_id);


--
-- TOC entry 4883 (class 2606 OID 16824)
-- Name: relatives relatives_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relatives
    ADD CONSTRAINT relatives_pkey PRIMARY KEY (relativ_id);


--
-- TOC entry 4895 (class 2606 OID 17159)
-- Name: renting_instruments renting_instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT renting_instruments_pkey PRIMARY KEY (renting_id);


--
-- TOC entry 4907 (class 2606 OID 17545)
-- Name: actual_seats_group reservat_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_group
    ADD CONSTRAINT reservat_group_pkey PRIMARY KEY (reserv_id);


--
-- TOC entry 4905 (class 2606 OID 17517)
-- Name: actual_seats_ensemble reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_ensemble
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (reserv_id);


--
-- TOC entry 4873 (class 2606 OID 17584)
-- Name: sibling sibling_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sibling
    ADD CONSTRAINT sibling_pkey PRIMARY KEY (student_numb, person_sibling);


--
-- TOC entry 4909 (class 2606 OID 17561)
-- Name: storage_places storage_places_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storage_places
    ADD CONSTRAINT storage_places_pkey PRIMARY KEY (place_id);


--
-- TOC entry 4901 (class 2606 OID 17441)
-- Name: student_payment student_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT student_payment_pkey PRIMARY KEY (st_payment_id);


--
-- TOC entry 4869 (class 2606 OID 16577)
-- Name: student student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (student_numb);


--
-- TOC entry 4877 (class 2606 OID 16614)
-- Name: time_slot time_slot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_slot
    ADD CONSTRAINT time_slot_pkey PRIMARY KEY (time_slot_id);


--
-- TOC entry 4861 (class 2606 OID 16425)
-- Name: types_instruments types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_instruments
    ADD CONSTRAINT types_pkey PRIMARY KEY (type_id);


--
-- TOC entry 5131 (class 2618 OID 26530)
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
-- TOC entry 4978 (class 2620 OID 26497)
-- Name: renting_instruments rental_duration_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rental_duration_check BEFORE INSERT OR UPDATE ON public.renting_instruments FOR EACH ROW EXECUTE FUNCTION public.check_rental_duration();


--
-- TOC entry 4979 (class 2620 OID 26763)
-- Name: renting_instruments renting_check2; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER renting_check2 BEFORE INSERT OR UPDATE ON public.renting_instruments FOR EACH ROW EXECUTE FUNCTION public.renting_check2();


--
-- TOC entry 4981 (class 2620 OID 25933)
-- Name: student_payment trg_update_total_paid; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_total_paid BEFORE INSERT OR UPDATE ON public.student_payment FOR EACH ROW EXECUTE FUNCTION public.update_total_paid();


--
-- TOC entry 4982 (class 2620 OID 25935)
-- Name: instructor_payment trg_update_total_received; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_total_received BEFORE INSERT OR UPDATE ON public.instructor_payment FOR EACH ROW EXECUTE FUNCTION public.update_total_received();


--
-- TOC entry 4980 (class 2620 OID 26512)
-- Name: complet_lessons update_price_id_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_price_id_trigger AFTER INSERT OR UPDATE ON public.complet_lessons FOR EACH ROW EXECUTE FUNCTION public.update_price_id();


--
-- TOC entry 4923 (class 2606 OID 17384)
-- Name: persons address_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT address_fk FOREIGN KEY (address_id) REFERENCES public.address(address_id) NOT VALID;


--
-- TOC entry 4920 (class 2606 OID 16703)
-- Name: student address_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT address_id FOREIGN KEY (address_id) REFERENCES public.address(address_id) NOT VALID;


--
-- TOC entry 4929 (class 2606 OID 16730)
-- Name: instructor address_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT address_id_fk FOREIGN KEY (address_id) REFERENCES public.address(address_id) NOT VALID;


--
-- TOC entry 4918 (class 2606 OID 16559)
-- Name: mus_instruments brand_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments
    ADD CONSTRAINT brand_id_fk FOREIGN KEY (brand_id) REFERENCES public.brands(brand_id) NOT VALID;


--
-- TOC entry 4930 (class 2606 OID 17269)
-- Name: instructor contact_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT contact_fk FOREIGN KEY (contact_id) REFERENCES public.contact_detail(contact_id) NOT VALID;


--
-- TOC entry 4924 (class 2606 OID 17379)
-- Name: persons contact_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT contact_fk FOREIGN KEY (contact_id) REFERENCES public.contact_detail(contact_id) NOT VALID;


--
-- TOC entry 4921 (class 2606 OID 16888)
-- Name: student details_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT details_fk FOREIGN KEY (details_id) REFERENCES public.contact_detail(contact_id) NOT VALID;


--
-- TOC entry 4972 (class 2606 OID 17535)
-- Name: actual_seats_ensemble ensemble_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_ensemble
    ADD CONSTRAINT ensemble_fk FOREIGN KEY (reserv_id) REFERENCES public.ensemble(ensem_id) NOT VALID;


--
-- TOC entry 4940 (class 2606 OID 17025)
-- Name: ensemble ensembles_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT ensembles_fk FOREIGN KEY (ensembles_id) REFERENCES public.ensemble_genre(ensembles_id);


--
-- TOC entry 4973 (class 2606 OID 17548)
-- Name: actual_seats_group group_lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_group
    ADD CONSTRAINT group_lessons_fk FOREIGN KEY (group_lessons_id) REFERENCES public.group_lessons(grouplesson_id) NOT VALID;


--
-- TOC entry 4931 (class 2606 OID 17285)
-- Name: hold_instrument inst_stud_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT inst_stud_fk FOREIGN KEY (inst_stud_id) REFERENCES public.instructor(instruktor_numb) NOT VALID;


--
-- TOC entry 4932 (class 2606 OID 17290)
-- Name: hold_instrument inst_stud_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT inst_stud_fk2 FOREIGN KEY (inst_stud_id) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4935 (class 2606 OID 16964)
-- Name: booking_individual instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb) NOT VALID;


--
-- TOC entry 4941 (class 2606 OID 17030)
-- Name: ensemble instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb);


--
-- TOC entry 4947 (class 2606 OID 17098)
-- Name: group_lessons instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb) NOT VALID;


--
-- TOC entry 4959 (class 2606 OID 17349)
-- Name: complet_lessons instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb);


--
-- TOC entry 4969 (class 2606 OID 17476)
-- Name: instructor_payment instruktor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT instruktor_fk FOREIGN KEY (instruktor_numb) REFERENCES public.instructor(instruktor_numb);


--
-- TOC entry 4954 (class 2606 OID 17160)
-- Name: renting_instruments instrum_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT instrum_fk FOREIGN KEY (instrum_id) REFERENCES public.mus_instruments(instrument_id);


--
-- TOC entry 4936 (class 2606 OID 16949)
-- Name: booking_individual instrument_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT instrument_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4948 (class 2606 OID 17088)
-- Name: group_lessons instrument_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT instrument_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4974 (class 2606 OID 17571)
-- Name: conditions instrument_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT instrument_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4933 (class 2606 OID 16921)
-- Name: hold_instrument instrument_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT instrument_id_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id);


--
-- TOC entry 4916 (class 2606 OID 16489)
-- Name: attend_student instrument_idfk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student
    ADD CONSTRAINT instrument_idfk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4937 (class 2606 OID 16954)
-- Name: booking_individual lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id) NOT VALID;


--
-- TOC entry 4942 (class 2606 OID 17035)
-- Name: ensemble lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4949 (class 2606 OID 17093)
-- Name: group_lessons lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id) NOT VALID;


--
-- TOC entry 4957 (class 2606 OID 17394)
-- Name: price lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id) NOT VALID;


--
-- TOC entry 4965 (class 2606 OID 17442)
-- Name: student_payment lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4970 (class 2606 OID 17481)
-- Name: instructor_payment lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4960 (class 2606 OID 17354)
-- Name: complet_lessons lessons_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT lessons_id FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4934 (class 2606 OID 16931)
-- Name: hold_instrument level_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT level_fk FOREIGN KEY (level_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4938 (class 2606 OID 16959)
-- Name: booking_individual level_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT level_fk FOREIGN KEY (level_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4917 (class 2606 OID 16494)
-- Name: attend_student level_idfk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student
    ADD CONSTRAINT level_idfk FOREIGN KEY (level_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4958 (class 2606 OID 17399)
-- Name: price levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4961 (class 2606 OID 17404)
-- Name: complet_lessons levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4966 (class 2606 OID 17447)
-- Name: student_payment levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id);


--
-- TOC entry 4971 (class 2606 OID 17486)
-- Name: instructor_payment levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id);


--
-- TOC entry 4950 (class 2606 OID 17083)
-- Name: group_lessons max_places_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT max_places_fk FOREIGN KEY (max_places_id) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4943 (class 2606 OID 17055)
-- Name: ensemble max_students_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT max_students_fk FOREIGN KEY (max_students) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4951 (class 2606 OID 17078)
-- Name: group_lessons min_places_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT min_places_fk FOREIGN KEY (min_places_id) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4944 (class 2606 OID 17050)
-- Name: ensemble min_students_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT min_students_fk FOREIGN KEY (min_students) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4922 (class 2606 OID 16883)
-- Name: student person_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT person_fk FOREIGN KEY (person_id) REFERENCES public.persons(person_id) NOT VALID;


--
-- TOC entry 4927 (class 2606 OID 16725)
-- Name: sibling person_sibling_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sibling
    ADD CONSTRAINT person_sibling_id_fk FOREIGN KEY (person_sibling) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4976 (class 2606 OID 17630)
-- Name: personin personin_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin
    ADD CONSTRAINT personin_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id);


--
-- TOC entry 4977 (class 2606 OID 17635)
-- Name: personin personin_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin
    ADD CONSTRAINT personin_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.contact_detail(contact_id);


--
-- TOC entry 4962 (class 2606 OID 17359)
-- Name: complet_lessons price_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT price_fk FOREIGN KEY (price_id) REFERENCES public.price(price_id);


--
-- TOC entry 4955 (class 2606 OID 17414)
-- Name: renting_instruments price_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT price_fk FOREIGN KEY (price_id) REFERENCES public.price(price_id) NOT VALID;


--
-- TOC entry 4967 (class 2606 OID 17452)
-- Name: student_payment price_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT price_fk FOREIGN KEY (price_id) REFERENCES public.price(price_id);


--
-- TOC entry 4925 (class 2606 OID 17389)
-- Name: persons relativ_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT relativ_fk FOREIGN KEY (relativ_id) REFERENCES public.relatives(relativ_id) NOT VALID;


--
-- TOC entry 4963 (class 2606 OID 17364)
-- Name: complet_lessons slot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT slot_fk FOREIGN KEY (slot_id) REFERENCES public.time_slot(time_slot_id);


--
-- TOC entry 4975 (class 2606 OID 17576)
-- Name: conditions storage_places_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT storage_places_fk FOREIGN KEY (storage_places_id) REFERENCES public.storage_places(place_id) NOT VALID;


--
-- TOC entry 4939 (class 2606 OID 16944)
-- Name: booking_individual student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT student_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4956 (class 2606 OID 17170)
-- Name: renting_instruments student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT student_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb);


--
-- TOC entry 4964 (class 2606 OID 17369)
-- Name: complet_lessons student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT student_fk FOREIGN KEY (student_id) REFERENCES public.student(student_numb);


--
-- TOC entry 4968 (class 2606 OID 17462)
-- Name: student_payment student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT student_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb);


--
-- TOC entry 4928 (class 2606 OID 16720)
-- Name: sibling student_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sibling
    ADD CONSTRAINT student_numb_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4926 (class 2606 OID 17374)
-- Name: persons student_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT student_numb_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4945 (class 2606 OID 17045)
-- Name: ensemble students_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT students_numb_fk FOREIGN KEY (students_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4952 (class 2606 OID 17068)
-- Name: group_lessons students_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT students_numb_fk FOREIGN KEY (students_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4946 (class 2606 OID 17040)
-- Name: ensemble time_slot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT time_slot_fk FOREIGN KEY (time_slot_id) REFERENCES public.time_slot(time_slot_id);


--
-- TOC entry 4953 (class 2606 OID 17073)
-- Name: group_lessons time_slot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT time_slot_fk FOREIGN KEY (time_slot_id) REFERENCES public.time_slot(time_slot_id) NOT VALID;


--
-- TOC entry 4919 (class 2606 OID 16564)
-- Name: mus_instruments type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments
    ADD CONSTRAINT type_id_fk FOREIGN KEY (type_id) REFERENCES public.types_instruments(type_id) NOT VALID;


-- Completed on 2024-12-24 20:58:22

--
-- PostgreSQL database dump complete
--

