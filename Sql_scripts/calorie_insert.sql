USE FastFood;
GO


-- Wendys calorie tables ---------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ##caloriesCA;
GO
CREATE TABLE ##caloriesCA (
	restaurant NVARCHAR(50),
	item_name NVARCHAR(100),
	calories NVARCHAR(15)
);
GO

DROP TABLE IF EXISTS ##caloriesUS;
GO
CREATE TABLE ##caloriesUS (
	restaurant NVARCHAR(50),
	item_name NVARCHAR(100),
	calories NVARCHAR(15)
);
GO

INSERT INTO ##caloriesCA
SELECT * 
FROM OPENROWSET (
	'Microsoft.ACE.OLEDB.16.0',
	'Excel 12.0 Xml;
	IMEX=0;
	Database=C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\menus\calories\wendys_calories_CA.xlsx;',
	Sheet1$
);
GO

INSERT INTO ##caloriesUS
SELECT * 
FROM OPENROWSET (
	'Microsoft.ACE.OLEDB.16.0',
	'Excel 12.0 Xml;
	IMEX=0;
	Database=C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\menus\calories\wendys_calories_US.xlsx;',
	Sheet1$
);
GO

-- Remove all special symbols '®' and '™'
UPDATE ##caloriesCA
SET item_name = REPLACE(item_name, '®', '')
WHERE item_name LIKE '%®%';

UPDATE ##caloriesCA
SET item_name = REPLACE(item_name, '™', '')
WHERE item_name LIKE '%™%';

UPDATE ##caloriesUS
SET item_name = REPLACE(item_name, '®', '')
WHERE item_name LIKE '%®%';

UPDATE ##caloriesUS
SET item_name = REPLACE(item_name, '™', '')
WHERE item_name LIKE '%™%';

-- Remove all duplicate item names
EXEC Tools.dbo.DeleteDuplicateRecords 
	'FastFood',
	'##caloriesCA',
	'item_name',
	'item_name';
GO

EXEC Tools.dbo.DeleteDuplicateRecords 
	'FastFood',
	'##caloriesUS',
	'item_name',
	'item_name';
GO

-- Remove all commas in the calories column
UPDATE ##caloriesCA
SET calories = REPLACE(calories, ',','')
WHERE calories LIKE '%,%';

UPDATE ##caloriesUS
SET calories = REPLACE(calories, ',','')
WHERE calories LIKE '%,%';

-- Average the calorie ranges and/or splits
EXEC avg_calorie_rng '##caloriesCA';
EXEC avg_calorie_rng '##caloriesUS';
EXEC avg_calorie_split '##caloriesCA';
EXEC avg_calorie_split '##caloriesUS';

-- Insert back into main table
INSERT INTO caloriesCA (restaurant, item_name, calories)
SELECT restaurant, item_name, calories
FROM ##caloriesCA;

INSERT INTO caloriesUS (restaurant, item_name, calories)
SELECT restaurant, item_name, calories
FROM ##caloriesUS;

