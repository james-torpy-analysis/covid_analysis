-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (1.0*total_deaths)/(1.0*total_cases)*100
AS death_percentage
FROM CovidDeaths
WHERE location LIKE 'Australia'
ORDER BY 1,2;

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (1.0*total_cases)/(1.0*population)*100
AS infection_percentage
FROM CovidDeaths
WHERE location = 'Australia'
ORDER BY 1,2;

-- Looking at Countires with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as highest_infection_count, 
MAX((1.0*total_cases)/(1.0*population))*100 AS percent_population_infected
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;

-- Showing Countries with Highest Death Count per Population
SELECT location, population, MAX(total_deaths) as total_death_count, 
MAX((CAST(total_deaths as FLOAT(3)))/(CAST(population as FLOAT(3))))*100 AS percent_population_deaths
FROM CovidDeaths
WHERE total_deaths IS NOT null AND population IS NOT null AND continent IS NOT null
GROUP BY location, population
ORDER BY 3 DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
SUM(1.0*new_deaths)/SUM(1.0*new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT null AND new_cases IS NOT null
GROUP BY date
ORDER BY 1;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
SUM(1.0*new_deaths)/SUM(1.0*new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT null AND new_cases IS NOT null
ORDER BY 1;


-- Looking at Total Population vs Vaccinations
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
)
SELECT *, ((1.0*RollingPeopleVaccinated)/(1.0*Population))*100
FROM PopvsVac;

-- TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date DATE,
Population NUMERIC,
NewVaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null;

SELECT *, ((1.0*RollingPeopleVaccinated)/(1.0*Population))*100
FROM PercentPopulationVaccinated;

--Creating view to store for later visualisations:
DROP VIEW IF EXISTS PercentPopulationVaccinatedView;
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null;

SELECT * FROM PercentPopulationVaccinatedView;
