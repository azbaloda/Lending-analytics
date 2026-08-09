-- Top 10 Indian States by Disbursal Volume & Average CIBIL

SELECT 
    u.state_name,
    COUNT(DISTINCT u.user_id) AS total_borrowers,
    COUNT(a.application_id) AS total_applications,
    COUNT(CASE WHEN a.current_stage = 'DISBURSED' THEN a.application_id END) AS disbursed_apps,
    ROUND(COUNT(CASE WHEN a.current_stage = 'DISBURSED' THEN a.application_id END) * 100.0 / COUNT(a.application_id), 2) AS approval_rate_pct,
    ROUND(SUM(a.principal_amount) / 10000000.0, 2) AS total_disbursed_principal_cr,
    ROUND(SUM(a.processing_fee) / 100000.0 ,2) AS total_processing_fee_lakhs,
    ROUND(AVG(u.existing_cibil_score) ,1) AS avg_cibil_score
FROM users u
JOIN loan_applications a ON u.user_id = a.user_id
GROUP BY u.state_name
ORDER BY total_disbursed_principal_cr DESC
LIMIT 10;
