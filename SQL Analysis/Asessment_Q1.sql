WITH savers AS (
    SELECT 
        ss.owner_id AS owner_id,
        COUNT(ss.id) AS savers_saver,
        SUM(ss.amount) AS savings
    FROM adashi_staging.savings_savingsaccount ss 
    WHERE ss.amount > 0
    GROUP BY ss.owner_id
),
investors AS (
    SELECT 
        pp.owner_id AS owner_id,
        COUNT(pp.id) AS investors_invest,
        SUM(pp.amount) AS investments
    FROM adashi_staging.plans_plan pp 
    WHERE pp.amount > 0
    GROUP BY pp.owner_id
),
cust_names AS (
    SELECT 
        uc.id AS owner_id,
        CONCAT(uc.first_name, ' ', uc.last_name) AS name
    FROM adashi_staging.users_customuser uc
)
SELECT 
    cn.owner_id,
    cn.name,
    s.savers_saver,
    i.investors_invest,
    ROUND(s.savings + i.investments, 2) AS total_deposits
FROM 
    cust_names cn
JOIN 
    savers s ON cn.owner_id = s.owner_id
JOIN 
    investors i ON cn.owner_id = i.owner_id
ORDER BY 
    total_deposits DESC;
