USE FastFood;
GO

-- Create a lookup table for states, provinces, territories and their abbreviations -----------------------
DROP TABLE IF EXISTS lookup_abbr;
GO
CREATE TABLE lookup_abbr (
	state_province NVARCHAR(50),
	state_province_abbr NCHAR(2)
);
GO

INSERT INTO lookup_abbr VALUES
('Alabama', 'AL'),
('Alaska', 'AK'),
('Arizona', 'AZ'),
('Arkansas', 'AR'),
('California', 'CA'),
('Colorado', 'CO'),
('Connecticut', 'CT'),
('Delaware', 'DE'),
('Florida', 'FL'),
('Georgia', 'GA'),
('Hawaii', 'HI'),
('Idaho', 'ID'),
('Illinois', 'IL'),
('Indiana', 'IN'),
('Iowa', 'IA'),
('Kansas', 'KS'),
('Kentucky', 'KY'),
('Louisiana', 'LA'),
('Maine', 'ME'),
('Maryland', 'MD'),
('Massachusetts', 'MA'),
('Michigan', 'MI'),
('Minnesota', 'MN'),
('Mississippi', 'MS'),
('Missouri', 'MO'),
('Montana', 'MT'),
('Nebraska', 'NE'),
('Nevada', 'NV'),
('New Hampshire', 'NH'),
('New Jersey', 'NJ'),
('New Mexico', 'NM'),
('New York', 'NY'),
('North Carolina', 'NC'),
('North Dakota', 'ND'),
('Ohio', 'OH'),
('Oklahoma', 'OK'),
('Oregon', 'OR'),
('Pennsylvania', 'PA'),
('Rhode Island', 'RI'),
('South Carolina', 'SC'),
('South Dakota', 'SD'),
('Tennessee', 'TN'),
('Texas', 'TX'),
('Utah', 'UT'),
('Vermont', 'VT'),
('Virginia', 'VA'),
('Washington', 'WA'),
('West Virginia', 'WV'),
('Wisconsin', 'WI'),
('Wyoming', 'WY'),
('District of Columbia', 'DC'),
('American Samoa', 'AS'),
('Guam', 'GU'),
('Northern Mariana Islands', 'MP'),
('Puerto Rico', 'PR'),
('U.S. Virgin Islands', 'VI'),
('Ontario', 'ON'),
('Quebec', 'QC'),
('Nova Scotia', 'NS'),
('New Brunswick', 'NB'),
('Manitoba', 'MB'),
('British Columbia', 'BC'),
('Prince Edward Island', 'PE'),
('Saskatchewan', 'SK'),
('Alberta', 'AB'),
('Newfoundland and Labrador', 'NL'),
('Northwest Territories', 'NT'),
('Yukon', 'YT'),
('Nunavut', 'NU');
GO


-- Create tables for our fast food chains ------------------------------------------------------------------
DROP TABLE IF EXISTS mcdonalds_location;
GO 
CREATE TABLE mcdonalds_location (
	store_id INT IDENTITY(1,1) PRIMARY KEY,
	country NVARCHAR(20) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	state_province NVARCHAR(50) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8, 
	city NVARCHAR(50) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	[address] NVARCHAR(100) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO

DROP TABLE IF EXISTS wendys_location;
GO
CREATE TABLE wendys_location (
	store_id INT IDENTITY(1,1) PRIMARY KEY,
	country NVARCHAR(20) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	state_province NVARCHAR(50) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	city NVARCHAR(50) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	[address] NVARCHAR(100) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO

DROP TABLE IF EXISTS subway_location;
GO
CREATE TABLE subway_location (
	store_id INT IDENTITY(1,1) PRIMARY KEY,
	country NVARCHAR(20) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	state_province NVARCHAR(50) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	city NVARCHAR(50) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	[address] NVARCHAR(100) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO

DROP TABLE IF EXISTS kfc_location;
GO
CREATE TABLE kfc_location (
	store_id INT IDENTITY(1,1) PRIMARY KEY,
	country NVARCHAR(20) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	state_province NVARCHAR(50) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	city NVARCHAR(50) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	[address] NVARCHAR(100) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO

DROP TABLE IF EXISTS timhortons_location;
GO
CREATE TABLE timhortons_location (
	store_id INT IDENTITY(1,1) PRIMARY KEY,
	country NVARCHAR(20) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	state_province NVARCHAR(50) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	city NVARCHAR(50) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	[address] NVARCHAR(110) COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8,
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
GO


-- Create tables for the Menu items -----------------------------------------------------------------------
DROP TABLE IF EXISTS mcdonalds_menu_CA;
GO
CREATE TABLE mcdonalds_menu_CA (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price DECIMAL(5, 2),
	calories INT
);
GO

DROP TABLE IF EXISTS mcdonalds_menu_US;
GO
CREATE TABLE mcdonalds_menu_US (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price DECIMAL(5, 2),
	calories INT
);
GO

DROP TABLE IF EXISTS wendys_menu_CA;
GO
CREATE TABLE wendys_menu_CA (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price DECIMAL(5, 2),
	calories INT
);
GO

DROP TABLE IF EXISTS wendys_menu_US;
GO
CREATE TABLE wendys_menu_US (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price DECIMAL(5, 2),
	calories INT
);
GO

DROP TABLE IF EXISTS subway_menu_CA;
GO
CREATE TABLE subway_menu_CA (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price DECIMAL(5, 2),
	calories INT
);
GO

DROP TABLE IF EXISTS subway_menu_US;
GO
CREATE TABLE subway_menu_US (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price DECIMAL(5, 2),
	calories INT
);
GO

DROP TABLE IF EXISTS kfc_menu_CA;
GO
CREATE TABLE kfc_menu_CA (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price DECIMAL(5, 2),
	calories INT
);
GO

DROP TABLE IF EXISTS kfc_menu_US;
GO
CREATE TABLE kfc_menu_US (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price DECIMAL(5, 2),
	calories INT
);
GO


-- Create tables for the calorie lists -----------------------------------------------------------------------
DROP TABLE IF EXISTS wendys_calories_CA;
GO
CREATE TABLE wendys_calories_CA (
	item_name NVARCHAR(100),
	calories VARCHAR(15)
);
GO

DROP TABLE IF EXISTS wendys_calories_US;
GO
CREATE TABLE wendys_calories_US (
	item_name NVARCHAR(100),
	calories VARCHAR(15)
);
GO


-- Create procedures/functions for commonly used cleaning methods (specific to our tables) ------------------

-- Capitalize every first letter in a string (accounting for spaces, and hyphens)
-- while turning every other character to lowercase
DROP FUNCTION IF EXISTS dbo.firstCap;
GO
CREATE FUNCTION dbo.firstCap (@inputString VARCHAR(4000))
RETURNS VARCHAR(4000)
AS
BEGIN
	DECLARE @outputString VARCHAR(255);
	DECLARE @index INT = 1;
	DECLARE @char CHAR(1);
	DECLARE @prevChar CHAR(1);

	SET @outputString = LOWER(@inputString);

	WHILE @index <= LEN(@outputString)
	BEGIN
		SET @char = SUBSTRING(@outputString, @index, 1);
		SET @prevChar = CASE WHEN @index = 1 THEN ' '
							ELSE SUBSTRING(@outputString, @index - 1, 1)
						END;

		IF @prevChar IN (' ', '-')
			SET @outputString = STUFF(@outputString, @index, 1, UPPER(@char));

		SET @index += 1;
	END;

	RETURN @outputString;	
END;
GO

-- Return the average calorie for a calorie range in a given table
DROP PROC IF EXISTS avg_calorie_rng;
GO
CREATE PROC avg_calorie_rng
	@tbl_name NVARCHAR(50)
AS
BEGIN
	-- Check for table existence first. So if someone tries SQL injection, it will not break the proc
	IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE [name] = @tbl_name) 
		AND NOT EXISTS (SELECT 1 FROM tempdb.sys.objects WHERE [name] = @tbl_name)
	BEGIN
		RAISERROR(N'Invalid input', -1, 1);
		RETURN;
	END
	
	DECLARE @sql NVARCHAR(4000);
	SET @sql = 
		N'WITH CTE AS (
			SELECT item_name, calories,
				CAST(LEFT(calories, CHARINDEX(''-'', calories) - 1) AS INT) AS minimum,
				CAST(RIGHT(calories, LEN(calories) - CHARINDEX(''-'', calories)) AS INT) AS maximum
			FROM dbo.' + QUOTENAME(@tbl_name) + '
			WHERE calories LIKE ''%-%''
		)
		UPDATE CTE 
		SET calories = (minimum + maximum) / 2';

	EXEC (@sql);
END
GO

-- Return the average calorie for a given calorie split. E.g. '120/200'. Even if there is no 'medium'.
DROP PROC IF EXISTS avg_calorie_split;
GO
CREATE PROC avg_calorie_split
	@tbl_name NVARCHAR(50)
AS
BEGIN
	-- Check for table existence first. So if someone tries SQL injection, it will not break the proc
	IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE [name] = @tbl_name) 
		AND NOT EXISTS (SELECT 1 FROM tempdb.sys.objects WHERE [name] = @tbl_name)
	BEGIN
		RAISERROR(N'Invalid input', -1, 1);
		RETURN;
	END

	DECLARE @sql NVARCHAR(4000);
	SET @sql = 
		N'WITH CTE AS (
			SELECT item_name, calories,
				CAST(LEFT(calories, CHARINDEX(''/'', calories) - 1) AS INT) AS minimum,
				CAST(RIGHT(calories, LEN(calories) - CHARINDEX(''/'', calories)) AS INT) AS maximum
			FROM dbo.' + QUOTENAME(@tbl_name) + '
			WHERE calories LIKE ''%/%''
		)
		UPDATE CTE 
		SET calories = (minimum + maximum) / 2';

	EXEC (@sql);
END
GO




