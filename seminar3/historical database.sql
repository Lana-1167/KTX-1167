CREATE TABLE historical_lessons (
lesson_id SERIAL PRIMARY KEY,
lesson_date DATE NOT NULL,
lesson_type VARCHAR(20) NOT NULL,
genre VARCHAR(50),
instrument VARCHAR(50),
lesson_price DECIMAL(10, 2) NOT NULL,
student_firstname VARCHAR(100) NOT NULL,
student_surname VARCHAR(100) NOT NULL,
student_email VARCHAR(100) NOT NULL
);




INSERT INTO historical_lessons (lesson_date, lesson_type, genre, instrument, 
lesson_price, student_firstname, student_surname, student_email)
SELECT 
    i.period_start, 
    'Individual' AS lesson_type, 
    'No genre' AS genre,
    m.instruments,
    p.price_service,
    s.firstname,
    s.surname,
    c.e_mail
FROM booking_individual i
LEFT JOIN student s 
    ON i.student_numb = s.student_numb
LEFT JOIN contact_detail c 
    ON s.details_id = c.contact_id
LEFT JOIN mus_instruments m 
    ON i.instrument_id = m.instrument_id
LEFT JOIN price p 
    ON i.lessons_id = p.lessons_id  
    AND i.level_id = p.levels_id     
WHERE i.lessons_id = 1 
  AND i.level_id IN (1, 2, 3);  




INSERT INTO historical_lessons (lesson_date, lesson_type, genre, instrument, lesson_price, 
student_firstname, student_surname, student_email)

SELECT 
    g.data_group, 
    'Group' AS lesson_type, 
    'No genre' AS Genre,
    m.instruments,
    p.price_service,
    s.firstname,
    s.surname,
    c.e_mail
FROM group_lessons g
LEFT JOIN student s 
    ON g.students_numb = s.student_numb
LEFT JOIN contact_detail c 
    ON s.details_id = c.contact_id
LEFT JOIN mus_instruments m 
    ON g.instrument_id = m.instrument_id
LEFT JOIN price p 
    ON g.lessons_id = p.lessons_id  
WHERE g.lessons_id = 2;      
  




INSERT INTO historical_lessons (lesson_date, lesson_type, genre, instrument, lesson_price, student_firstname, student_surname, student_email)
SELECT 
    e.data_ensem, 
    'Ensemble' AS lesson_type, 
    gg.gentre_ensembles AS genre,
    'Different musical instruments' AS instrument,
    p.price_service,
    s.firstname,
    s.surname,
    c.e_mail
FROM ensemble e
LEFT JOIN student s 
    ON e.students_numb = s.student_numb
LEFT JOIN contact_detail c 
    ON s.details_id = c.contact_id
LEFT JOIN ensemble_genre gg 
    ON e.ensembles_id = gg.ensembles_id
LEFT JOIN price p 
    ON e.lessons_id = p.lessons_id  
    WHERE e.lessons_id = 3; 

	
select * from public.historical_lessons;