
Select * 
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where continent is not null
and Location like'%States%'


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, total_cases, Population, (total_cases/ population) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where Location like'%States%'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population

Select Location, Population, max(total_cases) as HighestInfectionRate, max(total_cases/ population) * 100 as PercenatPopulationInfected
from PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location, population
Order by PercenatPopulationInfected desc


--Showing Countries with Highest Death Count per Population


Select Location , max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
Order by TotalDeathsCount desc


--Lets Break things down by Continent

--Shwoing continents with the highest death count per population

Select continent , max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathsCount desc


--Global NUMBERS

Select Sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int)) / SUM(cast(new_cases as int)) * 100 as DeathPercentage 
from PortfolioProject..CovidDeaths$
Where continent is not null
--Group by date
Order by 1,2

Select date , Sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int)) / SUM(cast(new_cases as int)) * 100 as DeathPercentage 
from PortfolioProject..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations.


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *  , (RollingPeopleVaccinated/Population) * 100
From PopVsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *  , (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location , dea.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *  , (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated