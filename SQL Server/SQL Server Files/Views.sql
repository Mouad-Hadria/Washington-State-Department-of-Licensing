
------------ Phase 6: Preparing data for visualizations

---- View 1:

DROP VIEW IF  EXISTS Geographical_distribution
GO

CREATE VIEW Geographical_distribution AS

SELECT City,County,State,COUNT(*) as 'Number of transactions' FROM PortfolioProjects.dbo.Electric_Vehicle_Registrations
GROUP BY City,County,State
HAVING State NOT IN ('QC','BC','AP','AE','AB','ON','XX')

---- View 2:

DROP VIEW IF EXISTS Car_brand_popularity
GO

CREATE VIEW Car_brand_popularity AS

SELECT TOP 8 Make,COUNT(DOL_Vehicle_ID) AS 'Count of vehicles' FROM PortfolioProjects.dbo.SupportTable
GROUP BY Make ORDER BY 2 DESC

---- View 3:

DROP VIEW IF EXISTS Electric_vehicle_transactions_over_Time
GO

CREATE VIEW Electric_vehicle_transactions_over_Time AS

SELECT Transaction_Year,Electric_Vehicle_Type,COUNT(*) AS 'Number of transactions' FROM PortfolioProjects.dbo.Electric_Vehicle_Registrations
GROUP BY Transaction_Year,Electric_Vehicle_Type

---- View 4:

DROP VIEW IF EXISTS Top_electric_models
GO

CREATE VIEW Top_electric_models AS

SELECT Transaction_Year,Model,COUNT(*) AS 'Number of transactions' FROM PortfolioProjects.Dbo.Electric_Vehicle_Registrations
GROUP BY Transaction_Year,Model
HAVING Model in (SELECT TOP 6 Model FROM PortfolioProjects.dbo.Electric_Vehicle_Registrations GROUP BY Model ORDER BY COUNT(*) DESC)

---- View 5:

DROP VIEW IF EXISTS Eligibility_status
GO

CREATE VIEW Eligibility_status AS

SELECT [Alternative Fuel Eligibility],COUNT(DOL_Vehicle_ID) AS 'Count of vehicles' FROM SupportTable
GROUP BY [Alternative Fuel Eligibility]

---- View 6:

DROP VIEW IF EXISTS Electric_range_group_vehicle_Count
GO

CREATE VIEW Electric_range_group_vehicle_Count AS

SELECT [Electric range group],Electric_Vehicle_Type,COUNT(DOL_Vehicle_ID) AS 'Count of vehicles' FROM SupportTable
GROUP BY [Electric range group],Electric_Vehicle_Type

---- View 7:

DROP VIEW IF EXISTS Electric_range_among_categories
GO

CREATE VIEW Electric_range_among_categories AS

SELECT Electric_Range,Electric_Vehicle_Type FROM SupportTable
WHERE Electric_Range <> 0