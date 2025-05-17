Select * 
From COVID..CovidDeaths
where continent is  null
order by 3,4

Select * 
From COVID..CovidVaccinations
--order by 3,4

Select Location, date,  total_cases, new_cases, total_deaths, population
From COVID..CovidDeaths
order by 1,2


-- Total cases vs total deaths (likelihood of dying if you contract covid)
Select Location, date,  total_cases, total_deaths, (CAST(total_deaths AS decimal(18,2))/CAST(total_cases AS decimal(18,2)))*100  as DeathPercentage
From COVID..CovidDeaths
where continent is not null
order by 1,2

-- Total cases vs Population (shows the percentage of population has got covid)
Select Location, date, population, total_cases, (CAST(total_cases AS decimal(18,2))/CAST(population AS decimal(18,2)))*100  as CovidPercentage
From COVID..CovidDeaths
order by 1,2

-- Countries with highest infection rate per population
Select Location, population, Max(total_cases) as MaxInfectionCount, Max((CAST(total_cases AS decimal(18,2))/CAST(population AS decimal(18,2)))*100)  as CovidPercentage
From COVID..CovidDeaths
Group by Location, population
order by CovidPercentage DESC

-- Countries with highest death rate per population
Select Location, Max(total_deaths) as TotalDeathCount
From COVID..CovidDeaths
where continent is not null
Group by Location 
order by TotalDeathCount DESC

-- Continent with highest death rate per population
Select continent, Max(total_deaths) as TotalDeathCount
From COVID..CovidDeaths
where continent is not null
Group by continent 
order by TotalDeathCount DESC

-- Global impact 
Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(CAST(new_deaths AS decimal(18,2)))/sum(CAST(new_cases AS decimal(18,2))))*100  as DeathPercentage
From COVID..CovidDeaths
where continent is not null
Group by date
order by 1,2

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(CAST(new_deaths AS decimal(18,2)))/sum(CAST(new_cases AS decimal(18,2))))*100  as DeathPercentage
From COVID..CovidDeaths
where continent is not null
--Group by date
order by 1,2

 -- Total population vs vaccination
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location order by d.LOCATION, d.date) as RollingVaccinationCount
From COVID..CovidDeaths d
Join COVID..CovidVaccinations v
     On d.location = v.LOCATION
     and d.date = v.DATE
where d.continent is not null
order by 2,3

-- Rolling Vaccination count per population using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
AS
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location order by d.LOCATION, d.date) as RollingVaccinationCount
From COVID..CovidDeaths d
Join COVID..CovidVaccinations v
     On d.location = v.LOCATION
     and d.date = v.DATE
where d.continent is not null
--order by 2,3

)
Select *, (RollingVaccinationCount/CAST(Population AS decimal(18,2))) *100
From PopvsVac
order by 2,3

-- Rolling Vaccination count per population using Temporary Table
DROP TABLE if EXISTS #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent NVARCHAR(255),
LOCATION NVARCHAR(255),
Date DATE,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingVaccinationCount NUMERIC
)

Insert INTO  #PercentPopVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location order by d.LOCATION, d.date) as RollingVaccinationCount
From COVID..CovidDeaths d
Join COVID..CovidVaccinations v
     On d.location = v.LOCATION
     and d.date = v.DATE
where d.continent is not null
--order by 2,3

Select *, (RollingVaccinationCount/CAST(Population AS decimal(18,2))) *100
From #PercentPopVaccinated
order by 2,3

-- Creating View to store data for later visualisation
DROP VIEW PercentPopulationVaccinated
GO
CREATE VIEW PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location order by d.LOCATION, d.date) as RollingVaccinationCount
From COVID..CovidDeaths d
Join COVID..CovidVaccinations v
     On d.location = v.LOCATION
     and d.date = v.DATE
where d.continent is not null
GO
