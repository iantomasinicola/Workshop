/*
Workshop: Scrittura query e tuning delle performance.

Individuare in quali circostanze una categoria di prodotti ha registrato un rincaro del prezzo medio di vendita superiore al 20% rispetto all'anno precedente.
L'analisi deve riguardare soltanto le vendite effettuate a clienti degli stati uniti e del canada.
•	Attenzione 1: il prezzo di vendita non è in dollari.
•	Attenzione 2: considerare anche lo sconto.
•	Attenzione 3: la media del prezzo di vendita deve essere pesata per la quantità di ogni linea d'ordine
Eseguire l'esercizio prima sul database operativo e poi sul datawarehouse.

Traccia della soluzione
Step 1
Individuare le tabelle contenenti
1) Gli ordini
2) I prodotti associati ad ogni ordine
3) L'anagrafica dei prodotti
4) Le categorie e le sotto-categorie associate ai prodotti
5) I clienti
6) Le regioni dei clienti
7) I cambi valutari

Step 2
Scrivere le join tra le varie tabelle. Lasciare nella SELECT l'istruzione count(*).
In questo modo possiamo controllare
che il numero di righe sia sempre lo stesso dopo ogni JOIN
Suggerimento: partire dalla tabella con i prodotti associati agli ordini

Step 3
Scrivere la condizione WHERE e selezionare le colonne di interesse nella SELECT, tabella per tabella.
Suggerimento: servono 4 colonne dalla [SalesOrderDetail], 2 dalla [SalesOrderHeader], 1 dalla [ProductCategory] 1 dalla [CurrencyRate]
Valutare in base al numero di righe se finalizzare lo step3 in una CTE/Subquery o in una tabella temporanea.

Step 4
Partendo dallo step precedente, aggiungere nella SELECT le colonne calcolate:
1) YearOrderDate: anno della data d'ordine
2) UnitPriceAdjusted: UnitPrice meno lo sconto e moltiplicato per il cambio
Attenzione: UnitPriceDiscont è in percentuale o in valore assoluto?
Attenzione: Hai gestito bene i NULL?
Per questo passo uso una CTE o una tabella temporanea?

Step 5
Raggruppare per YearOrderDate e Categoria. 
Calcolare la media  dello UnitPriceAdjusted pesato per la quantità
Esempio di media pesata: 
Esame 1 voto 30 crediti 18
Esame 2 voto 28 crediti 9
Media del voto pesata  per i crediti = (30*18 + 28*9) / (18+9)
Inseriamo i dati in una tabella temporanea o in una cte?

Step 6
Calcolare per ogni riga dello step precedente, l'AvgUnitPrice della stessa categoria
per l'anno precedente. 
Suggerimento: usare la window function lag. 
Cosa metti tra le parentesi del lag? Cosa nella partition by all'interno dell'over?
Cosa nell'order by all'interno dell'over?

Step 7
Calcolare lo scostamento percentuale con la formula
(valore finale - valore iniziale) / valore iniziale
Inserirlo prima nella select e poi nella where.

Step 8
Ripetere tutti i passi sul DWH. Attenzione alle differenze di progettazione! 
*/

/*analisi preliminari */
--Distribuzione colonna status di Sales.SalesOrderHeader
SELECT Status, COUNT(*)
FROM   Sales.SalesOrderHeader
GROUP BY Status
--deduciamo che tutti gli ordini sono validi

--Distribuzione currency per il cambio
SELECT FromCurrencyCode, ToCurrencyCode, COUNT(*)
FROM   Sales.SalesOrderHeader as oh
LEFT JOIN  Sales.CurrencyRate as cr
	on oh.CurrencyRateID = cr.CurrencyRateID
GROUP BY FromCurrencyCode, ToCurrencyCode
--Deduciamo che quando in Sales.SalesOrderHeader c'è NULL, l'importo è gia in USD

--Distribuzione colonna UnitPriceDiscount di Sales.SalesOrderDetail
SELECT UnitPriceDiscount, COUNT(*)
FROM   Sales.SalesOrderDetail
GROUP BY UnitPriceDiscount
--deduciamo che gli sconti sono in percentuale

--Step 1, 2, 3, 4
SELECT 
     od.OrderQty,
	 od.UnitPrice, 
	 od.UnitPriceDiscount,
	 od.unitprice * (1-od.UnitPriceDiscount) / isnull(cr.AverageRate,1) as UnitPriceAdjusted,
	 year(oh.orderdate) as order_year,
	 pc.ProductCategoryID, 
	 pc.name as category_name,
	 cr.AverageRate AS CurrencyRate
into  #perimetro_query
FROM SALES.SalesOrderDetail as od
inner join SALES.SalesOrderHeader as oh
	on od.SalesOrderID = oh.salesorderid
inner join sales.Product as p
	on od.ProductID  = p.productid
inner join sales.ProductSubcategory as ps
	on p.ProductSubcategoryID = ps.ProductSubcategoryID
inner join sales.ProductCategory as pc
	on ps.ProductCategoryID = pc.ProductCategoryID
inner join sales.Customer as c
	on oh.customerid = c.CustomerID	
inner join sales.SalesTerritory as st
	on c.TerritoryID = st.TerritoryID
left join sales.CurrencyRate as cr
	on oh.CurrencyRateID = cr.CurrencyRateID
where st.CountryRegionCode in  ('us','ca');

--step 5
SELECT 
	order_year, 
	ProductCategoryID,
	category_name,
	sum(UnitPriceAdjusted*OrderQty)/sum(OrderQty) as avg_price
into #anno_categoria
FROM   #perimetro_query
GROUP BY 
	order_year, 
	ProductCategoryID, 
	category_name;

--step 6, 7
with final as (
	SELECT *,
		lag(avg_price) over(partition by productcategoryid
							order by order_year) as avg_price_previous
	FROM  #anno_categoria)
SELECT *,	
	(avg_price - avg_price_previous)/avg_price_previous as scostamento_percentuale
FROM  final
WHERE (avg_price - avg_price_previous)/avg_price_previous>0.20;












