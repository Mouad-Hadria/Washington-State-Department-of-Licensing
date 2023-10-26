
----- Crafting a Supporting Table

WITH CTE AS
(
SELECT DOL_Vehicle_ID,Electric_Vehicle_Type,Electric_Range,Make,[Alternative Fuel Eligibility] 
FROM PortfolioProjects.Dbo.Electric_Vehicle_Population

UNION

SELECT DOL_Vehicle_ID,Electric_Vehicle_Type,Electric_Range,Make,[Alternative Fuel Eligibility]
FROM PortfolioProjects.Dbo.Electric_Vehicle_Registrations
)

SELECT *,'#############' AS 'Electric range group'  INTO SupportTable FROM CTE

-- Detecting the redundant transaction IDs 

SELECT * FROM SupportTable WHERE DOL_Vehicle_ID in
(
SELECT DISTINCT(DOL_Vehicle_ID) FROM SupportTable
GROUP BY DOL_Vehicle_ID
HAVING COUNT(DOL_Vehicle_ID) > 1
)

-- Deleting the redundant transaction ID

DELETE FROM SupportTable
WHERE DOL_Vehicle_ID = '192417662' AND [Alternative Fuel Eligibility] = 'Unknown'

------------ Phase 2: Electric vehicle trends

---- Electric vehicle adoption over time

SELECT Transaction_Year,COUNT(*) AS 'Number of transactions' FROM PortfolioProjects.dbo.Electric_Vehicle_Registrations
GROUP BY Transaction_Year ORDER BY 1 ASC

---- Market share analysis

--

SELECT Electric_Vehicle_Type,COUNT(DOL_Vehicle_ID) AS 'Count of vehicles' FROM SupportTable
GROUP BY Electric_Vehicle_Type ORDER BY 2 DESC

--

SELECT Transaction_Year,Electric_Vehicle_Type,COUNT(*) AS 'Number of transactions' FROM PortfolioProjects.dbo.Electric_Vehicle_Registrations
GROUP BY Transaction_Year,Electric_Vehicle_Type ORDER BY 1 ASC

---- Most popular electric vehicle models
--

SELECT TOP 7 Model,COUNT(*) AS 'Number of transactions' FROM PortfolioProjects.dbo.Electric_Vehicle_Registrations
GROUP BY Model ORDER BY 2 DESC

--

SELECT Transaction_Year,Model,COUNT(*) AS 'Number of transactions' FROM PortfolioProjects.Dbo.Electric_Vehicle_Registrations
GROUP BY Transaction_Year,Model
HAVING Model in (SELECT TOP 5 Model FROM PortfolioProjects.dbo.Electric_Vehicle_Registrations GROUP BY Model ORDER BY COUNT(*) DESC)
ORDER BY 1 ASC
 
------------ Phase 3: Electric vehicle characteristics analysis

---- Electric range analysis

--

SELECT DOL_Vehicle_ID,Electric_Range,Electric_Vehicle_Type 
FROM SupportTable WHERE Electric_Range <> 0 ORDER BY 1 DESC

-- 

UPDATE SupportTable
SET [Electric range group] =
CASE

WHEN Electric_Range = 0    THEN 'not-reported'
WHEN Electric_Range <= 50  THEN ' 0-50'
WHEN Electric_Range <= 100 THEN ' 50-100'
WHEN Electric_Range <= 150 THEN '100-150'
WHEN Electric_Range <= 200 THEN '150-200'
WHEN Electric_Range <= 250 THEN '200-250'
WHEN Electric_Range <= 300 THEN '250-300'
WHEN Electric_Range <= 350 THEN '300-350'

END

SELECT [Electric range group],COUNT(DOL_Vehicle_ID) AS 'Count of vehicles' FROM SupportTable
GROUP BY [Electric range group] ORDER BY 1 ASC

---- Manufacturer analysis

SELECT Make,COUNT(DOL_Vehicle_ID) AS 'Count of vehicles' FROM SupportTable
GROUP BY Make ORDER BY 2 DESC

---- Vehicle eligibility for alternative fuel status analysis

SELECT [Alternative Fuel Eligibility],COUNT(DOL_Vehicle_ID) AS 'Count of vehicles' FROM SupportTable
GROUP BY [Alternative Fuel Eligibility] ORDER BY 2 DESC

------------ Phase 4: Electric vehicle transactions analysis

SELECT DISTINCT(Transaction_Type),COUNT(*) AS 'Number of transactions' FROM PortfolioProjects.Dbo.Electric_Vehicle_Registrations
GROUP BY Transaction_Type ORDER BY 2 DESC

------------ Phase 5: Geographic analysis

---- Number of declared cities,Counties,States

SELECT COUNT(DISTINCT(City)) AS 'N° of cities',COUNT(DISTINCT(County)) AS 'N° of counties',COUNT(DISTINCT(State)) AS 'N° of states'
FROM PortfolioProjects.Dbo.Electric_Vehicle_Registrations
WHERE State NOT IN ('QC','BC','AP','AE','AB','ON','XX')

---- Geographical distribution

SELECT City,County,State,COUNT(*) as 'Number of transactions' FROM PortfolioProjects.dbo.Electric_Vehicle_Registrations
GROUP BY City,County,State
HAVING State NOT IN ('QC','BC','AP','AE','AB','ON','XX')
ORDER BY 4 DESC