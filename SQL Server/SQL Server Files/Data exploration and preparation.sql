
------------ Phase 1: Data preparation and exploration

---- Data import

SELECT 
Clean_Alternative_Fuel_Vehicle_Type AS 'Electric_Vehicle_Type',DOL_Vehicle_ID,Model_Year,Make,Model,Vehicle_Primary_Use,Electric_Range,Odometer_Reading,
Odometer_Code,New_or_Used_Vehicle AS 'Vehicle_Condition',Sale_Price,Sale_Date,Base_MSRP,Transaction_Type,DOL_Transaction_Date,Transaction_Year,County,City,
State_of_Residence AS 'State',Postal_Code
INTO Electric_Vehicle_Registrations FROM PortfolioProjects.dbo.Electric_Vehicle_Title_and_Registration_Activity

SELECT
County,City,State,Postal_Code,Model_Year,Make,Model,Electric_Vehicle_Type,Clean_Alternative_Fuel_Vehicle_CAFV_Eligibility AS 'Alternative Fuel Eligibility',
Electric_Range,Base_MSRP,DOL_Vehicle_ID
INTO Electric_Vehicle_Population FROM PortfolioProjects.dbo.Electric_Vehicle_Population_Data


---- Data cleaning and preprocessing

-- Detetcing missing values

DECLARE @TableName NVARCHAR(128) = 'Electric_Vehicle_Registrations';
DECLARE @ColumnName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);

DECLARE ColumnCursor CURSOR FOR
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TableName;

OPEN ColumnCursor;
FETCH NEXT FROM ColumnCursor INTO @ColumnName;

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @SQL =' SELECT COUNT(*) AS ''The count of null values in '+QUOTENAME(@ColumnName)+'''
	FROM PortfolioProjects.dbo.Electric_Vehicle_Registrations WHERE ' + QUOTENAME(@ColumnName)  + 'IS NULL'
	EXEC sp_executesql @SQL
    
    FETCH NEXT FROM ColumnCursor INTO @ColumnName;
END;

CLOSE ColumnCursor;
DEALLOCATE ColumnCursor;

-- Consulting the column ['Alternative Fuel Eligibility']

SELECT Electric_Range,[Alternative Fuel Eligibility]
FROM PortfolioProjects.dbo.Electric_Vehicle_Population
ORDER BY 1 asc

UPDATE PortfolioProjects.dbo.Electric_Vehicle_Population
SET [Alternative Fuel Eligibility] = 'Unknown'
WHERE [Alternative Fuel Eligibility] = 'Eligibility unknown as battery range has not been researched'

SELECT DISTINCT(TAB2.DOL_Vehicle_ID),TAB2.Electric_Range,TAB1.[Alternative Fuel Eligibility]
FROM PortfolioProjects.dbo.Electric_Vehicle_Population AS TAB1
JOIN PortfolioProjects.dbo.Electric_Vehicle_Registrations AS TAB2
ON TAB1.DOL_Vehicle_ID = TAB2.DOL_Vehicle_ID
ORDER BY 2 ASC

-- Handling a missing column in Electric_Vehicle_Registrations table

ALTER TABLE PortfolioProjects.dbo.Electric_Vehicle_Registrations
ADD [Alternative Fuel Eligibility] VARCHAR(55)

UPDATE PortfolioProjects.dbo.Electric_Vehicle_Registrations
SET [Alternative Fuel Eligibility] = 
CASE
WHEN Electric_Range = 0  THEN 'Unknown'
WHEN Electric_Range < 30 THEN 'Not eligible due to low battery range'
ELSE 'Clean Alternative Fuel Vehicle Eligible'
END

---- Basic descriptive statistics

CREATE PROCEDURE usp_Basic_Descriptive_Statistics
@column_name VARCHAR(55)
AS
BEGIN
DECLARE @sql NVARCHAR(MAX)

SET @sql = 
'
SELECT MIN('+QUOTENAME(@column_name)+') AS ''Min of '+QUOTENAME(@column_name)+''',
AVG('+QUOTENAME(@column_name)+') AS ''Average of '+QUOTENAME(@column_name)+''',
MAX('+QUOTENAME(@column_name)+') AS ''Maximum of '+QUOTENAME(@column_name)+''',
STDEV('+QUOTENAME(@column_name)+') AS ''Standard Deviation of '+QUOTENAME(@column_name)+'''
FROM PortfolioProjects.Dbo.Electric_Vehicle_Registrations
'
EXEC sp_executesql @sql
END

-- Electric range

usp_Basic_Descriptive_Statistics @column_name = 'Electric_Range'

-- Odometer reading

usp_Basic_Descriptive_Statistics @column_name = 'Odometer_Reading'

-- Sale price

usp_Basic_Descriptive_Statistics @column_name = 'Sale_Price'

-- Base manufacturer's suggested retail price

usp_Basic_Descriptive_Statistics @column_name = 'Base_MSRP'
