SELECT *
FROM PortfolioProject1.dbo.CovidDeaths
Where continent is not NULL
Order by 3,4

--SELECT *
--FROM PortfolioProject1.dbo.CovidVaccinations
--Order by 3,4

--Select data that we are going to be using

SELECT location, 
		date, 
		total_cases, 
		new_cases, 
		total_deaths, 
		population
FROM PortfolioProject1.dbo.CovidDeaths
Order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, 
		date,
		total_cases,  
		total_deaths, 
		(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at the Total Cases Vs Population
--Shows what percentage of population got Covid

SELECT location, 
		date, 
		total_cases, 
		population, 
		(total_cases/population)*100 As InfectedPopulationPercentage
FROM PortfolioProject1.dbo.CovidDeaths
--Where location like '%states%'
Order by 1,2

-- Looking at countries with the highest infection rate as compared to population

SELECT location, 
		MAX(total_cases) AS HighestInfectionCount, 
		population, 
		MAX((total_cases/population))*100 As InfectedPopulationPercentage
FROM PortfolioProject1.dbo.CovidDeaths
--Where location like '%states%'
Group by location, population
Order by InfectedPopulationPercentage DESC

-- Showing countries with Highest Death Count per population

--SELECT location, 
--		MAX(CAST(total_deaths as INT)) AS TotalDeathCount
--FROM PortfolioProject1.dbo.CovidDeaths
----Where location like '%states%'
--Where continent is not NULL
--Group by location
--Order by TotalDeathCount DESC

-- Let's break things down by continent

--Showing continents with Highest Death Count per population

SELECT continent, 
		MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not NULL
Group by continent
Order by TotalDeathCount DESC


--Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as INT)) As total_deaths, (SUM(Cast(new_deaths as INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
Where continent is not NULL
GROUP BY date
ORDER BY 1,2 

SELECT SUM(new_cases) as total_cases, SUM(Cast(new_deaths as INT)) As total_deaths, (SUM(Cast(new_deaths as INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
Where continent is not NULL
ORDER BY 1,2 

--Joining the two tables

--Looking at total population vs vaccinations

SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
Order by 3,2


--Looking at total_new_vaccinations by location

SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
Order by 3,2

--USE CTE as we cannot use column we just created 

With PopVsVac(continent, date, location, population, new_vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--Order by 3,2
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

-- shows 12% of population is vaccinated in Albania


--TEMP TABLE to do the same thing as CTE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
date datetime, 
location nvarchar(255),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not NULL
--Order by 3,2

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1.dbo.CovidDeaths dea
JOIN PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--Order by 3,2

SELECT * 
FROM PercentPopulationVaccinated