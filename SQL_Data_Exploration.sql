-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location , date, total_cases, total_deaths,CAST(CAST(total_deaths as decimal)/CAST(total_cases AS decimal)*100 AS decimal(18,2)) as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'senegal'
order by 1,2

-- Looking Total Cases Vs Population
select Location , date, total_cases, population,CAST(CAST(total_cases as decimal)/CAST(population AS decimal)*100 AS decimal(18,2)) as PercentageOfPopInfec
from CovidDeaths
where location like 'senegal'
order by 1,2


--Loking at Countries with Highest Infection Rate compared to population
select Location , population , MAX(total_cases) as HighestInfectionCount, MAX((CAST(total_cases as decimal)/CAST(population AS decimal)))*100 as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected

-- Highest Death count per Population 
select Location , population , MAX(total_deaths) as HighestDeathCount, MAX((CAST(total_deaths as decimal)/CAST(population AS decimal)))*100 as PercentPopulationDead
from CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationDead

--GLOBAL NUMBERS
select TRIM(SUBSTRING(CAST(date as varchar),8,5)) as annee, location, SUM(CAST(new_cases as decimal)) as total_cases, SUM(cast(new_deaths as decimal)) total_deaths
from CovidDeaths
where continent is not null and location like 'senegal'
group by TRIM(SUBSTRING(CAST(date as varchar),8,5)), location, population
order by 1


--Total Vaccinations Vs Total Population For Senegal
WITH TotalVaccinatedSenegal as (
	select location, SUM(CAST(new_vaccinations as decimal)) TotalVaccinated
	FROM CovidVaccinations
	where location like 'Senegal'
	group by location
)
select distinct dea.continent, dea.location, dea.date, ISNULL(vac.new_vaccinations,0) new_vaccinations,TotalVaccinated,
CAST((ISNULL(vac.new_vaccinations,0) / tvs.TotalVaccinated) as decimal(20,5)) RatioVaccinated,
MAX(CAST(dea.population as decimal)) OVER (Partition by vac.Location order by vac.Location, dea.date) as Senegal_Population
from CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON vac.location = dea.location
JOIN TotalVaccinatedSenegal tvs ON tvs.location = vac.location
where vac.location like 'Senegal' and dea.continent is not null
order by 3,4

--TEMP TABLE with CTE TotalVaccinatedSenegal
--DROP TABLE IF EXISTS #TotalVaccinatedSenegal;
CREATE TABLE #TotalVaccinatedSenegal (
location varchar(30),
TotalVaccinated decimal(20,0)
);

WITH TotalVaccinatedSenegal as (
	select location, SUM(CAST(new_vaccinations as decimal)) TotalVaccinated
	FROM CovidVaccinations
	where location like 'Senegal'
	group by location
)
INSERT INTO #TotalVaccinatedSenegal 
SELECT location, TotalVaccinated 
FROM TotalVaccinatedSenegal;

select distinct dea.continent, dea.location, dea.date, ISNULL(vac.new_vaccinations,0) new_vaccinations,TotalVaccinated,
CAST((ISNULL(vac.new_vaccinations,0) / tvs.TotalVaccinated) as decimal(20,5)) RatioVaccinated,
MAX(CAST(dea.population as decimal)) OVER (Partition by vac.Location order by vac.Location, dea.date) as Senegal_Population
from CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON vac.location = dea.location
JOIN #TotalVaccinatedSenegal tvs ON tvs.location = vac.location
where vac.location like 'Senegal' and dea.continent is not null
order by 3,4 ;