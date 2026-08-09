# Lending-analytics

## **What is this Project About?** <br>
High-level overview of digital lending personal loan analytics of 100,000+ borrowers, applications, bureau underwriting logs, and repayments.

### **Table Names & Column Definitions:** <br>
**users:** Demographics <br>
columns - user_id, gender, age, state_name, city_tier, education, profession, employment_type, monthly_income, existing_cibil_score <br>
**loan_applications:** Financial & session terms <br>
columns - application_id, user_id, requested_amount, requested_tenure_months, principal_amount, processing_fee, disbursed_amount, yearly_interest_rate_pct, current_stage, status, created_at, updated_at<br>
**underwriting_logs:** Bureau parameters & credit decision engine <br>
columns - log_id, application_id, bureau_cibil_score, total_pl_count_bureau, active_pl_count_bureau, total_current_balance_pl_bureau, is_suit_filed, total_overdue_amount_bureau, max_dpd_pl_bureau, max_dpd_pl_bureau_5yrs, risk_grade, approval_max_amount, approval_max_tenure, offered_interest_rate, calculated_foir, rejection_reason, evaluated_at<br>
**repayments:** Delinquency & installment tracking <br>
columns - repayment_id, application_id, installment_num, due_date, paid_date, due_amount, paid_amount, dpd, dpd_bucket, status<br>

### **📌Problem Statement 1: Application Funnel & Drop-off Analysis** <br>
**Business Need:** In digital personal lending apps, borrowers move through sequential stages (DRAFT →→ KYC →→ CREDIT →→ OFFER →→ DISBURSED). <br>
Product managers need to know where users drop off and how much potential loan revenue is lost at each stage.<br>
**Detailed Problem Statement:** Analyze the volume of loan applications at each funnel stage, calculate the percentage conversion share relative to total top-of-funnel demand, measure requested loan value vs actual disbursed principal, and calculate total upfront processing fee revenue collected.<br>
**Key Metrics Calculated:** Total Application Count, Stage Percentage Share (%), Total Requested Value (₹ Cr), Disbursed Principal Value (₹ Cr), Upfront Processing Fee Income (₹ Lakhs).<br>
**Business Impact:** Identifies conversion friction points (e.g., high drop-offs at KYC or Offer Generation) to optimize onboarding UX.<br>

### **📌 Problem Statement 2: User Re-engagement & Abandonment Recovery Analysis** <br>
**Business Need:** Applicants who abandon a loan application early often return days or weeks later to apply again. Lending companies need to measure how effectively retargeting campaigns recover lost leads.<br>
**Detailed Problem Statement:** Identify unique borrowers who abandoned an initial loan application (current_stage = 'ABANDONED') but subsequently returned and successfully secured a disbursed loan on a later application (current_stage = 'DISBURSED'), calculating the average re-engagement window in days.<br>
**Key Metrics Calculated:** Re-engaged Borrower Count, Recovered Disbursal Volume (₹ Cr), Average Days to Re-engage.<br>
**Business Impact:** Evaluates marketing retargeting campaigns (SMS/WhatsApp nudges) to measure recovered disbursal revenue from abandoned leads.<br>

### **📌 Problem Statement 3: Risk Grade Policy Matrix & Sanction Limit Utilization** <br>
**Business Need:** Risk managers set underwriting risk grades (A+, A, B, C, REJECTED). Risk committees need to evaluate if higher risk grades yield appropriate interest margins and sanction limit utilization.<br>
**Detailed Problem Statement:** Evaluate approval conversion rates, total disbursed principal, upfront fee revenue, average interest rates, and sanction limit utilization (Disbursed Principal / Approved Max Sanction Limit) across Risk Grades.<br>
**Key Metrics Calculated:** Approval Conversion Rate (%), Disbursed Principal (₹ Cr), Fee Income (₹ Lakhs), Average Interest Rate (% p.a.), Sanction Limit Utilization (%).<br>
**Business Impact:** Ensures high-grade borrowers (A+/A) are utilizing their sanctioned credit limits while low-grade borrowers (C) are appropriately risk-priced.<br>

### **📌 Problem Statement 4: Credit Bureau Decline Breakdown & "What-If" Policy Simulation** <br>
**Business Need:** Credit policies decline thousands of applicants. Management wants to know why applicants are rejected and model the financial impact of relaxing specific credit rules. <br>
**Detailed Problem Statement:** Break down all system rejections by policy decline rules (SUIT_FILED, CIBIL_LOW, OVERDUE_HIGH, DPD_HIGH, etc.) with average CIBIL and overdue balances.<br>
Perform a "What-If" Policy Simulation: Re-evaluate rejected applicants with CIBIL 520–550, 0 overdue amount, and monthly income ≥ ₹50,000 to measure how much incremental disbursal volume (₹ Cr) policy relaxation unlocks.<br>
**Key Metrics Calculated:** Rejection Reason Share (%), Average CIBIL per Decline Rule, Newly Eligible Applicants Count, Incremental Disbursal Volume Unlocked (₹ Cr), Projected New Portfolio Approval Rate (%).<br>
**Business Impact:** Helps risk committees make data-driven policy adjustments to expand loan disbursals without taking unmanageable default risk.<br>

### **📌 Problem Statement 5: Demographics & Regional Risk Distribution**
**Business Need:** Lending risk varies across geographical states, city tiers, and income levels. Operations teams need to identify top-performing states and demographic cohorts.<br>
**Detailed Problem Statement:** Analyze loan application volumes, approval rates, total disbursed principal, processing fee revenue, and average CIBIL scores across the top 10 Indian States and 6 Monthly Income Bins (<₹25K to >₹150K).<br>
**Key Metrics Calculated:** State Borrower Count, State Approval Rate (%), Total Disbursed Principal (₹ Cr), Income Bin Approval Rate (%), Processing Fee Revenue (₹ Lakhs).<br>
**Business Impact:** Guides geographic expansion, localized marketing spend, and tier-specific credit risk cutoffs.<br>

### **📌 Problem Statement 6: Repayment Delinquency Matrix & Overdue Balance Distribution**
**Business Need:** Portfolio credit risk is measured by tracking how many EMI installments fall into delinquency buckets (dpd_1_to_7 up to dpd_more_than_180).<br>
**Detailed Problem Statement:** Aggregate total scheduled EMI installments, calculate total due amount vs actual paid amount, and determine the net outstanding overdue balance across standard DPD delinquency buckets.<br>
**Key Metrics Calculated:** Installment Count per DPD Bucket, Percentage Share (%), Total Scheduled Due (₹ Lakhs), Total Collected Paid (₹ Lakhs), Net Outstanding Overdue (₹ Lakhs).<br>
**Business Impact:** Provides finance & collection teams with an accurate view of collection efficiency and outstanding credit risk exposure.<br>

### **📌 Problem Statement 7: Delinquency Escalation Velocity (Early Warning Risk Alerts)**
**Business Need:** Collections teams need early warning indicators before a borrower defaults completely. Detecting rapid DPD escalation allows early intervention.<br>
**Detailed Problem Statement:** Use MySQL Window Functions (LAG()) to track installment-over-installment payment behavior, identifying accounts that were on-time or low DPD (≤7 DPD) in the previous installment but experienced a sharp delinquency jump to ≥30 DPD in the current installment. Rank professions and states by their Early Warning Risk Index.<br>
**Key Metrics Calculated:** Escalated Accounts Count, Average DPD Jump (Days), Risk Escalation Rank.<br>
**Business Impact:** Enables collections to trigger proactive payment reminders before loans enter 90+ DPD Non-Performing Asset (NPA) status.<br>

### **📌 Problem Statement 8: RFM (Recency, Frequency, Monetary) Customer Segmentation**
**Business Need:** Marketing and product teams want to identify high-value repeat borrowers vs churned or at-risk customers to run targeted re-engagement campaigns.<br>
**Detailed Problem Statement:** Apply MySQL Windowing functions (NTILE(5) OVER ()) to score all 100,000 borrowers from 1 to 5 on Recency (days since last app), Frequency (application count), and Monetary value (total principal disbursed). Combine scores to segment borrowers into Personas (VIP Champion, Loyal Core, At-Risk, Churned).<br>
**Key Metrics Calculated:** Recency Days, Frequency App Count, Total Disbursed INR, RFM Composite Score (3 to 15), Customer Persona Group.<br>
**Business Impact:** Tailors marketing offers (e.g., pre-approved top-up loans for Loyal Core, special interest rate discounts for VIP Champions).<br>

### **📌 Problem Statement 9: Turnaround Processing Time & SLA Breach Analysis**
**Business Need:** Turnaround time (TAT) is critical in digital lending. If evaluation takes too long, users get frustrated and abandon the application.<br>
**Detailed Problem Statement:** Calculate the processing turnaround time in hours (TIMESTAMPDIFF(HOUR, created_at, updated_at)) for every application across funnel stages. Measure SLA breaches (>24 hours) and determine their impact on application abandonment.<br>
**Key Metrics Calculated:** Average Processing Hours per Stage, Total SLA Breaches Count (>24 hrs), SLA Breach Percentage (%).<br>
**Business Impact:** Identifies operational bottlenecks in automated credit verification to reduce processing times and lower user abandonment.<br>
