-- Michael Klisiwecz (mklisiw1)
-- Xiaokun Yu(xyu61)

DROP TABLE IF EXISTS Euro_vaccine_small;
DROP TABLE IF EXISTS Euro_variant_small;
DROP TABLE IF EXISTS Global_small;
DROP TABLE IF EXISTS State_cases_small;
DROP TABLE IF EXISTS State_vaccines_small;
DROP TABLE IF EXISTS State_gdp_small;
DROP TABLE IF EXISTS States_small;


CREATE TABLE States_small (
       name VARCHAR(50),
       abv VARCHAR(5),
       latitude FLOAT,
       longitude FLOAT,
       population FLOAT,
       PRIMARY KEY(name)
);
CREATE TABLE State_cases_small (
       state VARCHAR(100),
       date DATETIME,
       confirmed FLOAT,
       deaths FLOAT,
       caseFatalityRatio FLOAT,
       PRIMARY KEY(state, date),
       FOREIGN KEY(state) REFERENCES States_small(name) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE State_vaccines_small (
       location VARCHAR(10),
       date VARCHAR(30),
       administered INT,
       administered12Plus INT,
       administered18Plus INT,
       administered65Plus INT,
       fullyVaccedPercent FLOAT,
       PRIMARY KEY(location, date)
);

CREATE TABLE State_gdp_small (
       state VARCHAR(100),
       2020Q1 INT,
       2020Q2 INT,
       2020Q3 INT,
       2020Q4 INT,
       2021Q1 INT,
       2021Q2 INT,
       2021Q3 INT,
       PRIMARY KEY(state),
       FOREIGN KEY(state) REFERENCES States_small(name) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Global_small (
        country_name VARCHAR(100),
        latitude FLOAT,
        longitude FLOAT,
        date_ VARCHAR(10),
        population INT,
        cases INT,
        deaths INT,
        case_fatality_ration FLoat,
        PRIMARY KEY(country_name, date_)
);
CREATE TABLE Euro_vaccine_small(
       country VARCHAR(100),
       vaccine_rate_cumulative FLOAT,
       date_ VARCHAR(30) DEFAULT '2022-04-08',
       PRIMARY KEY(country,date_),
       FOREIGN KEY(country,date_) REFERENCES Global_small(country_name,date_) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE Euro_variant_small(
       country VARCHAR(100),
       year_week VARCHAR(20),
       number_sequenced INT,
       variant VARCHAR(20),
       PRIMARY KEY(country, year_week),
       FOREIGN KEY(country,year_week) REFERENCES Global_small(country_name,date_) ON DELETE CASCADE ON UPDATE CASCADE
);


LOAD DATA LOCAL INFILE './small_data/states_small.txt'
INTO TABLE States_small
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './small_data/state_cases_small.txt'
INTO TABLE State_cases_small
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './small_data/state_vaccines_small.txt'
INTO TABLE State_vaccines_small
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './small_data/state_gdp_small.txt'
INTO TABLE State_gdp_small
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './small_data/global_small.txt'
INTO TABLE Global_small
FIELDS TERMINATED BY ' '
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './small_data/eu_vaccine_small.txt'
INTO TABLE Euro_vaccine_small
FIELDS TERMINATED BY ' '
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './small_data/eu_variant_small.txt'
INTO TABLE Euro_variant_small
FIELDS TERMINATED BY ' '
IGNORE 1 ROWS;

-- INSERTION


DELIMITER //
DROP PROCEDURE IF EXISTS insertValues //
CREATE PROCEDURE insertValues(IN newState VARCHAR(40), IN newDate VARCHAR(30), IN newConfirmed INT, IN newDeath INT, IN newRatio DECIMAL(5,3))
BEGIN
        IF EXISTS(SELECT * FROM States WHERE name = newState) THEN
                INSERT INTO State_cases
                VALUES (newState, newDate, newConfirmed, newDeath, newRatio);
		SELECT "Successful!" AS message;
        ELSE
		SELECT "ERROR: Invalid State" AS message;
        END IF;
END; //
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS insertGlobalData //
CREATE PROCEDURE insertGlobalData(IN new_country VARCHAR(100), IN new_year_week VARCHAR(10), IN cases INT,IN deaths INT,IN case_fat_ratio DECIMAL(5,3))
BEGIN
        IF EXISTS(SELECT * FROM Global AS G WHERE G.country_name = new_country AND G.date_ = new_year_week) THEN
		SELECT "ERROR: Data already exists for this date and time" AS message;
        ELSE
		INSERT INTO Global
		VALUES(new_country, null,null, new_year_week, 0,cases,deaths, case_fat_ratio);
                SELECT "Success!" as message;
        END IF;
END; //
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS insertVarEU //
CREATE PROCEDURE insertVarEU(IN new_country VARCHAR(100), IN new_year_week VARCHAR(20), IN new_number_seq INT,IN new_var VARCHAR(20))
BEGIN
        IF EXISTS(SELECT * FROM Global AS G WHERE G.country_name = new_country \
AND G.date_ = new_year_week)\
 THEN
                INSERT INTO Euro_variant
                VALUES (new_country, new_year_week, new_number_seq, new_var);
		SELECT "Success!" AS message;
        ELSE
                SELECT "ERROR: country and date must match values in global dataset" AS message;
        END IF;
END; //
DELIMITER ;