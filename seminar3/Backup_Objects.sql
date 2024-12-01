--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2024-12-01 21:13:02

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
-- TOC entry 5165 (class 0 OID 0)
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
-- TOC entry 5166 (class 0 OID 0)
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
-- TOC entry 5167 (class 0 OID 0)
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
-- TOC entry 5168 (class 0 OID 0)
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
-- TOC entry 5169 (class 0 OID 0)
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
-- TOC entry 5170 (class 0 OID 0)
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
-- TOC entry 5171 (class 0 OID 0)
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
-- TOC entry 5172 (class 0 OID 0)
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
-- TOC entry 5173 (class 0 OID 0)
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
-- TOC entry 5174 (class 0 OID 0)
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
-- TOC entry 5175 (class 0 OID 0)
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
-- TOC entry 5176 (class 0 OID 0)
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
-- TOC entry 5177 (class 0 OID 0)
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
-- TOC entry 5178 (class 0 OID 0)
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
-- TOC entry 5179 (class 0 OID 0)
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
-- TOC entry 5180 (class 0 OID 0)
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
-- TOC entry 5181 (class 0 OID 0)
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
-- TOC entry 5182 (class 0 OID 0)
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
-- TOC entry 5183 (class 0 OID 0)
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
-- TOC entry 5184 (class 0 OID 0)
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
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 225
-- Name: types_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.types_type_id_seq OWNED BY public.types_instruments.type_id;


--
-- TOC entry 4791 (class 2604 OID 25167)
-- Name: address address_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address ALTER COLUMN address_id SET DEFAULT nextval('public.address_address_id_seq'::regclass);


--
-- TOC entry 4789 (class 2604 OID 25168)
-- Name: attend_student attend_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student ALTER COLUMN attend_id SET DEFAULT nextval('public.app_attend_app_id_seq'::regclass);


--
-- TOC entry 4787 (class 2604 OID 25169)
-- Name: brands brand_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands ALTER COLUMN brand_id SET DEFAULT nextval('public.brands_brand_id_seq'::regclass);


--
-- TOC entry 4812 (class 2604 OID 25170)
-- Name: conditions condition_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions ALTER COLUMN condition_id SET DEFAULT nextval('public.conditions_condition_id_seq'::regclass);


--
-- TOC entry 4799 (class 2604 OID 25171)
-- Name: contact_detail contact_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_detail ALTER COLUMN contact_id SET DEFAULT nextval('public.contactsdetail_contactdet_id_seq'::regclass);


--
-- TOC entry 4786 (class 2604 OID 25172)
-- Name: ensemble_genre ensembles_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble_genre ALTER COLUMN ensembles_id SET DEFAULT nextval('public.ensembles_ensembles_id_seq'::regclass);


--
-- TOC entry 4814 (class 2604 OID 26502)
-- Name: historical_lessons lesson_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historical_lessons ALTER COLUMN lesson_id SET DEFAULT nextval('public.historical_lessons_lesson_id_seq'::regclass);


--
-- TOC entry 4794 (class 2604 OID 25173)
-- Name: instructor instruktor_numb; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor ALTER COLUMN instruktor_numb SET DEFAULT nextval('public.instructor_instruktor_numb_seq'::regclass);


--
-- TOC entry 4796 (class 2604 OID 25174)
-- Name: invitations invitation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitations ALTER COLUMN invitation_id SET DEFAULT nextval('public.invitations_invitation_id_seq'::regclass);


--
-- TOC entry 4785 (class 2604 OID 25175)
-- Name: lessons lessons_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons ALTER COLUMN lessons_id SET DEFAULT nextval('public.lessons_lessons_id_seq'::regclass);


--
-- TOC entry 4784 (class 2604 OID 25176)
-- Name: levels level_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels ALTER COLUMN level_id SET DEFAULT nextval('public.levels_level_id_seq'::regclass);


--
-- TOC entry 4790 (class 2604 OID 25177)
-- Name: mus_instruments instrument_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments ALTER COLUMN instrument_id SET DEFAULT nextval('public.mus_instruments_instrument_id_seq'::regclass);


--
-- TOC entry 4797 (class 2604 OID 25178)
-- Name: numb_places place_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.numb_places ALTER COLUMN place_id SET DEFAULT nextval('public.maxsimum_places_max_id_seq'::regclass);


--
-- TOC entry 4813 (class 2604 OID 25179)
-- Name: personin person_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin ALTER COLUMN person_id SET DEFAULT nextval('public.personin_person_id_seq'::regclass);


--
-- TOC entry 4793 (class 2604 OID 25180)
-- Name: persons person_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons ALTER COLUMN person_id SET DEFAULT nextval('public.person_contact_person_id_seq'::regclass);


--
-- TOC entry 4798 (class 2604 OID 25181)
-- Name: relatives relativ_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relatives ALTER COLUMN relativ_id SET DEFAULT nextval('public.relatives_relativ_id_seq'::regclass);


--
-- TOC entry 4811 (class 2604 OID 25182)
-- Name: storage_places place_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storage_places ALTER COLUMN place_id SET DEFAULT nextval('public.storage_places_place_id_seq'::regclass);


--
-- TOC entry 4792 (class 2604 OID 25183)
-- Name: student student_numb; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student ALTER COLUMN student_numb SET DEFAULT nextval('public.student_student_id_seq'::regclass);


--
-- TOC entry 4795 (class 2604 OID 25184)
-- Name: time_slot time_slot_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_slot ALTER COLUMN time_slot_id SET DEFAULT nextval('public.time_slot_slot_id_seq'::regclass);


--
-- TOC entry 4788 (class 2604 OID 25185)
-- Name: types_instruments type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_instruments ALTER COLUMN type_id SET DEFAULT nextval('public.types_type_id_seq'::regclass);


--
-- TOC entry 5148 (class 0 OID 17512)
-- Dependencies: 270
-- Data for Name: actual_seats_ensemble; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.actual_seats_ensemble (reserv_id, ensemble_id, actual_seats) FROM stdin;
1	1	9
2	2	8
3	3	4
4	4	9
5	5	3
6	6	5
7	7	2
8	8	7
9	9	6
10	10	9
11	11	8
12	12	9
13	13	5
14	14	5
15	15	3
16	16	5
17	17	3
18	18	7
19	19	2
20	20	5
\.


--
-- TOC entry 5149 (class 0 OID 17540)
-- Dependencies: 271
-- Data for Name: actual_seats_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.actual_seats_group (reserv_id, group_lessons_id, actual_seats) FROM stdin;
1	1	9
2	2	8
3	3	4
4	4	9
5	5	3
6	6	5
7	7	2
8	8	7
9	9	6
10	10	9
11	11	8
12	12	9
13	13	5
14	14	5
15	15	3
16	16	5
17	17	3
18	18	7
19	19	2
20	20	5
\.


--
-- TOC entry 5110 (class 0 OID 16507)
-- Dependencies: 232
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.address (address_id, postal_code, city, street, home, room) FROM stdin;
1	8351	Vladimir	P.O. Box 385, 892 Enim. Ave	55	101
2	5241447	Portland	1264 Suspendisse Street	30	8
3	3369	Balfour	Ap #981-2375 Vitae Rd.	36	183
4	7671	Tam dảo	Ap #875-6855 At Ave	70	156
5	221257621	Kettering	172-6634 Risus Avenue	52	47
6	464480	Dieppe	P.O. Box 961, 7719 Vulputate Rd.	65	78
7	18291	Montes Claros	5071 Amet Rd.	91	60
8	74026	Chuncheon	Ap #932-6217 Nonummy Ave	49	19
9	819151	Malakand	721 Quam. St.	55	4
10	6196	Lozova	Tellus. Ave	87	195
11	12354	Stockhom	Nibh. Av	1	46
12	99856	Stockhom	Egestas. St.	55	1
13	3457	Stockhom	Penatibus Rd. St.	34	15
14	6347	Stockhom	Metus Street	208	85
15	887533	Stockhom	9306 Dis Road	99	32
16	645673	Stockhom	Vulputate, Ave	345	976
17	453	Stockhom	Viverra. St.	7	6
18	238609	Stockhom	Tellus Road	9	111
\.


--
-- TOC entry 5106 (class 0 OID 16459)
-- Dependencies: 228
-- Data for Name: attend_student; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attend_student (attend_id, name, surname, telephone, e_mail, instrument_id, level_id) FROM stdin;
\.


--
-- TOC entry 5133 (class 0 OID 16938)
-- Dependencies: 255
-- Data for Name: booking_individual; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.booking_individual (indiv_id, student_numb, period_start, period_end, numb_lessons, instrument_id, lessons_id, level_id, instructor_id) FROM stdin;
1	100	2024-09-01	2004-09-30	10	2	1	1	1001
2	101	2024-09-01	2004-09-30	9	1	1	1	1003
3	102	2024-09-01	2004-09-30	11	3	1	1	1002
4	103	2024-09-10	2004-09-10	3	4	1	1	1004
5	103	2024-09-01	2004-09-30	5	4	1	1	1004
6	104	2024-09-01	2004-09-30	10	5	1	1	1000
7	105	2024-09-01	2004-09-30	4	6	1	2	1002
8	106	2024-09-01	2004-09-30	8	7	1	1	1001
9	107	2024-09-01	2004-09-30	9	8	1	2	1001
10	108	2024-09-01	2004-09-30	9	7	1	1	1001
11	109	2024-09-01	2004-09-30	4	1	1	2	1000
12	109	2024-09-01	2004-09-30	5	2	1	2	1001
13	100	2024-10-01	2004-10-31	6	2	1	1	1001
14	101	2024-10-01	2004-10-31	8	1	1	1	1003
15	102	2024-10-01	2004-10-31	9	3	1	1	1002
16	103	2024-10-10	2004-10-31	3	4	1	1	1004
17	104	2024-10-01	2004-10-31	5	5	1	1	1000
18	105	2024-10-01	2004-10-31	10	6	1	2	1002
19	106	2024-10-01	2004-10-31	13	7	1	1	1001
20	107	2024-10-01	2004-10-31	8	8	1	2	1001
21	108	2024-10-01	2004-10-31	9	7	1	1	1001
22	109	2024-10-01	2004-10-15	7	1	1	2	1000
23	109	2024-10-16	2004-10-31	5	2	1	2	1001
\.


--
-- TOC entry 5102 (class 0 OID 16410)
-- Dependencies: 224
-- Data for Name: brands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.brands (brand_id, brand) FROM stdin;
1	Gibson
2	Harman Professional
3	Shure
4	Yamaha
5	Fender Musical Instruments
6	Steinway Musical Instruments
7	Sennheiser
8	Roland
\.


--
-- TOC entry 5144 (class 0 OID 17341)
-- Dependencies: 266
-- Data for Name: complet_lessons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.complet_lessons (admin_id, lessons_id, levels_id, period_start, period_end, slot_id, student_id, instructor_id, note, price_id) FROM stdin;
109	1	1	2024-09-25	2024-09-26	3	102	1002	was carried out	9
110	1	1	2024-09-01	2024-09-30	1	104	1000	dfgh	3
9	1	1	2024-09-01	2024-09-01	3	100	1001	was carried out	9
1	3	0	2024-09-01	2024-09-01	1	100	1000	was carried out	9
35	1	1	2024-09-22	2024-09-22	3	102	1002	was carried out	9
36	1	1	2024-09-25	2024-09-25	3	102	1002	was carried out	9
37	1	1	2024-09-27	2024-09-27	3	102	1002	was carried out	9
38	1	1	2024-09-27	2024-09-27	3	102	1002	was carried out	9
39	1	1	2024-09-10	2024-09-10	4	103	1004	was carried out	9
40	1	1	2024-09-10	2024-09-10	5	103	1004	was carried out	9
41	1	1	2024-09-10	2024-09-10	6	103	1004	was carried out	9
42	1	1	2024-09-15	2024-09-15	4	103	1004	was carried out	9
43	1	1	2024-09-18	2024-09-18	4	103	1004	was carried out	9
44	1	1	2024-09-20	2024-09-20	4	103	1004	was carried out	9
45	1	1	2024-09-22	2024-09-22	4	103	1004	was carried out	9
46	1	1	2024-09-25	2024-09-25	4	103	1004	was carried out	9
47	1	1	2024-09-01	2024-09-01	7	104	1000	was carried out	9
48	1	1	2024-09-04	2024-09-04	5	104	1000	was carried out	9
49	1	1	2024-09-10	2024-09-10	5	104	1000	was carried out	9
50	1	1	2024-09-15	2024-09-15	5	104	1000	was carried out	9
51	1	1	2024-09-18	2024-09-18	5	104	1000	was carried out	9
52	1	1	2024-09-20	2024-09-20	5	104	1000	was carried out	9
53	1	1	2024-09-22	2024-09-22	5	104	1000	was carried out	9
54	1	1	2024-09-25	2024-09-25	5	104	1000	was carried out	9
55	1	1	2024-09-27	2024-09-27	5	104	1000	was carried out	9
56	1	1	2024-09-29	2024-09-29	5	104	1000	was carried out	9
57	1	2	2024-09-01	2024-09-01	8	105	1002	was carried out	9
58	1	2	2024-09-04	2024-09-04	6	105	1002	was carried out	9
59	1	2	2024-09-10	2024-09-10	6	105	1002	was carried out	9
60	1	2	2024-09-15	2024-09-15	6	105	1002	was carried out	9
61	1	1	2024-09-01	2024-09-01	9	106	1001	was carried out	9
62	1	1	2024-09-04	2024-09-04	7	106	1001	was carried out	9
63	1	1	2024-09-10	2024-09-10	7	106	1001	was carried out	9
64	1	1	2024-09-15	2024-09-15	7	106	1001	was carried out	9
65	1	1	2024-09-18	2024-09-18	7	106	1001	was carried out	9
66	1	1	2024-09-20	2024-09-20	7	106	1001	was carried out	9
67	1	1	2024-09-22	2024-09-22	7	106	1001	was carried out	9
68	1	1	2024-09-25	2024-09-25	7	106	1001	was carried out	9
69	1	2	2024-09-01	2024-09-01	10	107	1001	was carried out	9
70	1	2	2024-09-04	2024-09-04	8	107	1001	was carried out	9
71	1	2	2024-09-10	2024-09-10	8	107	1001	was carried out	9
72	1	2	2024-09-15	2024-09-15	8	107	1001	was carried out	9
73	1	2	2024-09-18	2024-09-18	8	107	1001	was carried out	9
74	1	2	2024-09-20	2024-09-20	8	107	1001	was carried out	9
75	1	2	2024-09-22	2024-09-22	8	107	1001	was carried out	9
76	1	2	2024-09-25	2024-09-25	8	107	1001	was carried out	9
77	1	2	2024-09-27	2024-09-27	8	107	1001	was carried out	9
78	1	1	2024-09-01	2024-09-01	11	108	1001	was carried out	9
79	1	1	2024-09-04	2024-09-04	9	108	1001	was carried out	9
80	1	1	2024-09-10	2024-09-10	9	108	1001	was carried out	9
81	1	1	2024-09-15	2024-09-15	9	108	1001	was carried out	9
82	1	1	2024-09-18	2024-09-18	9	108	1001	was carried out	9
83	1	1	2024-09-20	2024-09-20	9	108	1001	was carried out	9
84	1	1	2024-09-22	2024-09-22	9	108	1001	was carried out	9
85	1	1	2024-09-25	2024-09-25	9	108	1001	was carried out	9
86	1	1	2024-09-27	2024-09-27	9	108	1001	was carried out	9
87	1	2	2024-09-02	2024-09-02	1	109	1000	was carried out	9
2	3	0	2024-09-01	2024-09-01	1	101	1000	was carried out	9
3	3	0	2024-09-01	2024-09-01	1	102	1000	was carried out	9
4	3	0	2024-09-01	2024-09-01	1	103	1000	was carried out	9
5	2	0	2024-09-01	2024-09-01	2	100	1005	was carried out	9
6	2	0	2024-09-01	2024-09-01	2	101	1005	was carried out	9
7	2	0	2024-09-01	2024-09-01	2	102	1005	was carried out	9
8	2	0	2024-09-01	2024-09-01	2	103	1005	was carried out	9
10	1	1	2024-09-04	2024-09-04	1	100	1001	was carried out	9
11	1	1	2024-09-10	2024-09-10	1	100	1001	was carried out	9
12	1	1	2024-09-15	2024-09-15	1	100	1001	was carried out	9
13	1	1	2024-09-18	2024-09-18	1	100	1001	was carried out	9
14	1	1	2024-09-20	2024-09-20	1	100	1001	was carried out	9
15	1	1	2024-09-22	2024-09-22	1	100	1001	was carried out	9
16	1	1	2024-09-25	2024-09-25	1	100	1001	was carried out	9
17	1	1	2024-09-27	2024-09-27	1	100	1001	was carried out	9
18	1	1	2024-09-29	2024-09-29	1	100	1001	was carried out	9
19	1	1	2024-09-01	2024-09-01	4	101	1003	was carried out	9
20	1	1	2024-09-04	2024-09-04	2	101	1003	was carried out	9
21	1	1	2024-09-10	2024-09-10	2	101	1003	was carried out	9
22	1	1	2024-09-15	2024-09-15	2	101	1003	was carried out	9
23	1	1	2024-09-18	2024-09-18	2	101	1003	was carried out	9
24	1	1	2024-09-20	2024-09-20	2	101	1003	was carried out	9
25	1	1	2024-09-22	2024-09-22	2	101	1003	was carried out	9
26	1	1	2024-09-25	2024-09-25	2	101	1003	was carried out	9
27	1	1	2024-09-27	2024-09-27	2	101	1003	was carried out	9
28	1	1	2024-09-01	2024-09-01	5	102	1002	was carried out	9
29	1	1	2024-09-01	2024-09-01	6	102	1002	was carried out	9
30	1	1	2024-09-04	2024-09-04	3	102	1002	was carried out	9
31	1	1	2024-09-10	2024-09-10	3	102	1002	was carried out	9
32	1	1	2024-09-15	2024-09-15	3	102	1002	was carried out	9
33	1	1	2024-09-18	2024-09-18	3	102	1002	was carried out	9
34	1	1	2024-09-20	2024-09-20	3	102	1002	was carried out	9
88	1	2	2024-09-04	2024-09-04	9	109	1000	was carried out	9
89	1	2	2024-09-10	2024-09-10	9	109	1000	was carried out	9
90	1	2	2024-09-15	2024-09-15	9	109	1000	was carried out	9
91	1	2	2024-09-18	2024-09-18	9	109	1000	was carried out	9
92	1	2	2024-09-20	2024-09-20	9	109	1000	was carried out	9
93	1	2	2024-09-22	2024-09-22	9	109	1000	was carried out	9
94	1	2	2024-09-25	2024-09-25	9	109	1000	was carried out	9
95	1	2	2024-09-27	2024-09-27	9	109	1000	was carried out	9
96	3	0	2024-09-08	2024-09-08	2	104	1001	was carried out	9
97	3	0	2024-09-08	2024-09-08	2	105	1001	was carried out	9
98	3	0	2024-09-08	2024-09-08	2	106	1001	was carried out	9
99	3	0	2024-09-16	2024-09-16	3	107	1004	was carried out	9
100	3	0	2024-09-16	2024-09-16	3	108	1004	was carried out	9
101	3	0	2024-09-16	2024-09-16	3	109	1004	was carried out	9
102	2	0	2024-09-08	2024-09-08	3	104	1001	was carried out	9
103	2	0	2024-09-08	2024-09-08	3	105	1001	was carried out	9
104	2	0	2024-09-08	2024-09-08	3	106	1001	was carried out	9
105	2	0	2024-09-16	2024-09-16	4	107	1004	was carried out	9
106	2	0	2024-09-16	2024-09-16	4	108	1004	was carried out	9
107	2	0	2024-09-16	2024-09-16	4	109	1004	was carried out	9
108	3	1	2024-09-01	2024-09-02	1	100	1000	dfgh	9
\.


--
-- TOC entry 5154 (class 0 OID 17563)
-- Dependencies: 276
-- Data for Name: conditions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conditions (condition_id, instrument_id, data_start, data_end, storage_places_id, "unique serial number", cost) FROM stdin;
1	1	2024-09-01	2025-06-30	1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1000
2	2	2024-09-01	2024-12-31	1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12	50000
3	3	2024-09-01	2025-02-28	1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13	5000
4	3	2024-09-01	2025-02-28	1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14	5000
5	3	2024-09-01	2025-10-31	3	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15	5000
6	3	2024-09-01	2025-09-30	2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a16	5000
7	3	2024-09-01	2025-09-01	4	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a17	5000
8	3	2024-09-01	2025-12-01	2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a18	5000
9	2	2024-09-01	2025-12-31	2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a19	50000
\.


--
-- TOC entry 5128 (class 0 OID 16865)
-- Dependencies: 250
-- Data for Name: contact_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contact_detail (contact_id, telephone, e_mail) FROM stdin;
1	(205) 543-2518	venenatis.vel.faucibus@protonmail.com
2	(573) 214-0115	nunc@aol.com
3	1-518-618-4727	faucibus.orci@icloud.com
4	(748) 845-1422	sed.dolor@icloud.com
5	1-911-414-1024	pellentesque.massa.lobortis@icloud.ca
6	(614) 361-7317	commodo.ipsum.suspendisse@google.ca
7	1-317-718-4777	molestie.orci@hotmail.ca
8	1-745-878-0357	magna.sed.dui@hotmail.com
9	(310) 265-7931	vel.est@google.couk
10	1-625-358-2289	tincidunt.neque@yahoo.org
11	1-367-646-4810	penatibus.et@protonmail.couk
12	(212) 908-6557	tempus.eu@outlook.org
13	1-175-876-6642	fames.ac@hotmail.com
14	(+46) 265-885421	sed@google.com
15	(+10) 345-79781	amet.metus@aol.couk
16	(355) 707-6026	orci@icloud.ca
17	(718) 866-9733	tempor@hotmail.edu
18	(582) 607-8922	idrty@yahoo.edu
19	(+46) 346-3564	magna.cras@aol.edu
20	1-666-315-6032	elementum.dui@icloud.com
21	(236) 256-5121	egestas@outlook.org
22	1-214-662-8621	orrewci.adipiscing@hotmail.org
23	(495) 937-6437	ullamcorper.duis@outlook.ca
24	(666) 954-2361	mauris.suspendisse@yahoo.org
25	(161) 464-9536	lacinia.vitae@outlook.edu
26	(+46) 566-34655	uyew@outlook.edu
27	(+46) 456-23156	phasellus@protonmail.com
28	(+46) 642-33469	placerat.cras@hotmail.com
29	(+10) 097-98743	natoque@outlook.ca
30	(+10) 245-67423	enim@google.org
\.


--
-- TOC entry 5135 (class 0 OID 17019)
-- Dependencies: 257
-- Data for Name: ensemble; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ensemble (ensem_id, students_numb, ensembles_id, data_ensem, time_slot_id, min_students, max_students, lessons_id, instructor_id) FROM stdin;
1	100	1	2024-09-01	1	1	9	3	1000
2	101	1	2024-09-01	1	1	9	3	1000
3	102	1	2024-09-01	1	1	9	3	1000
4	103	1	2024-09-01	1	1	9	3	1000
5	104	2	2024-09-08	2	1	5	3	1001
6	105	2	2024-09-08	2	1	5	3	1001
7	106	2	2024-09-08	2	1	5	3	1001
8	107	3	2024-09-16	3	1	7	3	1004
9	108	3	2024-09-16	3	1	7	3	1004
11	100	1	2024-10-01	1	1	9	3	1000
12	101	1	2024-10-01	1	1	9	3	1000
13	102	1	2024-10-01	1	1	9	3	1000
14	103	1	2024-10-01	1	1	9	3	1000
15	104	2	2024-10-08	2	1	5	3	1001
16	105	2	2024-10-08	2	1	5	3	1001
17	106	2	2024-10-08	2	1	5	3	1001
18	107	3	2024-10-16	3	1	7	3	1004
19	108	3	2024-10-16	3	1	7	3	1004
20	108	3	2024-10-16	3	1	7	3	1004
10	109	3	2024-09-16	3	1	7	3	1004
\.


--
-- TOC entry 5100 (class 0 OID 16403)
-- Dependencies: 222
-- Data for Name: ensemble_genre; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ensemble_genre (ensembles_id, gentre_ensembles) FROM stdin;
1	punk rock
2	gospel band
3	сlassical music
\.


--
-- TOC entry 5137 (class 0 OID 17062)
-- Dependencies: 259
-- Data for Name: group_lessons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.group_lessons (grouplesson_id, students_numb, data_group, time_slot_id, min_places_id, max_places_id, instrument_id, lessons_id, instructor_id) FROM stdin;
1	100	2024-09-01	2	1	7	1	2	1005
2	101	2024-09-01	2	1	7	2	2	1005
3	102	2024-09-01	2	1	7	1	2	1005
4	103	2024-09-01	2	1	7	2	2	1005
5	104	2024-09-08	3	1	6	3	2	1002
6	105	2024-09-08	3	1	6	4	2	1002
7	106	2024-09-08	3	1	6	3	2	1002
8	107	2024-09-16	4	1	7	5	2	1003
9	108	2024-09-16	4	1	7	6	2	1003
10	108	2024-09-16	4	1	7	5	2	1003
11	100	2024-10-01	2	1	9	1	2	1000
12	101	2024-10-01	2	1	9	2	2	1000
13	102	2024-10-01	2	1	9	1	2	1000
14	103	2024-10-01	2	1	9	2	2	1000
15	104	2024-10-08	3	1	5	3	2	1001
16	105	2024-10-08	3	1	5	4	2	1001
17	106	2024-10-08	3	1	5	3	2	1001
18	107	2024-10-16	4	1	7	5	2	1004
19	108	2024-10-16	4	1	7	6	2	1004
20	108	2024-10-16	4	1	7	5	2	1004
\.


--
-- TOC entry 5159 (class 0 OID 26499)
-- Dependencies: 281
-- Data for Name: historical_lessons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historical_lessons (lesson_id, lesson_date, lesson_type, genre, instrument, lesson_price, student_firstname, student_surname, student_email) FROM stdin;
1	2024-09-01	Individual	No genre	Piano	100.00	Austin	Morrison	venenatis.vel.faucibus@protonmail.com
2	2024-09-01	Individual	No genre	Piano	500.00	Austin	Morrison	venenatis.vel.faucibus@protonmail.com
3	2024-09-01	Individual	No genre	Violin	100.00	Mccarty	Morrison	nunc@aol.com
4	2024-09-01	Individual	No genre	Violin	500.00	Mccarty	Morrison	nunc@aol.com
5	2024-09-01	Individual	No genre	Guitar	100.00	Allegra	Velasquez	faucibus.orci@icloud.com
6	2024-09-01	Individual	No genre	Guitar	500.00	Allegra	Velasquez	faucibus.orci@icloud.com
7	2024-09-10	Individual	No genre	Drums	100.00	Walker	Mason	sed.dolor@icloud.com
8	2024-09-10	Individual	No genre	Drums	500.00	Walker	Mason	sed.dolor@icloud.com
9	2024-09-01	Individual	No genre	Drums	100.00	Walker	Mason	sed.dolor@icloud.com
10	2024-09-01	Individual	No genre	Drums	500.00	Walker	Mason	sed.dolor@icloud.com
11	2024-09-01	Individual	No genre	cello	100.00	Indira	Holland	pellentesque.massa.lobortis@icloud.ca
12	2024-09-01	Individual	No genre	cello	500.00	Indira	Holland	pellentesque.massa.lobortis@icloud.ca
13	2024-09-01	Individual	No genre	electric guitar	100.00	Page	Holland	commodo.ipsum.suspendisse@google.ca
14	2024-09-01	Individual	No genre	Trumpet	100.00	Yoshio	Holland	molestie.orci@hotmail.ca
15	2024-09-01	Individual	No genre	Trumpet	500.00	Yoshio	Holland	molestie.orci@hotmail.ca
16	2024-09-01	Individual	No genre	Flutes	100.00	Henry	Zamora	magna.sed.dui@hotmail.com
17	2024-09-01	Individual	No genre	Trumpet	100.00	Sopoline	Hood	vel.est@google.couk
18	2024-09-01	Individual	No genre	Trumpet	500.00	Sopoline	Hood	vel.est@google.couk
19	2024-09-01	Individual	No genre	Violin	100.00	Reuben	Ray	tincidunt.neque@yahoo.org
20	2024-09-01	Individual	No genre	Piano	100.00	Reuben	Ray	tincidunt.neque@yahoo.org
21	2024-10-01	Individual	No genre	Piano	100.00	Austin	Morrison	venenatis.vel.faucibus@protonmail.com
22	2024-10-01	Individual	No genre	Piano	500.00	Austin	Morrison	venenatis.vel.faucibus@protonmail.com
23	2024-10-01	Individual	No genre	Violin	100.00	Mccarty	Morrison	nunc@aol.com
24	2024-10-01	Individual	No genre	Violin	500.00	Mccarty	Morrison	nunc@aol.com
25	2024-10-01	Individual	No genre	Guitar	100.00	Allegra	Velasquez	faucibus.orci@icloud.com
26	2024-10-01	Individual	No genre	Guitar	500.00	Allegra	Velasquez	faucibus.orci@icloud.com
27	2024-10-10	Individual	No genre	Drums	100.00	Walker	Mason	sed.dolor@icloud.com
28	2024-10-10	Individual	No genre	Drums	500.00	Walker	Mason	sed.dolor@icloud.com
29	2024-10-01	Individual	No genre	cello	100.00	Indira	Holland	pellentesque.massa.lobortis@icloud.ca
30	2024-10-01	Individual	No genre	cello	500.00	Indira	Holland	pellentesque.massa.lobortis@icloud.ca
31	2024-10-01	Individual	No genre	electric guitar	100.00	Page	Holland	commodo.ipsum.suspendisse@google.ca
32	2024-10-01	Individual	No genre	Trumpet	100.00	Yoshio	Holland	molestie.orci@hotmail.ca
33	2024-10-01	Individual	No genre	Trumpet	500.00	Yoshio	Holland	molestie.orci@hotmail.ca
34	2024-10-01	Individual	No genre	Flutes	100.00	Henry	Zamora	magna.sed.dui@hotmail.com
35	2024-10-01	Individual	No genre	Trumpet	100.00	Sopoline	Hood	vel.est@google.couk
36	2024-10-01	Individual	No genre	Trumpet	500.00	Sopoline	Hood	vel.est@google.couk
37	2024-10-01	Individual	No genre	Violin	100.00	Reuben	Ray	tincidunt.neque@yahoo.org
38	2024-10-16	Individual	No genre	Piano	100.00	Reuben	Ray	tincidunt.neque@yahoo.org
39	2024-10-01	Group	No genre	Violin	50.00	Allegra	Velasquez	faucibus.orci@icloud.com
40	2024-10-01	Group	No genre	Violin	50.00	Austin	Morrison	venenatis.vel.faucibus@protonmail.com
41	2024-09-01	Group	No genre	Violin	50.00	Allegra	Velasquez	faucibus.orci@icloud.com
42	2024-09-01	Group	No genre	Violin	50.00	Austin	Morrison	venenatis.vel.faucibus@protonmail.com
43	2024-10-01	Group	No genre	Piano	50.00	Walker	Mason	sed.dolor@icloud.com
44	2024-10-01	Group	No genre	Piano	50.00	Mccarty	Morrison	nunc@aol.com
45	2024-09-01	Group	No genre	Piano	50.00	Walker	Mason	sed.dolor@icloud.com
46	2024-09-01	Group	No genre	Piano	50.00	Mccarty	Morrison	nunc@aol.com
47	2024-10-08	Group	No genre	Guitar	50.00	Yoshio	Holland	molestie.orci@hotmail.ca
48	2024-10-08	Group	No genre	Guitar	50.00	Indira	Holland	pellentesque.massa.lobortis@icloud.ca
49	2024-09-08	Group	No genre	Guitar	50.00	Yoshio	Holland	molestie.orci@hotmail.ca
50	2024-09-08	Group	No genre	Guitar	50.00	Indira	Holland	pellentesque.massa.lobortis@icloud.ca
51	2024-10-08	Group	No genre	Drums	50.00	Page	Holland	commodo.ipsum.suspendisse@google.ca
52	2024-09-08	Group	No genre	Drums	50.00	Page	Holland	commodo.ipsum.suspendisse@google.ca
53	2024-10-16	Group	No genre	cello	50.00	Sopoline	Hood	vel.est@google.couk
54	2024-10-16	Group	No genre	cello	50.00	Henry	Zamora	magna.sed.dui@hotmail.com
55	2024-09-16	Group	No genre	cello	50.00	Sopoline	Hood	vel.est@google.couk
56	2024-09-16	Group	No genre	cello	50.00	Henry	Zamora	magna.sed.dui@hotmail.com
57	2024-10-16	Group	No genre	electric guitar	50.00	Sopoline	Hood	vel.est@google.couk
58	2024-09-16	Group	No genre	electric guitar	50.00	Sopoline	Hood	vel.est@google.couk
59	2024-09-01	Ensemble	punk rock	Different musical instruments	60.00	Austin	Morrison	venenatis.vel.faucibus@protonmail.com
60	2024-09-01	Ensemble	punk rock	Different musical instruments	60.00	Mccarty	Morrison	nunc@aol.com
61	2024-09-01	Ensemble	punk rock	Different musical instruments	60.00	Allegra	Velasquez	faucibus.orci@icloud.com
62	2024-09-01	Ensemble	punk rock	Different musical instruments	60.00	Walker	Mason	sed.dolor@icloud.com
63	2024-09-08	Ensemble	gospel band	Different musical instruments	60.00	Indira	Holland	pellentesque.massa.lobortis@icloud.ca
64	2024-09-08	Ensemble	gospel band	Different musical instruments	60.00	Page	Holland	commodo.ipsum.suspendisse@google.ca
65	2024-09-08	Ensemble	gospel band	Different musical instruments	60.00	Yoshio	Holland	molestie.orci@hotmail.ca
66	2024-09-16	Ensemble	сlassical music	Different musical instruments	60.00	Henry	Zamora	magna.sed.dui@hotmail.com
67	2024-09-16	Ensemble	сlassical music	Different musical instruments	60.00	Sopoline	Hood	vel.est@google.couk
68	2024-10-01	Ensemble	punk rock	Different musical instruments	60.00	Austin	Morrison	venenatis.vel.faucibus@protonmail.com
69	2024-10-01	Ensemble	punk rock	Different musical instruments	60.00	Mccarty	Morrison	nunc@aol.com
70	2024-10-01	Ensemble	punk rock	Different musical instruments	60.00	Allegra	Velasquez	faucibus.orci@icloud.com
71	2024-10-01	Ensemble	punk rock	Different musical instruments	60.00	Walker	Mason	sed.dolor@icloud.com
72	2024-10-08	Ensemble	gospel band	Different musical instruments	60.00	Indira	Holland	pellentesque.massa.lobortis@icloud.ca
73	2024-10-08	Ensemble	gospel band	Different musical instruments	60.00	Page	Holland	commodo.ipsum.suspendisse@google.ca
74	2024-10-08	Ensemble	gospel band	Different musical instruments	60.00	Yoshio	Holland	molestie.orci@hotmail.ca
75	2024-10-16	Ensemble	сlassical music	Different musical instruments	60.00	Henry	Zamora	magna.sed.dui@hotmail.com
76	2024-10-16	Ensemble	сlassical music	Different musical instruments	60.00	Sopoline	Hood	vel.est@google.couk
77	2024-10-16	Ensemble	сlassical music	Different musical instruments	60.00	Sopoline	Hood	vel.est@google.couk
78	2024-09-16	Ensemble	сlassical music	Different musical instruments	60.00	Reuben	Ray	tincidunt.neque@yahoo.org
\.


--
-- TOC entry 5131 (class 0 OID 16915)
-- Dependencies: 253
-- Data for Name: hold_instrument; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hold_instrument (hold_id, inst_stud_id, instrument_id, level_id) FROM stdin;
1	1000	1	3
2	1000	5	3
3	1001	7	3
4	1001	8	3
5	1001	2	3
6	1002	3	3
7	1002	6	3
8	1003	1	3
9	1004	4	3
10	100	2	1
11	101	1	1
12	102	3	1
13	103	4	1
14	104	5	1
15	105	6	2
16	106	7	1
17	107	8	2
18	108	7	1
19	109	1	2
20	109	2	2
\.


--
-- TOC entry 5118 (class 0 OID 16595)
-- Dependencies: 240
-- Data for Name: instructor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.instructor (instruktor_numb, name_inst, surname_inst, address_id, contact_id) FROM stdin;
1000	Charde	Benjamin	7	20
1001	Rhoda	Francis	8	21
1002	Freya	Ferguson	9	22
1003	Madeline	Pittman	10	23
1004	Kevyn	Erickson	11	24
1005	Elmo	Carr	12	25
\.


--
-- TOC entry 5146 (class 0 OID 17468)
-- Dependencies: 268
-- Data for Name: instructor_payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.instructor_payment (ins_payment_id, instruktor_numb, period_start, period_end, lessons_id, levels_id, price_id, total_number_classes, total_received) FROM stdin;
1	1000	2024-09-01	2024-09-30	1	1	3	10	1000
2	1001	2024-09-01	2024-09-30	1	1	3	27	2700
3	1002	2024-09-01	2024-09-30	1	1	3	11	1100
4	1003	2024-09-01	2024-09-30	1	1	3	9	900
5	1004	2024-09-01	2024-09-30	1	1	3	8	800
6	1005	2024-09-01	2024-09-30	1	1	3	0	0
7	1000	2024-09-01	2024-09-30	1	2	4	9	900
8	1001	2024-09-01	2024-09-30	1	2	4	9	900
9	1002	2024-09-01	2024-09-30	1	2	4	4	400
10	1003	2024-09-01	2024-09-30	1	2	4	0	0
11	1004	2024-09-01	2024-09-30	1	2	4	0	0
12	1005	2024-09-01	2024-09-30	1	2	4	0	0
13	1000	2024-09-01	2024-09-30	2	0	6	0	0
14	1001	2024-09-01	2024-09-30	2	0	6	3	150
15	1002	2024-09-01	2024-09-30	2	0	6	0	0
16	1003	2024-09-01	2024-09-30	2	0	6	0	0
17	1004	2024-09-01	2024-09-30	2	0	6	3	150
18	1005	2024-09-01	2024-09-30	2	0	6	4	200
19	1000	2024-09-01	2024-09-30	3	0	7	4	240
20	1001	2024-09-01	2024-09-30	3	0	7	3	180
21	1002	2024-09-01	2024-09-30	3	0	7	0	0
22	1003	2024-09-01	2024-09-30	3	0	7	0	0
23	1004	2024-09-01	2024-09-30	3	0	7	3	180
24	1005	2024-09-01	2024-09-30	3	0	7	0	0
25	1000	2024-09-01	2024-09-30	1	1	3	11	1100
\.


--
-- TOC entry 5122 (class 0 OID 16626)
-- Dependencies: 244
-- Data for Name: invitations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invitations (invitation_id, student_numb, instrument_id) FROM stdin;
\.


--
-- TOC entry 5098 (class 0 OID 16396)
-- Dependencies: 220
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lessons (lessons_id, type_lessons) FROM stdin;
1	individual
2	group
3	ensemble
0	no lessons type
\.


--
-- TOC entry 5096 (class 0 OID 16389)
-- Dependencies: 218
-- Data for Name: levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.levels (level_id, level_stud) FROM stdin;
1	beginner
2	intermediate
3	advanced
0	no level
\.


--
-- TOC entry 5108 (class 0 OID 16466)
-- Dependencies: 230
-- Data for Name: mus_instruments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mus_instruments (instrument_id, instruments, quantities, brand_id, type_id) FROM stdin;
1	Violin	10	2	1
2	Piano	6	1	6
3	Guitar	8	4	7
4	Drums	4	5	4
5	cello	10	3	1
6	electric guitar	7	6	8
7	Trumpet	9	7	2
8	Flutes	6	8	3
\.


--
-- TOC entry 5124 (class 0 OID 16647)
-- Dependencies: 246
-- Data for Name: numb_places; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.numb_places (place_id, numb_places) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
10	10
\.


--
-- TOC entry 5156 (class 0 OID 17624)
-- Dependencies: 278
-- Data for Name: personin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personin (person_id, name, surname, address_id, contact_id) FROM stdin;
\.


--
-- TOC entry 5115 (class 0 OID 16579)
-- Dependencies: 237
-- Data for Name: persons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.persons (person_id, name_per, surname_per, student_numb, contact_id, address_id, relativ_id) FROM stdin;
5000	Eaton	Holland	104	11	2	1
5001	Christopher	Holland	105	12	2	1
5002	Keefe	Morrison	100	13	1	2
5003	Tana	Velasquez	102	14	4	2
5004	Zelenia	Mason	103	15	6	1
5005	Chancellor	Morrison	101	16	1	1
5006	Octavius	Nunez	107	17	4	7
5007	Tucker	Mcguire	109	18	3	5
5008	Christopher	Callahan	108	19	6	7
5009	Lane	Holland	106	20	2	2
\.


--
-- TOC entry 5142 (class 0 OID 17331)
-- Dependencies: 264
-- Data for Name: price; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price (price_id, price_start, price_finish, lessons_id, levels_id, type_service, price_service, unit_measur) FROM stdin;
1	2000-01-01	2050-01-01	0	0	Rent instruments	100	SWK
2	2000-01-01	2050-01-01	0	0	Home delivery	0	SWK
4	2000-01-01	2050-01-01	1	2	Individual intermedia	100	SWK
5	2000-01-01	2050-01-01	1	3	Individual advanced	200	SWK
6	2000-01-01	2050-01-01	2	0	Group lessons	50	SWK
7	2000-01-01	2050-01-01	3	0	Ensembles	60	SWK
8	2000-01-01	2050-01-01	0	0	Sibling discounts	5	%
3	2000-01-01	2024-09-30	1	1	Individual beginner	100	SWK
9	2024-10-01	2050-01-02	1	1	Individual beginner	500	SWK
\.


--
-- TOC entry 5126 (class 0 OID 16819)
-- Dependencies: 248
-- Data for Name: relatives; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.relatives (relativ_id, relationship) FROM stdin;
1	Father
2	Mother
3	Grandfather
4	Grandmother
5	Great-grandfather
6	Uncle
7	Aunt
8	Cousins
\.


--
-- TOC entry 5139 (class 0 OID 17152)
-- Dependencies: 261
-- Data for Name: renting_instruments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.renting_instruments (renting_id, student_numb, instrum_id, period_start, period_end, quantity_instruments, price_id) FROM stdin;
4	107	1	2024-01-09	2024-12-09	2	1
1	100	1	2024-09-01	2025-06-30	1	1
2	101	2	2024-09-01	2024-12-30	1	1
3	103	3	2024-09-01	2025-02-28	2	1
\.


--
-- TOC entry 5116 (class 0 OID 16588)
-- Dependencies: 238
-- Data for Name: sibling; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sibling (student_numb, person_sibling) FROM stdin;
100	101
104	105
105	104
\.


--
-- TOC entry 5157 (class 0 OID 25927)
-- Dependencies: 279
-- Data for Name: sibling_count; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sibling_count (count) FROM stdin;
1
\.


--
-- TOC entry 5152 (class 0 OID 17554)
-- Dependencies: 274
-- Data for Name: storage_places; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.storage_places (place_id, storage_places) FROM stdin;
1	lease agreement
2	balance in stock
3	under repair
4	written off the balance sheet
\.


--
-- TOC entry 5113 (class 0 OID 16542)
-- Dependencies: 235
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student (student_numb, firstname, surname, address_id, details_id, person_id) FROM stdin;
100	Austin	Morrison	1	1	5000
101	Mccarty	Morrison	1	2	5000
102	Allegra	Velasquez	3	3	5003
103	Walker	Mason	6	4	5004
104	Indira	Holland	2	5	5005
105	Page	Holland	2	6	5005
106	Yoshio	Holland	2	7	5007
107	Henry	Zamora	4	8	5008
108	Sopoline	Hood	5	9	5009
109	Reuben	Ray	6	10	5001
\.


--
-- TOC entry 5145 (class 0 OID 17434)
-- Dependencies: 267
-- Data for Name: student_payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_payment (st_payment_id, student_numb, period_start, period_end, lessons_id, levels_id, price_id, sibling_price_id, total_numb_classes, total_paid) FROM stdin;
36	104	2024-09-01	2024-09-30	1	1	3	2	11	3190.00
1	100	2024-09-01	2024-09-30	1	1	3	0	10	950
2	101	2024-09-01	2024-09-30	1	1	3	0	9	855
3	102	2024-09-01	2024-09-30	1	1	3	0	11	1100
4	103	2024-09-01	2024-09-30	1	1	3	0	8	800
5	104	2024-09-01	2024-09-30	1	1	3	0	10	900
6	105	2024-09-01	2024-09-30	1	1	3	0	0	0
7	106	2024-09-01	2024-09-30	1	1	3	0	8	720
8	107	2024-09-01	2024-09-30	1	1	3	0	0	0
9	108	2024-09-01	2024-09-30	1	1	3	0	9	900
10	109	2024-09-01	2024-09-30	1	1	3	0	0	0
11	100	2024-09-01	2024-09-30	1	2	4	0	0	0
12	101	2024-09-01	2024-09-30	1	2	4	0	0	0
13	102	2024-09-01	2024-09-30	1	2	4	0	0	0
14	103	2024-09-01	2024-09-30	1	2	4	0	0	0
15	104	2024-09-01	2024-09-30	1	2	4	0	0	0
16	105	2024-09-01	2024-09-30	1	2	4	0	4	360
17	106	2024-09-01	2024-09-30	1	2	4	0	0	0
18	107	2024-09-01	2024-09-30	1	2	4	0	9	900
19	108	2024-09-01	2024-09-30	1	2	4	0	0	0
20	109	2024-09-01	2024-09-30	1	2	4	0	9	900
21	100	2024-09-01	2024-09-30	2	0	6	0	1	47.5
22	101	2024-09-01	2024-09-30	2	0	6	0	1	47.5
23	102	2024-09-01	2024-09-30	2	0	6	0	1	50
24	103	2024-09-01	2024-09-30	2	0	6	0	1	50
25	104	2024-09-01	2024-09-30	2	0	6	0	1	45
26	105	2024-09-01	2024-09-30	2	0	6	0	1	45
27	106	2024-09-01	2024-09-30	2	0	6	0	1	45
28	107	2024-09-01	2024-09-30	2	0	6	0	1	50
29	108	2024-09-01	2024-09-30	2	0	6	0	1	50
30	109	2024-09-01	2024-09-30	2	0	6	0	1	50
31	100	2024-09-01	2024-09-30	3	0	7	0	1	57
32	101	2024-09-01	2024-09-30	3	0	7	0	1	57
33	102	2024-09-01	2024-09-30	3	0	7	0	1	60
34	103	2024-09-01	2024-09-30	3	0	7	0	1	60
35	104	2024-09-01	2024-09-30	3	0	7	0	1	53
\.


--
-- TOC entry 5120 (class 0 OID 16609)
-- Dependencies: 242
-- Data for Name: time_slot; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.time_slot (time_slot_id, start_time, end_time) FROM stdin;
1	8	9
2	9	10
3	10	11
4	11	12
5	12	13
6	13	14
7	14	15
8	15	16
9	16	17
10	17	18
11	18	19
\.


--
-- TOC entry 5104 (class 0 OID 16417)
-- Dependencies: 226
-- Data for Name: types_instruments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.types_instruments (type_id, types_instrum) FROM stdin;
1	Strings
2	Wind
3	Reed
4	Drums
5	Percussion
6	Keyboards
7	Mechanical
8	Electronic
\.


--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 231
-- Name: address_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.address_address_id_seq', 1, false);


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 265
-- Name: admin_staff_admin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_staff_admin_id_seq', 1, false);


--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 227
-- Name: app_attend_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_attend_app_id_seq', 1, false);


--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 254
-- Name: booking_individual_indiv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.booking_individual_indiv_id_seq', 1, false);


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 223
-- Name: brands_brand_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.brands_brand_id_seq', 8, true);


--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 275
-- Name: conditions_condition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conditions_condition_id_seq', 1, false);


--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 249
-- Name: contactsdetail_contactdet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contactsdetail_contactdet_id_seq', 1, false);


--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 256
-- Name: ensemble_ensem_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ensemble_ensem_id_seq', 1, false);


--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 221
-- Name: ensembles_ensembles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ensembles_ensembles_id_seq', 3, true);


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 258
-- Name: group_lessons_grouplesson_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.group_lessons_grouplesson_id_seq', 1, false);


--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 280
-- Name: historical_lessons_lesson_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historical_lessons_lesson_id_seq', 78, true);


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 252
-- Name: hold_instrument_hold_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hold_instrument_hold_id_seq', 1, false);


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 239
-- Name: instructor_instruktor_numb_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.instructor_instruktor_numb_seq', 1000, true);


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 262
-- Name: instructor_payment_ins_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.instructor_payment_ins_payment_id_seq', 1, false);


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 243
-- Name: invitations_invitation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invitations_invitation_id_seq', 1, false);


--
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 219
-- Name: lessons_lessons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lessons_lessons_id_seq', 3, true);


--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 217
-- Name: levels_level_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.levels_level_id_seq', 1, true);


--
-- TOC entry 5203 (class 0 OID 0)
-- Dependencies: 245
-- Name: maxsimum_places_max_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.maxsimum_places_max_id_seq', 1, false);


--
-- TOC entry 5204 (class 0 OID 0)
-- Dependencies: 229
-- Name: mus_instruments_instrument_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mus_instruments_instrument_id_seq', 1, false);


--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 236
-- Name: person_contact_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.person_contact_person_id_seq', 5000, true);


--
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 277
-- Name: personin_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personin_person_id_seq', 1, false);


--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 251
-- Name: price_price_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.price_price_id_seq', 1, false);


--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 247
-- Name: relatives_relativ_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.relatives_relativ_id_seq', 1, false);


--
-- TOC entry 5209 (class 0 OID 0)
-- Dependencies: 260
-- Name: renting_instruments_renting_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renting_instruments_renting_id_seq', 2, true);


--
-- TOC entry 5210 (class 0 OID 0)
-- Dependencies: 272
-- Name: reservations_reserv_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservations_reserv_group_id_seq', 1, false);


--
-- TOC entry 5211 (class 0 OID 0)
-- Dependencies: 269
-- Name: reservations_reserv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservations_reserv_id_seq', 1, false);


--
-- TOC entry 5212 (class 0 OID 0)
-- Dependencies: 273
-- Name: storage_places_place_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.storage_places_place_id_seq', 1, false);


--
-- TOC entry 5213 (class 0 OID 0)
-- Dependencies: 263
-- Name: student_payment_st_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_payment_st_payment_id_seq', 8, true);


--
-- TOC entry 5214 (class 0 OID 0)
-- Dependencies: 233
-- Name: student_student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_student_id_seq', 100, true);


--
-- TOC entry 5215 (class 0 OID 0)
-- Dependencies: 234
-- Name: student_student_numb_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_student_numb_seq', 1, true);


--
-- TOC entry 5216 (class 0 OID 0)
-- Dependencies: 241
-- Name: time_slot_slot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.time_slot_slot_id_seq', 1, false);


--
-- TOC entry 5217 (class 0 OID 0)
-- Dependencies: 225
-- Name: types_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.types_type_id_seq', 8, true);


--
-- TOC entry 4830 (class 2606 OID 16512)
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);


--
-- TOC entry 4862 (class 2606 OID 17348)
-- Name: complet_lessons admin_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT admin_staff_pkey PRIMARY KEY (admin_id);


--
-- TOC entry 4826 (class 2606 OID 16484)
-- Name: attend_student app_attend_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student
    ADD CONSTRAINT app_attend_pkey PRIMARY KEY (attend_id);


--
-- TOC entry 4852 (class 2606 OID 16943)
-- Name: booking_individual booking_individual_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT booking_individual_pkey PRIMARY KEY (indiv_id);


--
-- TOC entry 4822 (class 2606 OID 16453)
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (brand_id);


--
-- TOC entry 4874 (class 2606 OID 17570)
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (condition_id);


--
-- TOC entry 4848 (class 2606 OID 16870)
-- Name: contact_detail contactsdetail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_detail
    ADD CONSTRAINT contactsdetail_pkey PRIMARY KEY (contact_id);


--
-- TOC entry 4854 (class 2606 OID 17024)
-- Name: ensemble ensemble_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT ensemble_pkey PRIMARY KEY (ensem_id);


--
-- TOC entry 4820 (class 2606 OID 16446)
-- Name: ensemble_genre ensembles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble_genre
    ADD CONSTRAINT ensembles_pkey PRIMARY KEY (ensembles_id);


--
-- TOC entry 4856 (class 2606 OID 17067)
-- Name: group_lessons group_lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT group_lessons_pkey PRIMARY KEY (grouplesson_id);


--
-- TOC entry 4878 (class 2606 OID 26504)
-- Name: historical_lessons historical_lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historical_lessons
    ADD CONSTRAINT historical_lessons_pkey PRIMARY KEY (lesson_id);


--
-- TOC entry 4850 (class 2606 OID 16920)
-- Name: hold_instrument hold_instrument_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT hold_instrument_pkey PRIMARY KEY (hold_id);


--
-- TOC entry 4866 (class 2606 OID 17475)
-- Name: instructor_payment instructor_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT instructor_payment_pkey PRIMARY KEY (ins_payment_id);


--
-- TOC entry 4838 (class 2606 OID 16600)
-- Name: instructor instructor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT instructor_pkey PRIMARY KEY (instruktor_numb);


--
-- TOC entry 4842 (class 2606 OID 16631)
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (invitation_id);


--
-- TOC entry 4818 (class 2606 OID 16439)
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (lessons_id);


--
-- TOC entry 4816 (class 2606 OID 16432)
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (level_id);


--
-- TOC entry 4844 (class 2606 OID 16652)
-- Name: numb_places maxsimum_places_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.numb_places
    ADD CONSTRAINT maxsimum_places_pkey PRIMARY KEY (place_id);


--
-- TOC entry 4828 (class 2606 OID 16471)
-- Name: mus_instruments mus_instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments
    ADD CONSTRAINT mus_instruments_pkey PRIMARY KEY (instrument_id);


--
-- TOC entry 4876 (class 2606 OID 17629)
-- Name: personin personin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin
    ADD CONSTRAINT personin_pkey PRIMARY KEY (person_id);


--
-- TOC entry 4834 (class 2606 OID 16882)
-- Name: persons persons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT persons_pkey PRIMARY KEY (person_id);


--
-- TOC entry 4860 (class 2606 OID 17338)
-- Name: price price_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_pkey PRIMARY KEY (price_id);


--
-- TOC entry 4846 (class 2606 OID 16824)
-- Name: relatives relatives_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relatives
    ADD CONSTRAINT relatives_pkey PRIMARY KEY (relativ_id);


--
-- TOC entry 4858 (class 2606 OID 17159)
-- Name: renting_instruments renting_instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT renting_instruments_pkey PRIMARY KEY (renting_id);


--
-- TOC entry 4870 (class 2606 OID 17545)
-- Name: actual_seats_group reservat_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_group
    ADD CONSTRAINT reservat_group_pkey PRIMARY KEY (reserv_id);


--
-- TOC entry 4868 (class 2606 OID 17517)
-- Name: actual_seats_ensemble reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_ensemble
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (reserv_id);


--
-- TOC entry 4836 (class 2606 OID 17584)
-- Name: sibling sibling_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sibling
    ADD CONSTRAINT sibling_pkey PRIMARY KEY (student_numb, person_sibling);


--
-- TOC entry 4872 (class 2606 OID 17561)
-- Name: storage_places storage_places_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storage_places
    ADD CONSTRAINT storage_places_pkey PRIMARY KEY (place_id);


--
-- TOC entry 4864 (class 2606 OID 17441)
-- Name: student_payment student_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT student_payment_pkey PRIMARY KEY (st_payment_id);


--
-- TOC entry 4832 (class 2606 OID 16577)
-- Name: student student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (student_numb);


--
-- TOC entry 4840 (class 2606 OID 16614)
-- Name: time_slot time_slot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_slot
    ADD CONSTRAINT time_slot_pkey PRIMARY KEY (time_slot_id);


--
-- TOC entry 4824 (class 2606 OID 16425)
-- Name: types_instruments types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_instruments
    ADD CONSTRAINT types_pkey PRIMARY KEY (type_id);


--
-- TOC entry 5094 (class 2618 OID 26530)
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
-- TOC entry 4941 (class 2620 OID 26497)
-- Name: renting_instruments rental_duration_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rental_duration_check BEFORE INSERT OR UPDATE ON public.renting_instruments FOR EACH ROW EXECUTE FUNCTION public.check_rental_duration();


--
-- TOC entry 4942 (class 2620 OID 26510)
-- Name: renting_instruments renting_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER renting_check BEFORE INSERT OR UPDATE OF quantity_instruments ON public.renting_instruments FOR EACH ROW EXECUTE FUNCTION public.renting_check2();


--
-- TOC entry 4944 (class 2620 OID 25933)
-- Name: student_payment trg_update_total_paid; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_total_paid BEFORE INSERT OR UPDATE ON public.student_payment FOR EACH ROW EXECUTE FUNCTION public.update_total_paid();


--
-- TOC entry 4945 (class 2620 OID 25935)
-- Name: instructor_payment trg_update_total_received; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_total_received BEFORE INSERT OR UPDATE ON public.instructor_payment FOR EACH ROW EXECUTE FUNCTION public.update_total_received();


--
-- TOC entry 4943 (class 2620 OID 26512)
-- Name: complet_lessons update_price_id_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_price_id_trigger AFTER INSERT OR UPDATE ON public.complet_lessons FOR EACH ROW EXECUTE FUNCTION public.update_price_id();


--
-- TOC entry 4886 (class 2606 OID 17384)
-- Name: persons address_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT address_fk FOREIGN KEY (address_id) REFERENCES public.address(address_id) NOT VALID;


--
-- TOC entry 4883 (class 2606 OID 16703)
-- Name: student address_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT address_id FOREIGN KEY (address_id) REFERENCES public.address(address_id) NOT VALID;


--
-- TOC entry 4892 (class 2606 OID 16730)
-- Name: instructor address_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT address_id_fk FOREIGN KEY (address_id) REFERENCES public.address(address_id) NOT VALID;


--
-- TOC entry 4881 (class 2606 OID 16559)
-- Name: mus_instruments brand_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments
    ADD CONSTRAINT brand_id_fk FOREIGN KEY (brand_id) REFERENCES public.brands(brand_id) NOT VALID;


--
-- TOC entry 4893 (class 2606 OID 17269)
-- Name: instructor contact_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT contact_fk FOREIGN KEY (contact_id) REFERENCES public.contact_detail(contact_id) NOT VALID;


--
-- TOC entry 4887 (class 2606 OID 17379)
-- Name: persons contact_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT contact_fk FOREIGN KEY (contact_id) REFERENCES public.contact_detail(contact_id) NOT VALID;


--
-- TOC entry 4884 (class 2606 OID 16888)
-- Name: student details_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT details_fk FOREIGN KEY (details_id) REFERENCES public.contact_detail(contact_id) NOT VALID;


--
-- TOC entry 4935 (class 2606 OID 17535)
-- Name: actual_seats_ensemble ensemble_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_ensemble
    ADD CONSTRAINT ensemble_fk FOREIGN KEY (reserv_id) REFERENCES public.ensemble(ensem_id) NOT VALID;


--
-- TOC entry 4903 (class 2606 OID 17025)
-- Name: ensemble ensembles_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT ensembles_fk FOREIGN KEY (ensembles_id) REFERENCES public.ensemble_genre(ensembles_id);


--
-- TOC entry 4936 (class 2606 OID 17548)
-- Name: actual_seats_group group_lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actual_seats_group
    ADD CONSTRAINT group_lessons_fk FOREIGN KEY (group_lessons_id) REFERENCES public.group_lessons(grouplesson_id) NOT VALID;


--
-- TOC entry 4894 (class 2606 OID 17285)
-- Name: hold_instrument inst_stud_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT inst_stud_fk FOREIGN KEY (inst_stud_id) REFERENCES public.instructor(instruktor_numb) NOT VALID;


--
-- TOC entry 4895 (class 2606 OID 17290)
-- Name: hold_instrument inst_stud_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT inst_stud_fk2 FOREIGN KEY (inst_stud_id) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4898 (class 2606 OID 16964)
-- Name: booking_individual instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb) NOT VALID;


--
-- TOC entry 4904 (class 2606 OID 17030)
-- Name: ensemble instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb);


--
-- TOC entry 4910 (class 2606 OID 17098)
-- Name: group_lessons instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb) NOT VALID;


--
-- TOC entry 4922 (class 2606 OID 17349)
-- Name: complet_lessons instructor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT instructor_fk FOREIGN KEY (instructor_id) REFERENCES public.instructor(instruktor_numb);


--
-- TOC entry 4932 (class 2606 OID 17476)
-- Name: instructor_payment instruktor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT instruktor_fk FOREIGN KEY (instruktor_numb) REFERENCES public.instructor(instruktor_numb);


--
-- TOC entry 4917 (class 2606 OID 17160)
-- Name: renting_instruments instrum_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT instrum_fk FOREIGN KEY (instrum_id) REFERENCES public.mus_instruments(instrument_id);


--
-- TOC entry 4899 (class 2606 OID 16949)
-- Name: booking_individual instrument_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT instrument_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4911 (class 2606 OID 17088)
-- Name: group_lessons instrument_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT instrument_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4937 (class 2606 OID 17571)
-- Name: conditions instrument_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT instrument_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4896 (class 2606 OID 16921)
-- Name: hold_instrument instrument_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT instrument_id_fk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id);


--
-- TOC entry 4879 (class 2606 OID 16489)
-- Name: attend_student instrument_idfk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student
    ADD CONSTRAINT instrument_idfk FOREIGN KEY (instrument_id) REFERENCES public.mus_instruments(instrument_id) NOT VALID;


--
-- TOC entry 4900 (class 2606 OID 16954)
-- Name: booking_individual lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id) NOT VALID;


--
-- TOC entry 4905 (class 2606 OID 17035)
-- Name: ensemble lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4912 (class 2606 OID 17093)
-- Name: group_lessons lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id) NOT VALID;


--
-- TOC entry 4920 (class 2606 OID 17394)
-- Name: price lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id) NOT VALID;


--
-- TOC entry 4928 (class 2606 OID 17442)
-- Name: student_payment lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4933 (class 2606 OID 17481)
-- Name: instructor_payment lessons_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT lessons_fk FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4923 (class 2606 OID 17354)
-- Name: complet_lessons lessons_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT lessons_id FOREIGN KEY (lessons_id) REFERENCES public.lessons(lessons_id);


--
-- TOC entry 4897 (class 2606 OID 16931)
-- Name: hold_instrument level_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hold_instrument
    ADD CONSTRAINT level_fk FOREIGN KEY (level_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4901 (class 2606 OID 16959)
-- Name: booking_individual level_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT level_fk FOREIGN KEY (level_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4880 (class 2606 OID 16494)
-- Name: attend_student level_idfk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attend_student
    ADD CONSTRAINT level_idfk FOREIGN KEY (level_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4921 (class 2606 OID 17399)
-- Name: price levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4924 (class 2606 OID 17404)
-- Name: complet_lessons levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id) NOT VALID;


--
-- TOC entry 4929 (class 2606 OID 17447)
-- Name: student_payment levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id);


--
-- TOC entry 4934 (class 2606 OID 17486)
-- Name: instructor_payment levels_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor_payment
    ADD CONSTRAINT levels_fk FOREIGN KEY (levels_id) REFERENCES public.levels(level_id);


--
-- TOC entry 4913 (class 2606 OID 17083)
-- Name: group_lessons max_places_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT max_places_fk FOREIGN KEY (max_places_id) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4906 (class 2606 OID 17055)
-- Name: ensemble max_students_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT max_students_fk FOREIGN KEY (max_students) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4914 (class 2606 OID 17078)
-- Name: group_lessons min_places_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT min_places_fk FOREIGN KEY (min_places_id) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4907 (class 2606 OID 17050)
-- Name: ensemble min_students_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT min_students_fk FOREIGN KEY (min_students) REFERENCES public.numb_places(place_id) NOT VALID;


--
-- TOC entry 4885 (class 2606 OID 16883)
-- Name: student person_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT person_fk FOREIGN KEY (person_id) REFERENCES public.persons(person_id) NOT VALID;


--
-- TOC entry 4890 (class 2606 OID 16725)
-- Name: sibling person_sibling_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sibling
    ADD CONSTRAINT person_sibling_id_fk FOREIGN KEY (person_sibling) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4939 (class 2606 OID 17630)
-- Name: personin personin_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin
    ADD CONSTRAINT personin_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.address(address_id);


--
-- TOC entry 4940 (class 2606 OID 17635)
-- Name: personin personin_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personin
    ADD CONSTRAINT personin_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.contact_detail(contact_id);


--
-- TOC entry 4925 (class 2606 OID 17359)
-- Name: complet_lessons price_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT price_fk FOREIGN KEY (price_id) REFERENCES public.price(price_id);


--
-- TOC entry 4918 (class 2606 OID 17414)
-- Name: renting_instruments price_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT price_fk FOREIGN KEY (price_id) REFERENCES public.price(price_id) NOT VALID;


--
-- TOC entry 4930 (class 2606 OID 17452)
-- Name: student_payment price_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT price_fk FOREIGN KEY (price_id) REFERENCES public.price(price_id);


--
-- TOC entry 4888 (class 2606 OID 17389)
-- Name: persons relativ_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT relativ_fk FOREIGN KEY (relativ_id) REFERENCES public.relatives(relativ_id) NOT VALID;


--
-- TOC entry 4926 (class 2606 OID 17364)
-- Name: complet_lessons slot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT slot_fk FOREIGN KEY (slot_id) REFERENCES public.time_slot(time_slot_id);


--
-- TOC entry 4938 (class 2606 OID 17576)
-- Name: conditions storage_places_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT storage_places_fk FOREIGN KEY (storage_places_id) REFERENCES public.storage_places(place_id) NOT VALID;


--
-- TOC entry 4902 (class 2606 OID 16944)
-- Name: booking_individual student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_individual
    ADD CONSTRAINT student_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4919 (class 2606 OID 17170)
-- Name: renting_instruments student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.renting_instruments
    ADD CONSTRAINT student_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb);


--
-- TOC entry 4927 (class 2606 OID 17369)
-- Name: complet_lessons student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complet_lessons
    ADD CONSTRAINT student_fk FOREIGN KEY (student_id) REFERENCES public.student(student_numb);


--
-- TOC entry 4931 (class 2606 OID 17462)
-- Name: student_payment student_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_payment
    ADD CONSTRAINT student_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb);


--
-- TOC entry 4891 (class 2606 OID 16720)
-- Name: sibling student_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sibling
    ADD CONSTRAINT student_numb_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4889 (class 2606 OID 17374)
-- Name: persons student_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persons
    ADD CONSTRAINT student_numb_fk FOREIGN KEY (student_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4908 (class 2606 OID 17045)
-- Name: ensemble students_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT students_numb_fk FOREIGN KEY (students_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4915 (class 2606 OID 17068)
-- Name: group_lessons students_numb_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT students_numb_fk FOREIGN KEY (students_numb) REFERENCES public.student(student_numb) NOT VALID;


--
-- TOC entry 4909 (class 2606 OID 17040)
-- Name: ensemble time_slot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ensemble
    ADD CONSTRAINT time_slot_fk FOREIGN KEY (time_slot_id) REFERENCES public.time_slot(time_slot_id);


--
-- TOC entry 4916 (class 2606 OID 17073)
-- Name: group_lessons time_slot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_lessons
    ADD CONSTRAINT time_slot_fk FOREIGN KEY (time_slot_id) REFERENCES public.time_slot(time_slot_id) NOT VALID;


--
-- TOC entry 4882 (class 2606 OID 16564)
-- Name: mus_instruments type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mus_instruments
    ADD CONSTRAINT type_id_fk FOREIGN KEY (type_id) REFERENCES public.types_instruments(type_id) NOT VALID;


-- Completed on 2024-12-01 21:13:03

--
-- PostgreSQL database dump complete
--

