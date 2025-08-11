 DataAnalytics-Assessment

 Introduction
This repository contains SQL answers to the Data Analytics Assessment. The SQL answers contain queries for various business scenarios to run against the `adashi_staging` database. These queries demonstrate accuracy, efficiency and readability of the SQL query statements.

 Explanations per Question

 Q1: Identify High-Value Customers with Multiple Products
- Goal was to triangulate customers who hold at least one funded savings plan and at least one funded investment plan.
- Method 
  - Joined tables for `users_customuser`, `savings_savingsaccount`, and `plans_plan`.
  - Used a conditional aggregation on the join statement to count the savings and investment plans based on flags.
    - the investment plan must either be a fixed investment or a managed portfolio
  - Returned only customers with savings and investment plans, filtered on customers with both product types.
  - Summed the confirmed savings deposit values for total deposits.
- Output: This provided a list of cross-selling opportunities sorted by total deposits.

 Q2: Transaction Frequency Analysis
- Goal was to categorize customers on Average Monthly Transaction Frequency.
- Method 
  - Quantified transaction counts per customer per month from the savings_savingsaccount table.
  - Reported frequency of High, Medium, Low using CASE statements.
  - Used GROUP BY to aggregate results into daily transaction frequency per customer monthly and show customer counts against transactional frequency.
 Q3: Account Inactivity Alert
- Purpose: Determine active accounts (savings or investments) with no transactions in the past 365 days.
- Methodology:
  - First joined `plans_plan` to `savings_savingsaccount` to obtain last transaction dates per plan.
  - Filtered down to plans with no transactions within the past year.
  - Measured how many days of inactivity and narrowed down and labeled the plan types to Savings or Investment. 

 Q4: Customer Lifetime Value
- Purpose: Estimate customer lifetime value by volume transactions and account age.
- Methodology: 
  - Counted tenure in months since signing up for the account.
  - Counted how many total transactions and calculated average profit per transaction profit (0.1% of transaction value).
  - Calculated CLV based on a formula that projected yearly profit based on monthly transaction rates.
  - Sorted customers from highest to lowest projected CLV.
   - By using `GREATEST(1, ...)` we prevented division by zero to reduce dangerous run times and created stability.  

 Challenges and Solutions
- The first round of queries either returned no results or timed out because of extensive joins and filters. I simplified the query by leveraging conditional aggregation, and better handling by using clearer investment/savings plan flags.
- Performance: Joining large tables made for slow queries. Used efficient indexing and filtered down faster with subqueries to improve speed.
- Data Understanding: Required understanding of many different tables’ columns and business logic.
- Dates: Navigating date differences, and null safety was conducted cautiously to prevent runtime errors and to ensure that tenure and inactivity were accurate calculations.
