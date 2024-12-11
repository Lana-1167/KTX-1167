CREATE OR REPLACE FUNCTION renting_check2() RETURNS TRIGGER AS $$
DECLARE
    active_rentals_count INT;
BEGIN
    -- Calculate the number of active rentals for a new instrument
    SELECT COUNT(*) INTO active_rentals_count
    FROM renting_instruments
    WHERE instrum_id = NEW.instrum_id AND period_end >= CURRENT_DATE;

    -- Check limit
    IF active_rentals_count >= 2 THEN
        RAISE EXCEPTION 'You need to specify the number of musical instruments from 0 to 2';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER renting_check2
BEFORE INSERT OR UPDATE ON renting_instruments
FOR EACH ROW EXECUTE FUNCTION renting_check2();
