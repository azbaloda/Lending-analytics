-- Monthly Income Bins vs Disbursal Volume & Approval Rate

SELECT 
    CASE 
        WHEN u.monthly_income < 25000 THEN '1. Low Income (< ₹25K)'
        WHEN u.monthly_income BETWEEN 25000 AND 50000 THEN '2. Lower Middle (₹25K - ₹50K)'
        WHEN u.monthly_income BETWEEN 50001 AND 75000 THEN '3. Middle Income (₹50K - ₹75K)'
        WHEN u.monthly_income BETWEEN 75001 AND 100000 THEN '4. Upper Middle (₹75K - ₹100K)'
        WHEN u.monthly_income BETWEEN 100001 AND 150000 THEN '5. High Income (₹100K - ₹150K)'
        ELSE '6. Top Tier (> ₹150K)'
    END AS monthly_income_bin,
    COUNT(DISTINCT l.user_id) AS user_count, 
    COUNT(l.application_id) AS total_applications_count,
    COUNT(CASE WHEN l.current_stage = 'DISBURSED' THEN l.application_id END) AS disbursed_applications_count,
    ROUND(COUNT(CASE WHEN l.current_stage = 'DISBURSED' THEN l.application_id END) * 100.0 / COUNT(l.application_id), 2) AS approval_rate_pct,
    ROUND(SUM(l.principal_amount) / 10000000.0, 2) AS principal_disbursed_amt_cr,
    ROUND(SUM(l.processing_fee) / 100000.0, 2) AS processing_fee_income_lakhs
FROM loan_applications l
LEFT JOIN underwriting_logs ur ON l.application_id = ur.application_id
LEFT JOIN users u ON l.user_id = u.user_id
GROUP BY monthly_income_bin
ORDER BY MIN(u.monthly_income) ASC;
