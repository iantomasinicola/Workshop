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


--SOLUZIONE1
SELECT T.CLASS AS RealClass,
	p.predizione
FROM  (SELECT T1.Rownumber, T1.CLASS 
		FROM  [dbo].[IrisTest]  AS T1) AS T
CROSS APPLY  dbo.PredizioneIris1(T.Rownumber) AS P;

--SOLUZIONE2
with 
  cte as (
	SELECT 
		b.rownumber as riga_di_test,
		a.class as possibile_predizione,
		 CONVERT(DECIMAL(8,4),power(a.[sepal_length]-B.sepal_length,2) + 
			  POWER(a.sepal_width-B.sepal_width,2)+
			  POWER(a.[petal_length]-B.[petal_length],2) + 
			  POWER(a.[petal_width]-B.[petal_width],2)) as punteggio
	FROM [dbo].[IrisTraining]  as A
	CROSS JOIN  [dbo].[IrisTest]  as B),
  cte2 as (
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY RIGA_DI_TEST
						  ORDER BY punteggio asc) as rn
	FROM cte)
SELECT RIGA_DI_TEST,
	POSSIBILE_PREDIZIONE,
	COUNT(*) AS FrequenzaPredizione
INTO   #PRIMI5_con_predizione3
FROM   CTE2
WHERE  RN <= 5
GROUP BY RIGA_DI_TEST,
	POSSIBILE_PREDIZIONE;

WITH CTE AS (
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY RIGA_DI_TEST
					  ORDER BY FrequenzaPredizione DESC) AS RN
FROM   #PRIMI5_con_predizione3)
SELECT  *
FROM   CTE
WHERE  RN = 1

