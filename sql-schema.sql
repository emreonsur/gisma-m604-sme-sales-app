-- ------------------------------------------------------------------
-- DATABASE CREATION
-- ------------------------------------------------------------------
CREATE SCHEMA sme_sales_db;
USE sme_sales_db;
-- ------------------------------------------------------------------


-- ------------------------------------------------------------------
-- BILLING ENTITIES TABLE
-- ------------------------------------------------------------------
-- Stores the entities responsible for both invoicing and payments.
-- Each billing entity may be linked to one or more customers.
--
-- These entities are financially responsible for all linked customers.
--
-- A billing entity can be either:
--   - a natural person: identified by an 11-digit citizenship ID
--   - a legal entity: identified by a 10-digit trade number
--
-- The 'entity_type' field is set automatically using a BEFORE INSERT trigger,
-- based on the length of the 'trade_number_or_citizen_id' field.
-- Also maintained via an AFTER UPDATE trigger if the the field changes.
--
-- 'current_balance' shows the net amount owed to or by the billing entity.
-- It can be negative.
-- ------------------------------------------------------------------
CREATE TABLE billing_entities (
    billing_entity_id INT AUTO_INCREMENT PRIMARY KEY,
    trade_number_or_citizen_id CHAR(11) NOT NULL UNIQUE, -- 10-digit for legal entities, 11-digit for natural persons
    entity_type ENUM('Natural Person', 'Legal Entity'), -- Set automatically by the related BEFORE INSERT/AFTER UPDATE triggers
    trade_name VARCHAR(255) NOT NULL,
    tax_office VARCHAR(30), -- Optional: May be NULL for natural persons
    billing_address TEXT NOT NULL,
    current_balance DECIMAL(10, 2) NOT NULL DEFAULT 0.00, -- Net balance of the billing entity (can be negative if we owe them)
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Index for supporting search by trade name
CREATE INDEX idx_billing_entities_trade_name ON billing_entities(trade_name);
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- TRIGGERS FOR AUTOMATICALLY SETTING 'entity_type' IN THE billing_entities TABLE
-- ------------------------------------------------------------------
-- Purpose:
--   Automatically classifies each billing entity as either a
--   'Natural Person' or 'Legal Entity' based on the length of
--   their identification number ('trade_number_or_citizen_id' field):
--     - 11 digits: 'Natural Person'
--     - 10 digits: 'Legal Entity'
--
-- - BEFORE INSERT: Sets 'entity_type' before the row is inserted.
-- - AFTER UPDATE: Updates 'entity_type' only if the identification number changes.
-- ------------------------------------------------------------------
DELIMITER $$

-- BEFORE INSERT trigger setting 'entity_type' before insertion
CREATE TRIGGER trigger_set_entity_type_before_insert
BEFORE INSERT ON billing_entities
FOR EACH ROW
BEGIN
    SET NEW.entity_type =
        CASE
            WHEN CHAR_LENGTH(NEW.trade_number_or_citizen_id) = 11 THEN 'Natural Person'
            WHEN CHAR_LENGTH(NEW.trade_number_or_citizen_id) = 10 THEN 'Legal Entity'
            ELSE NULL
        END;
END $$

-- AFTER UPDATE trigger recalculating 'entity_type' only if ID changes
CREATE TRIGGER trigger_set_entity_type_after_update
AFTER UPDATE ON billing_entities
FOR EACH ROW
BEGIN
    IF OLD.trade_number_or_citizen_id <> NEW.trade_number_or_citizen_id THEN
        UPDATE billing_entities
        SET entity_type =
            CASE
                WHEN CHAR_LENGTH(NEW.trade_number_or_citizen_id) = 11 THEN 'Natural Person'
                WHEN CHAR_LENGTH(NEW.trade_number_or_citizen_id) = 10 THEN 'Legal Entity'
                ELSE NULL
            END
        WHERE billing_entity_id = NEW.billing_entity_id;
    END IF;
END $$

DELIMITER ;
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- STORED PROCEDURE: Insert_Billing_Entity
-- ------------------------------------------------------------------
-- Adds a billing entity (legal entity or natural person) into the system.
--   - Gets trade name, tax office, address, and identifier ('trade_number_or_citizen_id').
--   - Validates the length of the ID (must be 10 or 11 characters).
--
-- Rules for the 'trade_number_or_citizen_id' field:
--   - 10-digit: Legal Entity
--   - 11-digit: Natural Person
--
-- Note: 'entity_type' is assigned automatically by AFTER INSERT trigger
-- ------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE Insert_Billing_Entity (
    IN p_trade_number_or_citizen_id CHAR(11),
    IN p_trade_name VARCHAR(255),
    IN p_tax_office VARCHAR(30),
    IN p_billing_address TEXT
)
BEGIN
    DECLARE id_length INT;
    SET id_length = CHAR_LENGTH(p_trade_number_or_citizen_id);

    IF id_length <> 10 AND id_length <> 11 THEN
        SELECT 'Error: ID must be 10 digits (trade number) or 11 digits (citizenship ID)' AS result_message;
    ELSE
        INSERT INTO billing_entities (
            trade_number_or_citizen_id,
            trade_name,
            tax_office,
            billing_address
        )
        VALUES (
            p_trade_number_or_citizen_id,
            p_trade_name,
            p_tax_office,
            p_billing_address
        );

        SELECT CONCAT('Success: Billing entity added with ID = ', LAST_INSERT_ID()) AS result_message;
    END IF;
END $$

DELIMITER ;
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- Insert billing entities using the Insert_Billing_Entity stored
-- procedure to ensure validation of the 'trade_number_or_citizen_id'
-- and automatic classification of the 'entity_type' fields.
-- ------------------------------------------------------------------
-- Natural Persons (11-digit trade number)
CALL Insert_Billing_Entity('12345678910', 'Mehmet Yilmaz', 'Kadikoy', 'Bahariye Caddesi No:12, Kadikoy, Istanbul');
CALL Insert_Billing_Entity('12345678911', 'Ayse Demir', 'Besiktas', 'Ihlamur Sokak No:22, Besiktas, Istanbul');
CALL Insert_Billing_Entity('12345678912', 'Fatma Kaya', 'Osmangazi', 'Cekirge Caddesi No:8, Osmangazi, Bursa');
CALL Insert_Billing_Entity('12345678913', 'Ahmet Ozturk', 'Umraniye', 'Atakent Mahallesi No:18, Umraniye, Istanbul');
CALL Insert_Billing_Entity('12345678914', 'Zeynep Sahin', 'Gebze', 'Baris Mahallesi No:5, Gebze, Kocaeli');
-- Legal Entities (10-digit citizenship ID)
CALL Insert_Billing_Entity('1234567891', 'Yildizlar Gida AS', 'Adapazari', 'Yeni Sanayi Sitesi 1. Blok No:101, Adapazari, Sakarya');
CALL Insert_Billing_Entity('1234567892', 'Teknomak Ltd Sti', 'Izmit', 'Makineciler OSB No:3, Izmit, Kocaeli');
CALL Insert_Billing_Entity('1234567893', 'Ege Tarim Sanayi', 'Corlu', 'Trakya OSB Mah. No:7, Corlu, Tekirdag');
CALL Insert_Billing_Entity('1234567894', 'Bati Enerji AS', 'Merkez', 'Yeni Mahalle No:12, Merkez, Edirne');
CALL Insert_Billing_Entity('1234567895', 'Dogu Insaat ve Ticaret Ltd', 'Bandirma', 'Sanayi Caddesi No:88, Bandirma, Balikesir');

SELECT * FROM billing_entities;
-- --------------------------------------------


-- ------------------------------------------------------------------
-- CUSTOMERS TABLE
-- ------------------------------------------------------------------
-- Stores customer records.
--
-- Each billing entity can be linked to multiple customers (1:N relationship).
-- Each customer must belong to exactly one billing entity.
--
-- Notes on some fields:
-- - 'display_name' is an internal nickname for facilitating user recognition.
-- - 'billing_entity_id' links the customer with the entity responsible
--   for invoicing, sales tracking, and payments.
-- - 'delivery_address' stores the full delivery address as plain text.
-- ------------------------------------------------------------------
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    display_name VARCHAR(127) NOT NULL UNIQUE, -- Internal nickname for easy recognition
    billing_entity_id INT NOT NULL,
    delivery_address TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    FOREIGN KEY (billing_entity_id) REFERENCES billing_entities(billing_entity_id)
);
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- STORED PROCEDURE: Insert_Customer
-- ------------------------------------------------------------------
-- Inserts a new customer.
-- ------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE Insert_Customer (
    IN p_display_name VARCHAR(127),
    IN p_billing_entity_id INT,
    IN p_delivery_address TEXT
)
BEGIN
    INSERT INTO customers (
        display_name,
        billing_entity_id,
        delivery_address
    )
    VALUES (
        p_display_name,
        p_billing_entity_id,
        p_delivery_address
    );

    SELECT CONCAT('Success: Customer inserted with ID = ', LAST_INSERT_ID()) AS result_message;
END $$

DELIMITER ;
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- Insert customers using the Insert_Customer stored procedure
-- ------------------------------------------------------------------
-- Linked to billing_entity_id = 1
CALL Insert_Customer('Kadikoy Sube', 1, 'Sogutlucesme Caddesi No:5, Kadikoy, Istanbul');
CALL Insert_Customer('Moda Sube', 1, 'Moda Caddesi No:23, Kadikoy, Istanbul');
-- Linked to billing_entity_id = 2
CALL Insert_Customer('Besiktas Meydani', 2, 'Hasan Halife Sokak No:10, Besiktas, Istanbul');
CALL Insert_Customer('Akatlar Sube', 2, 'Zeytinoglu Caddesi No:9, Besiktas, Istanbul');
-- Linked individually
CALL Insert_Customer('Osmangazi Corner', 3, 'Uluyol Caddesi No:8, Osmangazi, Bursa');
CALL Insert_Customer('Umraniye Vadi', 4, 'Kazim Karabekir Mah. No:15, Umraniye, Istanbul');
CALL Insert_Customer('Gebze Ana Bayi', 5, 'Tatlikuyu Mah. No:30, Gebze, Kocaeli');
CALL Insert_Customer('Adapazari Sube', 6, 'Cark Caddesi No:77, Adapazari, Sakarya');
CALL Insert_Customer('Corlu Depo', 7, 'Istiklal Mah. No:11, Corlu, Tekirdag');
CALL Insert_Customer('Bandirma Perakende', 8, 'Yenimahalle No:3, Bandirma, Balikesir');

SELECT * FROM customers;
-- ------------------------------------------------------------------


-- ------------------------------------------------------------------
-- PRODUCTS TABLE
-- ------------------------------------------------------------------
-- Stores product records including pricing and stock details.
--
-- - 'formal_name': Used for official records like invoicing.
-- - 'display_name': Internal reference for quick user-interface identification.
-- ------------------------------------------------------------------
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    formal_name VARCHAR(255) NOT NULL UNIQUE, -- Used on invoices
    display_name VARCHAR(50) NOT NULL UNIQUE, -- Internal reference
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0.00),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- STORED PROCEDURE: Insert_Product
-- ------------------------------------------------------------------
-- Inserts a new product into the 'products' table.
-- ------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE Insert_Product (
    IN p_formal_name VARCHAR(255),
    IN p_display_name VARCHAR(50),
    IN p_unit_price DECIMAL(10,2),
    IN p_stock_quantity INT
)
BEGIN
    -- Validate price and stock before inserting
    IF p_unit_price < 0 THEN
        SELECT 'Error: Unit price must be non-negative.' AS result_message;
    ELSEIF p_stock_quantity < 0 THEN
        SELECT 'Error: Stock quantity must be non-negative.' AS result_message;
    ELSE
        INSERT INTO products (
            formal_name,
            display_name,
            unit_price,
            stock_quantity
        )
        VALUES (
            p_formal_name,
            p_display_name,
            p_unit_price,
            p_stock_quantity
        );

        SELECT CONCAT('Success: Product inserted with ID = ', LAST_INSERT_ID()) AS result_message;
    END IF;
END $$

DELIMITER ;
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- STORED PROCEDURE: Add_Product_Stock
-- ------------------------------------------------------------------
-- Increases the stock of a specific product by the 'display_name'
-- ------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE Add_Product_Stock (
    IN p_display_name VARCHAR(50),
    IN p_increment INT
)
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity + p_increment
    WHERE display_name = p_display_name;
END $$

DELIMITER ;

CALL Add_Product_Stock('Milk 1L', 20);

-- Check the result to verify stock increase
SELECT display_name, stock_quantity
FROM products
WHERE display_name = 'Milk 1L';
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- Insert products using the Insert_Product stored procedure to ensure
-- validation of pricing and stock levels before insertion into the system.
-- ------------------------------------------------------------------
CALL Insert_Product('Full Fat Milk 1L', 'Milk 1L', 10.00, 100);
CALL Insert_Product('Low Fat Milk 1L', 'Milk LF', 9.00, 80);
CALL Insert_Product('White Bread 400g', 'Bread', 5.00, 60);
CALL Insert_Product('Tomato Paste 500g', 'Paste', 15.00, 70);
CALL Insert_Product('Sunflower Oil 1L', 'Oil 1L', 25.00, 50);
CALL Insert_Product('Granulated Sugar 1kg', 'Sugar 1kg', 20.00, 40);
CALL Insert_Product('Wheat Flour 2kg', 'Flour 2kg', 18.00, 90);
CALL Insert_Product('Eggs Pack of 10', 'Eggs', 12.00, 30);
CALL Insert_Product('Table Salt 750g', 'Salt', 4.00, 20);
CALL Insert_Product('Pasta 500g', 'Pasta', 7.00, 60);

SELECT * FROM products;
-- ------------------------------------------------------------------


-- ------------------------------------------------------------------
-- SALES RELATED TABLES:
--    - sales
--    - sale_details
-- ------------------------------------------------------------------
-- ------------------------------------------------------------------
-- SALES TABLE
-- ------------------------------------------------------------------
-- Stores sales transactions linked to customers.
--
-- - Each sale is linked to a customer.
-- - 'invoice_id' refers to the external platform’s invoice identifier
--   and must be unique to prevent duplicates.
-- - 'total_amount' reflects the full value of the sale.
-- ------------------------------------------------------------------
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    invoice_id CHAR(16) NOT NULL UNIQUE, -- External reference, must be unique
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0.00),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Index to enhance search by customer
CREATE INDEX idx_sales_customer_id ON sales(customer_id);
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- TRIGGERS FOR MAINTAINING THE 'current_balance' FIELD IN THE
-- billing_entities TABLE
-- ------------------------------------------------------------------
-- Purpose:
--   Automatically updates the 'current_balance' of each billing entity
--   when a sale is inserted, deleted, or updated.
--
--   - On INSERT: Adds 'total_amount' to the billing entity's balance.
--   - On DELETE: Subtracts 'total_amount' from the billing entity's balance.
--   - On UPDATE: Recalculates balances only if 'customer_id' or 'total_amount' changes.
-- ------------------------------------------------------------------
DELIMITER $$

-- AFTER INSERT on sales
CREATE TRIGGER trigger_sales_after_insert
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    UPDATE billing_entities
    SET current_balance = current_balance + NEW.total_amount
    WHERE billing_entity_id = (
        SELECT billing_entity_id
        FROM customers
        WHERE customer_id = NEW.customer_id
    );
END $$

-- AFTER DELETE on sales
CREATE TRIGGER trigger_sales_after_delete
AFTER DELETE ON sales
FOR EACH ROW
BEGIN
    UPDATE billing_entities
    SET current_balance = current_balance - OLD.total_amount
    WHERE billing_entity_id = (
        SELECT billing_entity_id
        FROM customers
        WHERE customer_id = OLD.customer_id
    );
END $$

-- AFTER UPDATE on sales
CREATE TRIGGER trigger_sales_after_update
AFTER UPDATE ON sales
FOR EACH ROW
BEGIN
	DECLARE old_entity_id INT;
	DECLARE new_entity_id INT;

    -- Recalculate balances if only customer_id or total_amount changes
    IF OLD.customer_id <> NEW.customer_id OR OLD.total_amount <> NEW.total_amount THEN
        -- Get the billing entity of the old customer
        SELECT billing_entity_id INTO old_entity_id
        FROM customers
        WHERE customer_id = OLD.customer_id;

        -- Get the billing entity of the new customer
        SELECT billing_entity_id INTO new_entity_id
        FROM customers
        WHERE customer_id = NEW.customer_id;

        -- Subtract old sale amount from old entity
        UPDATE billing_entities
        SET current_balance = current_balance - OLD.total_amount
        WHERE billing_entity_id = old_entity_id;

        -- Add new sale amount to new entity
        UPDATE billing_entities
        SET current_balance = current_balance + NEW.total_amount
        WHERE billing_entity_id = new_entity_id;
    END IF;
END $$

DELIMITER ;
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- STORED PROCEDURE: Insert_Sale
-- ------------------------------------------------------------------
-- Inserts a new sale record into the 'sales' table.
--
-- It validates:
--   - 'total_amount' must be non-negative
--   - 'invoice_id' must consist of exactly 16 characters
--   - 'invoice_id' in the 'sales' table must be unique
-- ------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE Insert_Sale (
    IN p_customer_id INT,
    IN p_order_date DATE,
    IN p_invoice_id CHAR(16),
    IN p_total_amount DECIMAL(10, 2)
)
BEGIN
    DECLARE invoice_exists INT DEFAULT 0;
    DECLARE invoice_length INT;

    -- Check the length of the 'invoice_id'
    SET invoice_length = CHAR_LENGTH(p_invoice_id);

    -- Check if the 'invoice_id' already exists
    SELECT COUNT(*) INTO invoice_exists
    FROM sales
    WHERE invoice_id = p_invoice_id;

    -- Validate 'invoice_id' length
    IF invoice_length <> 16 THEN
        SELECT 'Error: invoice_id must be exactly 16 characters.' AS result_message;

    -- Validate if 'invoice_id' doesn't duplicates
    ELSEIF invoice_exists > 0 THEN
        SELECT CONCAT('Error: invoice_id "', p_invoice_id, '" already exists.') AS result_message;

    -- Validate 'total_amount'
    ELSEIF p_total_amount < 0.00 THEN
        SELECT 'Error: Total amount cannot be negative.' AS result_message;

    -- Insert if all checks completed and passed
    ELSE
        INSERT INTO sales (customer_id, order_date, invoice_id, total_amount)
        VALUES (p_customer_id, p_order_date, p_invoice_id, p_total_amount);

        SELECT CONCAT('Success: Sale inserted with ID = ', LAST_INSERT_ID()) AS result_message;
    END IF;
END $$

DELIMITER ;
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- Insert into sales using the stored procedure 'Insert_Sale_Record'
-- ------------------------------------------------------------------
-- Linked to the 'customers.customer_id' = 1
CALL Insert_Sale(1, '2025-06-01', 'INV0000000000001', 50.00);
CALL Insert_Sale(1, '2025-06-02', 'INV0000000000002', 63.00);
-- Linked to the 'customers.customer_id' = 2
CALL Insert_Sale(2, '2025-06-03', 'INV0000000000003', 89.00);
CALL Insert_Sale(2, '2025-06-04', 'INV0000000000004', 27.00);

CALL Insert_Sale(3, '2025-06-05', 'INV0000000000005', 103.00);
CALL Insert_Sale(4, '2025-06-06', 'INV0000000000006', 37.00);
CALL Insert_Sale(5, '2025-06-07', 'INV0000000000007', 84.00);
CALL Insert_Sale(6, '2025-06-08', 'INV0000000000008', 101.00);
CALL Insert_Sale(7, '2025-06-09', 'INV0000000000009', 66.00);
CALL Insert_Sale(8, '2025-06-10', 'INV0000000000010', 108.00);

SELECT * FROM sales;

-- Examine the changes on the 'current_balance' fields in the
-- billing_entities table, made by the related AFTER INSERT trigger.
-- All of the current balances were 0 at the beginning.
SELECT * FROM billing_entities;
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- STORED PROCEDURE: Update_Sale_Total
-- ------------------------------------------------------------------
--   Updates the 'total_amount' of a sale by summing up
--   the related 'sale_details.total_price'.
-- ------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE Update_Sale_Total (
    IN p_sale_id INT
)
BEGIN
    DECLARE v_total DECIMAL(10,2);

    -- Calculate 'total_price' from related sale_details
    SELECT SUM(total_price) INTO v_total
    FROM sale_details
    WHERE sale_id = p_sale_id;

    -- If result is NULL, set it to 0 since the total_amount field has NOT NULL constraint
    IF v_total IS NULL THEN
        SET v_total = 0.00;
    END IF;

    -- Update the sale record
    UPDATE sales
    SET total_amount = v_total
    WHERE sale_id = p_sale_id;
END $$

DELIMITER ;
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- SALE DETAILS TABLE
-- ------------------------------------------------------------------
-- Stores details for each sale, such as product, quantity, and pricing information.
-- ------------------------------------------------------------------
CREATE TABLE sale_details (
    sale_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL, -- Assigned automatically by the related before triggers
    total_price DECIMAL(10, 2) NOT NULL, -- Calculated automatically by the related before triggers

    FOREIGN KEY (sale_id) REFERENCES sales(sale_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- TRIGGERS TO ENFORCE PRODUCT PRICE AND CALCULATE 'total_price' IN
-- THE sale_details TABLE
-- ------------------------------------------------------------------
-- Purpose:
--   - On INSERT: Ensures 'unit_price' matches the current product price.
--
--   - On INSERT/UPDATE: Ensures 'total_price' is always calculated as:
--       quantity × unit_price.
--
--   - Prevents manual entry errors and keeps pricing consistent.
-- ------------------------------------------------------------------
DELIMITER $$

-- Trigger: BEFORE INSERT
CREATE TRIGGER trigger_sale_details_before_insert
BEFORE INSERT ON sale_details
FOR EACH ROW
BEGIN
    -- Set unit_price from the current product record
    SET NEW.unit_price = (
        SELECT unit_price
        FROM products
        WHERE product_id = NEW.product_id
    );

    -- Calculate total_price
    SET NEW.total_price = NEW.quantity * NEW.unit_price;
END $$

-- ----------

-- Trigger: BEFORE UPDATE
CREATE TRIGGER trigger_sale_details_before_update
BEFORE UPDATE ON sale_details
FOR EACH ROW
BEGIN
    -- Recalculate total_price
    SET NEW.total_price = NEW.quantity * NEW.unit_price;
END $$

DELIMITER ;
-- ------------------------------------------------------------------

-- ----------------------------------------------------------------------------------
-- STORED PROCEDURE: Insert_Sale_Detail
-- ----------------------------------------------------------------------------------
-- Inserts a sale detail record for an existing sale.
--  - Validates sufficient stock of the product.
--  - Decreases the product's stock after successful insertion.
--
-- Notes:
--  - 'unit_price' and 'total_price' are set by BEFORE INSERT trigger on 'sale_details'.
--  - Does NOT update the 'sales.total_amount' field; must be handled separately.
-- ----------------------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE Insert_Sale_Detail (
    IN p_sale_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;

    -- Start a transaction
    START TRANSACTION;

    -- Lock the product row and get stock
    SELECT stock_quantity INTO v_stock
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    -- Validate stock availability
    IF v_stock < p_quantity THEN
        ROLLBACK;
        SELECT CONCAT('Error: Insufficient stock. Available: ', v_stock) AS result_message;
    ELSE
        -- Insert sale detail
        INSERT INTO sale_details (sale_id, product_id, quantity)
        VALUES (p_sale_id, p_product_id, p_quantity);

        -- Decrease product stock
        UPDATE products
        SET stock_quantity = stock_quantity - p_quantity
        WHERE product_id = p_product_id;

        COMMIT;
        SELECT 'Success: Sale detail inserted and stock updated.' AS result_message;
    END IF;
END $$

DELIMITER ;
-- ------------------------------------------------------------------

-- ---------------------------------------------------------------
-- Insert 20 sale detail records using the 'Insert_Sale_Detail' SP
-- Each sale (from sale_id 1 to 10) receives exactly 2 sale_detail
-- rows for examining the effects of the related triggers.
-- ---------------------------------------------------------------
CALL Insert_Sale_Detail(1, 9, 1);  -- unit_price: 11, total: 11
CALL Insert_Sale_Detail(1, 5, 3);  -- unit_price: 13, total: 39

CALL Insert_Sale_Detail(2, 4, 1);  -- unit_price: 18, total: 18
CALL Insert_Sale_Detail(2, 3, 5);  -- unit_price: 9, total: 45

CALL Insert_Sale_Detail(3, 1, 1);  -- unit_price: 19, total: 19
CALL Insert_Sale_Detail(3, 10, 4); -- unit_price: 21, total: 84

CALL Insert_Sale_Detail(4, 2, 1);  -- unit_price: 9, total: 9
CALL Insert_Sale_Detail(4, 7, 1);  -- unit_price: 18, total: 18

CALL Insert_Sale_Detail(5, 8, 2);  -- unit_price: 14, total: 28
CALL Insert_Sale_Detail(5, 6, 5);  -- unit_price: 15, total: 75

CALL Insert_Sale_Detail(6, 3, 1);  -- unit_price: 9, total: 9
CALL Insert_Sale_Detail(6, 4, 2);  -- unit_price: 14, total: 28

CALL Insert_Sale_Detail(7, 6, 3);  -- unit_price: 12, total: 36
CALL Insert_Sale_Detail(7, 1, 4);  -- unit_price: 12, total: 48

CALL Insert_Sale_Detail(8, 10, 3); -- unit_price: 15, total: 45
CALL Insert_Sale_Detail(8, 8, 4);  -- unit_price: 14, total: 56

CALL Insert_Sale_Detail(9, 5, 2);  -- unit_price: 16, total: 32
CALL Insert_Sale_Detail(9, 7, 3);  -- unit_price: 12, total: 36

CALL Insert_Sale_Detail(10, 2, 5); -- unit_price: 12, total: 60
CALL Insert_Sale_Detail(10, 9, 4); -- unit_price: 12, total: 48

SELECT * FROM sale_details;
-- ------------------------------------------------------------------


-- ------------------------------------------------------------------
-- PAYMENTS TABLE
-- ------------------------------------------------------------------
-- Stores payments made by billing entities toward their balances.
--
-- - Each payment is linked to a billing entity (payer).
-- - 'method' indicates how the payment was made (cash, bank transfer).
-- - 'reference_code' is optional, useful for matching external records.
-- ------------------------------------------------------------------
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    billing_entity_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    method VARCHAR(50), -- Optional: cash, credit card, EFT
    reference_code VARCHAR(50), -- Optional: for linking to bank records
    notes TEXT, -- Optional: internal comments or payment description

    FOREIGN KEY (billing_entity_id) REFERENCES billing_entities(billing_entity_id)
);
-- ------------------------------------------------------------------

-- ----------------------------------------------------------------------------------
-- TRIGGER: trigger_payments_after_insert
-- ----------------------------------------------------------------------------------
-- Reduces the 'current_balance' of a billing entity when a payment is recorded.
-- ----------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER trigger_payments_after_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    UPDATE billing_entities
    SET current_balance = current_balance - NEW.amount
    WHERE billing_entity_id = NEW.billing_entity_id;
END $$

-- ----------------------------------------------------------------------------------
-- TRIGGER: trigger_payments_after_delete
-- ----------------------------------------------------------------------------------
-- Adds the amount payment back to balance.
-- ----------------------------------------------------------------------------------
CREATE TRIGGER trigger_payments_after_delete
AFTER DELETE ON payments
FOR EACH ROW
BEGIN
    UPDATE billing_entities
    SET current_balance = current_balance + OLD.amount
    WHERE billing_entity_id = OLD.billing_entity_id;
END $$

-- ----------------------------------------------------------------------------------
-- TRIGGER: trigger_payments_after_update
-- ----------------------------------------------------------------------------------
-- Adjusts the balance when a payment is modified (when 'amount' or 'billing_entity' changed).
-- ----------------------------------------------------------------------------------
CREATE TRIGGER trigger_payments_after_update
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    -- Revert OLD payment from OLD entity
    UPDATE billing_entities
    SET current_balance = current_balance + OLD.amount
    WHERE billing_entity_id = OLD.billing_entity_id;

    -- Apply NEW payment to NEW entity
    UPDATE billing_entities
    SET current_balance = current_balance - NEW.amount
    WHERE billing_entity_id = NEW.billing_entity_id;
END $$

DELIMITER ;
-- ----------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------
-- STORED PROCEDURE: Insert_Payment
-- ----------------------------------------------------------------------------------
-- Inserts a new payment record linked to a billing entity.
--
-- Features:
--   - Validates that the payment amount is positive.
--   - Automatically records the current date.
--
-- Related Triggers:
--   The AFTER INSERT trigger on 'payments' will subtract the payment amount
--   from the billing entity's 'current_balance'.
-- ----------------------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE Insert_Payment (
    IN p_billing_entity_id INT,
    IN p_amount DECIMAL(10,2),
    IN p_method VARCHAR(50),
    IN p_reference_code VARCHAR(50),
    IN p_notes TEXT
)
BEGIN
    -- Validate positive amount
    IF p_amount <= 0 THEN
        SELECT 'Error: Payment amount must be greater than zero.' AS result_message;
    ELSE
        INSERT INTO payments (
            billing_entity_id,
            payment_date,
            amount,
            method,
            reference_code,
            notes
        )
        VALUES (
            p_billing_entity_id,
            CURDATE(), -- current date
            p_amount,
            p_method,
            p_reference_code,
            p_notes
        );

        SELECT CONCAT('Success: Payment inserted with ID = ', LAST_INSERT_ID()) AS result_message;
    END IF;
END $$

DELIMITER ;
-- ----------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------
-- STORED PROCEDURES TO RETRIEVE
-- ----------------------------------------------------------------------------------
-- Get all customers with their billing entities' trade name
DELIMITER $$
CREATE PROCEDURE Get_Customers_With_Billing_Entities()
BEGIN
    SELECT 
        c.customer_id,
        c.display_name AS customer_name,
        b.trade_name AS billing_entity
    FROM customers c
    JOIN billing_entities b ON c.billing_entity_id = b.billing_entity_id;
END $$
DELIMITER ;

CALL Get_Customers_With_Billing_Entities();


-- Get sales with customer and billing entity info
DELIMITER $$
CREATE PROCEDURE Get_Sales_With_Customer_And_Entity()
BEGIN
    SELECT 
        s.sale_id,
        s.order_date,
        s.total_amount,
        c.display_name AS customer,
        b.trade_name AS billing_entity
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN billing_entities b ON c.billing_entity_id = b.billing_entity_id;
END $$
DELIMITER ;

CALL Get_Sales_With_Customer_And_Entity();


-- Retrieve all sale lines with product info
DELIMITER $$
CREATE PROCEDURE Get_Sale_Details_With_Products()
BEGIN
    SELECT 
        sd.sale_id,
        p.display_name AS product,
        sd.quantity,
        sd.unit_price,
        sd.total_price
    FROM sale_details sd
    JOIN products p ON sd.product_id = p.product_id;
END $$
DELIMITER ;

CALL Get_Sale_Details_With_Products();


-- Get all customers with sales
-- Sales may be NULL if there aren't any 
DELIMITER $$
CREATE PROCEDURE Get_Customers_And_Their_Sales()
BEGIN
    SELECT 
        c.display_name,
        s.sale_id,
        s.order_date,
        s.total_amount
    FROM customers c
    LEFT JOIN sales s ON c.customer_id = s.customer_id;
END $$
DELIMITER ;

CALL Get_Customers_And_Their_Sales();


-- Get total amount of sales per customer
DELIMITER $$
CREATE PROCEDURE Get_Total_Sales_Per_Customer()
BEGIN
    SELECT 
        c.display_name,
        SUM(s.total_amount) AS total_sales
    FROM customers c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.display_name;
END $$
DELIMITER ;

CALL Get_Total_Sales_Per_Customer();


-- Get units sold per product
DELIMITER $$
CREATE PROCEDURE Get_Total_Units_Sold_Per_Product()
BEGIN
    SELECT 
        p.display_name,
        SUM(sd.quantity) AS total_units_sold
    FROM sale_details sd
    JOIN products p ON sd.product_id = p.product_id
    GROUP BY p.display_name;
END $$
DELIMITER ;

CALL Get_Total_Units_Sold_Per_Product();


-- Get all customers who have never made a sale
DELIMITER $$
CREATE PROCEDURE Get_Customers_With_No_Sales()
BEGIN
    SELECT 
        c.display_name
    FROM customers c
    LEFT JOIN sales s ON c.customer_id = s.customer_id
    WHERE s.sale_id IS NULL;
END $$
DELIMITER ;

CALL Get_Customers_With_No_Sales();


-- Get current balance of each billing entity
DELIMITER $$
CREATE PROCEDURE Get_Billing_Entity_Balances()
BEGIN
    SELECT 
        trade_name,
        current_balance
    FROM billing_entities;
END $$
DELIMITER ;

CALL Get_Billing_Entity_Balances();


-- Get payment records of a specific billing entity by trade name
DELIMITER $$
CREATE PROCEDURE Get_Payments_For_Entity (
    IN p_trade_name VARCHAR(255)
)
BEGIN
    SELECT 
        p.payment_date,
        p.amount,
        p.method,
        p.reference_code
    FROM payments p
    JOIN billing_entities b ON p.billing_entity_id = b.billing_entity_id
    WHERE b.trade_name = p_trade_name;
END $$
DELIMITER ;

CALL Get_Payments_For_Entity('Yildizlar Gida AS');