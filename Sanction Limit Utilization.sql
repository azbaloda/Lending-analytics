-- Sanction Limit Utilization (Requested vs Approved Max Limit)

SELECT 
    uw.risk_grade,
    COUNT(a.application_id) AS total_disbursed_loans,
    ROUND(SUM(a.requested_amount) / 10000000.0, 2) AS total_requested_amt_cr,
    ROUND(SUM(uw.approval_max_amount) / 10000000.0, 2) AS total_approved_max_limit_cr,
    ROUND(SUM(a.principal_amount) / 10000000.0, 2) AS actual_principal_disbursed_cr,
    -- Limit Utilization Ratio = Disbursed Principal / Approved Max Limit
    ROUND(SUM(a.principal_amount) * 100.0 / SUM(uw.approval_max_amount), 2) AS limit_utilization_pct
FROM loan_applications a
JOIN underwriting_logs uw ON a.application_id = uw.application_id
WHERE a.current_stage = 'DISBURSED'
GROUP BY uw.risk_grade
ORDER BY limit_utilization_pct DESC;
