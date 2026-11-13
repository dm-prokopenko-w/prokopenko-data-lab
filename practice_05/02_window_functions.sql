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