-- Table: public.address

-- DROP TABLE IF EXISTS public.address;

CREATE TABLE IF NOT EXISTS public.address
(
    address_id integer NOT NULL DEFAULT nextval('address_address_id_seq'::regclass),
    postal_code integer NOT NULL,
    city character varying(100) COLLATE pg_catalog."default" NOT NULL,
    street character varying(100) COLLATE pg_catalog."default" NOT NULL,
    home integer NOT NULL,
    room integer,
    CONSTRAINT address_pkey PRIMARY KEY (address_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.address
    OWNER to postgres;
	


-- Table: public.complet_lessons

-- DROP TABLE IF EXISTS public.complet_lessons;

CREATE TABLE IF NOT EXISTS public.complet_lessons
(
    admin_id integer NOT NULL DEFAULT nextval('admin_staff_admin_id_seq'::regclass),
    lessons_id integer NOT NULL,
    levels_id integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    slot_id integer NOT NULL,
    student_id integer NOT NULL,
    instructor_id integer NOT NULL,
    note character varying(500) COLLATE pg_catalog."default" NOT NULL,
    price_id integer NOT NULL,
    CONSTRAINT admin_staff_pkey PRIMARY KEY (admin_id),
    CONSTRAINT instructor_fk FOREIGN KEY (instructor_id)
        REFERENCES public.instructor (instruktor_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lessons_id FOREIGN KEY (lessons_id)
        REFERENCES public.lessons (lessons_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT levels_fk FOREIGN KEY (levels_id)
        REFERENCES public.levels (level_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT price_fk FOREIGN KEY (price_id)
        REFERENCES public.price (price_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT slot_fk FOREIGN KEY (slot_id)
        REFERENCES public.time_slot (time_slot_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT student_fk FOREIGN KEY (student_id)
        REFERENCES public.student (student_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.complet_lessons
    OWNER to postgres;

-- Trigger: update_price_id_trigger

-- DROP TRIGGER IF EXISTS update_price_id_trigger ON public.complet_lessons;

CREATE OR REPLACE TRIGGER update_price_id_trigger
    AFTER INSERT OR UPDATE 
    ON public.complet_lessons
    FOR EACH ROW
    EXECUTE FUNCTION public.update_price_id();
	
	

-- Table: public.attend_student

-- DROP TABLE IF EXISTS public.attend_student;

CREATE TABLE IF NOT EXISTS public.attend_student
(
    attend_id integer NOT NULL DEFAULT nextval('app_attend_app_id_seq'::regclass),
    name_app character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "surname_ app" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    telephone character varying(10) COLLATE pg_catalog."default" NOT NULL,
    e_mail character varying(150) COLLATE pg_catalog."default",
    instrument_id integer NOT NULL,
    level_id integer NOT NULL,
    CONSTRAINT app_attend_pkey PRIMARY KEY (attend_id),
    CONSTRAINT instrument_idfk FOREIGN KEY (instrument_id)
        REFERENCES public.mus_instruments (instrument_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT level_idfk FOREIGN KEY (level_id)
        REFERENCES public.levels (level_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.attend_student
    OWNER to postgres;

	

-- Table: public.booking_individual

-- DROP TABLE IF EXISTS public.booking_individual;

CREATE TABLE IF NOT EXISTS public.booking_individual
(
    indiv_id integer NOT NULL DEFAULT nextval('booking_individual_indiv_id_seq'::regclass),
    student_numb integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    numb_lessons integer NOT NULL,
    instrument_id integer NOT NULL,
    lessons_id integer NOT NULL,
    level_id integer NOT NULL,
    instructor_id integer NOT NULL,
    CONSTRAINT booking_individual_pkey PRIMARY KEY (indiv_id),
    CONSTRAINT instructor_fk FOREIGN KEY (instructor_id)
        REFERENCES public.instructor (instruktor_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT instrument_fk FOREIGN KEY (instrument_id)
        REFERENCES public.mus_instruments (instrument_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT lessons_fk FOREIGN KEY (lessons_id)
        REFERENCES public.lessons (lessons_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT level_fk FOREIGN KEY (level_id)
        REFERENCES public.levels (level_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT student_fk FOREIGN KEY (student_numb)
        REFERENCES public.student (student_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.booking_individual
    OWNER to postgres;


-- Table: public.brands

-- DROP TABLE IF EXISTS public.brands;

CREATE TABLE IF NOT EXISTS public.brands
(
    brand_id integer NOT NULL DEFAULT nextval('brands_brand_id_seq'::regclass),
    brand character varying(300) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT brands_pkey PRIMARY KEY (brand_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.brands
    OWNER to postgres;


-- Table: public.complet_lessons

-- DROP TABLE IF EXISTS public.complet_lessons;

CREATE TABLE IF NOT EXISTS public.complet_lessons
(
    admin_id integer NOT NULL DEFAULT nextval('admin_staff_admin_id_seq'::regclass),
    lessons_id integer NOT NULL,
    levels_id integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    slot_id integer NOT NULL,
    student_id integer NOT NULL,
    instructor_id integer NOT NULL,
    note character varying(500) COLLATE pg_catalog."default" NOT NULL,
    price_id integer NOT NULL,
    CONSTRAINT admin_staff_pkey PRIMARY KEY (admin_id),
    CONSTRAINT instructor_fk FOREIGN KEY (instructor_id)
        REFERENCES public.instructor (instruktor_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lessons_id FOREIGN KEY (lessons_id)
        REFERENCES public.lessons (lessons_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT levels_fk FOREIGN KEY (levels_id)
        REFERENCES public.levels (level_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT price_fk FOREIGN KEY (price_id)
        REFERENCES public.price (price_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT slot_fk FOREIGN KEY (slot_id)
        REFERENCES public.time_slot (time_slot_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT student_fk FOREIGN KEY (student_id)
        REFERENCES public.student (student_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.complet_lessons
    OWNER to postgres;

-- Trigger: update_price_id_trigger

-- DROP TRIGGER IF EXISTS update_price_id_trigger ON public.complet_lessons;

CREATE OR REPLACE TRIGGER update_price_id_trigger
    AFTER INSERT OR UPDATE 
    ON public.complet_lessons
    FOR EACH ROW
    EXECUTE FUNCTION public.update_price_id();






-- Table: public.conditions

-- DROP TABLE IF EXISTS public.conditions;

CREATE TABLE IF NOT EXISTS public.conditions
(
    condition_id integer NOT NULL DEFAULT nextval('conditions_condition_id_seq'::regclass),
    instrument_id integer NOT NULL,
    data_start date NOT NULL,
    data_end date NOT NULL,
    storage_places_id integer NOT NULL,
    "unique serial number" uuid NOT NULL,
    cost numeric NOT NULL,
    CONSTRAINT conditions_pkey PRIMARY KEY (condition_id),
    CONSTRAINT instrument_fk FOREIGN KEY (instrument_id)
        REFERENCES public.mus_instruments (instrument_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT storage_places_fk FOREIGN KEY (storage_places_id)
        REFERENCES public.storage_places (place_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.conditions
    OWNER to postgres;






-- Table: public.contact_detail

-- DROP TABLE IF EXISTS public.contact_detail;

CREATE TABLE IF NOT EXISTS public.contact_detail
(
    contact_id integer NOT NULL DEFAULT nextval('contactsdetail_contactdet_id_seq'::regclass),
    telephone character varying(20) COLLATE pg_catalog."default" NOT NULL,
    e_mail character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT contactsdetail_pkey PRIMARY KEY (contact_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.contact_detail
    OWNER to postgres;
	

-- Table: public.ensemble

-- DROP TABLE IF EXISTS public.ensemble;

CREATE TABLE IF NOT EXISTS public.ensemble
(
    ensem_id integer NOT NULL DEFAULT nextval('ensemble_ensem_id_seq'::regclass),
    students_numb integer NOT NULL,
    ensembles_id integer NOT NULL,
    data_ensem date NOT NULL,
    time_slot_id integer NOT NULL,
    min_students integer NOT NULL,
    max_students integer NOT NULL,
    lessons_id integer NOT NULL,
    instructor_id integer NOT NULL,
    CONSTRAINT ensemble_pkey PRIMARY KEY (ensem_id),
    CONSTRAINT ensembles_fk FOREIGN KEY (ensembles_id)
        REFERENCES public.ensemble_genre (ensembles_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT instructor_fk FOREIGN KEY (instructor_id)
        REFERENCES public.instructor (instruktor_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lessons_fk FOREIGN KEY (lessons_id)
        REFERENCES public.lessons (lessons_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT max_students_fk FOREIGN KEY (max_students)
        REFERENCES public.numb_places (place_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT min_students_fk FOREIGN KEY (min_students)
        REFERENCES public.numb_places (place_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT students_numb_fk FOREIGN KEY (students_numb)
        REFERENCES public.student (student_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT time_slot_fk FOREIGN KEY (time_slot_id)
        REFERENCES public.time_slot (time_slot_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.ensemble
    OWNER to postgres;
	

-- Table: public.ensemble_genre

-- DROP TABLE IF EXISTS public.ensemble_genre;

CREATE TABLE IF NOT EXISTS public.ensemble_genre
(
    ensembles_id integer NOT NULL DEFAULT nextval('ensembles_ensembles_id_seq'::regclass),
    gentre_ensembles character varying(100) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT ensembles_pkey PRIMARY KEY (ensembles_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.ensemble_genre
    OWNER to postgres;



-- Table: public.group_lessons

-- DROP TABLE IF EXISTS public.group_lessons;

CREATE TABLE IF NOT EXISTS public.group_lessons
(
    grouplesson_id integer NOT NULL DEFAULT nextval('group_lessons_grouplesson_id_seq'::regclass),
    students_numb integer NOT NULL,
    data_group date NOT NULL,
    time_slot_id integer NOT NULL,
    min_places_id integer NOT NULL,
    max_places_id integer NOT NULL,
    instrument_id integer NOT NULL,
    lessons_id integer NOT NULL,
    instructor_id integer NOT NULL,
    CONSTRAINT group_lessons_pkey PRIMARY KEY (grouplesson_id),
    CONSTRAINT instructor_fk FOREIGN KEY (instructor_id)
        REFERENCES public.instructor (instruktor_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT instrument_fk FOREIGN KEY (instrument_id)
        REFERENCES public.mus_instruments (instrument_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT lessons_fk FOREIGN KEY (lessons_id)
        REFERENCES public.lessons (lessons_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT max_places_fk FOREIGN KEY (max_places_id)
        REFERENCES public.numb_places (place_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT min_places_fk FOREIGN KEY (min_places_id)
        REFERENCES public.numb_places (place_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT students_numb_fk FOREIGN KEY (students_numb)
        REFERENCES public.student (student_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT time_slot_fk FOREIGN KEY (time_slot_id)
        REFERENCES public.time_slot (time_slot_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.group_lessons
    OWNER to postgres;
	
	

-- Table: public.hold_instrument

-- DROP TABLE IF EXISTS public.hold_instrument;

CREATE TABLE IF NOT EXISTS public.hold_instrument
(
    hold_id integer NOT NULL DEFAULT nextval('hold_instrument_hold_id_seq'::regclass),
    inst_stud_id integer NOT NULL,
    instrument_id integer NOT NULL,
    level_id integer NOT NULL,
    CONSTRAINT hold_instrument_pkey PRIMARY KEY (hold_id),
    CONSTRAINT inst_stud_fk FOREIGN KEY (inst_stud_id)
        REFERENCES public.instructor (instruktor_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT inst_stud_fk2 FOREIGN KEY (inst_stud_id)
        REFERENCES public.student (student_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT instrument_id_fk FOREIGN KEY (instrument_id)
        REFERENCES public.mus_instruments (instrument_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT level_fk FOREIGN KEY (level_id)
        REFERENCES public.levels (level_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.hold_instrument
    OWNER to postgres;

	

-- Table: public.instructor

-- DROP TABLE IF EXISTS public.instructor;

CREATE TABLE IF NOT EXISTS public.instructor
(
    instruktor_numb integer NOT NULL DEFAULT nextval('instructor_instruktor_numb_seq'::regclass),
    name_inst character varying(150) COLLATE pg_catalog."default" NOT NULL,
    surname_inst character varying(150) COLLATE pg_catalog."default" NOT NULL,
    address_id integer NOT NULL,
    contact_id integer NOT NULL,
    CONSTRAINT instructor_pkey PRIMARY KEY (instruktor_numb),
    CONSTRAINT address_id_fk FOREIGN KEY (address_id)
        REFERENCES public.address (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT contact_fk FOREIGN KEY (contact_id)
        REFERENCES public.contact_detail (contact_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.instructor
    OWNER to postgres;


	

-- Table: public.instructor_payment

-- DROP TABLE IF EXISTS public.instructor_payment;

CREATE TABLE IF NOT EXISTS public.instructor_payment
(
    ins_payment_id integer NOT NULL DEFAULT nextval('instructor_payment_ins_payment_id_seq'::regclass),
    instruktor_numb integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    lessons_id integer NOT NULL,
	levels_id integer NOT NULL,
    price_id integer NOT NULL,
    total_number_classes integer NOT NULL,
    total_received numeric NOT NULL,
    
    CONSTRAINT instructor_payment_pkey PRIMARY KEY (ins_payment_id),
    CONSTRAINT instruktor_fk FOREIGN KEY (instruktor_numb)
        REFERENCES public.instructor (instruktor_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lessons_fk FOREIGN KEY (lessons_id)
        REFERENCES public.lessons (lessons_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT levels_fk FOREIGN KEY (levels_id)
        REFERENCES public.levels (level_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.instructor_payment
    OWNER to postgres;


-- Table: public.invitations

-- DROP TABLE IF EXISTS public.invitations;

CREATE TABLE IF NOT EXISTS public.invitations
(
    invitation_id integer NOT NULL DEFAULT nextval('invitations_invitation_id_seq'::regclass),
    student_numb integer NOT NULL,
    instrument_id integer NOT NULL,
    CONSTRAINT invitations_pkey PRIMARY KEY (invitation_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.invitations
    OWNER to postgres;



-- Table: public.lessons

-- DROP TABLE IF EXISTS public.lessons;

CREATE TABLE IF NOT EXISTS public.lessons
(
    lessons_id integer NOT NULL DEFAULT nextval('lessons_lessons_id_seq'::regclass),
    type_lessons character varying(50) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT lessons_pkey PRIMARY KEY (lessons_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.lessons
    OWNER to postgres;
	

-- Table: public.levels

-- DROP TABLE IF EXISTS public.levels;

CREATE TABLE IF NOT EXISTS public.levels
(
    level_id integer NOT NULL DEFAULT nextval('levels_level_id_seq'::regclass),
    level_stud character varying(50) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT levels_pkey PRIMARY KEY (level_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.levels
    OWNER to postgres;


-- Table: public.mus_instruments

-- DROP TABLE IF EXISTS public.mus_instruments;

CREATE TABLE IF NOT EXISTS public.mus_instruments
(
    instrument_id integer NOT NULL DEFAULT nextval('mus_instruments_instrument_id_seq'::regclass),
    instruments character varying(100) COLLATE pg_catalog."default" NOT NULL,
    quantities integer NOT NULL,
    brand_id integer NOT NULL,
    type_id integer NOT NULL,
    CONSTRAINT mus_instruments_pkey PRIMARY KEY (instrument_id),
    CONSTRAINT brand_id_fk FOREIGN KEY (brand_id)
        REFERENCES public.brands (brand_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT type_id_fk FOREIGN KEY (type_id)
        REFERENCES public.types_instruments (type_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.mus_instruments
    OWNER to postgres;
	


-- Table: public.numb_places

-- DROP TABLE IF EXISTS public.numb_places;

CREATE TABLE IF NOT EXISTS public.numb_places
(
    place_id integer NOT NULL DEFAULT nextval('maxsimum_places_max_id_seq'::regclass),
    numb_places integer NOT NULL,
    CONSTRAINT maxsimum_places_pkey PRIMARY KEY (place_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.numb_places
    OWNER to postgres;



-- Table: public.persons

-- DROP TABLE IF EXISTS public.persons;

CREATE TABLE IF NOT EXISTS public.persons
(
    person_id integer NOT NULL DEFAULT nextval('person_contact_person_id_seq'::regclass),
    name_per character varying(150) COLLATE pg_catalog."default" NOT NULL,
    surname_per character varying(150) COLLATE pg_catalog."default" NOT NULL,
    student_numb integer NOT NULL,
    contact_id integer NOT NULL,
    address_id integer NOT NULL,
    relativ_id integer NOT NULL,
    CONSTRAINT persons_pkey PRIMARY KEY (person_id),
    CONSTRAINT address_fk FOREIGN KEY (address_id)
        REFERENCES public.address (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT contact_fk FOREIGN KEY (contact_id)
        REFERENCES public.contact_detail (contact_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT relativ_fk FOREIGN KEY (relativ_id)
        REFERENCES public.relatives (relativ_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT student_numb_fk FOREIGN KEY (student_numb)
        REFERENCES public.student (student_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.persons
    OWNER to postgres;


	

-- Table: public.price

-- DROP TABLE IF EXISTS public.price;

CREATE TABLE IF NOT EXISTS public.price
(
    price_id integer NOT NULL DEFAULT nextval('price_price_id_seq'::regclass),
    price_start date NOT NULL,
    price_finish date NOT NULL,
    lessons_id integer NOT NULL,
    levels_id integer NOT NULL,
    type_service character varying COLLATE pg_catalog."default" NOT NULL,
    price_service numeric NOT NULL,
    unit_measur character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT price_pkey PRIMARY KEY (price_id),
    CONSTRAINT lessons_fk FOREIGN KEY (lessons_id)
        REFERENCES public.lessons (lessons_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT levels_fk FOREIGN KEY (levels_id)
        REFERENCES public.levels (level_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.price
    OWNER to postgres;


	

-- Table: public.relatives

-- DROP TABLE IF EXISTS public.relatives;

CREATE TABLE IF NOT EXISTS public.relatives
(
    relativ_id integer NOT NULL DEFAULT nextval('relatives_relativ_id_seq'::regclass),
    relationship character varying(50) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT relatives_pkey PRIMARY KEY (relativ_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.relatives
    OWNER to postgres;
	
	

-- Table: public.renting_instruments

-- DROP TABLE IF EXISTS public.renting_instruments;

CREATE TABLE IF NOT EXISTS public.renting_instruments
(
    renting_id integer NOT NULL DEFAULT nextval('renting_instruments_renting_id_seq'::regclass),
    student_numb integer NOT NULL,
    instrum_id integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    mon_numb_renting integer NOT NULL,
    quantity_instruments integer NOT NULL,
    price_id integer NOT NULL,
    CONSTRAINT renting_instruments_pkey PRIMARY KEY (renting_id),
    CONSTRAINT instrum_fk FOREIGN KEY (instrum_id)
        REFERENCES public.mus_instruments (instrument_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT price_fk FOREIGN KEY (price_id)
        REFERENCES public.price (price_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT student_fk FOREIGN KEY (student_numb)
        REFERENCES public.student (student_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.renting_instruments
    OWNER to postgres;

-- Trigger: renting_check

-- DROP TRIGGER IF EXISTS renting_check ON public.renting_instruments;

CREATE OR REPLACE TRIGGER renting_check
    BEFORE INSERT OR UPDATE OF quantity_instruments
    ON public.renting_instruments
    FOR EACH ROW
    EXECUTE FUNCTION public.renting_check();




-- Table: public.actual_seats_ensemble

-- DROP TABLE IF EXISTS public.actual_seats_ensemble;

CREATE TABLE IF NOT EXISTS public.actual_seats_ensemble
(
    reserv_id integer NOT NULL DEFAULT nextval('reservations_reserv_id_seq'::regclass),
    ensemble_id integer NOT NULL,
    actual_seats integer NOT NULL,
    CONSTRAINT reservations_pkey PRIMARY KEY (reserv_id),
    CONSTRAINT ensemble_fk FOREIGN KEY (reserv_id)
        REFERENCES public.ensemble (ensem_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.actual_seats_ensemble
    OWNER to postgres;



-- Table: public.actual_seats_group

-- DROP TABLE IF EXISTS public.actual_seats_group;

CREATE TABLE IF NOT EXISTS public.actual_seats_group
(
    reserv_id integer NOT NULL DEFAULT nextval('reservations_reserv_group_id_seq'::regclass),
    group_lessons_id integer NOT NULL,
    actual_seats integer NOT NULL,
    CONSTRAINT reservat_group_pkey PRIMARY KEY (reserv_id),
    CONSTRAINT group_lessons_fk FOREIGN KEY (group_lessons_id)
        REFERENCES public.group_lessons (grouplesson_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.actual_seats_group
    OWNER to postgres;




-- Table: public.sibling

-- DROP TABLE IF EXISTS public.sibling;

CREATE TABLE IF NOT EXISTS public.sibling
(
    student_numb integer NOT NULL,
    person_sibling integer NOT NULL,
    CONSTRAINT sibling_pkey PRIMARY KEY (student_numb, person_sibling),
    CONSTRAINT person_sibling_id_fk FOREIGN KEY (person_sibling)
        REFERENCES public.student (student_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT student_numb_fk FOREIGN KEY (student_numb)
        REFERENCES public.student (student_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sibling
    OWNER to postgres;




-- Table: public.storage_places

-- DROP TABLE IF EXISTS public.storage_places;

CREATE TABLE IF NOT EXISTS public.storage_places
(
    place_id integer NOT NULL DEFAULT nextval('storage_places_place_id_seq'::regclass),
    storage_places character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT storage_places_pkey PRIMARY KEY (place_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.storage_places
    OWNER to postgres;




-- Table: public.student

-- DROP TABLE IF EXISTS public.student;

CREATE TABLE IF NOT EXISTS public.student
(
    student_numb integer NOT NULL DEFAULT nextval('student_student_id_seq'::regclass),
    firstname character varying COLLATE pg_catalog."default" NOT NULL,
    surname character varying COLLATE pg_catalog."default" NOT NULL,
    address_id integer NOT NULL,
    details_id integer NOT NULL,
    person_id integer NOT NULL,
    CONSTRAINT student_pkey PRIMARY KEY (student_numb),
    CONSTRAINT address_id FOREIGN KEY (address_id)
        REFERENCES public.address (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT details_fk FOREIGN KEY (details_id)
        REFERENCES public.contact_detail (contact_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT person_fk FOREIGN KEY (person_id)
        REFERENCES public.persons (person_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.student
    OWNER to postgres;

	

-- Table: public.student_payment

-- DROP TABLE IF EXISTS public.student_payment;

CREATE TABLE IF NOT EXISTS public.student_payment
(
    st_payment_id integer NOT NULL DEFAULT nextval('student_payment_st_payment_id_seq'::regclass),
    student_numb integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    lessons_id integer NOT NULL,
    levels_id integer NOT NULL,
    price_id integer NOT NULL,
    sibling_price_id integer NOT NULL,
    total_numb_classes integer NOT NULL,
    total_paid numeric NOT NULL,
    CONSTRAINT student_payment_pkey PRIMARY KEY (st_payment_id),
    CONSTRAINT lessons_fk FOREIGN KEY (lessons_id)
        REFERENCES public.lessons (lessons_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT levels_fk FOREIGN KEY (levels_id)
        REFERENCES public.levels (level_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT price_fk FOREIGN KEY (price_id)
        REFERENCES public.price (price_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT student_fk FOREIGN KEY (student_numb)
        REFERENCES public.student (student_numb) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.student_payment
    OWNER to postgres;



-- Table: public.time_slot

-- DROP TABLE IF EXISTS public.time_slot;

CREATE TABLE IF NOT EXISTS public.time_slot
(
    time_slot_id integer NOT NULL DEFAULT nextval('time_slot_slot_id_seq'::regclass),
    start_time integer NOT NULL,
    end_time integer NOT NULL,
    CONSTRAINT time_slot_pkey PRIMARY KEY (time_slot_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.time_slot
    OWNER to postgres;



-- Table: public.types_instruments

-- DROP TABLE IF EXISTS public.types_instruments;

CREATE TABLE IF NOT EXISTS public.types_instruments
(
    type_id integer NOT NULL DEFAULT nextval('types_type_id_seq'::regclass),
    types_instrum character varying(150) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT types_pkey PRIMARY KEY (type_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.types_instruments
    OWNER to postgres;


