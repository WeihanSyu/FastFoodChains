USE FastFood;
GO


-- Create views for each chain to show calories/dollar -> Canadian Menu only
DROP VIEW IF EXISTS mcdonalds_cals_per_buck_CA;
GO
CREATE VIEW mcdonalds_cals_per_buck_CA
AS
SELECT *, CAST(ROUND(calories/price, 0) AS INT) AS [calories/dollar]
FROM mcdonalds_menu_CA;
GO

DROP VIEW IF EXISTS wendys_cals_per_buck_CA;
GO
CREATE VIEW wendys_cals_per_buck_CA
AS
SELECT *, CAST(ROUND(calories/price, 0) AS INT) AS [calories/dollar]
FROM wendys_menu_CA;
GO

DROP VIEW IF EXISTS subway_cals_per_buck_CA;
GO
CREATE VIEW subway_cals_per_buck_CA
AS
SELECT *, CAST(ROUND(calories/price, 0) AS INT) AS [calories/dollar]
FROM subway_menu_CA;
GO

-- Create an Overall Combined View for each chain -> Canadian Menu only
DROP VIEW IF EXISTS all_menus_CA;
GO
CREATE VIEW all_menus_CA 
AS
SELECT 'McDonalds' AS restaurant, * FROM mcdonalds_cals_per_buck_CA
UNION
SELECT 'Wendys', * FROM wendys_cals_per_buck_CA
UNION
SELECT 'Subway', * FROM subway_cals_per_buck_CA;
GO

-- Export our menus with calories/dollar to a csv in a format more suitable for Tableau use
SELECT 'McDonalds' AS restaurant, * FROM mcdonalds_cals_per_buck_CA
UNION
SELECT 'Wendys', * FROM wendys_cals_per_buck_CA
UNION
SELECT 'Subway', * FROM subway_cals_per_buck_CA;

-- Export our locations to a csv in a format more suitable for Tableau use
SELECT 'McDonalds' AS restaurant, * FROM mcdonalds_location
UNION
SELECT 'Wendys', * FROM wendys_location
UNION
SELECT 'Subway', * FROM subway_location;

----------------------------------------------------------------------------------------------------------


-- 1. Out of our list, which fast food chain has the most locations in BC?
WITH CTE AS (
	SELECT 'McDonalds' AS restaurant, COUNT(*) AS num_locations_BC 
	FROM mcdonalds_location WHERE country = 'Canada' AND state_province = 'BC' 
	UNION
	SELECT 'Wendys', COUNT(*) FROM wendys_location WHERE country = 'Canada' AND state_province = 'BC'
	UNION
	SELECT 'Subway', COUNT(*) FROM subway_location WHERE country = 'Canada' AND state_province = 'BC'
	UNION
	SELECT 'KFC', COUNT(*) FROM kfc_location WHERE country = 'Canada' AND state_province = 'BC'
	UNION
	SELECT 'Tim Hortons', COUNT(*) 
	FROM timhortons_location WHERE country = 'Canada' AND state_province = 'BC'
)
SELECT TOP(1) * FROM CTE
ORDER BY num_locations_BC DESC;

/* 2. Which restaurant leads the pack according to Calories/Dollar for categories "main" and "sides"
and by what percentage is it ahead of the runner-up? */

SELECT restaurant, category, 
	AVG([calories/dollar]) AS avg_item_calories,
	DENSE_RANK() OVER (PARTITION BY category ORDER BY AVG([calories/dollar]) DESC) AS rnk
FROM all_menus_CA
WHERE category = 'main' OR category = 'sides'
GROUP BY restaurant, category;

-- Percentage ahead
WITH CTE AS (
	SELECT restaurant, category, 
		AVG([calories/dollar]) AS avg_item_calories,
		DENSE_RANK() OVER (PARTITION BY category ORDER BY AVG([calories/dollar]) DESC) AS rnk
	FROM all_menus_CA
	WHERE category = 'main' OR category = 'sides'
	GROUP BY restaurant, category
),
CTE_2 AS (
	SELECT restaurant, category, 
		((CAST(avg_item_calories AS FLOAT) / LEAD(avg_item_calories) OVER (ORDER BY category, rnk)) - 1) * 100
		AS percent_diff_from_runner_up,
		rnk
	FROM CTE
)
SELECT restaurant, category, percent_diff_from_runner_up
FROM CTE_2
WHERE rnk = 1;

-- 3. Which restaurant has the worst bang for buck from the main line item selection?
SELECT TOP(1) restaurant, category, 
	AVG([calories/dollar]) AS avg_item_calories
FROM all_menus_CA
WHERE category = 'main'
GROUP BY restaurant, category
ORDER BY avg_item_calories ASC;

-- 4. Are combos and meals actually worth it?
SELECT item_name, [calories/dollar] 
FROM mcdonalds_cals_per_buck_CA
WHERE category = 'combo meals'
UNION
SELECT item_name, [calories/dollar] 
FROM mcdonalds_cals_per_buck_CA
WHERE category = 'main'
UNION
SELECT item_name, [calories/dollar] 
FROM mcdonalds_cals_per_buck_CA
WHERE category = 'breakfast';
/* NO! In fact, some individual items are most cost effective than getting the combo. 
This means that, either the drinks that come with the meal are horrible calories/dollar wise, or
the sides, or both. */

-- 5. What is the most cost effective menu to be ordering from?
WITH CTE AS (
	SELECT restaurant, category, 
		AVG([calories/dollar]) AS avg_item_calories,
		DENSE_RANK() OVER (PARTITION BY restaurant ORDER BY AVG([calories/dollar]) DESC) rnk
	FROM all_menus_CA
	GROUP BY restaurant, category
)
SELECT * FROM CTE
WHERE rnk = 1;
-- Baked Goods is the unanimous king of value. Not surprising. Full of fats.

-- 6. Now get the percentage of how many restaurants have the the same top 1 category
WITH CTE AS (
	SELECT restaurant, category, 
		AVG([calories/dollar]) AS avg_item_calories,
		DENSE_RANK() OVER (PARTITION BY restaurant ORDER BY AVG([calories/dollar]) DESC) rnk
	FROM all_menus_CA
	GROUP BY restaurant, category
)
SELECT TOP(1) category, 
	COUNT(*) AS cnt, 
	( CAST(COUNT(*) AS FLOAT) / SUM(COUNT(*)) OVER () ) * 100 AS [percentage of total]
FROM CTE
WHERE rnk = 1
GROUP BY category
ORDER BY COUNT(*) DESC;

-- 7. Should I be going for breakfast or just wait for lunch? 
SELECT restaurant, category, AVG([calories/dollar]) AS avg_item_calories
FROM all_menus_CA
WHERE category = 'breakfast' OR category = 'main'
GROUP BY restaurant, category;

-- 8. Get the average calories/dollar for an item of all fast food chains
SELECT AVG(CAST([calories/dollar] AS FLOAT))
FROM all_menus_CA;