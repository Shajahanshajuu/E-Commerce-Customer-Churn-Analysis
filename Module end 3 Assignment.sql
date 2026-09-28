USE ecomm;

-- Step 1: Create a cleaned copy of the table
DROP TABLE IF EXISTS customer_churn_cleaned;

CREATE TABLE customer_churn_cleaned AS
SELECT 
    CustomerID,
    Churn,
    -- Handle Tenure NULLs using Median (approx. 9)
    COALESCE(Tenure, 9) AS Tenure,
    
    -- Standardize PreferredLoginDevice
    CASE 
        WHEN PreferredLoginDevice IN ('Phone', 'Mobile Phone') THEN 'Mobile Phone'
        WHEN PreferredLoginDevice = 'Computer' THEN 'Computer'
        ELSE 'Mobile Phone' -- Default mode
    END AS PreferredLoginDevice,
    
    CityTier,
    
    -- Handle WarehouseToHome NULLs using Median (approx. 14)
    COALESCE(WarehouseToHome, 14) AS WarehouseToHome,
    
    -- Standardize PreferredPaymentMode
    CASE 
        WHEN PreferredPaymentMode IN ('CC', 'Credit Card') THEN 'Credit Card'
        WHEN PreferredPaymentMode IN ('COD', 'Cash on Delivery') THEN 'Cash on Delivery'
        WHEN PreferredPaymentMode = 'E wallet' THEN 'E-Wallet'
        ELSE PreferredPaymentMode
    END AS PreferredPaymentMode,
    
    Gender,
    
    -- Handle HourSpendOnApp NULLs using Median/Mode (approx. 2)
    COALESCE(HourSpendOnApp, 2) AS HourSpendOnApp,
    
    NumberOfDeviceRegistered,
    
    -- Standardize PreferedOrderCat
    CASE 
        WHEN PreferedOrderCat = 'Mobile' THEN 'Mobile Phone'
        ELSE PreferedOrderCat
    END AS PreferedOrderCat,
    
    SatisfactionScore,
    MaritalStatus,
    NumberOfAddress,
    Complain,
    
    -- Handle OrderAmountHikeFromlastYear NULLs using Median (approx. 15)
    COALESCE(OrderAmountHikeFromlastYear, 15) AS OrderAmountHikeFromlastYear,
    
    -- Handle CouponUsed NULLs using Mode (approx. 1)
    COALESCE(CouponUsed, 1) AS CouponUsed,
    
    -- Handle OrderCount NULLs using Mode (approx. 1)
    COALESCE(OrderCount, 1) AS OrderCount,
    
    -- Handle DaySinceLastOrder NULLs using Median (approx. 3)
    COALESCE(DaySinceLastOrder, 3) AS DaySinceLastOrder,
    
    CashbackAmount
FROM customer_churn;

-- Step 2: Set Primary Key on Cleaned Table
ALTER TABLE customer_churn_cleaned ADD PRIMARY KEY (CustomerID);

-- 1. Overall Churn Rate
SELECT 
    COUNT(*) AS Total_Customers,
    SUM(Churn) AS Churned_Customers,
    ROUND(AVG(Churn) * 100, 2) AS Churn_Rate_Pct
FROM customer_churn_cleaned;

-- 2. Churn Rate by Customer Complaints
SELECT 
    Complain,
    COUNT(*) AS Customer_Count,
    SUM(Churn) AS Churned_Count,
    ROUND(AVG(Churn) * 100, 2) AS Churn_Rate_Pct
FROM customer_churn_cleaned
GROUP BY Complain;

-- 3. Churn Rate by Preferred Order Category
SELECT 
    PreferedOrderCat,
    COUNT(*) AS Total_Orders,
    SUM(Churn) AS Churned_Count,
    ROUND(AVG(Churn) * 100, 2) AS Churn_Rate_Pct
FROM customer_churn_cleaned
GROUP BY PreferedOrderCat
ORDER BY Churn_Rate_Pct DESC;

-- 4. Churn Rate by Tenure Buckets
SELECT 
    CASE 
        WHEN Tenure <= 2 THEN '0-2 Months (New)'
        WHEN Tenure BETWEEN 3 AND 12 THEN '3-12 Months (Mid-term)'
        ELSE '12+ Months (Loyal)'
    END AS Tenure_Group,
    COUNT(*) AS Total_Customers,
    SUM(Churn) AS Churned_Customers,
    ROUND(AVG(Churn) * 100, 2) AS Churn_Rate_Pct
FROM customer_churn_cleaned
GROUP BY Tenure_Group
ORDER BY Churn_Rate_Pct DESC;