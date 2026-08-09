-- Credit Bureau Rejection Reason Breakdown

SELECT 
    rejection_reason,
    COUNT(*) AS total_rejections,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM underwriting_logs WHERE risk_grade = 'REJECTED'), 2) AS pct_of_total_rejections,
    ROUND(AVG(bureau_cibil_score), 1) AS avg_bureau_cibil_score,
    ROUND(AVG(total_overdue_amount_bureau), 2) AS avg_overdue_amount_inr,
    ROUND(AVG(total_current_balance_pl_bureau) / 100000.0, 2) AS avg_active_pl_balance_lakhs
FROM underwriting_logs
WHERE risk_grade = 'REJECTED'
GROUP BY rejection_reason
ORDER BY total_rejections DESC;
