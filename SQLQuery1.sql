Select *
from PortfolioProject..['owid-covid-data-death$']
order by 3,4

Select *
from PortfolioProject..['owid-covid-data-vaccination$']
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['owid-covid-data-death$']
order by 1,2

-- looking at total cases vs total deathes

Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['owid-covid-data-death$']
Where location like '%states%'
order by 1,2

-- looking at total cases vs population

Select location, date, total_cases,  population, (total_cases/population)*100 as CoivdPercentage
From PortfolioProject..['owid-covid-data-death$']
Where location like '%states%'
order by 1,2

-- looking at country with highest infection rate compared to population

Select location, MAX(total_cases) as HighestInfectionCount,  population, MAX((total_cases/population)*100) as InfectionPercentage
From PortfolioProject..['owid-covid-data-death$']
Where continent is not null
Group by location, population
order by InfectionPercentage desc

-- showing the country with highest death count per population

 Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['owid-covid-data-death$']
Where continent is not null
Group by location
order by TotalDeathCount desc

-- break things down by continent

 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['owid-covid-data-death$']
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- showing contient with highest death count per population

 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['owid-covid-data-death$']
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	   SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From PortfolioProject..['owid-covid-data-death$']
Where continent is not null
--Group by date
order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..['owid-covid-data-death$'] dea
Join PortfolioProject..['owid-covid-data-vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
	   as RollingPeopleVaccinated
From PortfolioProject..['owid-covid-data-death$'] dea
Join PortfolioProject..['owid-covid-data-vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- temp table

Create Table #PercentPopulationVaccinated
(
Contient nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
	   as RollingPeopleVaccinated
From PortfolioProject..['owid-covid-data-death$'] dea
Join PortfolioProject..['owid-covid-data-vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

select *
from #PercentPopulationVaccinated