USE FastFood;
GO

--- McDonalds Menu ------------------------------------------------------------------------------------------ 

-- Get the Canadian Data
DROP TABLE IF EXISTS ##mcdonalds_menu_CA;
GO
CREATE TABLE ##mcdonalds_menu_CA (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price VARCHAR(15),
	calories VARCHAR(15)
);
GO

INSERT INTO ##mcdonalds_menu_CA 
SELECT * 
FROM OPENROWSET (
	'Microsoft.ACE.OLEDB.16.0',
	'Excel 12.0 Xml;
	IMEX=1;
	Database=C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\menus\mcdonalds_menu_CA.xlsx;',
	Sheet1$
);
GO

-- Get the American Data
DROP TABLE IF EXISTS ##mcdonalds_menu_US;
GO
CREATE TABLE ##mcdonalds_menu_US (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price VARCHAR(15),
	calories VARCHAR(15)
);
GO

INSERT INTO ##mcdonalds_menu_US
SELECT * 
FROM OPENROWSET (
	'Microsoft.ACE.OLEDB.16.0',
	'Excel 12.0 Xml;
	IMEX=1;
	Database=C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\menus\mcdonalds_menu_US.xlsx;',
	Sheet1$
);
GO

-- Get rid of any duplicate items
EXEC Tools.dbo.DeleteDuplicateRecords 
	'FastFood',
	'##mcdonalds_menu_CA',
	'item_name',
	'item_name';
GO

EXEC Tools.dbo.DeleteDuplicateRecords
	'FastFood',
	'##mcdonalds_menu_US',
	'item_name',
	'item_name';
GO

-- Get rid of items without a price
DELETE FROM ##mcdonalds_menu_CA
WHERE price NOT LIKE '%[0-9]%';

DELETE FROM ##mcdonalds_menu_US
WHERE price NOT LIKE '%[0-9]%';

-- Average any calorie ranges. Consider everything medium sized unless stated explicitly.
EXEC avg_calorie_rng '##mcdonalds_menu_CA';
EXEC avg_calorie_rng '##mcdonalds_menu_US';

-- Remove all special symbols '®' and '™'
UPDATE ##mcdonalds_menu_CA
SET item_name = REPLACE(item_name, '®', '')
WHERE item_name LIKE '%®%';

UPDATE ##mcdonalds_menu_CA
SET item_name = REPLACE(item_name, '™', '')
WHERE item_name LIKE '%™%';

UPDATE ##mcdonalds_menu_US
SET item_name = REPLACE(item_name, '®', '')
WHERE item_name LIKE '%®%';

UPDATE ##mcdonalds_menu_US
SET item_name = REPLACE(item_name, '™', '')
WHERE item_name LIKE '%™%';

-- Place everything back into the main tables.
INSERT INTO mcdonalds_menu_CA (item_name, category, price, calories)
SELECT item_name, category, price, calories
FROM ##mcdonalds_menu_CA;
GO

INSERT INTO mcdonalds_menu_US (item_name, category, price, calories)
SELECT item_name, category, price , calories
FROM ##mcdonalds_menu_US;
GO


--- Wendys Menu ------------------------------------------------------------------------------------------ 

DROP TABLE IF EXISTS ##wendys_menu_CA;
GO
CREATE TABLE ##wendys_menu_CA (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price VARCHAR(15),
	calories VARCHAR(15)
);
GO

INSERT INTO ##wendys_menu_CA 
SELECT * 
FROM OPENROWSET (
	'Microsoft.ACE.OLEDB.16.0',
	'Excel 12.0 Xml;
	IMEX=0;
	Database=C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\menus\wendys_menu_CA.xlsx;',
	Sheet1$
);
GO

DROP TABLE IF EXISTS ##wendys_menu_US;
GO
CREATE TABLE ##wendys_menu_US (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price VARCHAR(15),
);
GO

INSERT INTO ##wendys_menu_US 
SELECT * 
FROM OPENROWSET (
	'Microsoft.ACE.OLEDB.16.0',
	'Excel 12.0 Xml;
	IMEX=1;
	Database=C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\menus\wendys_menu_US.xlsx;',
	Sheet1$
);
GO

-- Get rid of any duplicate items
EXEC Tools.dbo.DeleteDuplicateRecords 
	'FastFood',
	'##wendys_menu_CA',
	'item_name',
	'item_name';
GO

EXEC Tools.dbo.DeleteDuplicateRecords
	'FastFood',
	'##wendys_menu_US',
	'item_name',
	'item_name';
GO

-- Get rid of items without a price
DELETE FROM ##wendys_menu_CA
WHERE price IS NULL;

DELETE FROM ##wendys_menu_US
WHERE price IS NULL;

-- Remove all special symbols '®' and '™'
UPDATE ##wendys_menu_CA
SET item_name = REPLACE(item_name, '®', '')
WHERE item_name LIKE '%®%';

UPDATE ##wendys_menu_CA
SET item_name = REPLACE(item_name, '™', '')
WHERE item_name LIKE '%™%';

UPDATE ##wendys_menu_US
SET item_name = REPLACE(item_name, '®', '')
WHERE item_name LIKE '%®%';

UPDATE ##wendys_menu_US
SET item_name = REPLACE(item_name, '™', '')
WHERE item_name LIKE '%™%';

-- Average any calorie range
EXEC avg_calorie_rng '##wendys_menu_CA';

-- Pull in data from wendys calories tables to try and fill gaps ---------------------

-- There is literally no calorie info for the missing canadian data
SELECT m.item_name, m.calories, c.calories
FROM ##wendys_menu_CA m
JOIN wendys_calories_CA c
ON c.item_name = m.item_name
WHERE m.calories LIKE '';

ALTER TABLE ##wendys_menu_US
ADD calories INT DEFAULT ''
GO

WITH CTE AS (
	SELECT m.item_name, m.calories AS menu_cals, c.calories AS list_cals
	FROM ##wendys_menu_US m
	JOIN wendys_calories_US c
	ON c.item_name = m.item_name
)
UPDATE CTE SET menu_cals = list_cals;

-- Empty calories should be set to NULL or else they will equal '0' when inserting into INT column
UPDATE ##wendys_menu_CA
SET calories = NULL
WHERE calories = '';

-- Place everything back into the main tables.
INSERT INTO wendys_menu_CA (item_name, category, price, calories)
SELECT item_name, category, price, calories
FROM ##wendys_menu_CA;
GO

INSERT INTO wendys_menu_US (item_name, category, price, calories)
SELECT item_name, category, price, calories
FROM ##wendys_menu_US;
GO


--- Subway Menu ------------------------------------------------------------------------------------------ 

DROP TABLE IF EXISTS ##subway_menu_CA;
GO
CREATE TABLE ##subway_menu_CA (
	item_name NVARCHAR(100),
	category NVARCHAR(100),
	price VARCHAR(15),
	calories VARCHAR(15)
);
GO

INSERT INTO ##subway_menu_CA 
SELECT * 
FROM OPENROWSET (
	'Microsoft.ACE.OLEDB.16.0',
	'Excel 12.0 Xml;
	IMEX=1;
	Database=C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\menus\subway_menu_CA.xlsx;',
	Sheet1$
);
GO 

DELETE FROM ##subway_menu_CA
WHERE price IS NULL;

EXEC Tools.dbo.DeleteDuplicateRecords 
	'FastFood',
	'##subway_menu_CA',
	'item_name',
	'item_name';
GO

UPDATE ##subway_menu_CA
SET item_name = REPLACE(item_name, '®', '')
WHERE item_name LIKE '%®%';

UPDATE ##subway_menu_CA
SET item_name = REPLACE(item_name, '™', '')
WHERE item_name LIKE '%™%';

INSERT INTO subway_menu_CA (item_name, category, price, calories)
SELECT item_name, category, price, calories
FROM ##subway_menu_CA;


--- KFC Menu ------------------------------------------------------------------------------------------ 


SELECT * FROM mcdonalds_menu_CA;
SELECT * FROM mcdonalds_menu_US;
SELECT * FROM wendys_menu_CA;
SELECT * FROM wendys_menu_US;
SELECT * FROM subway_menu_CA

SELECT * FROM subway_menu_US;

SELECT * FROM kfc_menu_CA;