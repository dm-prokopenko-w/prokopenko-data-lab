COPY customers (customer_id, email, full_name, phone, country, city, registered_at)
FROM '/data/customers.csv' WITH (FORMAT csv, HEADER true);

COPY products (product_id, sku, name, brand, category, price, stock, is_active, attributes)
FROM '/data/products.csv' WITH (FORMAT csv, HEADER true);

COPY orders (order_id, customer_id, status, created_at)
FROM '/data/orders.csv' WITH (FORMAT csv, HEADER true);

COPY order_items (order_id, product_id, quantity, unit_price)
FROM '/data/order_items.csv' WITH (FORMAT csv, HEADER true);

/*
ALTER TABLE customers ALTER COLUMN customer_id RESTART WITH (SELECT MAX(customer_id) + 1 FROM customers);
ALTER TABLE products ALTER COLUMN product_id RESTART WITH (SELECT MAX(product_id) + 1 FROM products);
ALTER TABLE orders ALTER COLUMN order_id RESTART WITH (SELECT MAX(order_id) + 1 FROM orders);
*/

SELECT setval(pg_get_serial_sequence('customers', 'customer_id'), (SELECT max(customer_id) FROM customers));
SELECT setval(pg_get_serial_sequence('products',  'product_id'),  (SELECT max(product_id)  FROM products));
SELECT setval(pg_get_serial_sequence('orders',    'order_id'),    (SELECT max(order_id)    FROM orders));

INSERT INTO customers (email, full_name, city, phone, country)
VALUES('nazar.kravets@example.com', 'Назар Кравець', 'Тернопіль', '+380671234567', 'UA')
RETURNING customer_id, registered_at;