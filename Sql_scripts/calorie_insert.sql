USE FastFood;
GO


-- Wendys calorie tables ---------------------------------------------------------------------------------------

INSERT INTO wendys_calories_CA
SELECT * 
FROM OPENROWSET (
	'Microsoft.ACE.OLEDB.16.0',
	'Excel 12.0 Xml;
	IMEX=0;
	Database=C:\Users\Weihan\PersonalProjects\FastFoodChains\Datasets\Clean\menus\calories\wendys_calories_CA.xlsx;',
	Sheet1$
);
GO

INSERT INTO wendys_calories_US
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
UPDATE wendys_calories_CA
SET item_name = REPLACE(item_name, '®', '')
WHERE item_name LIKE '%®%';

UPDATE wendys_calories_CA
SET item_name = REPLACE(item_name, '™', '')
WHERE item_name LIKE '%™%';

UPDATE wendys_calories_US
SET item_name = REPLACE(item_name, '®', '')
WHERE item_name LIKE '%®%';

UPDATE wendys_calories_US
SET item_name = REPLACE(item_name, '™', '')
WHERE item_name LIKE '%™%';

-- Remove all duplicate item names
EXEC Tools.dbo.DeleteDuplicateRecords 
	'FastFood',
	'wendys_calories_CA',
	'item_name',
	'item_name';
GO

EXEC Tools.dbo.DeleteDuplicateRecords 
	'FastFood',
	'wendys_calories_US',
	'item_name',
	'item_name';
GO

-- Remove all commas in the calories column
UPDATE wendys_calories_CA
SET calories = REPLACE(calories, ',','')
WHERE calories LIKE '%,%';

UPDATE wendys_calories_US
SET calories = REPLACE(calories, ',','')
WHERE calories LIKE '%,%';

-- Average the calorie ranges and/or splits
EXEC avg_calorie_rng 'wendys_calories_CA';
EXEC avg_calorie_rng 'wendys_calories_US';
EXEC avg_calorie_split 'wendys_calories_CA';
EXEC avg_calorie_split 'wendys_calories_US';


