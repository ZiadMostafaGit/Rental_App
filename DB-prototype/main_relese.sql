USE rental_app;

-- Create users table with ENUM types (MySQL syntax)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('admin', 'lender', 'customer') NOT NULL,
    gender ENUM('male', 'female', 'other'),
    state VARCHAR(50),
    city VARCHAR(50),
    street VARCHAR(100),
    score DECIMAL(3,2) DEFAULT 0.0,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

-- Create user_phones junction table with corrected constraints
CREATE TABLE user_phones (
    user_id INT NOT NULL,
    phone_num VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id, phone_num),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- Create categories table
CREATE TABLE categories (
       id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);






-- Create items table
CREATE TABLE items (
   id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    status Enum ("available","not available") NOT NULL DEFAULT 'available',
   
    FOREIGN KEY (owner_id) REFERENCES users(id)
);

-- Create item_images table
CREATE TABLE item_images (
    item_id INTEGER NOT NULL,
    image_url VARCHAR(512) NOT NULL,
    PRIMARY KEY (item_id, image_url),
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);

-- Create item_in_category junction table
CREATE TABLE item_in_category (
    item_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    PRIMARY KEY (item_id, category_id),
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);








-- Create conversation table
CREATE TABLE conversation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,
    receiver_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES items(id),
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id),
    UNIQUE (item_id, sender_id, receiver_id)
);

-- Create messages table
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversation(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id)
);





-- Create rentals table with trigger-based validation
CREATE TABLE rentals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    user_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    current_status ENUM('pending', 'active', 'completed', 'canceled') NOT NULL DEFAULT 'pending',
    estimated_time INT,
    delivery_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES items(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;


-- Create reviews table
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    comments TEXT,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES items(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create indexes for better performance
CREATE INDEX idx_items_owner ON items(owner_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_rentals_item ON rentals(item_id);
CREATE INDEX idx_rentals_user ON rentals(user_id);
CREATE INDEX idx_reviews_item ON reviews(item_id);