USE FastFood;
GO

----- McDonalds Data -----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ##mcdonaldsUS;
GO
CREATE TABLE ##mcdonaldsUS (
	store_id VARCHAR(20),
	country NVARCHAR(20),
	[state] CHAR(2),
	city NVARCHAR(50),
	[address] NVARCHAR(100),
	zipcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO

DROP TABLE IF EXISTS ##mcdonaldsWorld;
GO
CREATE TABLE ##mcdonaldsWorld (
	store_id VARCHAR(20),
	country NVARCHAR(20),
	state_province NVARCHAR(30),
	city NVARCHAR(50),
	[address] NVARCHAR(100),
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO

-- BULK INSERT with bcp file and XML format file
BULK INSERT dbo.##mcdonaldsUS
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\bcp\mcdonaldsUS.bcp'
WITH (FORMATFILE = 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\xml\mcdonaldsUS.xml');
GO

-- Quickest way. Edit the raw data file first then BULK INSERT
BULK INSERT ##mcdonaldsUS
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\mcdonaldsUS.txt'
WITH
(
	CODEPAGE = '65001', -- Code page 65001 is the Windows code page ID for UTF-8 which are text files use
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
);
GO

BULK INSERT ##mcdonaldsWorld
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\mcdonaldsWorld.txt'
WITH
(
	CODEPAGE = '65001',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
);
GO

-- First, let's use our lookup table to change states, provinces, and territories to their abbr
WITH CTE AS (
	SELECT w.state_province, l.state_province_abbr
	FROM ##mcdonaldsWorld w
	JOIN lookup_abbr l ON l.state_province = w.state_province
)
UPDATE CTE
SET state_province = state_province_abbr;
GO
-- REMEMBER, SQL Server allows CRUD statements to act on CTE tables as if they were the source itself.

-- Cleanup cause the author misspelt a province
SELECT state_province FROM ##mcdonaldsWorld
WHERE LEN(state_province) > 2;

UPDATE ##mcdonaldsWorld 
SET state_province = 'SK' 
WHERE state_province = 'Saskatchewen';


-- Check every unique location for US between the two datasets, based on latitude & longitude
SELECT latitude, longitude FROM ##mcdonaldsWorld
WHERE country = 'United States'
UNION 
SELECT latitude, longitude FROM ##mcdonaldsUS;

-- We have more rows here so it probably means that there are duplicate latitude and longitudes but with
-- different other fields between US and World
WITH CTE AS (
	SELECT store_id, [state], city, [address], latitude, longitude
	FROM ##mcdonaldsUS
	UNION
	SELECT store_id, state_province, city, [address], latitude, longitude
	FROM ##mcdonaldsWorld
	WHERE country = 'United States'
),
CTE_2 AS (
	SELECT latitude, longitude FROM CTE
	GROUP BY latitude, longitude
	HAVING COUNT(*) > 1
)
SELECT u.latitude, u.longitude, u.store_id, u.[state], u.city, u.[address], 
	w.store_id, w.[state_province], w.city, w.[address] 
FROM ##mcdonaldsUS u
JOIN ##mcdonaldsWorld w ON w.latitude = u.latitude
WHERE u.latitude IN (SELECT latitude FROM CTE_2)
AND u.longitude IN (SELECT longitude FROM CTE_2)
ORDER BY u.latitude, u.longitude;

/*
We can see that slight differences in address spelling/structure has resulted in 51 duplicate entries.
There is a singular entry that has the same lat/long, but it actually consists of two separate locations.
Just very close. For reasons like this, rather than manually checking through everything, we will just use 
the most RECENT dataset.
*/

-- Let's store the duplicate lat/long values in a temp table
WITH CTE AS (
	SELECT store_id, [state], city, [address], latitude, longitude
	FROM ##mcdonaldsUS
	UNION
	SELECT store_id, state_province, city, [address], latitude, longitude
	FROM ##mcdonaldsWorld
	WHERE country = 'United States'
),
CTE_2 AS (
	SELECT latitude, longitude FROM CTE
	GROUP BY latitude, longitude
	HAVING COUNT(*) > 1
)
SELECT u.latitude, u.longitude
INTO #dup_coord
FROM ##mcdonaldsUS u
JOIN ##mcdonaldsWorld w ON w.latitude = u.latitude
WHERE u.latitude IN (SELECT latitude FROM CTE_2)
AND u.longitude IN (SELECT longitude FROM CTE_2)
ORDER BY u.latitude, u.longitude;
GO

-- Now create a temp table to house all our mcdonalds US data with the duplicates filtered out.
SELECT country, [state], city, [address], zipcode, latitude, longitude
INTO #mcdonalds
FROM ##mcdonaldsUS 
UNION
SELECT country, state_province, city, [address], postcode, latitude, longitude
FROM ##mcdonaldsWorld w
WHERE NOT EXISTS (SELECT 1 FROM #dup_coord d WHERE d.latitude = w.latitude)
AND NOT EXISTS (SELECT 1 FROM #dup_coord d WHERE d.longitude = w.longitude)
AND Country <> 'Canada';
GO

-- Insert all rows for Canada 
INSERT INTO #mcdonalds (country, [state], city, [address], zipcode, latitude, longitude)
SELECT country, state_province, city, [address], postcode, latitude, longitude
FROM ##mcdonaldsWorld
WHERE country = 'Canada';
GO

-- Finally place this into our active mcdonalds table
INSERT INTO mcdonalds (country, state_province, city, [address], postcode, latitude, longitude)
SELECT country, [state], city, [address], zipcode, latitude, longitude
FROM #mcdonalds;
GO

-- Get rid of leading and trailing quotations in address column due to changing to tab delimiter
UPDATE mcdonalds
SET [address] = SUBSTRING([address], 2, LEN([address]) - 2)
WHERE LEFT([address], 1) = '"';


----- Wendys Data -----------------------------------------------------------------------------------------------
BULK INSERT wendys
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\wendysUS_CA.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
);
GO

-- Sometimes PQ is used as the abbreviation for Quebec, but we want to normalize QC
UPDATE wendys
SET state_province = 'QC'
WHERE state_province = 'PQ';

----- Subway Data -----------------------------------------------------------------------------------------------
-- Have to use tab delimiter as the address sometimes has commas.
BULK INSERT subway
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\subwayUS.txt'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
);
GO

-- Get rid of leading and trailing quotations in address column due to changing to tab delimiter
UPDATE subway
SET [address] = SUBSTRING([address], 2, LEN([address]) - 2)
WHERE LEFT([address], 1) = '"';

-- Insert Canadian Data
BULK INSERT subway
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\subwayCA.txt'
WITH
(
	CODEPAGE = '65001',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
);
GO

-- Change any state_province names to their abbreviations
WITH CTE AS (
	SELECT s.state_province, l.state_province_abbr
	FROM subway s
	JOIN lookup_abbr l 
	ON l.state_province COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8 = s.state_province
)
UPDATE CTE
SET state_province = state_province_abbr;
GO


----- KFC Data -----------------------------------------------------------------------------------------------




SELECT * FROM subway;
SELECT * FROM mcdonalds;
SELECT * FROM wendys;