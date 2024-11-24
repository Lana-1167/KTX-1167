-- Trigger function for calculating total_paid
CREATE OR REPLACE FUNCTION update_total_paid()
RETURNS TRIGGER AS $$
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
        sibling_discount := 0.05; -- discount 5%
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
    NEW.total_paid := NEW.total_numb_classes * service_price * (1 + sibling_count * (1 - sibling_discount));

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Trigger to automatically call a function
CREATE TRIGGER trg_update_total_paid
BEFORE INSERT OR UPDATE ON student_payment
FOR EACH ROW
EXECUTE FUNCTION update_total_paid();