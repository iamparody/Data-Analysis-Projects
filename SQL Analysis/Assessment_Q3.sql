-- Q3: Account Inactivity Alert
-- Goal: Find active plans (savings or investment) with no inflow transactions in the last 365 days
-- Approach:
-- 1. Consider only active plans (assumed by status_id or is_deleted flags if available)
-- 2. Get the last transaction date per plan from savings_savingsaccount (inflow transactions)
-- 3. Filter plans with no transaction in the last 365 days or no transactions at all
-- 4. Calculate inactivity_days as days since last transaction (or from plan creation if no transactions)
-- 5. Label plan type as 'Savings' or 'Investment' based on is_fixed_investment or is_managed_portfolio flags

WITH last_txn AS (
    SELECT 
        plan_id,
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    GROUP BY plan_id
),
active_plans AS (
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        CASE 
            WHEN COALESCE(p.is_fixed_investment, 0) = 1 OR COALESCE(p.is_managed_portfolio, 0) = 1 THEN 'Investment'
            ELSE 'Savings'
        END AS type,
        COALESCE(l.last_transaction_date, p.created_on) AS last_transaction_date
    FROM plans_plan p
    LEFT JOIN last_txn l ON p.id = l.plan_id
    WHERE p.is_deleted = 0  
      AND p.amount > 0      -- only funded plans
)

SELECT 
    plan_id,
    owner_id,
    type,
    DATE(last_transaction_date) AS last_transaction_date,
    DATEDIFF(CURRENT_DATE, DATE(last_transaction_date)) AS inactivity_days
FROM active_plans
WHERE last_transaction_date <= CURRENT_DATE - INTERVAL 365 DAY
ORDER BY inactivity_days DESC;
