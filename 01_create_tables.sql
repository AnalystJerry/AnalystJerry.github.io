-- Drop tables if they already exist
DROP TABLES IF EXISTS players, salaries, schools, school_details;

--
-- Table structure for table `players`
--

CREATE TABLE players (
    playerID VARCHAR(20) PRIMARY KEY,
    birthYear INT,
    birthMonth INT,
    birthDay INT,
    birthCountry VARCHAR(50),
    birthState VARCHAR(50),
    birthCity VARCHAR(50),
    deathYear INT,
    deathMonth INT,
    deathDay INT,
    deathCountry VARCHAR(50),
    deathState VARCHAR(50),
    deathCity VARCHAR(50),
    nameFirst VARCHAR(50),
    nameLast VARCHAR(50),
    nameGiven VARCHAR(100),
    weight INT,
    height INT,
    bats CHAR(1),
    throws CHAR(1),
    debut DATE,
    finalGame DATE,
    retroID VARCHAR(20),
    bbrefID VARCHAR(20)
);

--
-- Table structure for table `salaries`
--

CREATE TABLE salaries (
    yearID INT,
    teamID VARCHAR(3),
    lgID VARCHAR(2),
    playerID VARCHAR(20),
    salary INT,
    PRIMARY KEY (yearID, teamID, playerID)
);

--
-- Table structure for table `school_details`
--

CREATE TABLE school_details (
    schoolID VARCHAR(50) PRIMARY KEY,
    name_full VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(2),
    country VARCHAR(50)
);

--
-- Table structure for table `schools`
--

CREATE TABLE schools (
    playerID VARCHAR(50),
    schoolID VARCHAR(50),
    yearID INT,
    PRIMARY KEY (playerID, schoolID, yearID)
);