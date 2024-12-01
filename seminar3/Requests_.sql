--Request №1

SELECT 
    TO_CHAR(period_start, 'Mon') AS month, 	-- Extracting the month in abbreviation format
    SUM(COUNT(*) FILTER (WHERE lessons_id = 1)) OVER () AS individual, 	-- Number of individual lessons
    SUM(COUNT(*) FILTER (WHERE lessons_id = 2)) OVER () AS group_lessons, 	-- Number of group lessons
    SUM(COUNT(*) FILTER (WHERE lessons_id = 3)) OVER () AS ensemble,	-- Number of ensemble lessons
    SUM(COUNT(*)) OVER () AS total  	-- Total number of lessons
FROM complet_lessons
WHERE EXTRACT(YEAR FROM period_start) = 2024	-- Filter by year (2024)
GROUP BY TO_CHAR(period_start, 'Mon'), EXTRACT(MONTH FROM period_start) 	-- Group by month
ORDER BY EXTRACT(MONTH FROM period_start);	-- Sort by month order



--Request №2

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





--Request №3
--In the condition:
--List all ensembles held during the next week, sorted by music genre and weekday.
--It will not be possible to check the data for the current month and year, since such data is not available. 
--But such a request looks like this:

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




--Request №3
--To make sure the data is there, let's run a query to check, 
--replacing the current month with a static one. 


SELECT
    i.instruktor_numb,
    i.name_inst,
    i.surname_inst,
    COUNT(a.lessons_id) AS lesson_count
FROM instructor i
LEFT JOIN complet_lessons a 
    ON i.instruktor_numb = a.instructor_id
  AND EXTRACT(MONTH FROM a.period_start) = 9  -- Let's replace it with the required month
  AND EXTRACT(YEAR FROM a.period_start) = 2024 -- Let's replace it with the required year 
GROUP BY i.instruktor_numb, i.name_inst, i.surname_inst
HAVING COUNT(a.lessons_id) > 3  -- Condition: more than 3 lessons
ORDER BY lesson_count DESC;  -- Sort by number of lessons






--Request №4

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
