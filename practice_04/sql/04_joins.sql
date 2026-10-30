SET TIME ZONE 'UTC';

-- Завдання 4.1
SELECT 
    c.name AS country, 
    b.name AS brand, 
    COUNT(DISTINCT  o.order_id) AS orders_cnt, 
    SUM(oi.quantity) AS units_sold, 
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM shop.order_items oi
JOIN shop.orders o ON o.order_id = oi.order_id
JOIN shop.countries c ON o.country_code = c.country_code
JOIN shop.products p ON oi.product_id = p.product_id
JOIN shop.brands b ON b.brand_id = p.brand_id
WHERE o.status = 'received'
    AND o.created_at >= '2025-10-01'
    AND o.created_at < '2026-01-01'
GROUP BY c.name, b.name
ORDER BY c.name, revenue DESC, b.name;

-- Завдання 4.2
SELECT 
    p.product_id, 
    p.sku, 
    p.name, 
    b.name AS brand, 
    c.name AS category
FROM shop.products p
JOIN shop.brands b ON p.brand_id = b.brand_id
JOIN shop.categories c ON c.category_id = p.category_id
LEFT JOIN shop.order_items oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL
ORDER BY p.product_id;

-- Завдання 4.3
SELECT 
    c.category_id, 
    c.name AS category, 
    cp.name AS parent, 
    COUNT(p.product_id) AS products_cnt
FROM shop.categories c
LEFT JOIN shop.categories cp ON c.parent_id = cp.category_id
LEFT JOIN shop.products p ON p.category_id = c.category_id
GROUP BY c.category_id, c.name, cp.name
ORDER BY c.category_id;


-- Завдання 4.4
SELECT 
    c.name AS country, 
    car.name AS carrier, 
    COUNT(o.order_id) AS orders_cnt
FROM shop.countries  c
CROSS JOIN shop.carriers car 
LEFT JOIN shop.orders o 
    ON car.carrier_id = o.carrier_id
    AND o.country_code = c.country_code 
    AND o.created_at >= '2025-12-01'
    AND o.created_at < '2026-01-01'
GROUP BY c.name, car.name
ORDER BY c.name, car.name;