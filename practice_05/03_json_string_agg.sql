SET TIME ZONE 'UTC';

-- Завдання 3.1

SELECT
    p.product_id,
    p.name,
    COALESCE(p.attributes ->> 'chip', p.attributes ->> 'cpu')  AS processor,
    (p.attributes ->> 'ram_gb')::int AS ram_gb,
    (p.attributes ->> 'storage_gb')::int AS storage_gb,
    (p.attributes ->> 'screen_in')::numeric  AS screen_in
FROM shop.products p
WHERE p.category_id = 8
ORDER BY ram_gb DESC, storage_gb DESC, product_id;

-- Завдання 3.2

SELECT
    p.product_id,
    p.name,
    p.attributes ->> 'chip' AS chip,
    (p.attributes ->> 'screen_in')::numeric  AS screen_in,
    (p.attributes ->> 'storage_gb')::int  AS storage_gb
FROM shop.products p
WHERE (p.attributes  ->> 'screen_in')::numeric >= 11
    AND (p.attributes  ->> 'storage_gb')::int >= 256
    AND p.category_id = 9
ORDER BY screen_in DESC, storage_gb DESC, product_id;

-- Завдання 3.3

SELECT
    p.product_id,
    p.name,
    p.attributes ->> 'color'  AS color
FROM shop.products p
WHERE p.category_id  = 4
    AND (((p.attributes ->> 'lte') :: boolean IS TRUE) OR (((p.attributes ->> 'cellular')::boolean) IS TRUE))
ORDER BY p.product_id;

-- Завдання 3.4

SELECT
    p.product_id,
    jsonb_build_object(
        'sku', p.sku,
        'name', p.name,
        'brand', b.name,
        'storage_gb',(p.attributes ->> 'storage_gb')::numeric,
        'read_mbps',(p.attributes ->> 'read_mbps')::numeric,
        'interface',(p.attributes ->> 'interface')
    ) AS card
FROM shop.products p
LEFT JOIN shop.brands b ON b.brand_id = p.brand_id
WHERE p.category_id = 22
ORDER By p.product_id;

-- Завдання 3.5

SELECT
    o.order_id,
    COUNT(oi.order_id) AS items_cnt,
    STRING_AGG(p.name, '; ' ORDER BY p.sku) AS products
FROM shop.orders o
LEFT JOIN shop.order_items oi ON oi.order_id = o.order_id
LEFT JOIN shop.products p ON p.product_id = oi.product_id
WHERE o.created_at::date = '2025-12-24'
    AND o.country_code = 'PL'
GROUP BY o.order_id
ORDER BY o.order_id;

-- Завдання 3.6

SELECT
    b.brand_id,
    b.name AS brand_name,
    COUNT(p.product_id) AS products_cnt,
    STRING_AGG(DISTINCT c.name, ', ' ORDER BY c.name ASC) AS categories
FROM shop.brands b
JOIN shop.products p ON p.brand_id = b.brand_id
JOIN shop.categories c ON c.category_id = p.category_id
GROUP BY b.brand_id, b.name
ORDER BY b.brand_id;
