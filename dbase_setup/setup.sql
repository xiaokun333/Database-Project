DROP TABLE IF EXISTS Euro_vaccine;
DROP TABLE IF EXISTS Euro_variant;
DROP TABLE IF EXISTS Global;
DROP TABLE IF EXISTS State_cases;
DROP TABLE IF EXISTS State_vaccines;
DROP TABLE IF EXISTS State_gdp;
DROP TABLE IF EXISTS States;


CREATE TABLE States(
       name VARCHAR(50),
       abv VARCHAR(5),
       latitude FLOAT,
       longitude FLOAT,
       population FLOAT,
       PRIMARY KEY(name)
);
CREATE TABLE State_cases (
       state VARCHAR(100),
       date DATETIME,
       confirmed FLOAT,
       deaths FLOAT,
       caseFatalityRatio FLOAT,
       PRIMARY KEY(state, date),
       FOREIGN KEY(state) REFERENCES States(name) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE State_vaccines (
       location VARCHAR(10),
       date VARCHAR(30),
       administered INT,
       administered12Plus INT,
       administered18Plus INT,
       administered65Plus INT,
       fullyVaccedPercent FLOAT,
       PRIMARY KEY(location, date)
);

CREATE TABLE State_gdp (
       state VARCHAR(100),
       2020Q1 INT,
       2020Q2 INT,
       2020Q3 INT,
       2020Q4 INT,
       2021Q1 INT,
       2021Q2 INT,
       2021Q3 INT,
       PRIMARY KEY(state),
       FOREIGN KEY(state) REFERENCES States(name) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE Global (
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
CREATE TABLE Euro_vaccine (
       country VARCHAR(100),
       vaccine_rate_cumulative FLOAT,
       date_ VARCHAR(30) DEFAULT '2022-04-08',
       PRIMARY KEY(country,date_),
       FOREIGN KEY(country,date_) REFERENCES Global(country_name,date_) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE Euro_variant (
       country VARCHAR(100),
       year_week VARCHAR(20),
       number_sequenced INT,
       variant VARCHAR(20),
       PRIMARY KEY(country, year_week),
       FOREIGN KEY(country,year_week) REFERENCES Global(country_name,date_) ON DELETE CASCADE ON UPDATE CASCADE
);

LOAD DATA LOCAL INFILE './data/states.txt'
INTO TABLE States
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './data/state_cases.txt'
INTO TABLE State_cases
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './data/state_vaccines.txt'
INTO TABLE State_vaccines
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './data/state_gdp.txt'
INTO TABLE State_gdp
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './data/global.txt'
INTO TABLE Global
FIELDS TERMINATED BY ' '
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './data/eu_vaccine.txt'
INTO TABLE Euro_vaccine
FIELDS TERMINATED BY ' '
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE './data/eu_variant.txt'
INTO TABLE Euro_variant
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