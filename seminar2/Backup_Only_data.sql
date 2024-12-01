--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2024-12-01 21:08:46

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
-- TOC entry 5116 (class 0 OID 16507)
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
-- TOC entry 5134 (class 0 OID 16865)
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
-- TOC entry 5106 (class 0 OID 16403)
-- Dependencies: 222
-- Data for Name: ensemble_genre; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ensemble_genre (ensembles_id, gentre_ensembles) FROM stdin;
1	punk rock
2	gospel band
3	сlassical music
\.


--
-- TOC entry 5124 (class 0 OID 16595)
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
-- TOC entry 5104 (class 0 OID 16396)
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
-- TOC entry 5130 (class 0 OID 16647)
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
-- TOC entry 5119 (class 0 OID 16542)
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
-- TOC entry 5126 (class 0 OID 16609)
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
-- TOC entry 5141 (class 0 OID 17019)
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
-- TOC entry 5154 (class 0 OID 17512)
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
-- TOC entry 5108 (class 0 OID 16410)
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
-- TOC entry 5110 (class 0 OID 16417)
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
-- TOC entry 5114 (class 0 OID 16466)
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
-- TOC entry 5143 (class 0 OID 17062)
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
-- TOC entry 5155 (class 0 OID 17540)
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
-- TOC entry 5102 (class 0 OID 16389)
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
-- TOC entry 5112 (class 0 OID 16459)
-- Dependencies: 228
-- Data for Name: attend_student; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attend_student (attend_id, name, surname, telephone, e_mail, instrument_id, level_id) FROM stdin;
\.


--
-- TOC entry 5139 (class 0 OID 16938)
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
-- TOC entry 5148 (class 0 OID 17331)
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
-- TOC entry 5150 (class 0 OID 17341)
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
-- TOC entry 5158 (class 0 OID 17554)
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
-- TOC entry 5160 (class 0 OID 17563)
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
-- TOC entry 5165 (class 0 OID 26499)
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
-- TOC entry 5137 (class 0 OID 16915)
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
-- TOC entry 5152 (class 0 OID 17468)
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
-- TOC entry 5128 (class 0 OID 16626)
-- Dependencies: 244
-- Data for Name: invitations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invitations (invitation_id, student_numb, instrument_id) FROM stdin;
\.


--
-- TOC entry 5162 (class 0 OID 17624)
-- Dependencies: 278
-- Data for Name: personin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personin (person_id, name, surname, address_id, contact_id) FROM stdin;
\.


--
-- TOC entry 5132 (class 0 OID 16819)
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
-- TOC entry 5121 (class 0 OID 16579)
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
-- TOC entry 5145 (class 0 OID 17152)
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
-- TOC entry 5122 (class 0 OID 16588)
-- Dependencies: 238
-- Data for Name: sibling; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sibling (student_numb, person_sibling) FROM stdin;
100	101
104	105
105	104
\.


--
-- TOC entry 5163 (class 0 OID 25927)
-- Dependencies: 279
-- Data for Name: sibling_count; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sibling_count (count) FROM stdin;
1
\.


--
-- TOC entry 5151 (class 0 OID 17434)
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
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 231
-- Name: address_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.address_address_id_seq', 1, false);


--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 265
-- Name: admin_staff_admin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_staff_admin_id_seq', 1, false);


--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 227
-- Name: app_attend_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_attend_app_id_seq', 1, false);


--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 254
-- Name: booking_individual_indiv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.booking_individual_indiv_id_seq', 1, false);


--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 223
-- Name: brands_brand_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.brands_brand_id_seq', 8, true);


--
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 275
-- Name: conditions_condition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conditions_condition_id_seq', 1, false);


--
-- TOC entry 5177 (class 0 OID 0)
-- Dependencies: 249
-- Name: contactsdetail_contactdet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contactsdetail_contactdet_id_seq', 1, false);


--
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 256
-- Name: ensemble_ensem_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ensemble_ensem_id_seq', 1, false);


--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 221
-- Name: ensembles_ensembles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ensembles_ensembles_id_seq', 3, true);


--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 258
-- Name: group_lessons_grouplesson_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.group_lessons_grouplesson_id_seq', 1, false);


--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 280
-- Name: historical_lessons_lesson_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historical_lessons_lesson_id_seq', 78, true);


--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 252
-- Name: hold_instrument_hold_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hold_instrument_hold_id_seq', 1, false);


--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 239
-- Name: instructor_instruktor_numb_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.instructor_instruktor_numb_seq', 1000, true);


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 262
-- Name: instructor_payment_ins_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.instructor_payment_ins_payment_id_seq', 1, false);


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 243
-- Name: invitations_invitation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invitations_invitation_id_seq', 1, false);


--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 219
-- Name: lessons_lessons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lessons_lessons_id_seq', 3, true);


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 217
-- Name: levels_level_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.levels_level_id_seq', 1, true);


--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 245
-- Name: maxsimum_places_max_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.maxsimum_places_max_id_seq', 1, false);


--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 229
-- Name: mus_instruments_instrument_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mus_instruments_instrument_id_seq', 1, false);


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 236
-- Name: person_contact_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.person_contact_person_id_seq', 5000, true);


--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 277
-- Name: personin_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personin_person_id_seq', 1, false);


--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 251
-- Name: price_price_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.price_price_id_seq', 1, false);


--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 247
-- Name: relatives_relativ_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.relatives_relativ_id_seq', 1, false);


--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 260
-- Name: renting_instruments_renting_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.renting_instruments_renting_id_seq', 2, true);


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 272
-- Name: reservations_reserv_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservations_reserv_group_id_seq', 1, false);


--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 269
-- Name: reservations_reserv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservations_reserv_id_seq', 1, false);


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 273
-- Name: storage_places_place_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.storage_places_place_id_seq', 1, false);


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 263
-- Name: student_payment_st_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_payment_st_payment_id_seq', 8, true);


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 233
-- Name: student_student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_student_id_seq', 100, true);


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 234
-- Name: student_student_numb_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_student_numb_seq', 1, true);


--
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 241
-- Name: time_slot_slot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.time_slot_slot_id_seq', 1, false);


--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 225
-- Name: types_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.types_type_id_seq', 8, true);


-- Completed on 2024-12-01 21:08:46

--
-- PostgreSQL database dump complete
--

