BEGIN;

-- categories
INSERT INTO categories (name) VALUES
  ('Бытовая техника'),           -- id=1
  ('Компьютеры');                -- id=2

INSERT INTO categories (name, parent_id) VALUES
  ('Холодильники', 1),           -- id=3
  ('Ноутбуки', 2),               -- id=4
  ('Телевизоры', 1);             -- id=5

-- products
INSERT INTO products (name, quantity, price, category_id) VALUES
  ('Холодильник A',  5, 55999.00, 3),
  ('Холодильник B',  2, 73999.00, 3),
  ('Ноутбук X',      7, 79999.00, 4),
  ('Телевизор Q',    4, 29999.99, 5);

-- clients
INSERT INTO clients (name, address) VALUES
  ('ООО Ромашка', 'ул. Цветочная, 1'),
  ('ИП Иванов',   'пр-т Полевой, 12');

-- orders
INSERT INTO orders (client_id) VALUES (1), (2);

-- order_items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
  (1, 1, 1, 55999.00),
  (1, 3, 2, 74999.00),
  (2, 4, 1, 29999.99);

COMMIT;
