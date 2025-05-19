-- Q4: Customer Lifetime Value (CLV) Estimation - Optimized Version
-- Calculate account tenure, total transactions, and estimated CLV per customer
-- Assumptions:
--   - profit_per_transaction = 0.1% (0.001) of transaction amount
--   - CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
-- 
-- Steps:
-- 1. Calculate tenure in months since signup, using GREATEST(1, ...) to avoid division by zero
-- 2. Count total transactions per customer
-- 3. Calculate average profit per transaction based on sum of confirmed amounts * 0.001 divided by total transactions
-- 4. Compute estimated CLV as yearly projection based on transaction frequency and profit per transaction
-- 5. Order results by estimated CLV in descending order

SELECT 
    u.id AS customer_id,
    u.name,
    -- Calculate tenure in months since signup, minimum 1 to prevent division by zero
    GREATEST(1, TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) AS tenure_months,
    
    -- Total number of transactions per customer
    COUNT(s.id) AS total_transactions,
    
    -- Estimated CLV calculation:
    -- (Transactions per month) * 12 * (average profit per transaction)
    ROUND(
        (COUNT(s.id) / GREATEST(1, TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()))) * 12 * 
        (SUM(COALESCE(s.confirmed_amount, 0) * 0.001) / COUNT(s.id)),
        2
    ) AS estimated_clv
FROM adashi_staging.users_customuser u
INNER JOIN adashi_staging.savings_savingsaccount s ON u.id = s.owner_id
GROUP BY u.id, u.name, u.date_joined
ORDER BY estimated_clv DESC;
