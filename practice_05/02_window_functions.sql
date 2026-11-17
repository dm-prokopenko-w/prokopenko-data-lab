SET TIME ZONE 'UTC';

-- Завдання 2.1

SELECT 
    o.order_id, 
    o.created_at::date AS order_date, 
    o.total_amount, 
    SUM(o.total_amount) OVER (PARTITION BY o.created_at::date) AS day_amount, 
    ROUND(100 * o.total_amount / SUM(o.total_amount) OVER (PARTITION BY o.created_at::date), 2) AS share_pct
FROM shop.orders o
WHERE o.country_code = 'PL'
    AND o.created_at >= '2025-12-01' 
    AND o.created_at < '2025-12-04'
    AND status <> 'cancelled'
ORDER BY order_date, share_pct DESC, o.order_id;
    
-- Завдання 2.2

SELECT 
    o.country_code, 
    o.created_at::date AS order_date, 
    SUM(o.total_amount) AS amount, 
    SUM(SUM(o.total_amount)) OVER (
        PARTITION BY o.country_code 
        ORDER BY o.created_at::date
    ) AS running_amount
FROM shop.orders o
WHERE o.created_at >= '2025-12-01' 
    AND o.created_at < '2026-01-01'
    AND o.status <> 'cancelled'
GROUP BY o.country_code, o.created_at::date
ORDER BY o.country_code, order_date;

-- Завдання 2.3

SELECT
    o.created_at :: date AS order_date,
    SUM(o.total_amount) AS amount,
    ROUND(AVG(SUM(o.total_amount)) OVER (ORDER BY o.created_at :: date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS avg_7d
FROM shop.orders o
WHERE o.country_code = 'PL'
    AND o.created_at >= '2025-12-01'
    AND o.created_at < '2026-01-01'
    AND status <> 'cancelled'
GROUP BY o.created_at::date
ORDER BY order_date;

-- Завдання 2.4

SELECT
    pp.product_id,
    pp.valid_from,
    pp.price,
    FIRST_VALUE(price) OVER (PARTITION BY product_id ORDER BY valid_from) AS first_price,
    LAST_VALUE(price) OVER (PARTITION BY product_id ORDER BY valid_from ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_price
FROM shop.product_prices pp
JOIN shop.products p ON p.product_id = pp.product_id
WHERE p.category_id = 9
    AND pp.country_code = 'PL'
    AND pp.price IS NOT NULL
    AND pp.valid_from >= '2025-01-01'
    AND pp.valid_from < '2026-01-01'
ORDER BY pp.product_id, pp.valid_from;



