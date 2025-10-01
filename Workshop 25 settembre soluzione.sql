/*1-NEIGHBOURS*/
SELECT TOP 1 
	a.class as predizione, 
	b.class as dato_reale,
	 CONVERT(DECIMAL(8,4),power(a.[sepal_length]-B.sepal_length,2) + 
	      POWER(a.sepal_width-B.sepal_width,2)+
		  POWER(a.[petal_length]-B.[petal_length],2) + 
		  POWER(a.[petal_width]-B.[petal_width],2)) as punteggio
FROM [dbo].[IrisTraining]  as A
CROSS JOIN [dbo].[NuovoIris] as B
ORDER BY punteggio ASC

/*5-NEIGHBOURS*/
--Versione con tabella temporanea
SELECT TOP 5 a.class as predizione, b.class as dato_reale,
	 CONVERT(DECIMAL(8,4),power(a.[sepal_length]-B.sepal_length,2) + 
	      POWER(a.sepal_width-B.sepal_width,2)+
		  POWER(a.[petal_length]-B.[petal_length],2) + 
		  POWER(a.[petal_width]-B.[petal_width],2)) as punteggio
INTO #T
FROM [dbo].[IrisTraining]  as A
CROSS JOIN [dbo].[NuovoIris] as B
ORDER BY punteggio ASC

SELECT *
FROM   #T

SELECT TOP 1 
	predizione
FROM   #T
GROUP BY predizione
ORDER BY COUNT(*) DESC


--Versione con subquery
SELECT TOP 1  
	z.predizione
FROM 
(
  SELECT TOP 5 
	a.class as predizione, 
	b.class as dato_reale,
	POWER(a.[sepal_length]-B.sepal_length,2) + POWER(a.sepal_width-B.sepal_width,2)+ POWER(a.[petal_length]-B.[petal_length],2) + POWER(a.[petal_width]-B.[petal_width],2) as punteggio
  FROM [dbo].[IrisTraining]  as A
  CROSS JOIN  [dbo].[NuovoIris] as B
  ORDER BY punteggio
  ) as z
  GROUP BY z.predizione
ORDER BY COUNT(*) desc
