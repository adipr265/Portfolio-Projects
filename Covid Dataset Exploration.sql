-- Writing queries to diaplay the imported data ordered by the location and date
-- Covid Deaths Data
SELECT *
FROM PORTFOLIO1.COVIDDEATHS
ORDER BY 4,5
;

-- Covid Vacinnations Data
SELECT *
FROM PORTFOLIO1.COVIDVACCINATIONS
ORDER BY 4,5
;

-- We are predominantly going to be using the Coviddeaths Dataset to analyze the damage caused by the covid-19 virus on the world's population
-- Task 1: Select the Data that we are going to be using
SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, POPULATION
FROM PORTFOLIO1.COVIDDEATHS
ORDER BY 1,2
;

-- Task 2: Looking at total cases vs total deaths to calculate the percentage of deaths for total cases of each country over time
-- Shows likelihood of dying if you contract cowid in your country
SELECT LOCATION, DATE, TOTAL_DEATHS, TOTAL_CASES, (TOTAL_DEATHS/TOTAL_CASES)*100 AS DEATH_PERCENTAGE
FROM PORTFOLIO1.COVIDDEATHS
ORDER BY 1,2
;

-- Lets formulate the death percentage only for Sweden
SELECT LOCATION, DATE, TOTAL_CASES, TOTAL_DEATHS, (TOTAL_DEATHS/TOTAL_CASES)*100 AS DEATH_PERCENTAGE
FROM PORTFOLIO1.COVIDDEATHS
WHERE LOCATION = 'SWEDEN'
ORDER BY 1,2 
;

-- Task 3: Looking at total cases vs populations to calculate the percentage of people infected with covid-19 at any given time
SELECT LOCATION, DATE, POPULATION, TOTAL_CASES, (TOTAL_CASES/POPULATION)*100 AS INFECTED_RATE
FROM PORTFOLIO1.COVIDDEATHS
ORDER BY 1,2
;

-- Lets formulate the infected rates only for Sweden
SELECT LOCATION, DATE, POPULATION, TOTAL_CASES, (TOTAL_CASES/POPULATION)*100 AS INFECTED_RATE
FROM PORTFOLIO1.COVIDDEATHS
WHERE LOCATION = 'SWEDEN'
ORDER BY 1,2 
;

-- Task 4: Looking at countries with the highest infection rates compared to population
SELECT LOCATION, POPULATION, MAX(TOTAL_CASES) AS TOTAL_CASES, MAX((TOTAL_CASES/POPULATION)*100) AS INFECTION_RATE
FROM PORTFOLIO1.COVIDDEATHS
GROUP BY LOCATION
ORDER BY 4 DESC
;

-- Task 5: Showing the countries with the highest death count
-- We observe some anomaly in the observed result with the location names hence we add the "where continent is not null" line
SELECT LOCATION, MAX(TOTAL_DEATHS) AS TOTAL_DEATH_COUNT
FROM PORTFOLIO1.COVIDDEATHS
WHERE CONTINENT IS NOT NULL
GROUP BY LOCATION
ORDER BY 2 DESC
;

-- Lets formulate the highest death count by continent
SELECT CONTINENT, MAX(TOTAL_DEATHS) AS TOTAL_DEATH_COUNT
FROM PORTFOLIO1.COVIDDEATHS
WHERE CONTINENT IS NOT NULL
GROUP BY CONTINENT
ORDER BY 2 DESC
;

-- Task 6: Showing the countries with the highest death percentages per population
SELECT LOCATION, POPULATION, MAX(TOTAL_DEATHS) AS TOTAL_DEATHS, MAX((TOTAL_DEATHS/POPULATION)*100) AS PERCENT_POPULATION_DIED
FROM PORTFOLIO1.COVIDDEATHS
GROUP BY LOCATION
ORDER BY 4 DESC
;

-- Task 7: Generating the Global death percentage numbers
SELECT DATE, SUM(NEW_CASES) AS CASES, SUM(NEW_DEATHS) AS DEATHS, (SUM(NEW_DEATHS)/SUM(NEW_CASES))*100 AS DEATH_PERCENTAGE
FROM PORTFOLIO1.COVIDDEATHS
WHERE CONTINENT IS NOT NULL
GROUP BY DATE
ORDER BY 1
;

-- Task 8: Looking at total population vs vaccination by joining the cowiddeaths and cowidvaccinations tables
-- Using a CTE in order to perform calculations on a derived column
WITH POPVSVAC(CONTINENT, LOCATION, DATE, POPULATION, NEW_VACCINATIONS, ROLLING_SUM_VACCINATIONS)
AS
(
SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, VAC.NEW_VACCINATIONS
, SUM(VAC.NEW_VACCINATIONS) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLING_SUM_VACCINATIONS
FROM PORTFOLIO1.COVIDDEATHS DEA
JOIN PORTFOLIO1.COVIDVACCINATIONS VAC
    ON DEA.LOCATION = VAC.LOCATION
    AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
)
SELECT *, ((ROLLING_SUM_VACCINATIONS)*100)/2 AS PERCENTAGE_PEOPLE_VACCINATED
FROM POPVSVAC
ORDER BY 2,3
;

-- Using a TEMP TABLE: another way to perform calculations on a derived column
DROP TEMPORARY TABLE IF EXISTS PEOPLE_VACCINATED;
CREATE TEMPORARY TABLE PEOPLE_VACCINATED AS
(
SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, VAC.NEW_VACCINATIONS
, SUM(VAC.NEW_VACCINATIONS) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLING_SUM_VACCINATIONS
FROM PORTFOLIO1.COVIDDEATHS DEA
JOIN PORTFOLIO1.COVIDVACCINATIONS VAC
    ON DEA.LOCATION = VAC.LOCATION
    AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
);
SELECT *, ((ROLLING_SUM_VACCINATIONS/POPULATION)*100)/2 AS PERCENTAGE_PEOPLE_VACCINATED
FROM PEOPLE_VACCINATED
ORDER BY 2,3
;

-- Task9: Creating a View to store data for later visualizations
CREATE VIEW PEOPLE_VACCINATED AS
SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, VAC.NEW_VACCINATIONS
, SUM(VAC.NEW_VACCINATIONS) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLING_SUM_VACCINATIONS
FROM PORTFOLIO1.COVIDDEATHS DEA
JOIN PORTFOLIO1.COVIDVACCINATIONS VAC
    ON DEA.LOCATION = VAC.LOCATION
    AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
;
   