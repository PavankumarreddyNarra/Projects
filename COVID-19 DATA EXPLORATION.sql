select *
from CovidDeaths$
where continent is not null 
order by 3,4


select *
from CovidVaccinations$
where continent is not null 
order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths$
order by 1,2

--looking  at total cases vs total deaths
-- shows likelihood of dying if you contact covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
from CovidDeaths$
--where location like '%india%'
order by date



--looking at total cases vs population
--shows what % of population got covid
select location,date,population,total_cases, (total_cases/population)*100 AS percentagepopulationinfected
from CovidDeaths$
order by 1,2


--looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highestinfectioncount, max((total_cases/population))*100 AS percentagepopulationinfected
from CovidDeaths$
--where location like '%india%'
group by location,population
order by percentagepopulationinfected desc



--showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
where continent is not null 
group by location
order by totaldeathcount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
--where location like '%india%'
where continent is not null 
group by continent
order by totaldeathcount desc


-- showing the continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
--where location like '%india%'
where continent is not null 
group by continent
order by totaldeathcount desc


--GLOBAL NUMBERS

select sum(new_cases) as totalcases, sum(cast(new_deaths as int )) as totaldeaths, sum(cast(new_deaths as int ))/sum(new_cases)*100 as deathpercentage
from CovidDeaths$ 
where continent is not null
--group by date
order by 1,2



--looking at total popultion vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
as rollingpeoplecount
--(rollingpeoplecount/population)*100
from CovidDeaths$  dea
join CovidVaccinations$  vac 
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as vaccpercentage
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(200),
Location nvarchar(200),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 