USE FastFood;
GO

----- McDonalds Data -----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ##mcdonaldsUS;
GO
CREATE TABLE ##mcdonaldsUS (
	country NVARCHAR(20),
	[state] CHAR(2),
	city NVARCHAR(50),
	[address] NVARCHAR(100),
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO

DROP TABLE IF EXISTS ##mcdonaldsWorld;
GO
CREATE TABLE ##mcdonaldsWorld (
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
/*
BULK INSERT dbo.##mcdonaldsUS
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\bcp\mcdonaldsUS.bcp'
WITH (FORMATFILE = 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\xml\mcdonaldsUS.xml');
GO
*/

-- Quickest way. Edit the raw data file first then BULK INSERT
BULK INSERT ##mcdonaldsUS
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\locations\mcdonaldsUS.txt'
WITH
(
	CODEPAGE = '65001', -- Code page 65001 is the Windows code page ID for UTF-8
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
);
GO

BULK INSERT ##mcdonaldsWorld
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\locations\mcdonaldsWorld.txt'
WITH
(
	CODEPAGE = '1252', -- Code page 1252 for Windows ANSI (Western) which is what this txt file uses
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
);
GO

-- First, let's use our stateProvince table to change states, provinces, and territories to their abbr
WITH CTE AS (
	SELECT state_province, stateProvince_code
	FROM ##mcdonaldsWorld w
	JOIN stateProvince s ON s.stateProvince_name = w.state_province
)
UPDATE CTE
SET state_province = stateProvince_code;
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
	SELECT [state], city, [address], postcode, latitude, longitude
	FROM ##mcdonaldsUS
	UNION	-- Using UNION with every single field means it will filter out duplicate rows ONLY if every single column matches
	SELECT state_province, city, [address], postcode, latitude, longitude
	FROM ##mcdonaldsWorld
	WHERE country = 'United States'
),
CTE_2 AS (
	SELECT latitude, longitude FROM CTE
	GROUP BY latitude, longitude
	HAVING COUNT(*) > 1
)
SELECT u.latitude, u.longitude, u.[state], u.city, u.[address] AS US_address, u.postcode AS US_postcode,
	w.[state_province], w.city, w.[address] AS world_address, w.postcode AS World_postcode
FROM ##mcdonaldsUS u
JOIN ##mcdonaldsWorld w ON w.latitude = u.latitude
WHERE u.latitude IN (SELECT latitude FROM CTE_2)
AND u.longitude IN (SELECT longitude FROM CTE_2)
ORDER BY u.latitude, u.longitude;

/*
We can see that slight differences in address spelling/structure has resulted in 54 duplicate entries.
There is a singular entry that has the same lat/long, but it actually consists of two separate locations.
Just very close. For reasons like this, rather than manually checking through everything, we will just use 
the most RECENT dataset.
*/

-- Let's store the duplicate lat/long values in a temp table
WITH CTE AS (
	SELECT [state], city, [address], postcode, latitude, longitude
	FROM ##mcdonaldsUS
	UNION
	SELECT state_province, city, [address], postcode, latitude, longitude
	FROM ##mcdonaldsWorld
	WHERE country = 'United States'
),
CTE_2 AS (
	SELECT latitude, longitude FROM CTE
	GROUP BY latitude, longitude
	HAVING COUNT(*) > 1
)
SELECT latitude, longitude
INTO #dup_coord
FROM CTE_2;
GO

-- Now create a temp table to house all our mcdonalds US data with any duplicates from World filtered out.
SELECT country, [state], city, [address], postcode, latitude, longitude
INTO #mcdonalds
FROM ##mcdonaldsUS 
UNION
SELECT country, state_province, city, [address], postcode, latitude, longitude
FROM ##mcdonaldsWorld w
WHERE NOT EXISTS (SELECT 1 FROM #dup_coord d WHERE d.latitude = w.latitude)
AND NOT EXISTS (SELECT 1 FROM #dup_coord d WHERE d.longitude = w.longitude)
AND country = 'United States';

-- Insert all rows for Canada 
INSERT INTO #mcdonalds (country, [state], city, [address], postcode, latitude, longitude)
SELECT country, state_province, city, [address], postcode, latitude, longitude
FROM ##mcdonaldsWorld
WHERE country = 'Canada';
GO

-- Get rid of leading and trailing quotations in address column due to changing to tab delimiter
UPDATE #mcdonalds
SET [address] = SUBSTRING([address], 2, LEN([address]) - 2)
WHERE LEFT([address], 1) = '"';

-- Get rid of leading and trailing whitespaces
EXEC Tools.dbo.remove_str_whitespace 
	'FastFood',
	'dbo',
	'#mcdonalds',
	'country,state,city,address,postcode';
GO

-- Normalize capitalizations (first letter each word including after delimiters)
UPDATE #mcdonalds
SET city = dbo.firstCap(city);

UPDATE #mcdonalds
SET [address] = dbo.firstCap([address]);

-- Finally place this into our restaurant_location table
INSERT INTO restaurant_location (restaurant, stateProvinceID, city, [address], postcode, latitude, longitude)
SELECT 'McDonalds', stateProvinceID, city, [address], postcode, latitude, longitude
FROM #mcdonalds m
INNER JOIN stateProvince s 
	ON s.country_name = m.country
	AND s.stateProvince_code = m.[state];
GO


----- Wendys Data -----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ##wendys
GO
CREATE TABLE ##wendys (
	country NVARCHAR(20),
	state_province CHAR(2),
	city NVARCHAR(50),
	[address] NVARCHAR(100),
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO

BULK INSERT ##wendys
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\locations\wendysUS_CA.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
);
GO

-- Sometimes PQ is used as the abbreviation for Quebec, but we want to normalize QC
UPDATE ##wendys
SET state_province = 'QC'
WHERE state_province = 'PQ';

-- Get rid of leading and trailing whitespaces
EXEC Tools.dbo.remove_str_whitespace 
	'FastFood',
	'dbo',
	'##wendys',
	'country,state_province,city,address,postcode';
GO

-- Normalize capitalizations (first letter each word including after delimiters)
UPDATE ##wendys
SET city = dbo.firstCap(city);

UPDATE ##wendys
SET [address] = dbo.firstCap([address]);

-- place into our restaurant_location table
INSERT INTO restaurant_location (restaurant, stateProvinceID, city, [address], postcode, latitude, longitude)
SELECT 'Wendys', stateProvinceID, city, [address], postcode, latitude, longitude
FROM ##wendys w
INNER JOIN stateProvince s 
	ON s.country_code = w.country
	AND s.stateProvince_code = w.state_province;
GO


----- Subway Data -----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ##subway
GO
CREATE TABLE ##subway (
	country NVARCHAR(20),
	state_province NVARCHAR(50),
	city NVARCHAR(50),
	[address] NVARCHAR(100),
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO

-- Have to use tab delimiter as the address sometimes has commas.
BULK INSERT ##subway
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\locations\subwayUS.txt'
WITH
(	
	CODEPAGE = '1252',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
);
GO

-- Insert Canadian Data
BULK INSERT ##subway
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\locations\subwayCA.txt'
WITH
(
	CODEPAGE = '1252',  
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
);
GO

-- Get rid of leading and trailing quotations in address column due to changing to tab delimiter
UPDATE ##subway
SET [address] = SUBSTRING([address], 2, LEN([address]) - 2)
WHERE LEFT([address], 1) = '"';

-- Change any state_province names to their abbreviations
WITH CTE AS (
	SELECT s.state_province, l.stateProvince_code
	FROM ##subway s
	JOIN stateProvince l
	ON l.stateProvince_name = s.state_province
)
UPDATE CTE
SET state_province = stateProvince_code;
GO

-- Checking for duplicates
WITH CTE AS (
	SELECT 
		*, 
		ROW_NUMBER() OVER (PARTITION BY 
			country, state_province, city, [address], postcode, latitude, longitude
		ORDER BY latitude, longitude) AS [row]
	FROM ##subway
)
DELETE FROM CTE WHERE [row] > 1
GO

-- Get rid of leading and trailing whitespaces
EXEC Tools.dbo.remove_str_whitespace 
	'FastFood',
	'dbo',
	'##subway',
	'country,state_province,city,address,postcode';
GO

-- Normalize capitalizations (first letter each word including after delimiters)
UPDATE ##subway
SET city = dbo.firstCap(city);

UPDATE ##subway
SET [address] = dbo.firstCap([address]);

-- Insert into main table
INSERT INTO restaurant_location (restaurant, stateProvinceID, city, [address], postcode, latitude, longitude)
SELECT 'Subway', stateProvinceID, city, [address], postcode, latitude, longitude
FROM ##subway s
INNER JOIN stateProvince sp
	ON sp.country_name = s.country
	AND sp.stateProvince_code = s.state_province;
GO


----- KFC Data -----------------------------------------------------------------------------------------------
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'ad hoc distributed queries', 1;
RECONFIGURE
GO

DROP TABLE IF EXISTS ##kfc;
GO
CREATE TABLE ##kfc (
	country NVARCHAR(20),
	state_province NVARCHAR(50),
	city NVARCHAR(50),
	[address] NVARCHAR(100),
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO

-- Use OPENROWSET or OPENDATASOURCE to insert from our xlsx file.
INSERT INTO ##kfc
SELECT * 
FROM OPENROWSET (
	'Microsoft.ACE.OLEDB.16.0',
	'Excel 12.0 Xml;
	Database=C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\locations\kfcCA.xlsx;',
	Sheet1$
);
GO
/*
INSERT INTO kfc_location
SELECT *
FROM OPENDATASOURCE (
	'Microsoft.ACE.OLEDB.16.0',
	'Data Source=C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\locations\kfcCA.xlsx;
	Extended Properties=Excel 12.0 Xml'
)...[Sheet1$];
GO
*/

BULK INSERT ##kfc
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\locations\kfcUS.txt'
WITH
(
	CODEPAGE = '1252',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
);
GO

-- Get rid of leading and trailing quotations in address column due to changing to tab delimiter
UPDATE ##kfc
SET [address] = SUBSTRING([address], 2, LEN([address]) - 2)
WHERE LEFT([address], 1) = '"';

-- Change any state_province names to their abbreviations
WITH CTE AS (
	SELECT k.state_province, s.stateProvince_code
	FROM ##kfc k
	JOIN stateProvince s
	ON s.stateProvince_name = k.state_province
)
UPDATE CTE
SET state_province = stateProvince_code;
GO

-- I know PEI is the canadian abbreviation, but we are 2 char international codes
UPDATE ##kfc SET state_province = 'PE' WHERE state_province = 'PEI';

-- Also update for Washington DC -> District of Columbia
UPDATE ##kfc SET state_province = 'DC' WHERE state_province = 'Washington DC';

-- Remove duplicates rows
WITH CTE AS (
	SELECT 
		*, 
		ROW_NUMBER() OVER (PARTITION BY 
			country, state_province, city, [address], postcode, latitude, longitude
		ORDER BY latitude, longitude) AS [row]
	FROM ##kfc
)
DELETE FROM CTE WHERE [row] > 1

-- Get rid of leading and trailing whitespaces
EXEC Tools.dbo.remove_str_whitespace 
	'FastFood',
	'dbo',
	'##kfc',
	'country,state_province,city,address,postcode';
GO

-- Normalize capitalizations (first letter each word including after delimiters)
UPDATE ##kfc
SET city = dbo.firstCap(city);

UPDATE ##kfc
SET [address] = dbo.firstCap([address]);

-- Insert into main table
INSERT INTO restaurant_location (restaurant, stateProvinceID, city, [address], postcode, latitude, longitude)
SELECT 'KFC', stateProvinceID, city, [address], postcode, latitude, longitude
FROM ##kfc k
INNER JOIN stateProvince s
	ON s.country_name = k.country
	AND s.stateProvince_code = k.state_province;
GO


----- Tim Hortons Data -----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ##timhortons;
GO
CREATE TABLE ##timhortons (
	country NVARCHAR(20),
	state_province NVARCHAR(50),
	city NVARCHAR(50),
	[address] NVARCHAR(200),
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO

BULK INSERT ##timhortons
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\locations\timhortonsCA.txt'
WITH
(
	CODEPAGE = '1252',  -- codepage for Windows ANSI (Western) which our txt file is using
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
);
GO

BULK INSERT ##timhortons
FROM 'C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\locations\timhortonsUS.txt'
WITH
(
	CODEPAGE = '65001',  
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '\n'
);
GO

-- Get rid of leading and trailing quotations in address column due to changing to tab delimiter
UPDATE ##timhortons
SET [address] = SUBSTRING([address], 2, LEN([address]) - 2)
WHERE LEFT([address], 1) = '"';

-- Change any state_province names to their abbreviations
WITH CTE AS (
	SELECT t.state_province, s.stateProvince_code
	FROM ##timhortons t
	JOIN stateProvince s
	ON s.stateProvince_name = t.state_province
)
UPDATE CTE
SET state_province = stateProvince_code;
GO

-- Remove duplicates rows
WITH CTE AS (
	SELECT 
		*, 
		ROW_NUMBER() OVER (PARTITION BY 
			country, state_province, city, [address], postcode, latitude, longitude
		ORDER BY latitude, longitude) AS [row]
	FROM ##timhortons
)
DELETE FROM CTE WHERE [row] > 1

-- Get rid of leading and trailing whitespaces
EXEC Tools.dbo.remove_str_whitespace 
	'FastFood',
	'dbo',
	'##timhortons',
	'country,state_province,city,address,postcode';
GO

-- Normalize capitalizations (first letter each word including after delimiters)
UPDATE ##timhortons
SET city = dbo.firstCap(city);

UPDATE ##timhortons
SET [address] = dbo.firstCap([address])

-- Insert into main table
INSERT INTO restaurant_location (restaurant, stateProvinceID, city, [address], postcode, latitude, longitude)
SELECT 'Tim Hortons', stateProvinceID, city, [address], postcode, latitude, longitude
FROM ##timhortons t
INNER JOIN stateProvince s
	ON s.country_name = t.country
	AND s.stateProvince_code = t.state_province;
GO


----- Domino's Pizza Data -----------------------------------------------------------------------------------------------
