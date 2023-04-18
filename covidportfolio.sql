select*from
portfolioproject..CovidDeaths
order by 3,4

--select*from
--portfolioproject..CovidVaccination
--order by 3,4

select location ,date,total_cases, new_cases,total_deaths,population
from portfolioproject..CovidDeaths
order by 1,2


--Total cases vs Total Deaths
select location ,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where location like 'italy'
order by 1,2


--total cases vs population
--shows what percentage of population get covid
select location ,date ,total_cases,population,(total_cases/population)*100 as casesPercentage
from portfolioproject..CovidDeaths
where location like 'india'
order by 1,2


--countries with highest infection rate 
select location ,population,MAX(total_cases)as HighestInfectionCount,MAX((total_cases/population))*100 as infection_rate
from portfolioproject..CovidDeaths
group by location, population
order by infection_rate desc


--countries with highest death count per population
select location,MAX(cast(total_deaths as int))as HighestDeathCount
from portfolioproject..CovidDeaths
where continent is not null
group by location
order by  HighestDeathCount desc


--continent with highest death count
select location,MAX(cast(total_deaths as int))as HighestDeathCount
from portfolioproject..CovidDeaths
where continent is null
group by location
order by  HighestDeathCount desc


--Global number
select date ,sum(new_cases)as totalcases,sum(cast(new_deaths as int))as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
where continent is not null
group by date
order by  1,2



select*from
portfolioproject..CovidVaccination



--looking at total population vs total vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
from portfolioproject.. CovidDeaths dea
join portfolioproject..CovidVaccination vac
on dea.location = vac.location
and dea.date  = vac.date
where dea.continent is not null
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3




-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



