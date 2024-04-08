--Covid 2020/2021 data

Select Location,date, total_cases,new_cases, population
From [Covid Project]..CovidDeaths$
Order by 1,2 

--Total Cases vs Total Death Costa Rica

Select Location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Project]..CovidDeaths$
Where location like '%Costa Rica%'
Order by 1,2 

--Percentage of Population infected Costa Rica

Select Location,date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From [Covid Project]..CovidDeaths$
Where location like '%Costa Rica%'
Order by 1,2 

--Countries with highest infection rates

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
From [Covid Project]..CovidDeaths$
Group by Location, population
Order by InfectionPercentage desc

--Countries with highest death count per Population

Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
From [Covid Project]..CovidDeaths$
Where continent is not null
Group by Location
Order by HighestDeathCount desc

--Continent Death Count

Select location, MAX(cast(total_deaths as int)) as DeathCount
From [Covid Project]..CovidDeaths$
Where continent is null
Group by location
Order by Deathcount desc

--Global Death-Cases count

Select SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From [Covid Project]..CovidDeaths$
Where continent is not null
Order by 1,2

--Total population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Covid Project]..CovidDeaths$ dea
join [Covid Project]..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE--

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Covid Project]..CovidDeaths$ dea
join [Covid Project]..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
From PopvsVac

--TempTable
Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)


Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Covid Project]..CovidDeaths$ dea
join [Covid Project]..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
order by 2,3
select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
From #PercentagePopulationVaccinated