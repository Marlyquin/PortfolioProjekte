Select * 
From CovidDeaths	
where continent is not null
order by 3,4

Select location, date, total_cases, new_cases,total_deaths, population
From CovidDeaths
order by 1,2

--Deutschland TodesProzent
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'ger%'
order by 1,2

--Deutschland Infektionsprozent
Select location,date,population, total_cases,(total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths
where location like 'ger%'
order by 1,2

--welches land höchste Infektionsrate relativ zur Population

Select location,population, MAX(total_cases)as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected 
from CovidDeaths
Group by location,population
order by PercentagePopulationInfected desc


-- Länder mit der höchsten Todesanzahl relativ zur Population

Select location, population, MAX(cast(total_deaths as int))as TotalDeathCount, MAX(total_deaths/population)*100 as DeathPercentage
from CovidDeaths
where continent is not null
Group by location,population
order by TotalDeathCount desc

--Kontinente mit höchster Todesanzahl per Population
Select continent, MAX(cast(total_deaths as int))as TotalDeathCount, MAX(total_deaths/population)*100 as DeathPercentage
from CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

---Globale Covidwerte
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/ Sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2

-- Total Population vs Vaccinations
--CTE
With PopVsVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidVacinations vac
JOIN CovidDeaths dea
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null

)
Select* , (RollingPeopleVaccinated/population)*100 
From PopVsVac

--Alternativ: TEMP TABLE 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidVacinations vac
JOIN CovidDeaths dea
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null

Select * 
From #PercentPopulationVaccinated

--Views für Visualisierungen

Create VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidVacinations vac
JOIN CovidDeaths dea
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null

Create VIEW GlobalValues as
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/ Sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null

Create VIEW GerTodesanzahl as
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'ger%'

Create VIEW GerInfektionsanzahl as
Select location,date,population, total_cases,(total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths
where location like 'ger%'
