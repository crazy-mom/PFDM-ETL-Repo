-- --------------------------------------------------------
-- FILE 2: Target System (DW_Financial_Reports) Setup - T-SQL
-- This table holds the data AFTER the bugged ETL run (with the BUG).
-- --------------------------------------------------------

-- 1. Drop the table if it exists (for clean setup)
IF OBJECT_ID('DW_Bills', 'U') IS NOT NULL
    DROP TABLE DW_Bills;

-- 2. Create the Target Table
CREATE TABLE DW_Bills (
    Patient_ID          INT PRIMARY KEY,
    Service_Charge      NUMERIC(10, 3) NOT NULL,
    Admin_Fee           NUMERIC(10, 2) NOT NULL,
    Final_Patient_Bill  NUMERIC(10, 2) -- Target only stores 2 decimals
);

-- 3. Insert the 10 Patient Records (LOADED Data with the BUG)
INSERT INTO DW_Bills (Patient_ID, Service_Charge, Admin_Fee, Final_Patient_Bill) VALUES
(101, 100.000, 5.00, 110.00),
(102, 45.000, 2.50, 49.75),
(103, 78.530, 0.00, 82.45),  -- <<< BUGGED VALUE: Should be 82.46 (truncated/rounded down)
(104, 200.000, 10.00, 220.00),
(105, 15.000, 1.00, 16.75),
(106, 50.000, 0.00, 52.50),
(107, 1.000, 0.00, 1.05),
(108, 9.990, 0.00, 10.48), -- <<< BUGGED VALUE: Should be 10.49 (truncated/rounded down)
(109, 5.000, 0.50, 5.75),
(110, 10.000, 1.00, 11.50);

SELECT 'DW_Bills table created and 10 records inserted (including bugged data).' AS Status;
