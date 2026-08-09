-- "What-If" Credit Policy Relaxation Simulation
-- Simulation Scenario: Re-evaluate REJECTED applicants with CIBIL 520-550, 0 overdue, and Income >= 50k

WITH current_portfolio AS (
    SELECT 
        COUNT(a.application_id) AS total_apps,
        SUM(CASE WHEN a.current_stage = 'DISBURSED' THEN 1 ELSE 0 END) AS current_disbursed_apps,
        SUM(a.principal_amount) AS current_disbursed_principal
    FROM loan_applications a
),
policy_simulation AS (
    SELECT 
        a.application_id,
        CASE 
            WHEN uw.risk_grade = 'REJECTED' 
                 AND uw.bureau_cibil_score BETWEEN 520 AND 550
                 AND uw.total_overdue_amount_bureau = 0
                 AND uw.max_dpd_pl_bureau_5yrs <= 10
                 AND u.monthly_income >= 50000
            THEN 1 ELSE 0 
        END AS is_eligible_under_relaxed_policy,
        CASE 
            WHEN uw.risk_grade = 'REJECTED' 
                 AND uw.bureau_cibil_score BETWEEN 520 AND 550
                 AND uw.total_overdue_amount_bureau = 0
                 AND uw.max_dpd_pl_bureau_5yrs <= 10
                 AND u.monthly_income >= 50000
            THEN LEAST(a.requested_amount,  100000.0)
            ELSE 0.0
        END AS simulated_additional_principal
    FROM loan_applications a
    JOIN users u ON a.user_id = u.user_id
    JOIN underwriting_logs uw ON a.application_id = uw.application_id
)
SELECT 
    cp.total_apps,
    cp.current_disbursed_apps,
    ROUND(cp.current_disbursed_principal / 10000000.0, 2) AS current_disbursed_cr,
    SUM(ps.is_eligible_under_relaxed_policy)  AS newly_approved_applicants,
    ROUND(SUM(ps.simulated_additional_principal) / 10000000.0, 2) AS incremental_disbursal_unlocked_cr,
    ROUND((cp.current_disbursed_principal + SUM(ps.simulated_additional_principal)) / 10000000.0, 2) AS projected_new_disbursed_cr
FROM policy_simulation ps
CROSS JOIN current_portfolio cp
GROUP BY cp.total_apps,  cp.current_disbursed_apps,  cp.current_disbursed_principal;
