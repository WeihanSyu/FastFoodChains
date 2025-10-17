USE FastFood;
GO


-- Create view to show calories/dollar -> Canadian Menu only
DROP VIEW IF EXISTS menu_cals_per_buck_CA;
GO
CREATE VIEW menu_cals_per_buck_CA
AS
SELECT 
	restaurant, item_name, category, price, calories, 
	CAST(ROUND(calories/price, 0) AS INT) AS [calories/dollar]
FROM menu WHERE country = 'Canada';
GO

-- Export our menus with calories/dollar to a csv for Tableau use
SELECT * FROM menu_cals_per_buck_CA;

-- Export our locations to a csv in a format more suitable for Tableau use
SELECT 
	store_id, restaurant, country_name AS country, 
	stateProvince_code AS state_province, city, 
	[address], postcode, latitude, longitude
FROM restaurant_location r
JOIN stateProvince s
ON s.stateProvinceID = r.stateProvinceID
WHERE restaurant IN ('McDonalds', 'Wendys', 'Subway');

----------------------------------------------------------------------------------------------------------


-- 1. Out of our list, which fast food chain has the most locations in BC?
SELECT TOP(1) restaurant, COUNT(*) AS num_locations 
FROM restaurant_location r
JOIN stateProvince s ON s.stateProvinceID = r.stateProvinceID
WHERE s.country_code = 'CA' AND s.stateProvince_code = 'BC'
GROUP BY restaurant
ORDER BY COUNT(*) DESC;

/* 2. Which restaurant leads the pack according to Calories/Dollar for categories "main" and "sides"
and by what percentage is it ahead of the runner-up? */

SELECT restaurant, category, 
	AVG([calories/dollar]) AS avg_item_calories,
	DENSE_RANK() OVER (PARTITION BY category ORDER BY AVG([calories/dollar]) DESC) AS rnk
FROM menu_cals_per_buck_CA
WHERE category = 'main' OR category = 'sides'
GROUP BY restaurant, category;

-- Percentage ahead
WITH CTE AS (
	SELECT restaurant, category, 
		AVG([calories/dollar]) AS avg_item_calories,
		DENSE_RANK() OVER (PARTITION BY category ORDER BY AVG([calories/dollar]) DESC) AS rnk
	FROM menu_cals_per_buck_CA
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
	AVG([calories/dollar]) AS [avg_item_cals/dollar]
FROM menu_cals_per_buck_CA
WHERE category = 'main'
GROUP BY restaurant, category
ORDER BY [avg_item_cals/dollar] ASC;

-- 4. Are combos and meals actually worth it?
SELECT item_name, [calories/dollar] 
FROM menu_cals_per_buck_CA
WHERE restaurant = 'McDonalds' 
AND category IN ('combo meals', 'main', 'breakfast')
ORDER BY item_name;

/* NO! In fact, some individual items are most cost effective than getting the combo. 
This means that, either the drinks that come with the meal are horrible calories/dollar wise, or
the sides, or both. */

-- 5. What is the most cost effective menu to be ordering from?
WITH CTE AS (
	SELECT restaurant, category, 
		AVG([calories/dollar]) AS avg_item_calories,
		DENSE_RANK() OVER (PARTITION BY restaurant ORDER BY AVG([calories/dollar]) DESC) rnk
	FROM menu_cals_per_buck_CA
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
	FROM menu_cals_per_buck_CA
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
FROM menu_cals_per_buck_CA
WHERE category = 'breakfast' OR category = 'main'
GROUP BY restaurant, category;

-- 8. Get the average calories/dollar for an item of all fast food chains
SELECT AVG(CAST([calories/dollar] AS FLOAT))
FROM menu_cals_per_buck_CA;



-- Optimization -------------------------------------------------------------------------------------------------
