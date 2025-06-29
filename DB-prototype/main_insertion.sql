USE rental_app;

-- 1. Insert users (admin, lender, customer)
INSERT INTO users (first_name, last_name, role, gender, email, password) VALUES
('Admin', 'User', 'admin', 'male', 'admin@example.com', 'hashed_password_123'),
('John', 'Lender', 'lender', 'male', 'lender@example.com', 'hashed_password_456'),
('Alice', 'Customer', 'customer', 'female', 'customer1@example.com', 'hashed_password_789'),
('Bob', 'Customer', 'customer', 'male', 'customer2@example.com', 'hashed_password_abc');

-- 2. Add phone numbers (two for one user)
INSERT INTO user_phones (user_id, phone_num) VALUES
(1, '+1111111111'),  -- Admin
(2, '+2222222222'),  -- Lender
(2, '+2222222223'),  -- Lender's second number
(3, '+3333333333'),  -- Alice
(4, '+4444444444');  -- Bob

-- 3. Create categories
INSERT INTO categories (name) VALUES
('Electronics'),
('Furniture'),
('Books');

-- 4. Add items (owned by lender)
INSERT INTO items (owner_id, title, description, price, status) VALUES
(2, 'MacBook Pro', '2023 model, 16GB RAM', 1500.00, 'available'),
(2, 'Leather Sofa', 'Brown leather sofa, 3-seater', 500.00, 'available'),
(2, 'Rust Programming Book', 'Learn Rust in 30 days', 30.00, 'available');

-- 5. Add item images (multiple for one item)
INSERT INTO item_images (item_id, image_url) VALUES
(1, 'https://example.com/macbook1.jpg'),
(1, 'https://example.com/macbook2.jpg'),
(2, 'https://example.com/sofa1.jpg'),
(3, 'https://example.com/book1.jpg');

-- 6. Categorize items (one item in two categories)
INSERT INTO item_in_category (item_id, category_id) VALUES
(1, 1),  -- MacBook in Electronics
(2, 2),  -- Sofa in Furniture
(3, 3),  -- Book in Books
(1, 3);  -- MacBook also in Books (for testing)

-- 7. Create conversation between customer and lender about an item
-- First check if conversation exists
SET @item_id = 1;
SET @customer_id = 3;
SET @lender_id = 2;

-- Get or create conversation
INSERT IGNORE INTO conversation (item_id, sender_id, receiver_id) 
VALUES (@item_id, @customer_id, @lender_id);

-- Get conversation ID
SET @conversation_id = (SELECT id FROM conversation 
WHERE item_id = @item_id 
AND ((sender_id = @customer_id AND receiver_id = @lender_id) 
     OR (sender_id = @lender_id AND receiver_id = @customer_id))
LIMIT 1);

-- 8. Add messages to conversation
INSERT INTO messages (conversation_id, sender_id, content) VALUES
(@conversation_id, @customer_id, 'Is the MacBook still available?'),
(@conversation_id, @lender_id, 'Yes, it is available'),
(@conversation_id, @customer_id, 'Can I get it for $1400?'),
(@conversation_id, @lender_id, 'Sorry, price is firm at $1500');

-- 9. Create rental (validate trigger works)
-- This will succeed
INSERT INTO rentals (item_id, user_id, start_date, end_date, delivery_address) VALUES
(1, 3, DATE_ADD(CURDATE(), INTERVAL 1 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), '123 Customer St');

-- This should fail (past date)
INSERT INTO rentals (item_id, user_id, start_date, end_date) VALUES
(1, 3, '2023-01-01', '2023-01-07');

-- This should fail (end before start)
INSERT INTO rentals (item_id, user_id, start_date, end_date) VALUES
(1, 3, DATE_ADD(CURDATE(), INTERVAL 1 DAY), CURDATE());

-- 10. Add reviews
INSERT INTO reviews (item_id, user_id, comments, rating) VALUES
(1, 3, 'Great laptop, fast delivery!', 5),
(2, 4, 'Sofa was comfortable but delivery was late', 3);

-- 11. Verify data with sample queries
-- Get all items with categories
SELECT i.id, i.title, GROUP_CONCAT(c.name) AS categories
FROM items i
LEFT JOIN item_in_category ic ON i.id = ic.item_id
LEFT JOIN categories c ON ic.category_id = c.id
GROUP BY i.id;

-- Get conversations with message count
SELECT c.id, i.title AS item, 
       CONCAT(u1.first_name, ' ', u1.last_name) AS sender,
       CONCAT(u2.first_name, ' ', u2.last_name) AS receiver,
       COUNT(m.id) AS message_count
FROM conversation c
JOIN items i ON c.item_id = i.id
JOIN users u1 ON c.sender_id = u1.id
JOIN users u2 ON c.receiver_id = u2.id
LEFT JOIN messages m ON c.id = m.conversation_id
GROUP BY c.id;

-- Check rentals with status
SELECT r.id, i.title, 
       CONCAT(u.first_name, ' ', u.last_name) AS renter,
       r.start_date, r.end_date, r.current_status
FROM rentals r
JOIN items i ON r.item_id = i.id
JOIN users u ON r.user_id = u.id;

-- Get average ratings
SELECT i.id, i.title, AVG(r.rating) AS avg_rating
FROM items i
LEFT JOIN reviews r ON i.id = r.item_id
GROUP BY i.id;