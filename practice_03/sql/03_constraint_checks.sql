INSERT INTO customers (email, full_name, city, phone, country)
VALUES('nazar.kravets@example.com', 'Назар Кравець', 'Тернопіль', '+380671234567', 'UA');
/*
 SQL Error [23505]: ERROR: duplicate key value violates unique constraint "customers_pkey"
  Detail: Key (customer_id)=(4) already exists.

Error position:
 */


INSERT INTO products (sku, name, brand, category, price, stock, is_active)
VALUES ('AAA-IPD11-128-WIFI', 'new name', 'new brand', 'new category', 0, 0, true);
/*
SQL Error [23514]: ERROR: new row for relation "products" violates check constraint "products_price_check"
  Detail: Failing row contains (1, AAA-IPD11-128-WIFI, new name, new brand, new category, 0.00, 0, t, null).
*/

INSERT INTO orders(order_id, customer_id, status)
VALUES (1, 10000, 'new');
/*
SQL Error [428C9]: ERROR: cannot insert a non-DEFAULT value into column "order_id"
  Detail: Column "order_id" is an identity column defined as GENERATED ALWAYS.
  Hint: Use OVERRIDING SYSTEM VALUE to override.
*/

INSERT INTO orders (order_id, customer_id, status)
VALUES (1, 10, 'new');
/*
SQL Error [428C9]: ERROR: cannot insert a non-DEFAULT value into column "order_id"
  Detail: Column "order_id" is an identity column defined as GENERATED ALWAYS.
  Hint: Use OVERRIDING SYSTEM VALUE to override.

Error position:
*/

UPDATE orders
SET status = 'returned'
WHERE order_id = 1;
/*
SQL Error [23514]: ERROR: new row for relation "orders" violates check constraint "orders_status_check"
  Detail: Failing row contains (1, 10, returned, 2025-04-13 00:59:39+03).
*/

DELETE FROM customers WHERE customer_id = 1;
/*
SQL Error [23503]: ERROR: update or delete on table "customers" violates foreign key constraint "orders_customer_id_fkey" on table "orders"
  Detail: Key (customer_id)=(1) is still referenced from table "orders".

Error position:
*/ 
