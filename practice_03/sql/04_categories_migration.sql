-- #1
BEGIN;

-- #2
CREATE TABLE categories (
    category_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

-- #3
CREATE TEMP TABLE products_raw (
    product_id bigint, sku text, name text, brand text, category text,
    price numeric, stock integer, is_active boolean, attributes jsonb
);

COPY products_raw
FROM '/data/products.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO categories (name)
SELECT DISTINCT category 
FROM products_raw
LIMIT 5;

-- #4
ALTER TABLE products ADD COLUMN category_id bigint REFERENCES categories(category_id) DEFAULT 1; 
-- Додав DEFAULT 1, щоб якщо категорій більше 5 то решта продуктів потрапляли в категорію з id = 1.

-- #5
UPDATE products p
SET category_id = c.category_id
FROM categories c
WHERE p.category = c.name;

--#6
ALTER TABLE products ALTER COLUMN category_id SET NOT NULL;

-- #7
ALTER TABLE products DROP COLUMN category;

-- #8
COMMIT;