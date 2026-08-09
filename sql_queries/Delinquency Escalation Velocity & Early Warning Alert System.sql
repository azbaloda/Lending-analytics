-- Delinquency Escalation Velocity & Early Warning Alert System

WITH repayment_transitions AS (
    SELECT 
        r.application_id,
        r.installment_num,
        r.dpd_bucket,
        r.dpd,
        LAG(r.dpd_bucket, 1) OVER (PARTITION BY r.application_id ORDER BY r.installment_num) AS prev_installment_bucket,
        LAG(r.dpd, 1) OVER (PARTITION BY r.application_id ORDER BY r.installment_num) AS prev_installment_dpd
    FROM repayments r
),
escalated_accounts AS (
    SELECT 
        application_id,
        installment_num,
        prev_installment_bucket,
        dpd_bucket AS current_escalated_bucket,
        (dpd - prev_installment_dpd) AS dpd_jump
    FROM repayment_transitions
    WHERE prev_installment_dpd <= 7   AND dpd >= 30
)
SELECT 
    u.state_name,
    u.profession,
    COUNT(DISTINCT e.application_id) AS total_escalated_accounts,
    ROUND(AVG(e.dpd_jump), 1) AS avg_dpd_jump_days,
    DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT e.application_id) DESC) AS risk_rank
FROM escalated_accounts e
JOIN loan_applications a ON e.application_id = a.application_id
JOIN users u ON a.user_id = u.user_id
GROUP BY u.state_name,  u.profession
HAVING total_escalated_accounts >= 3
ORDER BY risk_rank ASC
LIMIT 15;
