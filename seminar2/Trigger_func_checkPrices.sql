


CREATE OR REPLACE FUNCTION update_price_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Checking if the value needs to be updated
    IF NEW.price_id <> OLD.price_id THEN
        UPDATE complet_lessons
        SET price_id = (
            SELECT b.price_id
            FROM price a
            JOIN complet_lessons b ON a.lessons_id = b.lessons_id AND a.levels_id = b.levels_id
            WHERE a.price_finish = b.period_start
            LIMIT 1  -- Limit the result to just one line
        )
        WHERE price_id <> NEW.price_id;
		RAISE EXCEPTION '% The student must pay the fee on the date the lesson was taken!', OLD.price_id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_price_id_trigger
AFTER INSERT OR UPDATE ON complet_lessons
FOR EACH ROW
EXECUTE FUNCTION update_price_id();
















--Черновики

CREATE OR REPLACE FUNCTION save_price_id()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
    AS
    $$
BEGIN
IF (price_id = (
		select b.price_id 
		from price as a, admin_staff as b 
		where a.lessons_id=b.lessons_id and a.levels_id=b.levels_id 
		and a.price_finish = b.period_start))

AND(NEW.price_id <> OLD.price_id) THEN
        INSERT INTO admin_staff(price_id)
        VALUES(OLD.price_id );
        END IF;

RETURN NEW;
    END;
    $$

	
CREATE TRIGGER last_price_id
  BEFORE UPDATE
  ON admin_staff
  FOR EACH ROW
  EXECUTE PROCEDURE save_price_id();


DROP TRIGGER last_price_id ON price;
DROP TRIGGER last_price_id ON admin_staff;








CREATE OR REPLACE FUNCTION save_price_id()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
    AS
    $$
BEGIN
IF (price_id = (
		select b.price_id
		from price as a, admin_staff as b 
		where a.lessons_id=b.lessons_id and a.levels_id=b.levels_id 
		and a.price_finish = b.period_start
		group by b.price_id))

THEN
       
            RAISE EXCEPTION '% The number of musical', OLD.price_id;
        
        END IF;

RETURN OLD;
    END;
    $$



CREATE OR REPLACE TRIGGER last_price_id BEFORE UPDATE OF price_id OR INSERT ON admin_staff
    FOR EACH ROW EXECUTE FUNCTION save_price_id();








IF (period_start=(select b.period_start
from price as a, admin_staff as b 
where a.lessons_id=b.lessons_id and a.levels_id=b.levels_id 
and a.price_finish = b.period_start 
group by b.period_start))

and price_id = NEW.price_id

THEN
       
            RAISE EXCEPTION '% The number of musical', OLD.price_id;
        
        END IF;







