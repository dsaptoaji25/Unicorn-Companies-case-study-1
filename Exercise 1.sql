/*Nomor 1*/
SELECT 
	continent,
	COUNT(DISTINCT company)
FROM
	unicorn_companies
GROUP BY
	continent
ORDER BY
	COUNT(company) DESC
	
/* Nomor 2 */
SELECT
	country,
	COUNT(DISTINCT company) AS Number_of_companies
FROM
	unicorn_companies
GROUP BY
	country
HAVING
	COUNT(company) > 100
ORDER BY
	COUNT(company) DESC

/*Nomor 3*/
SELECT
	unicorn_industries.industry,
	SUM(unicorn_funding.funding),
	ROUND(AVG(valuation),0) AS avg_valuation
FROM
	unicorn_industries INNER JOIN unicorn_funding
	ON unicorn_industries.company_id = unicorn_funding.company_id
GROUP BY
	1
ORDER BY
	2 DESC

/* Nomor 4 */
SELECT
	EXTRACT(YEAR FROM unicorn_dates.date_joined) AS year_joined,
	COUNT(DISTINCT unicorn_companies.company_id) AS total_company
FROM unicorn_companies 
INNER JOIN unicorn_industries
	ON unicorn_companies.company_id = unicorn_industries.company_id
INNER JOIN unicorn_dates
	ON unicorn_companies.company_id = unicorn_dates.company_id
	AND unicorn_industries.industry = 'Fintech'
	AND EXTRACT(YEAR FROM unicorn_dates.date_joined) BETWEEN 2016 AND 2022
GROUP BY 1
ORDER BY 1 DESC

/* Nomor 5 */
WITH
detail_company AS (
SELECT
	company_id, company, city, country
FROM
	unicorn_companies
),
valuasi AS (
SELECT
	unicorn_industries.company_id,
	industry,
	valuation
FROM
	unicorn_industries LEFT JOIN unicorn_funding
	ON unicorn_industries.company_id = unicorn_funding.company_id
ORDER BY
	valuation DESC
)
SELECT
	*
FROM
	detail_company LEFT JOIN valuasi
	ON detail_company.company_id = valuasi.company_id
--WHERE
	--country = 'Indonesia'
ORDER BY
	valuation DESC
	
/* Nomor 6 */
SELECT
	unicorn_companies.*,
	date_joined,
	year_founded,
	EXTRACT(YEAR FROM unicorn_dates.date_joined) - unicorn_dates.year_founded AS company_age
FROM
	unicorn_companies INNER JOIN unicorn_dates
	ON unicorn_companies.company_id = unicorn_dates.company_id
ORDER BY
	company_age DESC
	
/* Nomor 7 */
SELECT
	unicorn_companies.*,
	date_joined,
	year_founded,
	EXTRACT(YEAR FROM unicorn_dates.date_joined) - unicorn_dates.year_founded AS company_age
FROM
	unicorn_companies INNER JOIN unicorn_dates	
	ON unicorn_companies.company_id = unicorn_dates.company_id
WHERE
	year_founded BETWEEN 1960 AND 2000
ORDER BY
	company_age DESC
	
/* Nomor 8 */
select * from unicorn_funding
/*Q1*/
SELECT 
	COUNT(DISTINCT company_id) AS total_company
FROM
	unicorn_funding
WHERE
	LOWER(select_investors) LIKE '%venture%'

/*Q2*/
SELECT
	COUNT(DISTINCT CASE WHEN LOWER(select_investors) LIKE '%venture%' THEN company_id END) AS investor_venture,
	COUNT(DISTINCT CASE WHEN LOWER(select_investors) LIKE '%capital%' THEN company_id END) AS investor_capital,
	COUNT(DISTINCT CASE WHEN LOWER(select_investors) LIKE '%partner%' THEN company_id END) AS investor_partner
FROM unicorn_funding

/* Nomor 9 */
SELECT
	COUNT(DISTINCT uc.company_id) AS total_asia,
	COUNT(DISTINCT CASE WHEN uc.country = 'Indonesia' THEN uc.company_id END) AS total_indonesia
FROM unicorn_companies uc 
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id
WHERE 
	ui.industry = '"Supply chain, logistics, & delivery"' 
	AND uc.continent = 'Asia'

/* Nomor 12 */
WITH top_3 AS (
SELECT
	ui.industry,
	COUNT(DISTINCT ui.company_id)
FROM unicorn_industries ui 
INNER JOIN unicorn_dates ud 
	ON ui.company_id = ud.company_id 
WHERE EXTRACT(YEAR FROM ud.date_joined) IN (2019,2020,2021)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3
),

yearly_rank AS (
SELECT
	ui.industry,
	EXTRACT(YEAR FROM ud.date_joined) AS year_joined,
	COUNT(DISTINCT ui.company_id) AS total_company,
	ROUND(AVG(uf.valuation)/1000000000,2) AS avg_valuation_billion
FROM unicorn_industries ui
INNER JOIN unicorn_dates ud 
	ON ui.company_id = ud.company_id 
INNER JOIN unicorn_funding uf 
	ON ui.company_id = uf.company_id 
GROUP BY 1,2
)

SELECT
	y.*
FROM yearly_rank y
INNER JOIN top_3 t
	ON y.industry = t.industry
WHERE y.year_joined IN (2019,2020,2021)
ORDER BY 1,2 DESC

/* Nomor 13 */
WITH country_level AS (
SELECT
	uc.country,
	COUNT(DISTINCT uc.company_id) AS total_per_country
FROM unicorn_companies uc
GROUP BY 1
)

SELECT
	*,
	(total_per_country / SUM(total_per_country)over())*100 AS pct_company
FROM country_level
group by 1,2
ORDER BY 2 DESC