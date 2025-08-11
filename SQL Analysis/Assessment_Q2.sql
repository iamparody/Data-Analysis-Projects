-- Step 1: Count transactions per customer per month
WITH monthly_transactions AS (
    SELECT 
        owner_id,
        EXTRACT(month from transaction_date) AS month,
        COUNT(*) AS transactions_in_month
    FROM savings_savingsaccount
    GROUP BY owner_id, EXTRACT(month from transaction_date)
),

-- Step 2: Compute average monthly transactions per customer
average_transactions AS (
    SELECT
        owner_id,
        ROUND(AVG(transactions_in_month), 0) AS avg_transactions_per_month
    FROM monthly_transactions
    GROUP BY owner_id
),

-- Step 3: Categorize customers by frequency band
categorized AS (
    SELECT
        owner_id,
        avg_transactions_per_month,
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM average_transactions
)

-- Step 4: Aggregate by frequency category
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_in_band
FROM categorized
GROUP BY frequency_category
ORDER BY customer_count DESC;
