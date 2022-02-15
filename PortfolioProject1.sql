SELECT *
FROM ProjectPortfolio1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if youn contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM ProjectPortfolio1..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of Population got Covid

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercentPoulationInfected
FROM ProjectPortfolio1..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM ProjectPortfolio1..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM ProjectPortfolio1..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM ProjectPortfolio1..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM ProjectPortfolio1..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
FROM ProjectPortfolio1..CovidDeaths dea
JOIN ProjectPortfolio1..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac( Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) 
AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population) * 100
FROM ProjectPortfolio1..CovidDeaths dea
JOIN ProjectPortfolio1..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) 
AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population) * 100
FROM ProjectPortfolio1..CovidDeaths dea
JOIN ProjectPortfolio1..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentagePopulationVaccinated

-- Creating View to Store Data for later Visualizations

CREATE VIEW PercentagePopulationVaccinated AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) 
AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population) * 100
FROM ProjectPortfolio1..CovidDeaths dea
JOIN ProjectPortfolio1..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
