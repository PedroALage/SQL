
SELECT *
FROM PortifolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortifolioProject..CovidVaccinations
--ORDER BY 3,4

-- Selecionado Base

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortifolioProject..CovidDeaths
ORDER BY 1,2

-- Porcetagem de morte ao contrair

SELECT location, date, total_cases, total_deaths
, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT))*100 AS DeathPercentage
FROM PortifolioProject..CovidDeaths
WHERE location LIKE '%Brazil%'
ORDER BY 1,2

-- Porcetagem da população que contraiu a doença

SELECT location, date, total_cases, population
, (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT))*100 AS PercentageInfected
FROM PortifolioProject..CovidDeaths
WHERE location LIKE '%Brazil%'
ORDER BY 1,2

-- Países com maior taxa de infecção

SELECT location, population, MAX(CAST(total_cases AS FLOAT)) AS InfectionCount
, MAX((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)))*100 AS PercentageInfected
FROM PortifolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentageInfected DESC

-- Países com maior número de mortos por população

SELECT location, MAX(CAST(total_deaths AS FLOAT)) AS DeathCount
FROM PortifolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathCount DESC

-- Continentes com maior número de mortos por população

SELECT location, MAX(CAST(total_deaths AS FLOAT)) AS DeathCount
FROM PortifolioProject..CovidDeaths
WHERE continent IS NULL 
AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY DeathCount DESC

-- Valores Mundiais (valores separados por semana)

SELECT date
, SUM(CAST(new_cases AS FLOAT)) AS NewCases
, SUM(CAST(new_deaths AS FLOAT)) AS NewDeaths
, CASE
	WHEN SUM(CAST(new_cases AS FLOAT)) <> 0 THEN (SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)))*100 
	ELSE 0
END AS DeathsPercentage

FROM PortifolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND (CAST(new_cases AS FLOAT) <> 0 OR CAST(new_deaths AS FLOAT) <> 0)
GROUP BY date
ORDER BY 1,2


-- População Total x Vacinação

WITH PopVac(continent, location, date, population, new_vaccinations, TotalVaccinations)
AS
(
SELECT dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *
, (TotalVaccinations/population)*100 AS VaccinationPercentage
FROM PopVac


-- Temp Table

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinations numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM #PercentagePopulationVaccinated


-- Criando Visualização

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent
, dea.location
, dea.date
, dea.population
, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentagePopulationVaccinated