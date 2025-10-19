-- --------------------------------------------------------
-- FILE 1: Source System (Hospital_Billing_System) Setup - T-SQL
-- This table holds the RAW data before the ETL transformation.
-- --------------------------------------------------------

-- 1. Drop the table if it exists (for clean setup)
IF OBJECT_ID('Source_Charges', 'U') IS NOT NULL
    DROP TABLE Source_Charges;

-- 2. Create the Source Table
CREATE TABLE Source_Charges (
    Patient_ID      INT PRIMARY KEY,
    Service_Charge  NUMERIC(10, 3) NOT NULL, -- Source allows 3 decimals
    Admin_Fee       NUMERIC(10, 2) NOT NULL
);

-- 3. Insert the 10 Patient Records (RAW Data)
INSERT INTO Source_Charges (Patient_ID, Service_Charge, Admin_Fee) VALUES
(101, 100.000, 5.00),
(102, 45.000, 2.50),
(103, 78.530, 0.00), -- Critical record 1: 78.53 * 1.05 = 82.4565 (Needs rounding test)
(104, 200.000, 10.00),
(105, 15.000, 1.00),
(106, 50.000, 0.00),
(107, 1.000, 0.00),
(108, 9.990, 0.00),  -- Critical record 2: 9.99 * 1.05 = 10.4895 (Needs rounding test)
(109, 5.000, 0.50),
(110, 10.000, 1.00);

-- Note: COMMIT is typically handled automatically in T-SQL when using
-- the EXECUTE command in VS Code, but for completeness, we add it.
COMMIT TRANSACTION;
--This is test comment
SELECT 'Source_Charges table created and 10 records inserted.' AS Status;
