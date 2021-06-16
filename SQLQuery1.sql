-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM PortfolioProject..covid_deaths
WHERE continent is not null 
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..covid_vaccination
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths
ORDER BY 1,2



-- Looking at Total cases and total Deaths in India
SELECT Location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..covid_deaths
WHERE location='India'
ORDER BY 1,2


-- Looking at Total cases Vs Population
SELECT Location, date, population, total_cases, (total_cases/ population)*100 AS CasesPopulataion 
FROM PortfolioProject..covid_deaths
WHERE location='India'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/ population)*100 AS PercentPopulationInfected 
FROM PortfolioProject..covid_deaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at countries highest death count Vs Population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..covid_deaths
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Let's break by continent

-- Showing continents with highest death counts 
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..covid_deaths
WHERE continent is null 
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS NewDeathPercentage
FROM PortfolioProject..covid_deaths
--WHERE location='India'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--------------------- Vaccination Data ---------------------------

SELECT *
From PortfolioProject..covid_vaccination


------------------------- Joining the two tables on Date and Location ------------------------------

SELECT *
From PortfolioProject..covid_deaths as deaths
JOIN PortfolioProject..covid_vaccination as vaccine
On deaths.date = vaccine.date
and deaths.location = vaccine.location

 -- Looking at Total Populataion Vs Vaccination
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
From PortfolioProject..covid_deaths as deaths
JOIN PortfolioProject..covid_vaccination as vaccine
On deaths.date = vaccine.date
and deaths.location = vaccine.location
WHERE deaths.continent is not null
ORDER BY 2, 3


-----------------------------------

SELECT deaths.continent, deaths.location, deaths.date, deaths.population,
	vaccine.new_vaccinations, SUM(CAST(vaccine.new_vaccinations as int)) OVER (Partition by deaths.Location ORDER BY deaths.location)
	as RollingPeopleVaccinated
From PortfolioProject..covid_deaths as deaths
JOIN PortfolioProject..covid_vaccination as vaccine
On deaths.location = vaccine.location
	and deaths.date = vaccine.date
WHERE deaths.continent is not null
ORDER BY 2, 3


-- Use CTE

With PropvsVac(Continent, Location, Date, Populataion, new_vaccinataion, RollingPeopleVaccinated)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population,
	vaccine.new_vaccinations, SUM(CAST(vaccine.new_vaccinations as int)) OVER (Partition by deaths.Location ORDER BY deaths.location)
	as RollingPeopleVaccinated
From PortfolioProject..covid_deaths as deaths
JOIN PortfolioProject..covid_vaccination as vaccine
On deaths.location = vaccine.location
	and deaths.date = vaccine.date
WHERE deaths.continent is not null
--ORDER BY 2, 3
)

--SELECT *, (RollingPeopleVaccinated/Populataion)*100 As PeopleVaccinatedPercentage
--From PropvsVac
--WHERE Location='India'

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
From PortfolioProject..covid_deaths as dea
Join PortfolioProject..covid_vaccination as vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated_V1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths as dea
Join PortfolioProject..covid_vaccination as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
