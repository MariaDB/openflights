-- Checks that every table holds as many rows as its data file has lines.
-- Run after sql/load-data.sql; docker/init.sh runs it automatically.
--
-- Prints one line per table with OK or MISMATCH. It never fails on a
-- mismatch, so a partial load still leaves you with a usable database
-- (and a visible warning) instead of an aborted container.
--
-- The expected counts are `wc -l data/<table>.dat`. Update them when a
-- data file changes.

USE flightdb2;

SELECT 'Verifying row counts...' AS '';

SELECT 'airports'  AS `table`, 7698  AS expected, COUNT(*) AS actual, IF(COUNT(*) = 7698,  'OK', 'MISMATCH') AS status FROM airports
UNION ALL
SELECT 'airlines',            6162,              COUNT(*),           IF(COUNT(*) = 6162,  'OK', 'MISMATCH')           FROM airlines
UNION ALL
SELECT 'routes',              67663,             COUNT(*),           IF(COUNT(*) = 67663, 'OK', 'MISMATCH')           FROM routes
UNION ALL
SELECT 'countries',           261,               COUNT(*),           IF(COUNT(*) = 261,   'OK', 'MISMATCH')           FROM countries
UNION ALL
SELECT 'planes',              246,               COUNT(*),           IF(COUNT(*) = 246,   'OK', 'MISMATCH')           FROM planes;

SELECT 'Done.' AS '';
