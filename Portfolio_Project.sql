Select *
From PortfolioProject..CovidDeaths
Where continent is not null


Select *
From PortfolioProject..CovidVaccination
Order by 3,4



--Looking at Total Cases vs Total Deaths
-- Likelihood of dying from COVID in Nigeria
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%'
Order by 1,2


--Looking at Total cases vs population
--Shows percentage of population with COVID
Select location, date,population, total_cases,(total_cases/population)*100 As CasebyPopulation
From PortfolioProject..CovidDeaths
Where location like '%States%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location,population, Max(total_cases) As HighestInfectionCount, Max((total_cases/population))*100 As CasebyPopulation
From PortfolioProject..CovidDeaths
Group by location, population
Order by 4 desc

--Looking at countries with the highest death count

Select location, Max(cast(total_deaths as Int)) As TotalDeathCount, Max((total_deaths/population))*100 As HighestDeathbyPopulation
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by 3 desc

--Group data by continent
Select continent, Max(cast(total_deaths as Int)) As TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by 2 desc

--Creating view for data by continent

CREATE VIEW DeathCountByContinent as
Select continent, Max(cast(total_deaths as Int)) As TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
--Order by 2 desc

Select *
From DeathCountByContinent

--GLOBAL REPORTS

--Sum of death per day
Select date, SUM(cast(new_deaths as int)) total_cases, SUM(new_cases) total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentages
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Total deaths across the world

Select SUM(cast(new_deaths as int)) total_deaths, SUM(new_cases) total_cases, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentages
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, total_vaccinations, dea.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as bigint)) OVER (Partition BY dea.location ORDER BY dea.date, dea.location) as RollingPeopleVaxxed
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
where dea.continent is not null AND dea.location Like '%States%'
Order by 2,3 

--Using CTE to calculate the % of Vaccinated per Country

With PopvsVaxxed (Continent,Location, Date, total_vaccinations, Population, new_vaccinations, RollingPeopleVaxxed)
As(
Select dea.continent, dea.location, dea.date, total_vaccinations, dea.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as bigint)) OVER (Partition BY dea.location ORDER BY dea.date, dea.location) as RollingPeopleVaxxed
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
where dea.continent is not null AND dea.location Like '%States%')
--Order by 2,3 

Select *, (RollingPeopleVaxxed/Population) *100 AS PercentageVaxxed
From PopvsVaxxed
