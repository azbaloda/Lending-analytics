-- Re-engaged Borrowers (Abandonment Recovery Analysis)	
	
WITH user_app_history AS (	
    SELECT 	
        a1.user_id,	
        a1.application_id AS first_abandoned_app,	
        a1.current_stage AS first_stage,	
        a1.created_at AS first_app_date,	
        a2.application_id AS second_disbursed_app,	
        a2.principal_amount AS recovered_principal_amt,	
        a2.created_at AS second_app_date,	
        TIMESTAMPDIFF(DAY, a1.created_at, a2.created_at) AS days_to_reengage	
    FROM loan_applications a1	
    JOIN loan_applications a2 ON a1.user_id = a2.user_id	
    WHERE a1.current_stage = 'ABANDONED'	
      AND a2.current_stage = 'DISBURSED'	
      AND a2.created_at > a1.created_at	
)	
SELECT 	
    COUNT(DISTINCT user_id) AS total_reengaged_users,	
    ROUND(SUM(recovered_principal_amt) / 10000000.0, 2) AS recovered_disbursal_volume_cr,	
    ROUND(AVG(days_to_reengage), 1) AS avg_days_to_reengage	
FROM user_app_history;	
