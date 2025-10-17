USE FastFood;
GO

-- Create a lookup table for states, provinces, territories and their abbreviations -----------------------
DROP TABLE IF EXISTS stateProvince;
GO
CREATE TABLE stateProvince (
	stateProvinceID INT IDENTITY(1,1) PRIMARY KEY,
	stateProvince_name NVARCHAR(50),
	stateProvince_code NCHAR(2),
	country_name NVARCHAR(50),
	country_code NCHAR(2)
);
GO

INSERT INTO stateProvince (stateProvince_name, stateProvince_code, country_name, country_code) VALUES
('Alabama', 'AL', 'United States', 'US'),
('Alaska', 'AK', 'United States', 'US'),
('Arizona', 'AZ', 'United States', 'US'),
('Arkansas', 'AR', 'United States', 'US'),
('California', 'CA', 'United States', 'US'),
('Colorado', 'CO', 'United States', 'US'),
('Connecticut', 'CT', 'United States', 'US'),
('Delaware', 'DE', 'United States', 'US'),
('Florida', 'FL', 'United States', 'US'),
('Georgia', 'GA', 'United States', 'US'),
('Hawaii', 'HI', 'United States', 'US'),
('Idaho', 'ID', 'United States', 'US'),
('Illinois', 'IL', 'United States', 'US'),
('Indiana', 'IN', 'United States', 'US'),
('Iowa', 'IA', 'United States', 'US'),
('Kansas', 'KS', 'United States', 'US'),
('Kentucky', 'KY', 'United States', 'US'),
('Louisiana', 'LA', 'United States', 'US'),
('Maine', 'ME', 'United States', 'US'),
('Maryland', 'MD', 'United States', 'US'),
('Massachusetts', 'MA', 'United States', 'US'),
('Michigan', 'MI', 'United States', 'US'),
('Minnesota', 'MN', 'United States', 'US'),
('Mississippi', 'MS', 'United States', 'US'),
('Missouri', 'MO', 'United States', 'US'),
('Montana', 'MT', 'United States', 'US'),
('Nebraska', 'NE', 'United States', 'US'),
('Nevada', 'NV', 'United States', 'US'),
('New Hampshire', 'NH', 'United States', 'US'),
('New Jersey', 'NJ', 'United States', 'US'),
('New Mexico', 'NM', 'United States', 'US'),
('New York', 'NY', 'United States', 'US'),
('North Carolina', 'NC', 'United States', 'US'),
('North Dakota', 'ND', 'United States', 'US'),
('Ohio', 'OH', 'United States', 'US'),
('Oklahoma', 'OK', 'United States', 'US'),
('Oregon', 'OR', 'United States', 'US'),
('Pennsylvania', 'PA', 'United States', 'US'),
('Rhode Island', 'RI', 'United States', 'US'),
('South Carolina', 'SC', 'United States', 'US'),
('South Dakota', 'SD', 'United States', 'US'),
('Tennessee', 'TN', 'United States', 'US'),
('Texas', 'TX', 'United States', 'US'),
('Utah', 'UT', 'United States', 'US'),
('Vermont', 'VT', 'United States', 'US'),
('Virginia', 'VA', 'United States', 'US'),
('Washington', 'WA', 'United States', 'US'),
('West Virginia', 'WV', 'United States', 'US'),
('Wisconsin', 'WI', 'United States', 'US'),
('Wyoming', 'WY', 'United States', 'US'),
('District of Columbia', 'DC', 'United States', 'US'),
('American Samoa', 'AS', 'United States', 'US'),
('Guam', 'GU', 'United States', 'US'),
('Northern Mariana Islands', 'MP', 'United States', 'US'),
('Puerto Rico', 'PR', 'United States', 'US'),
('U.S. Virgin Islands', 'VI', 'United States', 'US'),
('Ontario', 'ON', 'Canada', 'CA'),
('Quebec', 'QC', 'Canada', 'CA'),
('Nova Scotia', 'NS', 'Canada', 'CA'),
('New Brunswick', 'NB', 'Canada', 'CA'),
('Manitoba', 'MB', 'Canada', 'CA'),
('British Columbia', 'BC', 'Canada', 'CA'),
('Prince Edward Island', 'PE', 'Canada', 'CA'),
('Saskatchewan', 'SK', 'Canada', 'CA'),
('Alberta', 'AB', 'Canada', 'CA'),
('Newfoundland and Labrador', 'NL', 'Canada', 'CA'),
('Northwest Territories', 'NT', 'Canada', 'CA'),
('Yukon', 'YT', 'Canada', 'CA'),
('Nunavut', 'NU', 'Canada', 'CA');
GO


-- Create a table for our fast food chain locations ------------------------------------------------------------------
DROP TABLE IF EXISTS restaurant_location;
GO
CREATE TABLE restaurant_location (
	store_id INT IDENTITY(1,1) PRIMARY KEY,
	restaurant NVARCHAR(50),
	stateProvinceID INT FOREIGN KEY REFERENCES stateProvince(stateProvinceID),
	city NVARCHAR(50),
	[address] NVARCHAR(100),
	postcode NVARCHAR(20),
	latitude DECIMAL(8,6),
	longitude DECIMAL(9,6)
);
-- COLLATE Latin1_General_100_CI_AI_WS_SC_UTF8
-- Don't need too add this collation to our city and address columns anymore.
-- Just make sure we use NVARCHAR during BULK INSERT


-- Create tables for the Menu items -----------------------------------------------------------------------
DROP TABLE IF EXISTS menu;
GO
CREATE TABLE menu (
	country NVARCHAR(50),
	restaurant NVARCHAR(50),
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price DECIMAL(5, 2),
	calories INT,
	CONSTRAINT PK_menu PRIMARY KEY(country, restaurant, item_name)
);
GO


-- Create separate tables for canadian and American calorie data (Official franchise site)
DROP TABLE IF EXISTS caloriesCA;
GO
CREATE TABLE caloriesCA (
	restaurant NVARCHAR(50),
	item_name NVARCHAR(100),
	calories INT,
	CONSTRAINT PK_caloriesCA PRIMARY KEY(restaurant, item_name)
);
GO

DROP TABLE IF EXISTS caloriesUS;
GO
CREATE TABLE caloriesUS (
	restaurant NVARCHAR(50),
	item_name NVARCHAR(100),
	calories INT,
	CONSTRAINT PK_caloriesUS PRIMARY KEY(restaurant, item_name)
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




