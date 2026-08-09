-- RFM (Recency, Frequency, Monetary) Customer Segmentation

WITH user_behavior AS (
    SELECT 
        u.user_id,
        DATEDIFF('2025-12-31',MAX(a.created_at)) AS recency_days,
        COUNT(a.application_id) AS frequency_apps,
        SUM(CASE WHEN a.current_stage = 'DISBURSED' THEN a.principal_amount ELSE 0 END) AS total_monetary_val
    FROM users u
    JOIN loan_applications a ON u.user_id = a.user_id
    GROUP BY u.user_id
),
rfm_scores AS (
    SELECT 
        user_id,
        recency_days,
        frequency_apps,
        total_monetary_val,
        NTILE(5) OVER (ORDER BY recency_days ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency_apps DESC) AS f_score,
        NTILE(5) OVER (ORDER BY total_monetary_val DESC) AS m_score 
    FROM user_behavior
)
SELECT 
    user_id,
    recency_days,
    frequency_apps,
    FORMAT(total_monetary_val, 0) AS total_disbursed_principal_inr,
    r_score,  f_score,  m_score,
    (r_score + f_score + m_score) AS total_rfm_score,
    CASE 
        WHEN (r_score + f_score + m_score) >= 13 THEN 'VIP / High Value Champion'
        WHEN (r_score + f_score + m_score) BETWEEN 10 AND 12 THEN 'Loyal Core Borrower'
        WHEN (r_score + f_score + m_score) BETWEEN 7 AND 9 THEN 'At-Risk / Needs Re-engagement'
        ELSE 'Low Engagement / Churned'
    END AS customer_persona
FROM rfm_scores
ORDER BY total_rfm_score DESC
LIMIT 20;
