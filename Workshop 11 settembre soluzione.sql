/*******************************
Workshop del 11 settembre
*******************************/

/*
Step 8
Ripetere tutti i passi del Workshop del 4 settembre 
sullo schema DWH. Attenzione alle differenze di progettazione! 

Step 9
Incapsulare il codice in una stored procedure

Step 10
Aggiungere alla stored procedure un parametro di input per dinamizzare il filtro sul territorio (accettare in input un solo territorio)

Step 11
Aggiungere alla stored procedure un parametro di output che riporta il numero di righe della tabella finale

Step 12
Aggiungere una validazione dell’input. 
Restituire errore se è inserito un territorio non presente nel Database
*/


WITH FactSales AS (
SELECT 
    ProductKey,
	OrderDateKey,
	CurrencyKey,
	salesTerritoryKey,
	orderquantity,
	unitprice,
	unitpricediscountpct
FROM dwh.FactInternetSales
	UNION ALL
SELECT 
	ProductKey,
	OrderDateKey,
	CurrencyKey,
	salesTerritoryKey,
	orderquantity,
	unitprice,
	unitpricediscountpct
FROM dwh.FactResellerSales)
SELECT pc.EnglishProductCategoryName,
	d.CalendarYear,
	unitprice*(1-unitpricediscountpct)/averagerate as adjustedUnitPrice,
	orderquantity
into #perimetro
FROM FactSales as f
inner join dwh.dimSalesTerritory as t
	on f.salesTerritoryKey = t.salesTerritoryKey
inner join dwh.DimProduct as p
	on f.ProductKey = p.ProductKey
inner join dwh.DimProductSubcategory as sc
	on p.ProductSubcategoryKey = sc.ProductSubcategoryKey
inner join dwh.DimProductCategory as pc
	on sc.ProductcategoryKey = pc.ProductcategoryKey
inner join dwh.DimDate as d
	on f.OrderDateKey = d.datekey
inner join dwh.FactCurrencyRate as fct
	on f.CurrencyKey = fct.CurrencyKey
	and f.orderdatekey = fct.datekey
WHERE T.SalesTerritoryCountry IN ( 'United States' , 'caNADa') 


select EnglishProductCategoryName AS Category, 
	calendarYear AS YEAR,
	sum(adjustedUnitpRICE*ORDERQUANTITY)/SUM(ORDERQUANTITY) as average
into #final
from #perimetro
group by EnglishProductCategoryName, calendarYear

with 
cte as (
	select *, 
		lag(average) over(partition by category
						  order by year) as previous_average
	from #final
	)
SELECT category, 
	year,
	average,
	previous_average,
	(average-previous_average)/previous_average as scostamento
FROM cte
where  (average-previous_average)/previous_average > 0.20


/*Calcolo anni/categorie mancanti */
select distinct year
into #anni
from #final

select distinct category
into #categorie
from #final

SELECT *
INTO #COMBINAZIONI
FROM #ANNI
CROSS JOIN #CATEGORIE

SELECT C.Category,
	C.YEAR,
	F.AVERAGE
INTO #FINALFINAL
FROM #COMBINAZIONI AS C
LEFT JOIN #final AS F
	ON C.Category = F.Category
	AND F.YEAR = C.YEAR

/*Pivot dei dati*/
SELECT   Category,
	max(case when year = 2010 then Average else null end)	as average_2010,
	max(case when year = 2011 then Average else null end) as average_2011,
	max(case when year = 2012 then Average else null end) as average_2012
FROM     #FINALFINAL
GROUP BY Category 



