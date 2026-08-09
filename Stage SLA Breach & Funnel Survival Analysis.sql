-- Stage SLA Breach & Funnel Survival Analysis
-- Measure processing turnaround time (in hours) between application creation (created_at) and final decision (updated_at). Identify applications where processing exceeded 24 hours across stages!

WITH stage_processing AS (
    SELECT 
        a.application_id,
        a.current_stage,
        TIMESTAMPDIFF(HOUR, a.created_at, a.updated_at) AS processing_time_hours,
        CASE WHEN TIMESTAMPDIFF(HOUR,  a.created_at,  a.updated_at) > 24 THEN 1 ELSE 0 END AS is_sla_breached
    FROM loan_applications a
)
SELECT 
    current_stage,
    COUNT(application_id) AS total_apps,
    ROUND(AVG(processing_time_hours),  1) AS avg_processing_hours,
    SUM(is_sla_breached) AS total_sla_breaches,
    ROUND(SUM(is_sla_breached) * 100.0 / COUNT(application_id),  2) AS sla_breach_pct
FROM stage_processing
GROUP BY current_stage
ORDER BY avg_processing_hours DESC;
