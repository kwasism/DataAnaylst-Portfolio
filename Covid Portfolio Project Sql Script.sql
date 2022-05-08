
use p1
select *
from covid_deaths
where continent is not null
order by 3,4

--select *
--from covid_vax
--order by 3,4



-- Select The Data that will be used( continent selected for drill down later on)

select location, date,total_cases,new_cases,total_deaths,population
from covid_deaths
where continent is not null
order by 1,2



-- Total Cases Vs Total Deaths 
-- Shows the likely hood of death from crontracting covid in the specified country location 

select continent, date,total_cases,total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location like '%states%' 
and continent is not null
order by 1,2



-- Total Cases Vs Population
-- Shows % of population that had covid 
select continent, date,population, total_cases,(Total_deaths/total_cases)*100 as PercentofPopulationInfected
from covid_deaths
where location like '%states%'
order by 1,2



-- Countries with highest infection rate compared to population thats been reported at a certain time 

select Location, Population, max(total_cases) as HighestInfectionRate, max((Total_deaths/total_cases))*100 as PercentofPopulationInfected
from covid_deaths
--where location like '%states%'
group by Location, Population
order by PercentofPopulationInfected desc

-- Countries with Highest Death Count per population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc


---Break down by Continent/location

select location, max(cast(total_deaths as int)) as TotalDeathCount
from covid_deaths
where continent is null
group by location
order by TotalDeathCount desc


---showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc



--Global numbers
select SUM(new_cases) as New_Cases, SUM(cast(new_deaths as int)) as TotalDeaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from covid_deaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--Global numbers by date
select date, SUM(cast(new_cases as int)) as New_Cases, SUM(cast(new_deaths as int)) as TotalDeaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from covid_deaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

use p1
select *




-- look at total population vs vaccinations
-- show percentage of population that has recieved at least one Covid Vaccine
select dea.continent, dea.location,dea.date, dea.population, vax.new_vaccinations,
	SUM(cast(vax.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_deaths dea
join covid_vax vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
order by 2,3


-- USE CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated) 
as
(
select dea.continent, dea.location,dea.date, dea.population, vax.new_vaccinations,
	SUM(cast(vax.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_deaths dea
join covid_vax vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3
)
select * --(RollingPeopleVaccinated/Population)*100
from PopVsVac

drop table if exists PercentPopulationVaccinated
--Temp Table
use p1
create table PercentPopulationVaccinated
--Specify columns for table being created
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

--insert data into tables
insert into PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vax.new_vaccinations,
	SUM(convert(numeric, vax.new_vaccinations)) over (partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_deaths dea
join covid_vax vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated


--creating view to store data for later

create view PercentPopulationVaccinated_
as
select dea.continent, dea.location,dea.date, dea.population, vax.new_vaccinations,
	SUM(convert(numeric, vax.new_vaccinations)) over (partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_deaths dea
join covid_vax vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3

