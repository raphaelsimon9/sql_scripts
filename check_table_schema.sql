-- Check all columns that have a particular column_name in a particular schema
SELECT	TABLE_NAME
FROM	INFORMATION_SCHEMA.COLUMNS
WHERE	COLUMN_NAME = 'salary'
AND		TABLE_SCHEMA = 'sales';