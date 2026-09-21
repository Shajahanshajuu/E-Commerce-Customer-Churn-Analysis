-- Data Cleaning & Standardization
-- Standardize Preferred Login Device
use Ecommerce_Data;
UPDATE Ecommerce_Data
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone';

-- Standardize Preferred Payment Mode
UPDATE Ecommerce_Data
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC';

UPDATE Ecommerce_Data
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD';

-- Impute Missing Values with Mean (Example for Tenure and DaySinceLastOrder)
WITH CalculatedMeans AS (
    SELECT 
        AVG(Tenure) AS AvgTenure,
        AVG(DaySinceLastOrder) AS AvgDaySinceLastOrder
    FROM Ecommerce_Data
)
UPDATE Ecommerce_Data
SET 
    Tenure = COALESCE(Tenure, (SELECT AvgTenure FROM CalculatedMeans)),
    DaySinceLastOrder = COALESCE(DaySinceLastOrder, (SELECT AvgDaySinceLastOrder FROM CalculatedMeans));
    
    -- Key Churn Metrics
    -- Overall Churn Rate
SELECT 
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS TotalChurned,
    ROUND(CAST(SUM(Churn) AS FLOAT) / COUNT(*) * 100, 2) AS ChurnRatePercentage
FROM Ecommerce_Data;

-- Churn Rate by Preferred Order Category
SELECT 
    PreferedOrderCat,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(CAST(SUM(Churn) AS FLOAT) / COUNT(*) * 100, 2) AS ChurnRatePercentage
FROM Ecommerce_Data
GROUP BY PreferedOrderCat
ORDER BY ChurnRatePercentage DESC;

-- Churn Rate by Preferred Payment Mode
SELECT 
    PreferredPaymentMode,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(CAST(SUM(Churn) AS FLOAT) / COUNT(*) * 100, 2) AS ChurnRatePercentage
FROM Ecommerce_Data
GROUP BY PreferredPaymentMode
ORDER BY ChurnRatePercentage DESC;

-- Customer Service & Engagement Insights

-- Impact of Customer Complaints on Churn
SELECT 
    Complain,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(CAST(SUM(Churn) AS FLOAT) / COUNT(*) * 100, 2) AS ChurnRatePercentage
FROM Ecommerce_Data
GROUP BY Complain;

-- App Engagement vs Churn Rate
SELECT 
    HourSpendOnApp,
    COUNT(*) AS TotalCustomers,
    SUM(Churn) AS ChurnedCustomers,
    ROUND(CAST(SUM(Churn) AS FLOAT) / COUNT(*) * 100, 2) AS ChurnRatePercentage
FROM Ecommerce_Data
WHERE HourSpendOnApp IS NOT NULL
GROUP BY HourSpendOnApp
ORDER BY HourSpendOnApp ASC;