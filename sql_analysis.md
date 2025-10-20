# Fast Food Chains - Locations & Menus
## Questions and Answers

**Create a view to include a "calories per dollar" column for our Canadian menu**

```sql
CREATE VIEW menu_cals_per_buck_CA
AS
SELECT
  restaurant, item_name, category, price, calories, 
	CAST(ROUND(calories/price, 0) AS INT) AS [calories/dollar]
FROM menu WHERE country = 'Canada';
```

**1.** Which fast food chain has the most locations in BC, Canada?

```sql
SELECT TOP(1) restaurant, COUNT(*) AS num_locations 
FROM restaurant_location r
JOIN stateProvince s ON s.stateProvinceID = r.stateProvinceID
WHERE s.country_code = 'CA' AND s.stateProvince_code = 'BC'
GROUP BY restaurant
ORDER BY COUNT(*) DESC;
```

**Results:**

restaurant|num_locations|
----------|-------------|
Subway    |          421|

**2.** What are the top 5 cities by total number of restaurant locations present? Include their respective state, province or territory, and the amount of locations.

```sql
SELECT TOP(5) city, stateProvince_name AS state_province, COUNT(*) AS total_locations
FROM restaurant_location r
JOIN stateProvince s ON s.stateProvinceID = r.stateProvinceID
GROUP BY city, stateProvince_name
ORDER BY COUNT(*) DESC;
```

**Results:**

city|state_province|total_locations|
----|--------------|---------------|
Toronto|Ontario|437|
Houston|Texas|422|
Chicago|Illinois|365|
Calgary|Alberta|349|
Edmonton|Alberta|293|

**3.** For the top 5 cities from the above result, find their most popular (by amount of stores) restaurant
and its location count.

```sql
WITH CTE_1 AS (	
	SELECT city, s.stateProvinceID, COUNT(*) AS total_locations,
		RANK() OVER (ORDER BY COUNT(*) DESC) rnk
	FROM restaurant_location r
	JOIN stateProvince s ON s.stateProvinceID = r.stateProvinceID
	GROUP BY city, s.stateProvinceID 
),
CTE_2 AS (
	SELECT city, restaurant, COUNT(*) AS top_locations,
		RANK() OVER (PARTITION BY city ORDER BY COUNT(*) DESC, restaurant) rnk
	FROM restaurant_location 
	GROUP BY city, restaurant

)
SELECT c1.city, stateProvince_name AS state_province, total_locations, restaurant AS top_restaurant, top_locations
FROM CTE_1 c1 JOIN CTE_2 c2
ON c1.city = c2.city
JOIN stateProvince s
ON s.stateProvinceID = c1.stateProvinceID
WHERE c1.rnk <= 5 AND c2.rnk = 1
ORDER BY total_locations DESC;
```

**Results:**

city|state_province|total_locations|top_restaurant|top_locations|
----|--------------|---------------|--------------|-------------|
Toronto|Ontario|437|Subway|185|
Houston|Texas|422|Subway|219|
Chicago|Illinois|365|Subway|215|
Calgary|Alberta|349|Subway|126|
Edmonton|Alberta|293|Tim Hortons|107|

**4.** Which restaurant has the best calories/dollar ratio for categories "main" and "sides"?

```sql
WITH CTE AS (
	SELECT restaurant, category, 
		AVG([calories/dollar]) AS avg_calories_dollar,
		DENSE_RANK() OVER (PARTITION BY category ORDER BY AVG([calories/dollar]) DESC) AS rnk
	FROM menu_cals_per_buck_CA
	WHERE category = 'main' OR category = 'sides'
	GROUP BY restaurant, category
)
SELECT restaurant, category, avg_calories_dollar
FROM CTE WHERE rnk = 1;
```

**Results:**

restaurant|category|avg_calories_dollar
----------|--------|------------------|
Wendys    |    main|                93|
Wendys    |   sides|               115|

**5.** Building upon question 2, by what percentage is the restaurant ahead of the runner-up in calories/dollar?

```sql
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
```

**Results:** Wendys by a landslide.

restaurant|category|percent_diff_from_runner_up
----------|--------|--------------------------|
Wendys    |    main|                     25.68|
Wendys    |   sides|                     26.37|

**6.** Which restaurant has the worst bang for buck from the main line item selection?

```sql
SELECT TOP(1) restaurant,
	AVG([calories/dollar]) AS [avg_item_cals/dollar]
FROM menu_cals_per_buck_CA
WHERE category = 'main'
GROUP BY restaurant, category
ORDER BY [avg_item_cals/dollar] ASC;
```

**Results:**

restaurant|avg_item_cals/dollar|
----------|--------------------|
Subway    |                  60|

**7.** What is the most cost effective menu to be ordering from?

``` sql
WITH CTE AS (
	SELECT restaurant, category, 
		AVG([calories/dollar]) AS avg_item_calories,
		DENSE_RANK() OVER (PARTITION BY restaurant ORDER BY AVG([calories/dollar]) DESC) rnk
	FROM menu_cals_per_buck_CA
	GROUP BY restaurant, category
)
SELECT * FROM CTE
WHERE rnk = 1;
```

**Results:**

restaurant|category|avg_item_calories|rnk|
----------|--------|-----------------|---|
McDonalds|baked goods|149|1|
Subway|baked goods|240|1|
Wendys|baked goods|125|1|

**8.** Should I be going for breakfast, or just wait for lunch?

```sql
SELECT restaurant, category, AVG([calories/dollar]) AS avg_item_calories
FROM menu_cals_per_buck_CA
WHERE category = 'breakfast' OR category = 'main'
GROUP BY restaurant, category;
```

**Results:** If you enjoy the breakfast menu, then definitely go for it!

restaurant|category|avg_item_calories|
----------|--------|-----------------|
McDonalds|breakfast|103|
Subway|breakfast|110|
Wendys|breakfast|105|
McDonalds|main|74
Subway|main|60|
Wendys|main|93|

**9.** Are combos and meals actually worth it?

```sql
SELECT item_name, [calories/dollar] 
FROM menu_cals_per_buck_CA
WHERE restaurant = 'McDonalds' 
AND category IN ('combo meals', 'main', 'breakfast')
ORDER BY item_name;
```

**Results (snippet only):** If you order meals because you want a discount and don't actually care much for drinks and sides, don't bother. There often is no significant difference if we compare it by calories/dollar against the "main" food item offered in the meal/combo.

item_name|calories/dollar|
---------|---------------|
Bacon Deluxe McCrispy| 69|
Bacon Deluxe McCrispy Extra Value Meal|75|
Bacon 'N Egg McMuffin|65|
Bacon 'N Egg McMuffin Extra Value Meal|73|
Big Mac|84|
Big Mac Extra Value Meal| 81|
Double Big Mac|95|
Double Big Mac Extra Value Meal|93|
Filet-O-Fish | 67|
Filet-O-Fish Extra Value Meal | 72|
Junior Chicken |104|
Junior Chicken McValue Meal |104|
McChicken |78|
McChicken Extra Value Meal |79|
Quarter Pounder BLT |68|
Quarter Pounder BLT Extra Value Meal |67|



