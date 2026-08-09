-- Risk Grade Portfolio Yield & Processing Fee Revenue

WITH grade_metrics AS (
    SELECT 
        uw.risk_grade,
        COUNT(a.application_id) AS total_applications,
        COUNT(CASE WHEN a.current_stage = 'DISBURSED' THEN a.application_id END) AS disbursed_applications,
        SUM(a.principal_amount) AS total_principal_disbursed,
        SUM(a.processing_fee) AS total_processing_fee,
        AVG(CASE WHEN a.current_stage = 'DISBURSED' THEN a.yearly_interest_rate_pct END) AS avg_interest_rate
    FROM underwriting_logs uw
    JOIN loan_applications a ON uw.application_id = a.application_id
    GROUP BY uw.risk_grade
)
SELECT 
    risk_grade,
    total_applications,
    disbursed_applications,
    ROUND(disbursed_applications * 100.0 / total_applications, 2) AS approval_conversion_pct,
    ROUND(total_principal_disbursed / 10000000.0, 2) AS disbursed_principal_cr,
    ROUND(total_processing_fee / 100000.0, 2) AS processing_fee_income_lakhs,
    ROUND(avg_interest_rate, 2) AS avg_yearly_interest_rate_pct
FROM grade_metrics
ORDER BY 
    CASE risk_grade
        WHEN 'A+' THEN 1
        WHEN 'A' THEN 2
        WHEN 'B' THEN 3
        WHEN 'C' THEN 4
        ELSE 5
    END;
