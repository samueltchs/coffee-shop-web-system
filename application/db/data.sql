-- ======================================================================
-- DATABASE SEED DATA
-- ======================================================================

INSERT INTO suspension_reasons VALUES (1, 'Inactivity');
INSERT INTO suspension_reasons VALUES (2, 'Disciplinary');

INSERT INTO deletion_reasons VALUES (1, 'Inactivity');
INSERT INTO deletion_reasons VALUES (2, 'Disciplinary');

-- ===== Customers =====
-- password : validPassword1!
INSERT INTO customers VALUES(10000000,'Amelia','Hart','$2a$12$JLjbYKp0LRzfw99E6PbsQeTGP/WA3G6MGeljLraooCzCmOOLgRVna','Flat 7, Cedar Court','42 Willow Lane','Sheffield','S11 8QJ','07700900101','amelia.hart@example.com',0,'2026-04-23 15:37:56 +0100','Active',NULL,NULL,NULL,NULL,NULL);

-- password for all : Placeholder1!
INSERT INTO customers VALUES(10000001,'Oliver','Bennett','$2a$12$sXEcZR.JMam7T9uFehG9zOymKFH4Z0cI4EsLylLppdVWieU6OJnPK','18 Hawthorn Drive','Ecclesall','Sheffield','S11 9FP','07700900102','oliver.bennett@example.com',0,'2026-03-27 14:52:11 +0200','Active',NULL,NULL,NULL,NULL,NULL);
INSERT INTO customers VALUES(10000002,'Priya','Shah','$2a$12$sXEcZR.JMam7T9uFehG9zOymKFH4Z0cI4EsLylLppdVWieU6OJnPK','93 Brookfield Road','Nether Edge','Sheffield','S7 1FH','07700900103','priya.shah@example.com',1,'2026-02-15 09:08:43 +0200','Active',NULL,NULL,NULL,NULL,NULL);
INSERT INTO customers VALUES(10000003,'Ethan','Clarke','$2a$12$sXEcZR.JMam7T9uFehG9zOymKFH4Z0cI4EsLylLppdVWieU6OJnPK','Apartment 12, Porter House','6 Sharrow Vale Road','Sheffield','S11 8ZP','07700900104','ethan.clarke@example.com',3,'2026-04-02 21:37:56 +0100','Active',NULL,NULL,NULL,NULL,NULL);
INSERT INTO customers VALUES(10000004,'Sofia','Morgan','$2a$12$sXEcZR.JMam7T9uFehG9zOymKFH4Z0cI4EsLylLppdVWieU6OJnPK','27 Meadow Bank','Crookes','Sheffield','S10 1UJ','07700900105','sofia.morgan@example.com',3,'2026-04-23 15:37:56 +0100','Active',NULL,NULL,NULL,NULL,NULL);

-- ===== Inactivity demo customers =====
-- 10000005: Active, 4 months inactive (no warning yet)
INSERT INTO customers VALUES(10000005,'Alice','Active','$2a$12$sXEcZR.JMam7T9uFehG9zOymKFH4Z0cI4EsLylLppdVWieU6OJnPK','5 Rowan Close','Walkley','Sheffield','S6 3TN','7700001001','alice.active@demo.com',0,'2026-01-18 10:00:00 +0000','Active',NULL,NULL,NULL,NULL,NULL);

-- 10000006: Active, 5 months inactive (inactivity warning email preview shows)
INSERT INTO customers VALUES(10000006,'Bob','Warning','$2a$12$sXEcZR.JMam7T9uFehG9zOymKFH4Z0cI4EsLylLppdVWieU6OJnPK','61 Birch Avenue','Hillsborough','Sheffield','S6 4HD','7700001002','bob.warning@demo.com',0,'2025-12-18 10:00:00 +0000','Active',NULL,NULL,NULL,NULL,NULL);

-- 10000007: Flagged, day 0 of grace period (just auto-flagged at 6 months)
INSERT INTO customers VALUES(10000007,'Carol','JustFlagged','$2a$12$sXEcZR.JMam7T9uFehG9zOymKFH4Z0cI4EsLylLppdVWieU6OJnPK','14 Primrose Crescent','Darnall','Sheffield','S9 5BQ','7700001003','carol.flagged@demo.com',0,'2025-11-18 10:00:00 +0000','Flagged','2026-05-18 09:00:00 +0000',NULL,NULL,NULL,NULL);

-- 10000008: Flagged, day 4 of grace period (suspension warning email preview shows)
INSERT INTO customers VALUES(10000008,'Dan','DayFour','$2a$12$sXEcZR.JMam7T9uFehG9zOymKFH4Z0cI4EsLylLppdVWieU6OJnPK','Flat 3, Amber Mill','110 Riverside Way','Sheffield','S2 4SU','7700001004','dan.dayfour@demo.com',0,'2025-11-14 10:00:00 +0000','Flagged','2026-05-14 09:00:00 +0000',NULL,NULL,NULL,NULL);

-- 10000009: Suspended due to inactivity, just suspended (reactivate available, no delete)
INSERT INTO customers VALUES(10000009,'Eve','JustSuspended','$2a$12$sXEcZR.JMam7T9uFehG9zOymKFH4Z0cI4EsLylLppdVWieU6OJnPK','36 Oakfield Terrace','Heeley','Sheffield','S2 3GX','7700001005','eve.suspended@demo.com',0,'2025-11-13 10:00:00 +0000','Suspended',NULL,'2026-05-18 10:00:00 +0000',NULL,1,NULL);

-- 10000010: Suspended due to inactivity, 3 months ago (delete button appears, inbox message)
INSERT INTO customers VALUES(10000010,'Frank','ReadyToDelete','$2a$12$sXEcZR.JMam7T9uFehG9zOymKFH4Z0cI4EsLylLppdVWieU6OJnPK','72 Maple Grove','Woodseats','Sheffield','S8 0RL','7700001006','frank.delete@demo.com',0,'2025-08-13 10:00:00 +0000','Suspended',NULL,'2026-02-17 10:00:00 +0000',NULL,1,NULL);

-- 10000011: Suspended due to disciplinary (delete and reactivate both available immediately)
INSERT INTO customers VALUES(10000011,'Grace','Disciplinary','$2a$12$sXEcZR.JMam7T9uFehG9zOymKFH4Z0cI4EsLylLppdVWieU6OJnPK','9 Lavender Mews','Fulwood','Sheffield','S10 3LP','7700001007','grace.disc@demo.com',0,'2026-03-01 10:00:00 +0000','Suspended',NULL,'2026-05-10 10:00:00 +0000',NULL,2,NULL);

-- 10000012: Deleted due to inactivity — anonymised
INSERT INTO customers VALUES(10000012,'Deleted','Px4rTm',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'Deleted',NULL,NULL,'2026-02-08 10:00:00 +0000',NULL,1);

-- 10000013: Deleted due to disciplinary — anonymised
INSERT INTO customers VALUES(10000013,'Deleted','Kj9nQz',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'Deleted',NULL,NULL,'2026-04-15 10:00:00 +0000',NULL,2);

-- ===== Employees =====
-- password same as username
-- admin
INSERT INTO employees VALUES('Admin17!','Craig','Johnson','admin@gmail.com','$2a$12$Lgz80X3Yko1G3.tk3rs0netwPgQ2KNrXFQk0nvzkppwYnzyIzHmva','Admin',NULL,NULL);
-- barista
INSERT INTO employees VALUES('Barista1!','Georgios','Mike','barista@gmail.com','$2a$12$PIwasO0uiGdHgoQGaJLCA.b7.sIc.4U7tLhyhBdgbuggcCbylqRHq','Barista','2026-01-29 18:23:07 +0200',NULL);
-- manager
INSERT INTO employees VALUES('Manager1!','Samuel','Smith','manager@gmail.com','$2a$12$Afo5yWPE/74JL9jNq9LoNuQdBorfCiWz2uoORwJj.sxrT5TLitoUC','Manager','2026-03-11 07:45:52 +0200',NULL);

-- ===== Default Product Options =====
INSERT INTO roast_levels (roast_level) VALUES
('N/A'), ('Light'), ('Medium'), ('Dark');

INSERT INTO countries (country) VALUES
('N/A'), ('Arabic'), ('Brazilian'), ('Ethiopian');

INSERT INTO sizes (size) VALUES
('N/A'), ('Small'), ('Regular'), ('Large');

INSERT INTO milk_options (milk) VALUES
('N/A'), ('No Milk'), ('Whole Milk'), ('Soy Milk'), ('Oat Milk');

-- ===== Products =====
INSERT INTO products (product_id, type, name, availability, origin, roast_level, description, image_path) VALUES
(1, 'drinks', 'Latte', 1, 1, 1, 'Classic espresso with steamed milk and a light layer of foam. Smooth and creamy.', '/images/product_images/1.png'),
(2, 'drinks', 'Americano', 1, 1, 1, 'Espresso shots diluted with hot water. Strong but not as intense as straight espresso.', '/images/product_images/2.png'),
(3, 'drinks', 'Cappuccino', 0, 1, 1, 'Equal parts espresso, steamed milk, and thick milk foam. Traditional Italian favourite.', '/images/product_images/3.png'),
(4, 'drinks', 'Flat White', 0, 1, 1, 'Double espresso with velvety steamed milk. Silky texture with no foam on top.', '/images/product_images/4.png'),
(5, 'drinks', 'Cortado', 1, 1, 1, 'Espresso cut with a small amount of warm milk. Balanced and smooth with minimal foam.', '/images/product_images/5.png');

INSERT INTO product_variants (product_id, size_id, price, cost, milk_id) VALUES
-- Latte variants
(1, 2, 4.20, 1.00, 3), (1, 3, 4.50, 1.20, 3), (1, 4, 4.80, 1.40, 3),
(1, 2, 4.20, 1.00, 4), (1, 3, 4.50, 1.20, 4), (1, 4, 4.80, 1.40, 4),
(1, 2, 4.20, 1.00, 5), (1, 3, 4.50, 1.20, 5), (1, 4, 4.80, 1.40, 5),
-- Americano variants
(2, 2, 3.50, 0.80, 2), (2, 3, 3.80, 0.90, 2), (2, 4, 4.10, 1.00, 2),
-- Cappuccino variants
(3, 3, 4.20, 1.10, 3), (3, 4, 4.50, 1.30, 3),
(3, 3, 4.20, 1.10, 4), (3, 4, 4.50, 1.30, 4),
(3, 3, 4.20, 1.10, 5), (3, 4, 4.50, 1.30, 5),
-- Flat White variants
(4, 3, 4.60, 1.30, 3), (4, 3, 4.60, 1.30, 4), (4, 3, 4.60, 1.30, 5),
-- Cortado variants
(5, 2, 4.00, 1.15, 3), (5, 3, 4.30, 1.25, 3), (5, 4, 4.60, 1.35, 3),
(5, 2, 4.00, 1.15, 4), (5, 3, 4.30, 1.25, 4), (5, 4, 4.60, 1.35, 4),
(5, 2, 4.00, 1.15, 5), (5, 3, 4.30, 1.25, 5), (5, 4, 4.60, 1.35, 5);

INSERT INTO products (product_id, type, name, availability, origin, roast_level, stock_level, description, image_path) VALUES
(6, 'beans', 'Arabic Medium', 1, 2, 3, 25, 'Some beans', '/images/product_images/6.png'),
(7, 'beans', 'Ethiopian Light', 0, 4, 2, 33, 'Some more beans', '/images/product_images/7.png'),
(8, 'beans', 'Brazilian Dark', 1, 3, 4, 65, 'Some other beans', '/images/product_images/8.png');

INSERT INTO product_variants (product_id, size_id, price, cost, milk_id) VALUES
(6, 1, 10.5, 7, 1),
(7, 1, 16, 11.5, 1),
(8, 1, 13, 10, 1);

-- ===== Discount related =====
INSERT INTO eligible_purchase_types VALUES
(1, 'Both'), (2, 'Drinks Only'), (3, 'Beans Only');

INSERT INTO eligible_rules VALUES
(1, 'Amount of Purchase'),
(2, 'Quantity of Products');

INSERT INTO discount_codes VALUES
('WELCOME10', 'New Customer Offer', 10, 1, 1, 0.00, '2026-01-01', '2026-12-31', '2026-12-31', 1),
('COFFEE20', 'Coffee Lovers Deal', 20, 2, 2, 5.00, '2026-03-01', '2026-06-30', '2026-08-31', 1),
('SPRING15', 'Spring Promotion', 15, 1, 1, 10.00, '2026-03-01', '2026-05-31', '2026-11-30', 0);

-- ===== Payment Methods =====
INSERT INTO payment_methods VALUES (1, 'Card');
INSERT INTO payment_methods VALUES (2, 'Cash');

-- ===== Base Orders (1-9) =====
INSERT INTO orders VALUES(1, 10000000, '2026-04-03 11:37:56 +0100', 13.40, 50.60, 123456781, 'ABC10001', 'Barista1!', 0, 'Collected', 'Paid', NULL,      NULL, 1, 50.60);
INSERT INTO orders VALUES(2, 10000001, '2026-04-10 10:00:00 +0100',  3.60, 15.40, 123456782, 'ABC10002', 'Online', 1, 'Collected', 'Paid', 'COFFEE20', 20,  2, 12.32);
INSERT INTO orders VALUES(3, 10000002, '2026-04-11 11:15:00 +0100',  3.15, 12.00, 123456783, 'ABC10003', 'Online', 1, 'Collected', 'Paid', 'SPRING15', 15,  2, 10.20);
INSERT INTO orders VALUES(4, 10000000, '2026-04-12 09:30:00 +0100',  2.45,  8.60, 123456784, 'ABC10004', 'Online', 0, 'Collected', 'Paid', 'COFFEE20', 20,  1,  6.88);
INSERT INTO orders VALUES(5, 10000003, '2026-04-13 14:20:00 +0100',  1.90,  7.70, 123456785, 'ABC10005', 'Barista1!', 1, 'Collected', 'Paid', NULL,      NULL, 2,  7.70);
INSERT INTO orders VALUES(6, 10000000, '2026-04-14 16:45:00 +0100',  3.55, 12.90, 123456786, 'ABC10006', 'Online', 1, 'Collected', 'Paid', 'COFFEE20', 20,  1, 10.32);
INSERT INTO orders VALUES(7, 10000004, '2026-04-20 13:00:00 +0100', 11.50, 26.50, 123456787, 'ABC10007', 'Barista1!', 1, 'Collected', 'Paid', NULL,      NULL, 1, 26.50);
INSERT INTO orders VALUES(8, 10000003, '2026-05-02 15:30:00 +0100', 17.00, 29.00, 123456788, 'ABC10008', 'Barista1!', 1, 'Collected', 'Paid', NULL,      NULL, 2, 29.00);
INSERT INTO orders VALUES(9, 10000003, '2026-05-10 11:00:00 +0100',  2.35,  8.50, 123456789, 'ABC10009', 'Barista1!', 1, 'Collected', 'Paid', NULL,      NULL, 2,  8.50);

-- ===== Items in Orders (1-21) =====
-- Order 1: Amelia (Latte Small Whole x2, Americano Regular No Milk x4, Cappuccino Large Whole x6)
INSERT INTO item_in_orders VALUES(1,  1, 1, 4.20, 2, 2, 3, 0);
INSERT INTO item_in_orders VALUES(2,  2, 1, 3.80, 4, 3, 2, 0);
INSERT INTO item_in_orders VALUES(3,  3, 1, 4.50, 6, 4, 3, 0);

-- Order 2: Oliver (Latte Small Whole x2, Americano Small No Milk x2)
INSERT INTO item_in_orders VALUES(4,  1, 2, 4.20, 2, 2, 3, 0);
INSERT INTO item_in_orders VALUES(5,  2, 2, 3.50, 2, 2, 2, 0);

-- Order 3: Priya (Latte Regular Whole x1, Cortado Small Whole x1, Americano Small No Milk x1)
INSERT INTO item_in_orders VALUES(6,  1, 3, 4.50, 1, 3, 3, 0);
INSERT INTO item_in_orders VALUES(7,  5, 3, 4.00, 1, 2, 3, 0);
INSERT INTO item_in_orders VALUES(8,  2, 3, 3.50, 1, 2, 2, 0);

-- Order 4: Amelia (Flat White Regular Soy x1, Cortado Small Oat x1)
INSERT INTO item_in_orders VALUES(9,  4, 4, 4.60, 1, 3, 4, 0);
INSERT INTO item_in_orders VALUES(10, 5, 4, 4.00, 1, 2, 5, 0);

-- Order 5: Ethan (Cappuccino Regular Soy x1, Americano Small No Milk x1)
INSERT INTO item_in_orders VALUES(11, 3, 5, 4.20, 1, 3, 4, 0);
INSERT INTO item_in_orders VALUES(12, 2, 5, 3.50, 1, 2, 2, 0);

-- Order 6: Amelia (Latte Large Whole x1, Cortado Regular Whole x1, Americano Regular No Milk x1)
INSERT INTO item_in_orders VALUES(13, 1, 6, 4.80, 1, 4, 3, 0);
INSERT INTO item_in_orders VALUES(14, 5, 6, 4.30, 1, 3, 3, 0);
INSERT INTO item_in_orders VALUES(15, 2, 6, 3.80, 1, 3, 2, 0);

-- Order 7: Sofia (Arabic Medium x1, Ethiopian Light x1)
INSERT INTO item_in_orders VALUES(16, 6, 7, 10.50, 1, 1, 1, 0);
INSERT INTO item_in_orders VALUES(17, 7, 7, 16.00, 1, 1, 1, 0);

-- Order 8: Ethan (Ethiopian Light x1, Brazilian Dark x1)
INSERT INTO item_in_orders VALUES(18, 7, 8, 16.00, 1, 1, 1, 0);
INSERT INTO item_in_orders VALUES(19, 8, 8, 13.00, 1, 1, 1, 0);

-- Order 9: Ethan (Latte Regular Whole x1, Cortado Small Oat x1)
INSERT INTO item_in_orders VALUES(20, 1, 9, 4.50, 1, 3, 3, 0);
INSERT INTO item_in_orders VALUES(21, 5, 9, 4.00, 1, 2, 5, 0);

-- ===== Free Coffee Redemptions =====
INSERT INTO free_coffee_redemptions (redeem_timestamp, loyalty_number, product_id, size_id, milk_id) VALUES
('2026-01-10 09:15:00 UTC', 10000001, 1, 2, 3),
('2026-02-18 10:30:00 UTC', 10000002, 2, 3, 2),
('2026-03-20 11:25:00 UTC', 10000001, 5, 2, 3),
('2026-03-25 08:45:00 UTC', 10000003, 3, 3, 4),
('2026-04-12 14:10:00 UTC', 10000004, 4, 3, 5);

-- ===== Refunds =====
INSERT INTO refunds VALUES(1, 10000003, 'Defective Product', 'Pending',  NULL, 7,    '2026-03-01 10:00:00');
INSERT INTO refunds VALUES(2, 10000004, 'Wrong Order',       'Resolved', 4,    NULL, '2026-03-15 14:30:00');

-- ===== Complaints =====
INSERT INTO complaints VALUES(1, 10000003, 'My latte was cold and the barista was rude', 'Pending', '2026-04-01 10:30:00');
INSERT INTO complaints VALUES(2, 10000004, 'Wrong order received, I asked for oat milk', 'Resolved', '2026-04-15 14:20:00');
INSERT INTO complaints VALUES(3, 10000001, 'Long wait time, over 20 minutes', 'Pending', '2026-04-20 09:15:00');
INSERT INTO complaints VALUES(6, 10000004, 'I went to the cafe yesterday morning and the service was absolutely terrible. The barista was rude, my coffee was cold, and they got my order completely wrong. I asked for an oat milk latte and got a cappuccino with regular milk. This is not the first time it happens and I am very disappointed.', 'Pending', '2026-05-07 10:00:00');

-- ===== Discount Redemptions =====
INSERT INTO discount_redemptions (loyalty_number, code, is_redeemed) VALUES
(10000001, 'WELCOME10', 1),
(10000001, 'COFFEE20',  1),
(10000003, 'WELCOME10', 0),
(10000004, 'COFFEE20',  0);

-- ===== Login Times =====
INSERT INTO login_times (loyalty_number, login_time) VALUES
(10000000, '2026-04-24 08:11:03 +0100'),
(10000000, '2026-05-02 17:44:29 +0100'),
(10000000, '2026-05-10 09:23:11 +0100'),
(10000000, '2026-05-15 14:07:43 +0100'),
(10000001, '2026-04-11 10:05:47 +0100'),
(10000001, '2026-04-28 16:39:02 +0100'),
(10000001, '2026-05-12 11:30:00 +0100'),
(10000001, '2026-05-17 08:45:22 +0100'),
(10000002, '2026-04-12 13:58:14 +0100'),
(10000002, '2026-04-28 16:12:54 +0100'),
(10000002, '2026-05-09 10:58:30 +0100'),
(10000003, '2026-04-14 09:17:55 +0100'),
(10000003, '2026-05-03 12:31:08 +0100'),
(10000003, '2026-05-11 15:49:22 +0100'),
(10000003, '2026-05-16 09:02:38 +0100'),
(10000004, '2026-04-21 14:03:40 +0100'),
(10000004, '2026-05-11 15:20:09 +0100'),
(10000004, '2026-05-18 08:33:54 +0100');

-- ===== Favourites =====
INSERT INTO favourites (loyalty_number, item_id, name, time_favourited) VALUES
(10000000, 1, 'Latte',          '2026-04-05 10:15:00 +0100'),
(10000000, 5, 'Cortado',        '2026-04-14 17:30:00 +0100'),
(10000000, 3, 'Cappuccino',     '2026-05-02 18:04:11 +0100'),
(10000001, 1, 'Latte',          '2026-04-11 09:45:00 +0100'),
(10000001, 2, 'Americano',      '2026-04-28 16:41:33 +0100'),
(10000002, 3, 'Cappuccino',     '2026-04-12 14:20:00 +0100'),
(10000002, 5, 'Cortado',        '2026-05-09 11:00:47 +0100'),
(10000003, 3, 'Cappuccino',     '2026-04-14 11:00:00 +0100'),
(10000003, 1, 'Latte',          '2026-05-11 15:52:06 +0100'),
(10000004, 6, 'Arabic Medium',  '2026-04-21 14:07:19 +0100'),
(10000004, 8, 'Brazilian Dark', '2026-05-11 15:23:45 +0100');

-- ===== Recent Views =====
INSERT INTO recent_views (loyalty_number, item_id, time_viewed, name) VALUES
(10000000, 1, '2026-05-15 14:10:00 +0100', 'Latte'),
(10000000, 5, '2026-05-15 14:12:00 +0100', 'Cortado'),
(10000000, 3, '2026-05-15 14:15:00 +0100', 'Cappuccino'),
(10000000, 2, '2026-05-15 14:18:00 +0100', 'Americano'),
(10000001, 1, '2026-05-17 08:47:00 +0100', 'Latte'),
(10000001, 2, '2026-05-17 08:50:00 +0100', 'Americano'),
(10000001, 6, '2026-05-17 08:53:00 +0100', 'Arabic Medium'),
(10000002, 5, '2026-05-09 11:02:00 +0100', 'Cortado'),
(10000002, 3, '2026-05-09 11:05:00 +0100', 'Cappuccino'),
(10000002, 1, '2026-05-09 11:08:00 +0100', 'Latte'),
(10000003, 1, '2026-05-16 09:05:00 +0100', 'Latte'),
(10000003, 3, '2026-05-16 09:08:00 +0100', 'Cappuccino'),
(10000003, 5, '2026-05-16 09:11:00 +0100', 'Cortado'),
(10000004, 6, '2026-05-11 15:25:00 +0100', 'Arabic Medium'),
(10000004, 8, '2026-05-11 15:28:00 +0100', 'Brazilian Dark'),
(10000004, 7, '2026-05-11 15:31:00 +0100', 'Ethiopian Light');

-- ===== Profile Updates =====
INSERT INTO profile_updates (loyalty_number, field_updated, old_value, new_value, time_updated) VALUES
(10000003, 'phone_number', '07700900094', '07700900104', '2026-04-18 09:54:00 +0100'),
(10000003, 'first_name',   'Ethen',       'Ethan',      '2026-04-18 09:54:11 +0100'),
(10000003, 'password',     NULL,          NULL,         '2026-04-18 09:55:03 +0100'),
(10000000, 'phone_number', '07700900091', '07700900101', '2026-04-24 10:30:17 +0100'),
(10000001, 'last_name',    'Benett',      'Bennett',    '2026-04-29 11:14:52 +0100'),
(10000001, 'password',     NULL,          NULL,         '2026-05-12 11:33:08 +0100'),
(10000002, 'first_name',   'Pryia',       'Priya',      '2026-04-13 09:07:44 +0100'),
(10000004, 'phone_number', '07700900095', '07700900105', '2026-04-22 08:48:31 +0100');

-- barista test data (IDs start at 10/22 to avoid conflicts with base data above)

-- checkout: Completed, no tracking, barista=NULL, not Unpaid
-- card + loyalty (reference_id needed for card orders)
INSERT INTO orders VALUES(10, 10000001, '2026-05-15 10:00:00 UTC', 1.20,  4.50, NULL, 'KBX74291', NULL, 0,    'Completed', 'Paid', NULL, NULL, 1,    4.50);
-- cash + no loyalty (cash doesn't need a reference_id)
INSERT INTO orders VALUES(11, NULL,     '2026-05-15 11:00:00 UTC', 0.80,  3.50, NULL, NULL,        NULL, NULL, 'Completed', 'Paid', NULL, NULL, 2,    3.50);
-- owed, no payment yet
INSERT INTO orders VALUES(12, 10000002, '2026-05-15 12:00:00 UTC', 2.25,  8.50, NULL, NULL,        NULL, NULL, 'Completed', 'Owed', NULL, NULL, NULL, 8.50);

INSERT INTO item_in_orders VALUES(22, 1, 10, 4.50, 1, 3, 3, 0); -- Latte Regular Whole
INSERT INTO item_in_orders VALUES(23, 2, 11, 3.50, 1, 2, 2, 0); -- Americano Small No Milk
INSERT INTO item_in_orders VALUES(24, 5, 12, 4.30, 1, 3, 5, 0); -- Cortado Regular Oat
INSERT INTO item_in_orders VALUES(25, 1, 12, 4.20, 1, 2, 3, 0); -- Latte Small Whole

-- past sales extra cases (orders 1-12 already appear there too)
-- refunded + delivered + card
INSERT INTO orders VALUES(13, 10000001, '2026-04-25 10:00:00 UTC', 1.20,  4.50,  NULL,  'PLN62948', 'Barista1!', 1, 'Collected', 'Refunded', NULL, NULL, 1,    4.50);
-- owed + not delivered + cash
INSERT INTO orders VALUES(14, 10000003, '2026-04-26 10:00:00 UTC', 0.80,  3.50,  NULL,  NULL,       'Barista1!', 0, 'Collected', 'Owed',     NULL, NULL, 2,    3.50);
-- paid + has tracking (won't show on checkout or order labels without bean check)
INSERT INTO orders VALUES(15, 10000004, '2026-04-27 10:00:00 UTC', 7.00, 10.50, 12345,  'ZHW39214', 'Barista1!', 0, 'Completed', 'Paid',     NULL, NULL, 1,   10.50);

INSERT INTO item_in_orders VALUES(26, 1, 13,  4.50, 1, 3, 3, 1); -- Latte Regular Whole (refunded)
INSERT INTO item_in_orders VALUES(27, 2, 14,  3.50, 1, 2, 2, 0); -- Americano Small No Milk
INSERT INTO item_in_orders VALUES(28, 6, 15, 10.50, 1, 1, 1, 0); -- Arabic Medium

-- daily summary: must be logged in as Barista1!, date must match today (2026-05-18)
-- collected + paid + card
INSERT INTO orders VALUES(16, 10000001, '2026-05-18 09:00:00 UTC', 1.30, 4.60, NULL, 'RTV84562', 'Barista1!', 1,    'Collected', 'Paid', NULL, NULL, 1,    4.60);
-- completed + owed, not paid yet
INSERT INTO orders VALUES(17, 10000003, '2026-05-18 10:00:00 UTC', 1.35, 4.60, NULL, NULL,        'Barista1!', NULL, 'Completed', 'Owed', NULL, NULL, NULL, 4.60);
-- completed + paid + cash + no loyalty
INSERT INTO orders VALUES(18, NULL,     '2026-05-18 11:00:00 UTC', 0.90, 3.80, NULL, NULL,        'Barista1!', 0,    'Completed', 'Paid', NULL, NULL, 2,    3.80);

INSERT INTO item_in_orders VALUES(29, 4, 16, 4.60, 1, 3, 3, 0); -- Flat White Regular Whole
INSERT INTO item_in_orders VALUES(30, 5, 17, 4.60, 1, 4, 4, 0); -- Cortado Large Soy
INSERT INTO item_in_orders VALUES(31, 2, 18, 3.80, 1, 3, 2, 0); -- Americano Regular No Milk

-- order postage labels: Paid, Completed, delivered=0, all items beans
-- card + loyalty
INSERT INTO orders VALUES(19, 10000001, '2026-04-28 10:00:00 UTC',  7.00, 10.50, NULL, 'WBJ49371', 'Barista1!', 0, 'Completed', 'Paid', NULL, NULL, 1, 10.50);
-- cash + no loyalty
INSERT INTO orders VALUES(20, NULL,     '2026-04-29 10:00:00 UTC', 10.00, 13.00, NULL, NULL,        'Barista1!', 0, 'Completed', 'Paid', NULL, NULL, 2, 13.00);
-- tracking_id=0 still counts as no tracking in get_deliverable
INSERT INTO orders VALUES(21, 10000002, '2026-04-30 10:00:00 UTC', 11.50, 16.00, 0,    'NJP51923', NULL,             0, 'Completed', 'Paid', NULL, NULL, 1, 16.00);

INSERT INTO item_in_orders VALUES(32, 6, 19, 10.50, 1, 1, 1, 0); -- Arabic Medium
INSERT INTO item_in_orders VALUES(33, 8, 20, 13.00, 1, 1, 1, 0); -- Brazilian Dark
INSERT INTO item_in_orders VALUES(34, 7, 21, 16.00, 1, 1, 1, 0); -- Ethiopian Light

-- make refunds FCR case: item 35 is the redeemed free coffee
-- search 10000003, pick item type, select item 35 -> redemption_check fires
-- net_price=7.00 because the latte was free (FCR), customer only paid for the americanos
INSERT INTO orders VALUES(22, 10000003, '2026-05-01 10:00:00 UTC', 2.80, 11.50, NULL, NULL, 'Barista1!', 1, 'Collected', 'Paid', NULL, NULL, 2, 7.00);
INSERT INTO item_in_orders VALUES(35, 1, 22, 4.50, 1, 3, 3, 0); -- Latte Regular Whole (FCR item, qty=1)
INSERT INTO item_in_orders VALUES(36, 2, 22, 3.50, 2, 2, 2, 0); -- Americano Small No Milk x2
INSERT INTO free_coffee_redemptions VALUES(6, '2026-05-01 10:00:00 UTC', 22, 35, 10000003, 1, 3, 3);

-- incomplete/unpaid - should not appear on any barista page
INSERT INTO orders VALUES(23, 10000000, '2026-05-18 12:30:00 +0100', 2.20, 8.80, 987654321, NULL, 'Online', 0, 'Incomplete', 'Unpaid', NULL, NULL, NULL, 8.80);

-- verify refunds + refund postage labels
-- labels shows Pending + loyalty present -> refund 1 (existing) + 3 + 4 = 3 entries
-- all statuses and both order/item refund types covered across refunds 1-7
INSERT INTO refunds VALUES(3, 10000001, 'Wrong size received',                    'Pending',  10,   NULL, '2026-05-10 10:00:00');
INSERT INTO refunds VALUES(4, 10000002, 'Item arrived cold',                      'Pending',  NULL, 24,   '2026-05-11 10:00:00');
INSERT INTO refunds VALUES(5, 10000001, 'Wrong milk type',                        'Resolved', NULL, 4,    '2026-05-12 10:00:00');
INSERT INTO refunds VALUES(6, 10000002, 'Customer changed mind after collection', 'Denied',   3,    NULL, '2026-05-13 10:00:00');
INSERT INTO refunds VALUES(7, 10000003, 'Waited too long for order',              'Denied',   NULL, 11,   '2026-05-14 10:00:00');
