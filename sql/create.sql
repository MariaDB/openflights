CREATE DATABASE IF NOT EXISTS flightdb2;

USE flightdb2;

DROP TABLE IF EXISTS `routes`;
DROP TABLE IF EXISTS `airlines`;
DROP TABLE IF EXISTS `airports`;
DROP TABLE IF EXISTS `countries`;
DROP TABLE IF EXISTS `planes`;
DROP TABLE IF EXISTS `locales`;

CREATE TABLE `airlines` (
  `alid`         int(11)      NOT NULL AUTO_INCREMENT,
  `name`         text,
  `alias`        text,
  `iata`         varchar(2)   DEFAULT NULL,
  `icao`         varchar(3)   DEFAULT NULL,
  `callsign`     text,
  `country`      text,
  `country_code` varchar(2),
  `uid`          int(11)      DEFAULT NULL,
  `mode`         char(1)      DEFAULT 'F',
  `active`       varchar(1)   DEFAULT 'N',
  `source`       text,
  `frequency`    int(11)      DEFAULT 0,
  PRIMARY KEY (`alid`),
  KEY `iata` (`iata`),
  KEY `icao` (`icao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `airports` (
  `apid`         int(11)      NOT NULL AUTO_INCREMENT,
  `name`         text         NOT NULL,
  `city`         text,
  `country`      text,
  `country_code` varchar(2),
  `iata`         varchar(3)   DEFAULT NULL,
  `icao`         varchar(4)   DEFAULT NULL,
  `latitude`     double       NOT NULL,
  `longitude`    double       NOT NULL,
  `elevation`    int(11)      DEFAULT NULL,
  `uid`          int(11)      DEFAULT NULL,
  `timezone`     float        DEFAULT NULL,
  `dst`          char(1)      DEFAULT NULL,
  `tz_id`        text,
  `type`         text,
  `source`       text,
  PRIMARY KEY (`apid`),
  KEY `latitude` (`latitude`),
  KEY `longitude` (`longitude`),
  KEY `iata` (`iata`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `countries` (
  `dafif_code`   varchar(2)   NOT NULL,
  `name`         text,
  `iso_code`     varchar(2)   DEFAULT NULL,
  PRIMARY KEY (`dafif_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `planes` (
  `plid`         int(11)      NOT NULL AUTO_INCREMENT,
  `name`         varchar(80),
  `iata`         text         DEFAULT NULL,
  `icao`         text         DEFAULT NULL,
  `abbr`         text,
  `speed`        double       DEFAULT NULL,
  `public`       char(1)      DEFAULT 'N',
  `frequency`    int(11)      DEFAULT 0,
  PRIMARY KEY (`plid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `routes` (
  `rid`          int(11)      NOT NULL AUTO_INCREMENT,
  `airline`      varchar(3)   DEFAULT NULL,
  `alid`         int(11)      DEFAULT NULL,
  `src_ap`       varchar(4)   DEFAULT NULL,
  `src_apid`     int(11)      DEFAULT NULL,
  `dst_ap`       varchar(4)   DEFAULT NULL,
  `dst_apid`     int(11)      DEFAULT NULL,
  `codeshare`    text,
  `stops`        text,
  `equipment`    text,
  `added`        varchar(1)   DEFAULT NULL,
  PRIMARY KEY (`rid`),
  UNIQUE KEY `alid` (`alid`, `src_apid`, `dst_apid`),
  KEY `src_apid` (`src_apid`),
  KEY `dst_apid` (`dst_apid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `locales` (
  `locale`       varchar(5)   NOT NULL,
  `name`         text,
  PRIMARY KEY (`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SELECT 'Done. Next: run sql/load-data.sql' AS '';
