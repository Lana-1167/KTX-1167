
--VIEW №1

CREATE OR REPLACE VIEW lessons_summary AS
SELECT 
     TO_CHAR(period_start, 'Mon') AS month,
     SUM(COUNT(*) FILTER (WHERE lessons_id = 1)) OVER () 
     AS individual,
     SUM(COUNT(*) FILTER (WHERE lessons_id = 2)) OVER () 
     AS group_lessons,
     SUM(COUNT(*) FILTER (WHERE lessons_id = 3)) OVER () 
     AS ensemble,
     SUM(COUNT(*)) OVER () AS total
FROM complet_lessons
WHERE EXTRACT(YEAR FROM period_start) = 2024
GROUP BY TO_CHAR(period_start, 'Mon'), EXTRACT(MONTH FROM period_start)
ORDER BY EXTRACT(MONTH FROM period_start);



--VIEW №2

CREATE OR REPLACE VIEW siblings_students AS
SELECT
    no_of_siblings,  -- Number of brothers and sisters
    COUNT(*) AS number_of_students  -- Number of students for a given number of siblings
FROM (
    SELECT 
        s1.student_numb,
        COUNT(s2.person_sibling) AS no_of_siblings  -- Number of brothers and sisters
    FROM student s1
    LEFT JOIN sibling s2
        ON s1.student_numb = s2.student_numb OR s2.person_sibling =s1.student_numb
    GROUP BY s1.student_numb
) AS sibling_counts
GROUP BY no_of_siblings
ORDER BY no_of_siblings;


--VIEW №3

CREATE OR REPLACE VIEW list_instructors  AS
SELECT
    i.instruktor_numb,
    i.name_inst,
    i.surname_inst,
    COUNT(a.lessons_id) AS lesson_count
FROM instructor i
LEFT JOIN complet_lessons a 
    ON i.instruktor_numb = a.instructor_id
   AND EXTRACT(MONTH FROM a.period_start) = EXTRACT(MONTH FROM CURRENT_DATE) -- Current month
   AND EXTRACT(YEAR FROM a.period_start) = EXTRACT(YEAR FROM CURRENT_DATE)   -- Current year
GROUP BY i.instruktor_numb, i.name_inst, i.surname_inst
HAVING COUNT(a.lessons_id) > 3  -- Condition: more than 3 lessons
ORDER BY lesson_count DESC;  -- Sort by number of lessons


--VIEW №4

CREATE OR REPLACE VIEW list_ensembles  AS
SELECT
    TO_CHAR(e.data_ensem, 'Day') AS day_of_week,  -- Day of the week
    g.gentre_ensembles AS genre,                 -- Musical genre
    CASE
        WHEN (e.max_students - COALESCE(SUM(r.actual_seats), 0)) = 0 THEN 'No seats available'  -- If there are no vacancies
        WHEN (e.max_students - COALESCE(SUM(r.actual_seats), 0)) <= 2 THEN '1 or 2 places'       -- If there are 1 or 2 places left
        ELSE 'Lots of places'                              -- If there are 1 or 2 places left
    END AS available_seats
FROM ensemble e
LEFT JOIN actual_seats_ensemble r ON e.ensem_id = r.reserv_id
LEFT JOIN ensemble_genre g ON e.ensembles_id = g.ensembles_id  -- Linking genres
WHERE e.data_ensem <= CURRENT_DATE + INTERVAL '1 day'          -- Beginning of next week
   AND e.data_ensem < CURRENT_DATE + INTERVAL '8 days'         -- End of next week
GROUP BY e.ensem_id, g.gentre_ensembles, e.data_ensem
ORDER BY g.gentre_ensembles, TO_CHAR(e.data_ensem, 'D');       -- Sort by genre and day of the week



