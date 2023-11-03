SELECT * 
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT * 
--FROM PortfolioProject..Covidvaccinations
--order by 3,4

SELECT Location,date,total_cases,new_cases,Total_deaths,population 
FROM PortfolioProject..CovidDeaths
order by 1,2

--Lokking at total cases vs total deaths
SELECT Location,date,total_cases,Total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--Looking at total_cases vs population
SELECT Location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2


--Looking at countries with higest infection rate campared to population
SELECT Location,population,max(total_cases)as HigestInfectionCount,max((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
group by location,population
order by PercentagePopulationInfected desc

--Showing countries with higest death count per population

SELECT Location,max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by location
order by TotalDeathCount  desc


--Lets break things down by continent

SELECT continent,max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by continent
order by TotalDeathCount  desc

--jOINING BOTH TABLE

SELECT *
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
order by 1,2,3


--total population vs vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations

FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--TEMP TABLE

DROP TABLE if exists #Percentpopulationvaccinated
CREATE TABLE #Percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #Percentpopulationvaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date)as Rollingpeoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date

SELECT*,( Rollingpeoplevaccinated/Population)*100
FROM  #Percentpopulationvaccinated

--Creating view to store data

CREATE VIEW Percentpopulationvaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date)as Rollingpeoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

SELECT*
FROM Percentpopulationvaccinated


