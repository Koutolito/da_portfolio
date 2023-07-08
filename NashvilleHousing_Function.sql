CREATE or ALTER FUNCTION GET_COLUMN_TYPE
(
@Column_name varchar,
@Table_name varchar
)
RETURNS varchar   --returns float type value
    AS 
    BEGIN
        DECLARE @DATA_TYPE varchar =''; --declares float variable 
        -- retrieves average salary and assign it to a variable 
			SELECT
			@DATA_TYPE = DATA_TYPE
			FROM INFORMATION_SCHEMA.COLUMNS 
			WHERE TABLE_NAME = @Table_name 
			AND COLUMN_NAME = @Column_name
    
        RETURN @DATA_TYPE; --returns a value
    END;