-- 5.1
-- 1
BEGIN;

-- 2
SELECT product_id, stock
FROM products
WHERE sku IN ('APL-IPD11-A16', 'SNY-XM5')
ORDER BY product_id
FOR UPDATE;

-- 3
INSERT INTO orders (customer_id)
SELECT customer_id
FROM customers
WHERE email = 'nazar.kravets@example.com'
RETURNING order_id;

-- 4
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT :order_id, p.product_id, v.qty, p.price
FROM products p
JOIN (VALUES ('APL-IPD11-A16', 2),
             ('SNY-XM5',       1)) AS v(sku, qty)
  ON v.sku = p.sku
ORDER BY p.product_id;

-- 5
UPDATE products p
SET stock = p.stock - v.qty
FROM (VALUES ('APL-IPD11-A16', 2),
             ('SNY-XM5',       1)) AS v(sku, qty)
WHERE p.sku = v.sku;

-- 6
COMMIT;

--5.2
-- 1
BEGIN;

-- 2
INSERT INTO orders (customer_id)
VALUES (1)
RETURNING order_id;

-- 3
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT :order_id, product_id, 3, price
FROM products
WHERE sku = 'APL-MBA13-M4';

-- 4
UPDATE products
SET stock = stock - 3
WHERE sku = 'APL-MBA13-M4';

-- 5
ROLLBACK;

--5.3
-- 1
BEGIN;

-- 2
WITH old_prices AS (
    SELECT sku, price
    FROM products
    WHERE sku IN ('APL-APP3', 'SMS-S25-256', 'GGL-PX10-128', 'LNV-TABP12')
),
upsert AS (
    INSERT INTO products (sku, name, brand, category, price, stock)
    VALUES
        ('APL-APP3',     'AirPods Pro 3',     'Apple',   'Навушники', 11999.00, 42),
        ('SMS-S25-256',  'Galaxy S25 256GB',  'Samsung', 'Смартфони', 35999.00, 20),
        ('GGL-PX10-128', 'Pixel 10 128GB',    'Google',  'Смартфони', 34999.00, 15),
        ('LNV-TABP12',   'Tab P12',           'Lenovo',  'Планшети',  15499.50, 10)
    ON CONFLICT (sku) DO UPDATE
    SET price = EXCLUDED.price,
        stock = EXCLUDED.stock
    RETURNING sku, price
)
SELECT u.sku,
       o.price AS old_price,
       u.price AS new_price
FROM upsert u
LEFT JOIN old_prices o USING (sku);

-- 3
SAVEPOINT before_discontinue;

-- 4
DELETE FROM products
WHERE sku = 'JBL-T520BT';

-- 5
ROLLBACK TO SAVEPOINT before_discontinue;

-- 6
UPDATE products
SET is_active = false
WHERE sku = 'JBL-T520BT';

-- 7
COMMIT;