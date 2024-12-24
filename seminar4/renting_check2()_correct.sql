CREATE OR REPLACE FUNCTION renting_check2() RETURNS TRIGGER AS $$
DECLARE
    active_rentals_count INT;
BEGIN
    -- Only check the active rentals for new insertions, not updates
    IF TG_OP = 'INSERT' THEN
        -- Calculate the number of active rentals for a new instrument
        SELECT COUNT(*) INTO active_rentals_count
        FROM renting_instruments
        WHERE instrum_id = NEW.instrum_id
        AND (period_end IS NULL OR period_end >= CURRENT_DATE);  -- Consider only active rentals

        -- Check limit: if there are already 2 active rentals, raise an exception
        IF active_rentals_count >= 2 THEN
            RAISE EXCEPTION 'You need to specify the number of musical instruments from 0 to 2';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER renting_check2
BEFORE INSERT OR UPDATE ON renting_instruments
FOR EACH ROW EXECUTE FUNCTION renting_check2();
