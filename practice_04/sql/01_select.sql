SET TIME ZONE 'UTC';

-- Завдання 1.1
SELECT customer_id, first_name, last_name, phone, registered_at
FROM shop.customers
WHERE c.country_code = 'PL'
  AND registered_at >= '2025-12-01'
  AND registered_at <  '2026-01-01'
  AND email IS NULL
ORDER BY registered_at DESC, customer_id;;

-- Завдання 1.2
SELECT product_id, sku, name, weight_kg
FROM shop.products
WHERE (sku LIKE 'PHN-%' OR sku LIKE 'TAB-%')
    AND name LIKE '%Pro%' 
    AND name NOT LIKE '%Pro Max%'
ORDER BY weight_kg DESC, sku ASC;

-- Завдання 1.3
SELECT DISTINCT country_code, payment_method, installments_count
FROM shop.orders
ORDER BY country_code, payment_method, installments_count;

-- Завдання 1.4
SELECT order_id, created_at, total_amount, payment_method
FROM shop.orders
WHERE country_code = 'UA'
    AND status = 'returned_to_sender'
    AND created_at >= '2025-01-01'
    AND created_at < '2026-01-01'
ORDER BY total_amount DESC, order_id
LIMIT 25 OFFSET 50;