-- Q2: Transaction Frequency Analysis
-- Goal: Calculate avg transactions per customer per month and categorize customers by frequency
-- Approach:
-- 1. Calculate total transactions per customer
-- 2. Calculate months active (difference between first and last transaction month, minimum 1)
-- 3. Compute average transactions per month = total transactions / months active
-- 4. Categorize customers based on avg transactions per month
-- 5. Group by frequency category and count customers in each group

WITH transaction_summary AS (
    SELECT 
        owner_id,
        COUNT(*) AS total_transactions,
        -- Calculate months active (at least 1 month)
        GREATEST(
            TIMESTAMPDIFF(MONTH, MIN(DATE(transaction_date)), MAX(DATE(transaction_date))) + 1,
            1
        ) AS months_active
    FROM savings_savingsaccount
    GROUP BY owner_id
),
customer_avg AS (
    SELECT 
        owner_id,
        total_transactions,
        months_active,
        total_transactions / months_active AS avg_transactions_per_month
    FROM transaction_summary
),
categorized AS (
    SELECT 
        owner_id,
        avg_transactions_per_month,
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM customer_avg
)

SELECT 
    frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM categorized
GROUP BY frequency_category
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;
