use wallet_analysis;

describe books2;

-- Getting a foreign key constraint name
SELECT
	CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM
	INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
	REFERENCED_TABLE_NAME IS NOT NULL
    AND
    TABLE_SCHEMA = 'wallet_analysis'
    AND
    TABLE_NAME = 'books2';

-- Dropping a foreign key constraint
alter table books2 drop foreign key books2_ibfk_1;
