-- The Transformation Check Query for MSSQL
SELECT
    Patient_ID,
    (Service_Charge * 1.05) + Admin_Fee AS Calculated_Raw_Value,
    Final_Patient_Bill AS Loaded_Value
FROM
    DW_Bills
WHERE
    -- Use the T-SQL ROUND function to model the correct expected value, and find where it mismatches.
    ROUND(((Service_Charge * 1.05) + Admin_Fee), 2) != Final_Patient_Bill;

