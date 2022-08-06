-- Finding all Covid Deaths WHERE Continent is known
SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- All Covid Vaccinations
--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- SELECT Data to be used

SELECT Location, date, total_Cases, new_Cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


-- Total Cases vs Total Deaths (Mortality of those who had COVID)
-- mortality of those who had covid in US
SELECT Location, date, total_cases, total_Deaths, round((total_deaths/total_cases)*100,4) as 'DeathPercentage'
FROM CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population contracted COVID

SELECT Location, date, total_cases, Population, round((total_cases/population)*100,4) as 'PercentPopulationInfected'
FROM CovidDeaths
--WHERE Location like '%states%'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to Population


SELECT Location, Population, max(total_cases) as 'HighestInfectionCount', max(round((total_cases/population)*100,4)) as 'PercentPopulationInfected'
FROM CovidDeaths
--WHERE Location like '%states%'
GROUP BY Location, Population
ORDER BY 'PercentPopulationInfected' DESC


-- Countries with Highest Death Count per Population


SELECT Location, max(cast(total_deaths as int)) as 'TotalDeathCount'
FROM CovidDeaths
--WHERE Location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY 'TotalDeathCount' DESC


-- Continents with Highest Death Count per Population

SELECT continent, max(cast(total_deaths as int)) as 'TotalDeathCount'
FROM CovidDeaths
--WHERE Location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY 'TotalDeathCount' DESC


-- || Global Numbers ||


SELECT sum(new_cases) 'total_cases', sum(cast(new_Deaths as int)) 'total_Deaths', sum(cast(new_Deaths as int))/sum(new_cases)*100 'DeathPercentage'
FROM CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations


SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(cast(v.new_vaccinations as int)) over (Partition by d.location ORDER BY d.location,d.date) as 'RollingPeopleVaccinated'
FROM CovidDeaths d
JOIN CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
	WHERE d.continent IS NOT NULL
ORDER BY 2,3



-- USE CTE for above query


With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(cast(v.new_vaccinations as int)) over (Partition by d.location ORDER BY d.location,d.date) as 'RollingPeopleVaccinated'
FROM CovidDeaths d
JOIN CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
	WHERE d.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location ORDER BY d.location,d.date) as 'RollingPeopleVaccinated'
FROM CovidDeaths d
JOIN CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
	WHERE d.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as


SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(cast(v.new_vaccinations as int)) over (Partition by d.location ORDER BY d.location,d.date) as 'RollingPeopleVaccinated'
FROM CovidDeaths d
JOIN CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
	WHERE d.continent IS NOT NULL
-- ORDER BY 2,3
