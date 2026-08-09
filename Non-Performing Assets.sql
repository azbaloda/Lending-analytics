-- Non-Performing Assets (NPA / 90+ DPD) Default Loss Rate by Risk Grade

WITH loan_defaults AS (
    SELECT 
        a.application_id,
        uw.risk_grade,
        a.principal_amount,
        SUM(CASE WHEN r.dpd > 90 THEN (r.due_amount - r.paid_amount) ELSE 0 END) AS npa_default_amount
    FROM loan_applications a
    JOIN underwriting_logs uw ON a.application_id = uw.application_id
    JOIN repayments r ON a.application_id = r.application_id
    WHERE a.current_stage = 'DISBURSED'
    GROUP BY a.application_id, uw.risk_grade, a.principal_amount
)
SELECT 
    risk_grade,
    COUNT(application_id) AS total_disbursed_loans,
    ROUND(SUM(principal_amount) / 10000000.0, 2) AS total_principal_cr,
    ROUND(SUM(npa_default_amount) / 100000.0, 2) AS npa_default_loss_lakhs,
    -- NPA Default Rate % = (Default Loss / Total Disbursed Principal) * 100
    ROUND(SUM(npa_default_amount) * 100.0 / SUM(principal_amount), 2) AS npa_default_rate_pct
FROM loan_defaults
GROUP BY risk_grade
ORDER BY npa_default_rate_pct ASC;
