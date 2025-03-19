Select* 
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--Select* 
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2 

-- Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float) / total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%state%'
Order by 1,2 

-- Looking at total cases vs population
-- Shows what percentage of population got covid
Select Location, date, total_cases, population, (cast(total_cases as float) / population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%state%'
Order by 1,2 

--checking highest infection rate for a country compared to population
Select Location, max(total_cases) as highestinfectioncount, max((cast(total_cases as float) / population))*100 as percentpopulationinfected
From PortfolioProject..CovidDeaths
Group by Location, population
Order by percentpopulationinfected desc

-- looking at countries with highest death count per population
Select Location, max(total_deaths) as totaldeathcount
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
Order by totaldeathcount desc

--showing the continents with highest death count 
Select continent, max(total_deaths) as totaldeathcount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by totaldeathcount desc

--Select location, max(total_deaths) as totaldeathcount
--From PortfolioProject..CovidDeaths
--where continent is null
--Group by location
--Order by totaldeathcount desc

--global numbers
Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(cast (new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
Order by 1,2  

--looking at total population vs vaccination 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, 
dea.date) as rollingpeoplevaccinated
, 
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	   and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--using CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, rollingpeoplevaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, 
dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	   and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)

select *, (rollingpeoplevaccinated/(cast (Population as float)))*100
From PopvsVac 

--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, 
dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	   and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/(cast (Population as float)))*100
From #percentpopulationvaccinated 

--creating view to store data for late visualisations

create view percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (partition by dea.location Order by dea.location, 
dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	   and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *
From percentpopulationvaccinated