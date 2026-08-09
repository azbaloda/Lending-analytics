
-- Stage-wise (Funnel-conversion)

WITH funnel_summary AS (
    SELECT 
        current_stage,
         COUNT(distinct user_id) as user_count, 
        COUNT(application_id) AS total_applications,
        SUM(requested_amount) AS total_requested_amount,
        SUM(principal_amount) AS total_principal_disbursed,
        SUM(processing_fee) AS total_processing_fee
    FROM loan_applications
    GROUP BY current_stage
),
overall AS (
    SELECT COUNT(*) AS total_apps FROM loan_applications
)
SELECT 
    f.current_stage AS funnel_stage,
    f.user_count,
    f.total_applications,
    ROUND(f.total_applications * 100.0 / o.total_apps, 2) AS stage_percentage,
    ROUND(f.total_requested_amount / 10000000.0, 2) AS total_requested_value_cr,
    ROUND(f.total_principal_disbursed / 10000000.0, 2) AS actual_disbursed_principal_cr
FROM funnel_summary f
CROSS JOIN overall o;


-- State-wise [ In a similar way we can write for gender-wise, city-tier wise, employment wise]

select u.state_name, 
   count(distinct l.user_id) as user_count, 
       count(l.application_id) as applications_count,
       count(case when current_stage ='DISBURSED' then l.application_id else null end) as applications_count,
       sum(least(l.requested_amount,ur.approval_max_amount)) as potential_approval_amt, 
   sum(l.principal_amount) as principal_amt
from underwriting_logs ur 
left join loan_applications l 
on ur.application_id = l.application_id
left join users u 
on l.user_id = u.user_id
group by u.state_name;


-- Monthly income 

SELECT 
    CASE 
        WHEN u.monthly_income < 25000 THEN '₹0 - ₹25K'
        WHEN u.monthly_income BETWEEN 25000 AND 50000 THEN '₹25K - ₹50K'
        WHEN u.monthly_income BETWEEN 50001 AND 75000 THEN '₹50K - ₹75K'
        WHEN u.monthly_income BETWEEN 75001 AND 100000 THEN '₹75K - ₹100K'
        WHEN u.monthly_income BETWEEN 100001 AND 150000 THEN '₹100K - ₹150K'
        WHEN u.monthly_income BETWEEN 150001 AND 200000 THEN '₹150K - ₹200K'
        ELSE '> ₹200K'
    END AS monthly_income_bin,
    COUNT(DISTINCT l.user_id) AS user_count, 
    COUNT(l.application_id) AS total_applications_count,
    COUNT(CASE WHEN l.current_stage = 'DISBURSED' THEN l.application_id END) AS disbursed_applications_count,
    ROUND(SUM(LEAST(l.requested_amount, COALESCE(ur.approval_max_amount, 0))) / 10000000.0, 2) AS potential_approval_amt_cr, 
    ROUND(SUM(l.principal_amount) / 10000000.0, 2) AS principal_disbursed_amt_cr
FROM loan_applications l
LEFT JOIN underwriting_logs ur ON l.application_id = ur.application_id
LEFT JOIN users u ON l.user_id = u.user_id
GROUP BY monthly_income_bin;
