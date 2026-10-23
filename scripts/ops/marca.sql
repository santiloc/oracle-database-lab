-- scripts/ops/marca.sql
-- Define la marca temporal usada para nombrear las evidencias del Lab 4.
SET FEEDBACK OFF
SET VERIFY OFF
COLUMN marca NEW_VALUE marca
SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYYMMDD"T"HH24MISS"Z"') AS marca
FROM dual;
SET FEEDBACK ON
