-- Create a trigger function to check the lease duration
CREATE OR REPLACE FUNCTION check_rental_duration()
RETURNS TRIGGER AS $$
BEGIN
    -- We check that the difference between the start and end dates of the lease does not exceed 12 months
  
    IF EXTRACT(YEAR FROM AGE(NEW.period_end, NEW.period_start)) * 12 + EXTRACT(MONTH FROM AGE(NEW.period_end, NEW.period_start)) > 12 THEN
        RAISE EXCEPTION 'Rental period cannot exceed 12 months.';
    END IF;


    -- If the check is passed, return NEW (data to insert or update)
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger that calls a function when a record is inserted or updated in the renting_instruments table
CREATE TRIGGER rental_duration_check
BEFORE INSERT OR UPDATE ON renting_instruments
FOR EACH ROW
EXECUTE FUNCTION check_rental_duration();
