WITH savings_customers AS (
    SELECT DISTINCT owner_id
    FROM plans_plan
    WHERE COALESCE(is_fixed_investment, 0) = 0 
      AND COALESCE(is_managed_portfolio, 0) = 0
      AND amount > 0
),
investment_customers AS (
    SELECT DISTINCT owner_id
    FROM plans_plan
    WHERE (COALESCE(is_fixed_investment, 0) = 1 
       OR COALESCE(is_managed_portfolio, 0) = 1)
       AND amount > 0
),
qualified_customers AS (
    SELECT s.owner_id
    FROM savings_customers s
    INNER JOIN investment_customers i ON s.owner_id = i.owner_id
)
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    -- Count of funded savings plans
    (SELECT COUNT(DISTINCT p.id)
     FROM plans_plan p
     WHERE p.owner_id = u.id
       AND COALESCE(p.is_fixed_investment, 0) = 0 
       AND COALESCE(p.is_managed_portfolio, 0) = 0
       AND p.amount > 0) AS savings_count,
    -- Count of funded investment plans
    (SELECT COUNT(DISTINCT p.id)
     FROM plans_plan p
     WHERE p.owner_id = u.id
       AND (COALESCE(p.is_fixed_investment, 0) = 1 OR COALESCE(p.is_managed_portfolio, 0) = 1)
       AND p.amount > 0) AS investment_count,
    -- Total confirmed deposit amount (successful deposit transactions only)
    COALESCE(SUM(s.confirmed_amount), 0) AS total_deposits
FROM users_customuser u
LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id 
    AND s.transaction_status = 'successful' 
    AND s.transaction_type_id = 1
    AND s.confirmed_amount > 0
WHERE u.id IN (SELECT owner_id FROM qualified_customers)
GROUP BY u.id, u.name
ORDER BY total_deposits DESC;
