USE FastFood;
GO

-- Create a lookup table for states, provinces, territories and their abbreviations
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

-- Create tables for our fast food chains
DROP TABLE IF EXISTS mcdonalds;
GO 
CREATE TABLE mcdonalds (
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

DROP TABLE IF EXISTS wendys;
GO
CREATE TABLE wendys (
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

DROP TABLE IF EXISTS subway;
GO
CREATE TABLE subway (
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

DROP TABLE IF EXISTS kfc;
GO
CREATE TABLE kfc (
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

