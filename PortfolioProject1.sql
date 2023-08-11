select *
from CovidDeaths

select *
from CovidVaccinations

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Looking at the total cases vs. total deaths

select location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float)) * 100 as DeathsPerCase
from CovidDeaths
order by 1,2

-- Looking at the total cases vs. total deaths in Colombia

select location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float)) * 100 as DeathsPerCase
from CovidDeaths
where location = 'Colombia'
order by 1,2

-- Searching for total cases vs. population in Colombia
--Shows what percentage of Colombian population got covid

select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float)) * 100 as PercentageCasesInPopulation
from CovidDeaths
where location = 'Colombia'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as MaxTotalCases, max((cast(total_cases as float)/cast(population as float)) * 100) as PercentageCasesInPopulation
from CovidDeaths
where continent is not null
group by location, population
order by PercentageCasesInPopulation desc

-- Looking at countries with highest death count per population

select location, max(total_deaths) as MaxTotalDeaths
from CovidDeaths
where continent is not null
group by location
order by MaxTotalDeaths desc

-- Breaking down highest death count by continent

select continent, max(total_deaths) as MaxTotalDeaths
from CovidDeaths
where continent is not null
group by continent
order by MaxTotalDeaths desc

-- Summing global new cases and global new deaths by day

select date, sum(new_cases) as NewCases, sum(new_deaths) as NewDeaths, sum(cast(new_deaths as float)) / sum(cast(new_cases as float)) *100 as GlobalDeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- Joining vaccinations table with deaths table
-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3
