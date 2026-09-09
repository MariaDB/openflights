USE flightdb2;

SELECT 'Importing airlines...' AS '';
LOAD DATA LOCAL INFILE 'data/airlines.dat'
REPLACE INTO TABLE airlines
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(alid, name, alias, iata, icao, callsign, country, active);

SELECT 'Importing airports...' AS '';
LOAD DATA LOCAL INFILE 'data/airports.dat'
REPLACE INTO TABLE airports
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(apid, name, city, country, iata, icao, y, x, elevation, timezone, dst, tz_id, type, source);

SELECT 'Importing routes...' AS '';
LOAD DATA LOCAL INFILE 'data/routes.dat'
REPLACE INTO TABLE routes
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(airline, alid, src_ap, src_apid, dst_ap, dst_apid, codeshare, stops, equipment);

SELECT 'Importing countries...' AS '';
LOAD DATA LOCAL INFILE 'data/countries.dat'
REPLACE INTO TABLE countries
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(name, iso_code, dafif_code);

SELECT 'Importing planes...' AS '';
LOAD DATA LOCAL INFILE 'data/planes.dat'
REPLACE INTO TABLE planes
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(name, iata, icao);

SELECT 'Importing locales...' AS '';
LOAD DATA LOCAL INFILE 'data/locales.dat'
REPLACE INTO TABLE locales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(locale, name);

SELECT 'Done.' AS '';
