USE rental_app;
DELIMITER //

CREATE PROCEDURE fetch_conversation_messages(
    IN p_item_id INT,
    IN p_sender_id INT,
    IN p_receiver_id INT
)
BEGIN
    -- Validate IDs first
    IF NOT EXISTS (SELECT 1 FROM items WHERE id = p_item_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid item ID';
    ELSEIF NOT EXISTS (SELECT 1 FROM users WHERE id = p_sender_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid sender ID';
    ELSEIF NOT EXISTS (SELECT 1 FROM users WHERE id = p_receiver_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid receiver ID';
    END IF;

    -- Return messages if conversation exists
    SELECT m.* 
    FROM messages m
    JOIN conversation c ON m.conversation_id = c.id
    WHERE c.item_id = p_item_id
      AND ((c.sender_id = p_sender_id AND c.receiver_id = p_receiver_id)
        OR (c.sender_id = p_receiver_id AND c.receiver_id = p_sender_id))
    ORDER BY m.created_at;
END //

DELIMITER ;fetch_conversation_messages

-- Usage: CALL fetch_conversation_messages(1, 3, 2);
-- =============================================================================================================================================================




USE rental_app;

DELIMITER //

CREATE FUNCTION insert_message(
    p_item_id INT,
    p_sender_id INT,
    p_receiver_id INT,
    p_content TEXT
) RETURNS BOOLEAN
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE v_conversation_id INT;
    
    -- Validate all IDs exist
    IF NOT EXISTS (SELECT 1 FROM items WHERE id = p_item_id) THEN
        RETURN FALSE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_sender_id) THEN
        RETURN FALSE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_receiver_id) THEN
        RETURN FALSE;
    END IF;
    
    -- Find existing conversation (check both directions)
    SELECT id INTO v_conversation_id
    FROM conversation
    WHERE item_id = p_item_id
    AND 
        (sender_id = p_sender_id AND receiver_id = p_receiver_id)
    
    LIMIT 1;
    
    -- If no conversation exists, create one
    IF v_conversation_id IS NULL THEN
        INSERT INTO conversation (item_id, sender_id, receiver_id)
        VALUES (p_item_id, p_sender_id, p_receiver_id);
        
        SET v_conversation_id = LAST_INSERT_ID();
        
        -- Verify conversation was created
        IF v_conversation_id = 0 THEN
            RETURN FALSE;
        END IF;
    END IF;
    
    -- Insert the message
    INSERT INTO messages (conversation_id, sender_id, content)
    VALUES (v_conversation_id, p_sender_id, p_content);
    
    -- Verify message was inserted
    IF ROW_COUNT() = 0 THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END //

DELIMITER ;






USE rental_app;

DELIMITER //

CREATE TRIGGER validate_rental_dates_insert
BEFORE INSERT ON rentals
FOR EACH ROW
BEGIN
    -- Check if start date is today or in the future
    IF NEW.start_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Rental start date must be today or in the future';
    END IF;
    
    -- Check if end date is after start date
    IF NEW.end_date < NEW.start_date THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Rental end date must be on or after start date';
    END IF;
END//

DELIMITER ;




USE rental_app;

DELIMITER //

CREATE TRIGGER validate_rental_dates_update
BEFORE UPDATE ON rentals
FOR EACH ROW
BEGIN
    -- Check if start date is today or in the future
    IF NEW.start_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Rental start date must be today or in the future';
    END IF;
    
    -- Check if end date is after start date
    IF NEW.end_date < NEW.start_date THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Rental end date must be on or after start date';
    END IF;
END//

DELIMITER ;

