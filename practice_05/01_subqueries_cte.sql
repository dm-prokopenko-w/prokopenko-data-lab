SET TIME ZONE 'UTC';

-- Завдання 1.1
SELECT
    o.order_id,
    o.created_at,
    o.total_amount,
    (SELECT ROUND(AVG(o3.total_amount), 2)
     FROM shop.orders o3
     WHERE o3.country_code = o.country_code) AS avg_amount
FROM shop.orders o
WHERE o.country_code = 'PL'
  AND o.created_at >= '2025-12-01'
  AND o.created_at <  '2026-01-01'
  AND o.total_amount > (SELECT AVG(o2.total_amount) * 5
                        FROM shop.orders o2
                        WHERE o2.country_code = 'PL')
ORDER BY o.total_amount, o.order_id;


-- Завдання 1.2

SELECT 
	per_customer.country_code AS country_code,
	COUNT(*) AS customers_cnt,
	COUNT(*) FILTER (WHERE orders_cnt >=2) repeat_customers_cnt,
	ROUND(AVG(per_customer.orders_cnt),2) AS avg_orders
FROM (SELECT customer_id, country_code, COUNT(*) AS orders_cnt
	FROM shop.orders
	WHERE created_at >= '2025-01-01' 
		AND created_at < '2026-01-01'
	GROUP BY customer_id, country_code) AS per_customer
GROUP BY country_code
ORDER BY country_code;

-- Завдання 1.3

WITH returned_customers AS (
	SELECT o.customer_id
	FROM shop.orders o 
	WHERE o.country_code = 'UA'
		AND o.status = 'returned_to_sender'
		AND o.created_at >= '2025-11-01'
		AND o.created_at < '2025-12-01'
	GROUP By o.customer_id
)
SELECT 
	c.customer_id, 
	c.first_name, 
	c.last_name, 
	c.phone
FROM shop.customers AS c
JOIN returned_customers r ON r.customer_id = c.customer_id
ORDER BY c.customer_id;

-- Завдання 1.4

WITH category_weight AS(
	SELECT 
		AVG(weight_kg) AS avg_weight,
		category_id
	FROM shop.products
	WHERE category_id IN (8, 9)	
	GROUP BY  category_id
)
SELECT
	p.product_id, 
	p.sku, 
	p.name, 
	p.category_id, 
	p.weight_kg, 
	ROUND(cw.avg_weight, 3) as category_avg_weight
FROM shop.products p
JOIN category_weight cw ON cw.category_id = p.category_id
WHERE p.category_id IN (8, 9)
	AND p.weight_kg > cw.avg_weight
ORDER BY p.category_id ASC, p.weight_kg DESC, p.product_id;

-- Завдання 1.5

SELECT 
	pp.point_id, 
	pp.point_type, 
	pp.number, 
	pp.address
FROM shop.pickup_points pp
JOIN shop.cities c ON pp.city_id = c.city_id
WHERE c.name = 'Ужгород'
	AND NOT EXISTS(
		SELECT 1
		FROM shop.orders o
		WHERE o.pickup_point_id = pp.point_id
			AND o.created_at >= '2025-12-01'
			AND o.created_at < '2026-01-01'
	)
ORDER BY pp.point_id;

-- Завдання 1.6

WITH daily AS (
    SELECT
        o.created_at::date AS order_date,
        COUNT(*)           AS orders_cnt,
        SUM(o.total_amount) AS amount
    FROM shop.orders o
    WHERE o.created_at >= '2025-12-01'
      AND o.created_at <  '2026-01-01'
      AND o.country_code = 'PL'
      AND o.payment_method <> 'cancelled'
    GROUP BY o.created_at::date
),
with_avg AS (
    SELECT
        order_date,
        orders_cnt,
        amount,
        ROUND(AVG(amount) OVER (), 2) AS avg_daily_amount
    FROM daily
)
SELECT order_date, orders_cnt, amount, avg_daily_amount
FROM with_avg
WHERE amount > avg_daily_amount
ORDER BY order_date;

-- Завдання 1.7

WITH RECURSIVE tree AS (
	SELECT 
		c1.category_id, 
		c1.category_id AS section_id
	FROM shop.categories c1
	WHERE c1.parent_id IS NULL

	UNION ALL

	SELECT 
		c2.category_id, 
		t.section_id
	FROM shop.categories c2
	JOIN tree t ON c2.parent_id = t.category_id
) 
SELECT 
	t.section_id, 
	c3.name AS section_name, 
	COUNT(p.category_id) AS products_cnt
FROM shop.categories c3
JOIN tree t ON t.section_id = c3.category_id
LEFT JOIN shop.products p ON p.category_id = t.category_id
GROUP BY t.section_id, 	c3.name
ORDER BY products_cnt DESC, section_id;