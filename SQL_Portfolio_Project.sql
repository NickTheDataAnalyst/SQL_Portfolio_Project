SELECT *
FROM [Portfolio Project].dbo.CovidDeaths$

SELECT *
FROM [Portfolio Project].dbo.CovidVaccinations$

--Selecting Data that I will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- getting a little specific

SELECT location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total cases vs Population

SELECT location, date, total_cases, population,(total_cases/population)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NOT NULL
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to population

SELECT location, population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected  
FROM [Portfolio Project].dbo.CovidDeaths$
--WHERE location like '%states%'
WHERE continent IS NOT NULL
Group by location, population
ORDER BY PercentPopulationInfected DESC

--Looking at Countries with Highest Deaths

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeathCount DESC

--Cast as int

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeathCount DESC

--Looking at Continent Level

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
order by TotalDeathCount DESC


SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NULL
GROUP BY location
order by TotalDeathCount DESC

--Showing the continent with the highest death count per population

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM
	(new_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2



SELECT *
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date


	--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 1,2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 1,2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date)
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3


	--USE CTE

	WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
	AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date)
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
	)
SELECT *
FROM PopvsVac




WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
	AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date)
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
	)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date)
FROM [Portfolio Project].dbo.CovidDeaths$ dea
JOIN [Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
	--WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPeopleVaccinated


--Creating View to store data for later visualization

CREATE VIEW TotalDeathsCount AS
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
--order by TotalDeathCount DESC
