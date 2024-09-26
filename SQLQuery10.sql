select * from 
portfolio..CovidDeaths
order by 3,4;

--select * from 
--portfolio..CovidVaccinations
--order by 3,4;


Select location, date, total_cases, new_cases, total_deaths, Population
from portfolio..CovidDeaths
order by 1,2;

-- Total Cases Vs Total Deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from portfolio..CovidDeaths
where location like '%india%'
order by 1,2;


-- Total Cases vs population 
-- Shows what percentsge of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as Infected_population_percent
from portfolio..CovidDeaths
where location like '%india%'
order by 1,2;


--Countries with highest infection rate compared to population
select location, population, max(total_cases) as Highest_Infection_count ,max(total_cases/population)*100 as Infected_population_percent
from portfolio..CovidDeaths
--where location like '%india%'
group by location,population
order by Infected_population_percent desc;


-- Countries with Highest Mortality

select location, MAX(cast(total_deaths as int)) as Total_Death_count
from portfolio..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by Total_Death_count desc;



-- Death By Continets 

select location, MAX(cast(total_deaths as int)) as Total_Death_count
from portfolio..CovidDeaths
--where location like '%india%'
where continent is null
group by location
order by Total_Death_count desc;

select continent, MAX(cast(total_deaths as int)) as Total_Death_count
from portfolio..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by Total_Death_count desc;


-- Continents with highest death counts per population

select continent, MAX(cast(total_deaths as int)) as Total_Death_count
from portfolio..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by Total_Death_count desc;


-- Global Numbers

select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)* 100 as death_percentage 
from portfolio..CovidDeaths
where continent is not null
group by date
order by 1,2; 

-- Total Population vs Vaccinations

select  dea.continent, dea.location, dea.date, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
 --(Rolling_people_vaccinated/population)*100
from portfolio..CovidDeaths dea
	join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;



-- USE CTE

with PopvsVac (continnent, location, date, population,  New_vaccinations, Rolling_People_Vaccinated)
as
(

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
	--, (Rolling_people_Vaccinated/population)*100
	from portfolio..CovidDeaths dea
	join portfolio..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
		where dea.continent is not null
		--order 2, 3
	)
	select *, (Rolling_People_Vaccinated/population)*100
	from PopvsVac;


	-- Temp Table

	create Table  #Percent_population_Vaccinated
	(
		Continent nvarchar(255),
		Location nvarchar(255),
		Date datetime,
		population numeric,
		New_Vaccinations numeric,
		Rolling_People_Vaccinated numeric

	)

	insert into #Percent_population_Vaccinated

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,

	sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
	--, (Rolling_people_Vaccinated/population)*100
	from portfolio..CovidDeaths dea
	join portfolio..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
		where dea.continent is not null
		--order 2, 3

	select *, (Rolling_People_Vaccinated/Population)*100
	from #Percent_population_Vaccinated;



-- Create View To store data for later visualizations

drop view if exists Percent_Population_Vaccinated;

go 

Create View  Percent_Population_Vaccinated 

as

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,

	sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
	--, (Rolling_people_Vaccinated/population)*100
	from portfolio..CovidDeaths dea
	join portfolio..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
		where dea.continent is not null;
		 

	select * from Percent_Population_Vaccinated;