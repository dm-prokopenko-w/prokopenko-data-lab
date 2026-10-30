SET TIME ZONE 'UTC';

-- Завдання 3.1
SELECT 
    country_code, 
    COUNT(order_id) AS orders_cnt, 
    COUNT(DISTINCT customer_id) AS customers_cnt, 
    SUM(total_amount) AS total_sum, 
    ROUND(AVG(total_amount), 2) AS avg_check, 
    MIN(total_amount) AS min_check, 
    MAX(total_amount) AS max_check
FROM shop.orders
WHERE status = 'received'
    AND created_at >= '2025-01-01'
    AND created_at < '2026-01-01'
GROUP BY country_code
ORDER BY country_code;

-- Завдання 3.2
SELECT 
    DATE_TRUNC('month', created_at)::date AS order_month, 
    COUNT(order_id) AS orders_cnt, 
    COUNT(DISTINCT customer_id) AS customers_cnt, 
    SUM(total_amount) AS total_sum, 
    ROUND(AVG(total_amount),2) AS avg_check
FROM shop.orders
WHERE status = 'received'
    AND country_code = 'UA'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY order_month DESC;

-- Завдання 3.3
SELECT
    country_code,
    EXTRACT(HOUR FROM created_at AT TIME ZONE 'UTC')::int AS order_hour,
    COUNT(order_id) AS orders_cnt,
    ROUND(AVG(total_amount), 2) AS avg_check
FROM shop.orders
WHERE status <> 'cancelled'
    AND created_at >= '2025-01-01'
    AND created_at <  '2026-01-01'
GROUP BY country_code, order_hour
ORDER BY country_code, order_hour;

-- Завдання 3.4
SELECT 
    customer_id, 
    COUNT(order_id) AS orders_cnt, 
    SUM(total_amount) AS total_sum, 
    MIN(created_at::date) AS first_order_date, 
    MAX(created_at::date) AS last_order_date
FROM shop.orders o
WHERE status = 'received'
    AND country_code = 'UA'
GROUP BY customer_id
HAVING COUNT(order_id) >= 15 
    AND SUM(total_amount) >= 500000
ORDER BY total_sum DESC, customer_id
LIMIT 20;