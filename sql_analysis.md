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

