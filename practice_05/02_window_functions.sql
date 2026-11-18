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

WITH days AS (
    SELECT g.d::date AS order_date
    FROM generate_series('2025-12-01'::date, '2025-12-31'::date, INTERVAL '1 day') AS g(d)
),
daily AS (
    SELECT
        o.created_at::date AS order_date,
        SUM(o.total_amount) AS amount
    FROM shop.orders o
    WHERE o.country_code = 'PL'
        AND o.created_at >= '2025-12-01'
        AND o.created_at < '2026-01-01'
        AND o.status <> 'cancelled'
    GROUP BY o.created_at::date
)
SELECT
    d.order_date,
    COALESCE(dl.amount, 0) AS amount,
    ROUND(AVG(COALESCE(dl.amount, 0)) OVER (
        ORDER BY d.order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS avg_7d
FROM days d
LEFT JOIN daily dl ON dl.order_date = d.order_date
ORDER BY d.order_date;

-- Завдання 2.4

SELECT
    pp.product_id,
    pp.valid_from,
    pp.price,
    FIRST_VALUE(pp.price) OVER (PARTITION BY pp.product_id ORDER BY pp.valid_from) AS first_price,
    LAST_VALUE(pp.price) OVER (PARTITION BY pp.product_id ORDER BY pp.valid_from ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_price
FROM shop.product_prices pp
JOIN shop.products p ON p.product_id = pp.product_id
WHERE p.category_id = 9
    AND pp.country_code = 'PL'
    AND pp.price IS NOT NULL
    AND pp.valid_from >= '2025-01-01'
    AND pp.valid_from < '2026-01-01'
ORDER BY pp.product_id, pp.valid_from;

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
    ROUND((((p.amount - LAG(p.amount) OVER (PARTITION BY p.country_code ORDER BY p.month))) / LAG(p.amount) OVER (PARTITION BY p.country_code ORDER BY p.month)) * 100, 1) AS change_pct
FROM prev p 
ORDER BY p.country_code, p.month;

-- Завдання 2.7

WITH ranked AS(
    SELECT 
        p.category_id AS category_id, 
        c.name AS category_name,
        ROW_NUMBER() OVER (PARTITION BY p.category_id ORDER BY SUM(oi.quantity)  DESC, p.product_id) AS place, 
        p.product_id AS product_id, 
        p.name AS product_name,
        SUM(oi.quantity) AS units_sold
    FROM shop.order_items oi
    JOIN shop.orders o ON o.order_id = oi.order_id
    JOIN shop.products p ON p.product_id = oi.product_id
    JOIN shop.categories c ON c.category_id = p.category_id
    WHERE o.country_code = 'UA'
        AND o.created_at >= '2025-12-01'
        AND o.created_at < '2026-01-01'
        AND o.status <> 'cancelled'
    GROUP BY p.category_id, c.name, p.product_id, p.name)
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

-- Завдання 2.8

WITH res_payments AS (
    SELECT
        p.payment_id as payment_id,
        p.order_id AS order_id,
        p.amount AS amount,
        p.installment_no AS installment_no,
        p.created_at AS created_at,
        ROW_NUMBER() OVER(PARTITION BY p.order_id ORDER BY p.created_at DESC, p.payment_id DESC) AS rn
    FROM shop.payments p
    WHERE p.payment_type = 'payment'
        AND p.status = 'succeeded'
)
SELECT
    o.order_id,
    p.payment_id,
    p.installment_no,
    p.amount,
    p.created_at
FROM shop.orders o
JOIN res_payments p ON p.order_id = o.order_id
WHERE o.country_code = 'PL'
    AND o.payment_method = 'installments'
    AND o.created_at >= '2025-10-01'
    AND o.created_at < '2025-11-01'
    AND p.rn = 1
ORDER BY o.order_id;