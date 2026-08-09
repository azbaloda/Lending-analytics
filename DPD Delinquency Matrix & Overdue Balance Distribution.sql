-- DPD Delinquency Matrix & Overdue Balance Distribution

SELECT 
    dpd_bucket,
    COUNT(*) AS total_installments,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM repayments), 2) AS pct_of_installments,
    ROUND(SUM(due_amount) / 100000.0, 2) AS total_due_amount_lakhs,
    ROUND(SUM(paid_amount) / 100000.0, 2) AS total_paid_amount_lakhs,
    ROUND(SUM(due_amount - paid_amount) / 100000.0, 2) AS total_outstanding_overdue_lakhs
FROM repayments
GROUP BY dpd_bucket
ORDER BY 
    CASE dpd_bucket
        WHEN 'ON_TIME' THEN 1
        WHEN 'dpd_1_to_7' THEN 2
        WHEN 'dpd_8_to_15' THEN 3
        WHEN 'dpd_15_to_30' THEN 4
        WHEN 'dpd_30_to_60' THEN 5
        WHEN 'dpd_60_to_90' THEN 6
        WHEN 'dpd_90_to_120' THEN 7
        WHEN 'dpd_120_to_150' THEN 8
        WHEN 'dpd_150_to_180' THEN 9
        ELSE 10
    END;
