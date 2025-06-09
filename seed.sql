-- Products
INSERT INTO products (id, name, pack) VALUES
(1, 'iPhone 16', false),
(2, 'Case for iPhone 16', false),
(3, 'Pack for iPhone 16', true),
(4, 'AirPods', false),
(5, 'Pack for Airpods', true);

-- Pack Items
INSERT INTO pack_items (product_id, pack_id, quantity) VALUES
(1, 3, 2),
(2, 3, 2),
(4, 5, 1),
(1, 5, 1);

-- Booking Products
INSERT INTO booking_products (start_date, end_date, product_id, quantity) VALUES
('2025-07-01', '2025-07-30', 3, 2),
('2025-07-05', '2025-07-10', 1, 3),
('2025-07-05', '2025-07-10', 5, 1);
