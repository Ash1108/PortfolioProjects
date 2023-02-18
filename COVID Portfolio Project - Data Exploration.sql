--select data from coviddeaths table

SELECT *
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL;

--select data from covidvaccinations table

SELECT * 
FROM [PortfolioProject].[dbo].[CovidVaccinations]
WHERE continent IS NOT NULL;

-- select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE location = 'india'
AND continent IS NOT NULL
ORDER BY 1,2;

-- looking at total cases vs population
-- shows what percentage of population got covid in your country

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'india'
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population)*100) AS percent_population_infected
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'india'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

-- showing countries with highest death count per population

SELECT location, population, MAX(cast(total_deaths AS int)) AS highest_death_count
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'india'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_death_count DESC;

-- LET'S BREAK THINGS BY CONTINENT

-- showing the continent with highest death count

SELECT continent, MAX(cast(total_deaths AS int)) AS highest_death_count
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'india'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC;


-- GLOBAL NUMBERS (ACROSS WORLD)

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS death_percentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'india'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- overall cases and deaths across the world

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS death_percentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'india'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

-- Joining two tables
-- looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --per day
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
ORDER BY 2,3;

-- use CTE(Common Table Expressions)

WITH PopvsVac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --per day
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- ORDER BY 2,3
)
SELECT * , (rolling_people_vaccinated/population)*100 AS people_vaccinated_percent
FROM PopvsVac


-- use TEMP TABLE

DROP TABLE IF EXISTS #PersonPopulationVaccinated
CREATE TABLE #PersonPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PersonPopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --per day
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100 AS people_vaccinated_percent
FROM #PersonPopulationVaccinated


-- creating views to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --per day
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL ;

SELECT *
FROM PercentPopulationVaccinated;
