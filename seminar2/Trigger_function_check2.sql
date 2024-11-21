CREATE FUNCTION renting_check() RETURNS trigger AS $renting_check$
    BEGIN
        
        IF NEW.quantity_instruments IS NULL THEN
            RAISE EXCEPTION '% You need to specify the number of musical instruments from 0 to 2', NEW.quantity_instruments;
        END IF;
        IF NEW.quantity_instruments > 2 THEN
            RAISE EXCEPTION '% The number of musical instruments should not be more than 2', NEW.quantity_instruments;
        END IF;
    
    RETURN NEW;
    END;
$renting_check$ LANGUAGE plpgsql;






CREATE OR REPLACE TRIGGER renting_check BEFORE UPDATE OF quantity_instruments OR INSERT ON renting_instruments
    FOR EACH ROW EXECUTE FUNCTION renting_check();