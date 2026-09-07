/*
====================================================================
Project: Retail & Fintech Transaction Analytics
Description: End-to-end SQL analysis covering transaction segmentation,
             merchant performance tiering, customer retention, and 
             cross-border payment flow.
====================================================================
*/

-- -----------------------------------------------------------------
-- 1. TRANSACTION SEGMENTATION & HIGH-VALUE FLOW
-- -----------------------------------------------------------------

-- 1.1 Flag all high-value transactions (> 10,000) for FY 2023
SELECT
    transaction_id,
    sender_id,
    recipient_id,
    transaction_amount,
    currency_code
FROM transactions
WHERE transaction_amount > 10000 
  AND EXTRACT(YEAR FROM transaction_date) = 2023;

-- 1.2 Aggregate volume by transaction tier (High Value vs. Regular)
SELECT
    CASE
        WHEN transaction_amount > 10000 THEN 'High Value'
        ELSE 'Regular'
    END AS transaction_category,
    SUM(transaction_amount) AS total_amount,
    COUNT(*) AS transaction_count
FROM transactions
WHERE EXTRACT(YEAR FROM transaction_date) = 2023
GROUP BY 
    CASE
        WHEN transaction_amount > 10000 THEN 'High Value'
        ELSE 'Regular'
    END;

-- 1.3 Cross-border vs Domestic segmentation with amount brackets
SELECT
    CASE
        WHEN t.transaction_amount > 10000 AND s.country_id <> r.country_id THEN 'High Value International'
        WHEN t.transaction_amount > 10000 AND s.country_id = r.country_id THEN 'High Value Domestic'
        WHEN t.transaction_amount <= 10000 AND s.country_id <> r.country_id THEN 'Regular International'
        ELSE 'Regular Domestic'
    END AS transaction_category,
    COUNT(t.transaction_amount) AS transaction_count,
    ROUND(SUM(t.transaction_amount), 2) AS total_volume
FROM transactions t
JOIN users s ON t.sender_id = s.user_id
JOIN users r ON t.recipient_id = r.user_id
WHERE EXTRACT(YEAR FROM t.transaction_date) = 2023
GROUP BY 1
ORDER BY transaction_count DESC;


-- -----------------------------------------------------------------
-- 2. CROSS-BORDER PAYMENT FLOW & CONVERSIONS
-- -----------------------------------------------------------------

-- 2.1 Q1 2024 Domestic vs International split
SELECT
    CASE
        WHEN s.country_id <> r.country_id THEN 'International'
        ELSE 'Domestic'
    END AS transaction_type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(t.transaction_amount), 2) AS total_volume
FROM transactions t
JOIN users s ON t.sender_id = s.user_id
JOIN users r ON t.recipient_id = r.user_id
WHERE t.transaction_date >= '2024-01-01' 
  AND t.transaction_date < '2024-04-01'
GROUP BY 1;

-- 2.2 Top 3 currencies by transaction volume (Trailing 12 Months)
SELECT
    currency_code,
    ROUND(SUM(transaction_amount), 2) AS total_converted
FROM transactions
WHERE transaction_date BETWEEN '2023-05-22' AND '2024-05-22'
GROUP BY currency_code
ORDER BY total_converted DESC
LIMIT 3;


-- -----------------------------------------------------------------
-- 3. MERCHANT PERFORMANCE & KPI TIERING
-- -----------------------------------------------------------------

-- 3.1 Top 10 merchants by total volume received (6-month evaluation)
SELECT
    m.merchant_id,
    m.business_name,
    ROUND(SUM(t.transaction_amount), 2) AS total_received,
    ROUND(AVG(t.transaction_amount), 2) AS average_transaction
FROM merchants m
JOIN transactions t ON t.recipient_id = m.merchant_id
WHERE t.transaction_date BETWEEN '2023-11-01' AND '2024-04-30'
GROUP BY m.merchant_id, m.business_name
ORDER BY total_received DESC
LIMIT 10;

-- 3.2 Merchant tiering based on aggregate settlement volume
SELECT
    m.merchant_id,
    m.business_name,
    ROUND(SUM(t.transaction_amount), 2) AS total_received,
    ROUND(AVG(t.transaction_amount), 2) AS average_transaction,
    CASE
        WHEN SUM(t.transaction_amount) > 50000 THEN 'Excellent'
        WHEN SUM(t.transaction_amount) > 20000 THEN 'Good'
        WHEN SUM(t.transaction_amount) > 10000 THEN 'Average'
        ELSE 'Below Average'
    END AS performance_score
FROM transactions t
JOIN merchants m ON t.recipient_id = m.merchant_id
WHERE t.transaction_date >= '2023-11-01'
  AND t.transaction_date < '2024-05-01'
GROUP BY m.merchant_id, m.business_name
ORDER BY total_received DESC;

-- 3.3 Monthly merchant revenue milestone monitoring ($50k benchmark)
SELECT
    m.merchant_id,
    m.business_name,
    EXTRACT(YEAR FROM t.transaction_date) AS transaction_year,
    EXTRACT(MONTH FROM t.transaction_date) AS transaction_month,
    ROUND(SUM(t.transaction_amount), 2) AS total_transaction_amount,
    CASE
        WHEN SUM(t.transaction_amount) > 50000 THEN 'Exceeded $50,000'
        ELSE 'Did Not Exceed $50,000'
    END AS performance_status
FROM merchants m
JOIN transactions t ON m.merchant_id = t.recipient_id
WHERE t.transaction_date >= '2023-11-01' 
  AND t.transaction_date <= '2024-05-01'
GROUP BY m.merchant_id, m.business_name, transaction_year, transaction_month
ORDER BY m.merchant_id, transaction_year, transaction_month;


-- -----------------------------------------------------------------
-- 4. CUSTOMER RETENTION & BEHAVIORAL ANALYTICS
-- -----------------------------------------------------------------

-- 4.1 High-value senders (Average transaction > 5,000)
SELECT
    u.user_id,
    u.email,
    ROUND(AVG(t.transaction_amount), 2) AS avg_amount
FROM users u
JOIN transactions t ON t.sender_id = u.user_id
WHERE t.transaction_date >= '2023-11-01' 
  AND t.transaction_date < '2024-05-01'
GROUP BY u.user_id, u.email
HAVING AVG(t.transaction_amount) > 5000
ORDER BY avg_amount DESC;

-- 4.2 Top loyalty spender (Trailing 12 Months)
SELECT
    u.user_id,
    u.email,
    u.name,
    ROUND(SUM(t.transaction_amount), 2) AS total_amount
FROM users u
JOIN transactions t ON t.sender_id = u.user_id
WHERE t.transaction_date BETWEEN '2023-05-22' AND '2024-05-22'
GROUP BY u.user_id, u.email, u.name
ORDER BY total_amount DESC
LIMIT 1;

-- 4.3 High-retention users (Active in >= 6 distinct months over 1 year)
SELECT
    u.user_id,
    u.email,
    COUNT(DISTINCT DATE_FORMAT(t.transaction_date, '%Y-%m')) AS active_months_count
FROM users u
JOIN transactions t ON u.user_id = t.sender_id
WHERE t.transaction_date >= '2023-05-01' 
  AND t.transaction_date < '2024-05-01'
GROUP BY u.user_id, u.email
HAVING COUNT(DISTINCT DATE_FORMAT(t.transaction_date, '%Y-%m')) >= 6
ORDER BY active_months_count DESC;

-- 4.4 Monthly transaction volume trend (FY 2023 seasonality)
SELECT
    EXTRACT(YEAR FROM transaction_date) AS transaction_year,
    EXTRACT(MONTH FROM transaction_date) AS transaction_month,
    ROUND(SUM(transaction_amount), 2) AS total_amount,
    COUNT(*) AS total_transactions
FROM transactions
WHERE EXTRACT(YEAR FROM transaction_date) = 2023
GROUP BY transaction_year, transaction_month
ORDER BY transaction_year, transaction_month;
