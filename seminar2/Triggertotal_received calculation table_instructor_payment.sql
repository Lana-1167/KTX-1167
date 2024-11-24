-- Trigger function for calculation total_received
CREATE OR REPLACE FUNCTION update_total_received()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;


-- Trigger to automatically call a function
CREATE TRIGGER trg_update_total_received
BEFORE INSERT OR UPDATE ON instructor_payment
FOR EACH ROW
EXECUTE FUNCTION update_total_received();