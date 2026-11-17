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

-- Завдання 2.5

SELECT 
    p.product_id, 
    p.name, 
    p.weight_kg, 
    RANK() OVER (ORDER BY p.weight_kg ASC) AS weight_rank, 
    DENSE_RANK() OVER (ORDER BY p.weight_kg ASC) AS weight_dense_rank
FROM shop.products p
WHERE p.category_id = 8
ORDER BY p.weight_kg, p.product_id;

-- Завдання 2.6

WITH prev AS(
    SELECT 
        o.country_code, 
        DATE_TRUNC('month', o.created_at) :: date AS month,
        SUM(o.total_amount) as amount
    FROM shop.orders o
    WHERE o.created_at >= '2025-01-01'
        AND o.created_at < '2026-01-01'
        AND o.status <> 'cancelled'
    GROUP BY o.country_code, DATE_TRUNC('month', o.created_at) :: date
)
SELECT 
    p.country_code AS country_code, 
    p.month AS month, 
    p.amount AS amount, 
    LAG(p.amount) OVER (PARTITION BY p.country_code ORDER BY p.month) AS prev_amount, 
    ROUND(((p.amount - LAG(p.amount) OVER (PARTITION BY p.country_code ORDER BY p.month))) / LAG(p.amount) OVER (PARTITION BY p.country_code ORDER BY p.month) * 100, 1) AS change_pct
FROM prev p 
ORDER BY p.country_code, p.month;


-- Завдання 2.7

WITH ranked AS(
    SELECT 
        p.category_id AS category_id, 
        c.category_name AS category_name, 
        ROW_NUMBER() OVER (PARTITION BY p.category_id ORDER BY SUM(oi.quantity)  DESC, p.product_id) AS place, 
        p.product_id AS product_id, 
        p.product_name AS product_name,  
        SUM(oi.quantity) AS units_sold
    FROM shop.order_items oi
    JOIN shop.orders o ON o.order_id = oi.order_id
    JOIN shop.products p ON p.product_id = oi.product_id
    JOIN shop.categories c ON c.category_id = p.category_id
    WHERE o.country_code = 'UA'
        AND o.created_at >= '2025-12-01'
        AND o.created_at < '2026-01-01'
        AND o.status <> 'cancelled'
    GROUP BY p.category_id, c.category_name, p.product_id, p.product_name)
SELECT 
    r.category_id,
    r.category_name,
    r.place,
    r.product_id,
    r.product_name,
    r.units_sold
FROM ranked r
WHERE r.place <= 3
ORDER BY r.category_id, r.place;
