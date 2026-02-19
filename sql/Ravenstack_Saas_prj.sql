create database ravenstack;
use ravenstack;

---------------------------------------
desc support_tickets;
desc feature_usage;
desc subscriptions;
desc churn_events;
desc accounts;
---------------------------------------
select * from accounts;

alter table accounts
modify column account_id varchar(50) not null;
ALTER TABLE accounts
ADD PRIMARY KEY (account_id);

alter table accounts
modify column account_name varchar(20);
alter table accounts
modify column signup_date date;

alter table accounts
modify column industry varchar(25);

alter table accounts
modify column referral_source varchar(15);

alter table accounts
modify column plan_tier varchar(20);

select distinct churn_flag from accounts;
update accounts 
set churn_flag = case when churn_flag= 'True' then 1 else 0 end;
alter table accounts
modify column churn_flag boolean;

update accounts 
set is_trial = case when is_trial= 'True' then 1 else 0 end;
alter table accounts
modify column is_trial boolean;

alter table accounts 
modify column country char(2) not null;
alter table accounts
add constraint check_country_length
check(length(country) = 2);
----------------------------------------
select * from churn_events;
alter table churn_events
modify column account_id varchar(50);

ALTER TABLE churn_events
ADD CONSTRAINT fk_churn_account
FOREIGN KEY (account_id) REFERENCES accounts(account_id);

alter table churn_events
modify column churn_date date;

select distinct is_reactivation from churn_events;
update churn_events
set is_reactivation = case when is_reactivation = 'True' then 1 else 0 end;
alter table churn_events
modify column is_reactivation boolean;

update churn_events
set preceding_downgrade_flag = case when preceding_downgrade_flag = 'True' then 1 else 0 end;
alter table churn_events
modify column preceding_downgrade_flag boolean;

update churn_events
set preceding_upgrade_flag = case when preceding_upgrade_flag = 'True' then 1 else 0 end;
alter table churn_events
modify column preceding_upgrade_flag boolean;

Alter table churn_events
modify column reason_code varchar(20);

update churn_events
set feedback_text = Null 
where feedback_text ='';

select churn_event_id,count(*) as cnt
from churn_events
group by churn_event_id
having count(*) > 1;

select count(*) as null_cnt
from churn_events
where churn_event_id is null;

alter table churn_events
modify column churn_event_id varchar(50) primary key;

alter table churn_events
modify column refund_amount_usd decimal(10,2) default 0;
alter table churn_events
add constraint chk_refund_amnt
check (refund_amount_usd >= 0);
----------------------------------------
desc feature_usage;
select * from feature_usage;
alter table feature_usage
modify column subscription_id varchar(50);
ALTER TABLE feature_usage
ADD CONSTRAINT fk_usage_subscription
FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id);

alter table feature_usage
modify column usage_date date;
select distinct is_beta_feature from feature_usage;
update feature_usage
set is_beta_feature = case when is_beta_feature = 'True' then 1 else 0 end;
alter table feature_usage
modify column is_beta_feature boolean;
alter table feature_usage
modify column feature_name varchar(20);
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT usage_id) AS distinct_ids,
  SUM(usage_id IS NULL) AS null_ids
FROM feature_usage;
SELECT usage_id, COUNT(*) AS cnt
FROM feature_usage
GROUP BY usage_id
HAVING COUNT(*) > 1;
SELECT *
FROM feature_usage
WHERE usage_id = 'U-f42b0a';


alter table feature_usage
modify column usage_id varchar(50);


---------------------------------------------
select * from subscriptions;

alter table subscriptions
modify column subscription_id varchar(50) not null;
ALTER TABLE subscriptions
ADD PRIMARY KEY (subscription_id);

alter table subscriptions
modify column account_id varchar(50);

ALTER TABLE subscriptions
ADD CONSTRAINT fk_sub_account
FOREIGN KEY (account_id) REFERENCES accounts(account_id);

alter table subscriptions
modify column start_date date;
select count(*) from subscriptions where end_date = '';
update subscriptions
set end_date = Null -- represents active subscription
where end_date = '';
alter table subscriptions
add constraint check_dates
check(end_date is Null or end_date >= start_date);
 
alter table subscriptions
modify column end_date date;
alter table subscriptions
modify column plan_tier varchar(20),
modify column billing_frequency varchar(20);
alter table subscriptions
modify column mrr_amount decimal(10,2),
modify column arr_amount decimal(10,2);

update subscriptions
set is_trial = case when is_trial = 'True' then 1 else 0 end;
alter table subscriptions
modify column is_trial boolean;

update subscriptions
set upgrade_flag = case when upgrade_flag = 'True' then 1 else 0 end;
alter table subscriptions
modify column upgrade_flag boolean;

update subscriptions
set downgrade_flag = case when downgrade_flag = 'True' then 1 else 0 end;
alter table subscriptions
modify column downgrade_flag boolean;

update subscriptions
set churn_flag = case when churn_flag = 'True' then 1 else 0 end;
alter table subscriptions
modify column churn_flag boolean;

update subscriptions
set auto_renew_flag = case when auto_renew_flag = 'True' then 1 else 0 end;
alter table subscriptions
modify column auto_renew_flag boolean;

---------------------------------------
select * from support_tickets;

alter table support_tickets
modify column ticket_id varchar(50) not null;
ALTER TABLE support_tickets
ADD PRIMARY KEY (ticket_id);

alter table support_tickets
modify column account_id varchar(50) ;
ALTER TABLE support_tickets
ADD CONSTRAINT fk_ticket_account
FOREIGN KEY (account_id) REFERENCES accounts(account_id);

alter table support_tickets
modify column submitted_at datetime;
alter table support_tickets
modify column closed_at datetime;
alter table support_tickets
modify column priority enum('urgent','medium','high','low');
select distinct escalation_flag from support_tickets;
update support_tickets
set escalation_flag = 0 -- 0 means false
where escalation_flag ='False';
update support_tickets
set escalation_flag = 1 -- 1 means true
where escalation_flag ='True';

alter table support_tickets
modify column escalation_flag boolean;

update support_tickets
set satisfaction_score = Null
where satisfaction_score ='';
alter table support_tickets
modify column satisfaction_score tinyint;

---------------------------------------------
-- For trial subscriptions no MRR Amount

select is_trial,count(*) as cnt
from subscriptions 
where mrr_amount = 0 
group by is_trial;

-- Trial accounts converted to paid accounts
WITH trial_accounts AS (
    SELECT
        account_id,
        MIN(start_date) AS trial_start_date
    FROM subscriptions
    WHERE is_trial = 1
    GROUP BY account_id
),
paid_accounts AS (
    SELECT
        account_id,
        MIN(start_date) AS paid_start_date
    FROM subscriptions
    WHERE is_trial = 0
    GROUP BY account_id
)
SELECT
    COUNT(t.account_id) AS total_trial_accounts,
    COUNT(
        CASE
            WHEN p.paid_start_date > t.trial_start_date
            THEN t.account_id
        END
    ) AS converted_accounts,
    ROUND(
        COUNT(
            CASE
                WHEN p.paid_start_date > t.trial_start_date
                THEN t.account_id
            END
        ) * 100.0 / COUNT(t.account_id),
        2
    ) AS conversion_rate_pct
FROM trial_accounts t
LEFT JOIN paid_accounts p
    ON t.account_id = p.account_id;

-----------------------------------------------
create or replace view account_lifecycle as (
select a.account_id,signup_date,
		min(case when s.is_trial = 1 then start_date end) as trial_start_date,
        min(case when s.is_trial = 0 then start_date end) as paid_start_date
from accounts a
left join subscriptions s 
on a.account_id = s.account_id
group by a.account_id,signup_date);

select * from account_lifecycle;

-- accounts started as trial and converted to paid

select * from account_lifecycle
where trial_start_date is not null 
and paid_start_date is not null
and paid_start_date > trial_start_date;

-- Time from signup to paid
select account_id,signup_date,paid_start_date,
		datediff(paid_start_date,signup_date) as days_signup_to_paid
from account_lifecycle
where paid_start_date is not null
order by signup_date;

-- Time from trial start → paid (pure trial efficiency)
select account_id,signup_date,trial_start_date,paid_start_date,
		datediff(trial_start_date,signup_date) as days_signup_to_trial,
        datediff(paid_start_date,trial_start_date) as days_trial_to_paid
from account_lifecycle
where paid_start_date is not null
and trial_start_date is not null
and paid_start_date > trial_start_date
order by signup_date;

-- Distribution
SELECT
    AVG(DATEDIFF(paid_start_date, trial_start_date)) AS avg_days_to_convert,
    MIN(DATEDIFF(paid_start_date, trial_start_date)) AS fastest_conversion,
    MAX(DATEDIFF(paid_start_date, trial_start_date)) AS slowest_conversion
FROM account_lifecycle
WHERE trial_start_date IS NOT NULL
  AND paid_start_date IS NOT NULL
  AND paid_start_date > trial_start_date;




--------------------------------------------
SELECT billing_frequency, COUNT(*)
FROM subscriptions
WHERE mrr_amount = 0
GROUP BY billing_frequency;

--------------------------------------------------------
create table dim_date as
select distinct date_format(d,'%Y-%m-01') as month_start,
		year(d) as Year,
        month(d) as month
from(
	select start_date as d from subscriptions
		union
	select end_date from subscriptions where end_date is not null
)t;

select * from dim_date
order by year,month;

CREATE OR REPLACE VIEW fact_subscription_monthly -- One row per subscription per active month
AS
SELECT
    s.subscription_id,
    s.account_id,
    d.month_start,
    s.plan_tier,
    s.billing_frequency,
    s.mrr_amount,
    s.is_trial,
    s.upgrade_flag,
    s.downgrade_flag,
    s.churn_flag
FROM subscriptions s
JOIN dim_date d   -- explicitly monthly dimension
  ON d.month_start >= DATE_FORMAT(s.start_date, '%Y-%m-01')
 AND (
      s.end_date IS NULL
      OR d.month_start <= DATE_FORMAT(s.end_date, '%Y-%m-01')
 );

 
 select * from fact_subscription_monthly;
 select count(*) from subscriptions;
 SELECT *
FROM fact_subscription_monthly
WHERE subscription_id = 'S-0027d3'
ORDER BY month_start;

 
 -- Get total active MRR per month across all accounts
 -- Active MRR for a month is the sum of MRR from all subscriptions whose lifecycle includes that month
 /* Subscription is active in a month if start_date <= reporting_month
	and end_date >= reporting_month */
 
SELECT
    YEAR(month_start)  AS year,
    MONTH(month_start) AS month,
    SUM(mrr_amount)    AS active_monthly_mrr
FROM fact_subscription_monthly
GROUP BY
    YEAR(month_start),
    MONTH(month_start)
ORDER BY
    year, month;
    
-----------------------------------------------------
-- Most Popular Plan by Number of customers (Current Vs Historically)

WITH current_plan AS (
    -- Most popular plan in the latest month
    SELECT
        plan_tier,
        COUNT(DISTINCT account_id) AS current_accounts
    FROM fact_subscription_monthly
    WHERE month_start = (
        SELECT MAX(month_start)
        FROM fact_subscription_monthly
    )
    GROUP BY plan_tier
),
historical_plan AS (
    -- Lifetime adoption
    SELECT
        plan_tier,
        COUNT(DISTINCT account_id) AS lifetime_accounts
    FROM fact_subscription_monthly
    GROUP BY plan_tier
)
SELECT
    h.plan_tier,
    h.lifetime_accounts,
    COALESCE(c.current_accounts, 0) AS current_accounts
FROM historical_plan h
LEFT JOIN current_plan c
    ON h.plan_tier = c.plan_tier
ORDER BY h.lifetime_accounts DESC;


-- Which plan brings the most recurring revenue right now?
SELECT
    plan_tier,
    SUM(mrr_amount) AS current_mrr, COUNT(DISTINCT account_id) as current_accounts
FROM fact_subscription_monthly
WHERE month_start = (
    SELECT MAX(month_start)
    FROM fact_subscription_monthly
)
GROUP BY plan_tier
ORDER BY current_mrr DESC;

-- Most revenue overall
SELECT
    plan_tier,
    SUM(mrr_amount) AS lifetime_mrr, COUNT(DISTINCT account_id) as lifetime_accounts
FROM fact_subscription_monthly
GROUP BY plan_tier
ORDER BY lifetime_mrr DESC;


-- Average Revenue per customer per month
SELECT
    month_start,count(DISTINCT account_id) AS aCTIVE_CUSTOMERS,SUM(mrr_amount) Total_month_revenue,
    ROUND(
        SUM(mrr_amount) / COUNT(DISTINCT account_id),
        2
    ) AS arpa
FROM fact_subscription_monthly
GROUP BY month_start
ORDER BY month_start;

--------------------------------------------------
-- Most accounts per country,Industry
select country,count(account_id) as Accounts_count
from accounts 
group by country
order by count(account_id) desc ;

select Industry,count(account_id) as Accounts_count
from accounts 
group by Industry
order by count(account_id) desc ;

select country,Industry,count(account_id) as Accounts_count
from accounts 
group by country,Industry
order by count(account_id) desc ;

-- Accounts signed up from various referal sources
select referral_source,count(account_id) as Accounts_count
from accounts 
group by referral_source
order by count(account_id) desc ;

-- Most Revenue per account,country,Industry

SELECT
    account_id,
    SUM(mrr_amount) AS Total_mrr
FROM fact_subscription_monthly
GROUP BY account_id
ORDER BY Total_mrr DESC;


SELECT
    a.country,count(distinct a.account_id) as accounts_count,
    SUM(f.mrr_amount) AS lifetime_mrr
FROM fact_subscription_monthly f
JOIN accounts a
    ON f.account_id = a.account_id
GROUP BY a.country
ORDER BY lifetime_mrr DESC;


SELECT
    a.industry,count(distinct a.account_id) as accounts_count,
    SUM(f.mrr_amount) AS lifetime_mrr
FROM fact_subscription_monthly f
JOIN accounts a
    ON f.account_id = a.account_id
GROUP BY a.industry
ORDER BY lifetime_mrr DESC;

-- Cohort analysis -----

CREATE OR REPLACE VIEW cohort_signup AS
    SELECT 
        account_id,
        DATE_FORMAT(signup_date, '%Y-%m-01') AS cohort_month
    FROM
        accounts
;

select * from cohort_signup
order by cohort_month;

SELECT
    c.cohort_month,
    f.month_start,
    TIMESTAMPDIFF(MONTH, c.cohort_month, f.month_start) AS months_since_signup,
    COUNT(DISTINCT f.account_id) AS active_accounts
FROM cohort_signup c
JOIN fact_subscription_monthly f
    ON c.account_id = f.account_id
GROUP BY
    c.cohort_month,
    f.month_start
ORDER BY
    c.cohort_month,
    f.month_start;
    

-- Monthly churn rate ---- 

WITH monthly_stats AS (
    SELECT
        month_start,
        COUNT(DISTINCT account_id) AS active_accounts,
        COUNT(DISTINCT CASE WHEN churn_flag = 1 THEN account_id END) AS churned_accounts
    FROM fact_subscription_monthly
    GROUP BY month_start
)
SELECT
    month_start,
    active_accounts,
    churned_accounts,
    ROUND(churned_accounts * 100.0 / active_accounts, 2) AS churn_rate_pct
FROM monthly_stats
ORDER BY month_start;

-- Avg Monthly Revenue per customer (Customer LTV)
SELECT
    account_id,
    SUM(mrr_amount) AS lifetime_revenue,
    COUNT(DISTINCT month_start) AS active_months,
    ROUND(SUM(mrr_amount) / COUNT(DISTINCT month_start),2) AS avg_monthly_revenue
FROM fact_subscription_monthly
GROUP BY account_id
ORDER BY lifetime_revenue DESC;

-- Accounts with more tickets churn more? 
WITH ticket_counts AS (
    SELECT
        account_id,
        COUNT(*) AS total_tickets
    FROM support_tickets
    GROUP BY account_id
)
SELECT
    a.churn_flag,
    AVG(t.total_tickets) AS avg_tickets
FROM accounts a
LEFT JOIN ticket_counts t
    ON a.account_id = t.account_id
GROUP BY a.churn_flag;



-- Accounts with beta feature
WITH beta_users AS (
    SELECT DISTINCT
        s.account_id
    FROM feature_usage f
    JOIN subscriptions s
        ON f.subscription_id = s.subscription_id
    WHERE f.is_beta_feature = 1
)
SELECT
    a.churn_flag,
    COUNT(DISTINCT a.account_id) AS accounts
FROM accounts a
LEFT JOIN beta_users b
    ON a.account_id = b.account_id
GROUP BY a.churn_flag;

 
 -- top revenue accounts per country
SELECT *
FROM (
    SELECT
        a.country,
        f.account_id,
        SUM(f.mrr_amount) AS total_mrr,
        RANK() OVER (PARTITION BY a.country ORDER BY SUM(f.mrr_amount) DESC) AS rnk
    FROM fact_subscription_monthly f
    JOIN accounts a
        ON f.account_id = a.account_id
    GROUP BY a.country, f.account_id
) t
WHERE rnk <= 3;



-----------------------------------------------
-- Month-over-Month MRR Movement (Mrr = monthly recurring revenue)
    
-- layered SQL views to separate time-expansion logic, aggregation, and revenue classification. 
-- makes the MRR movement calculations transparent, reusable, and easy to validate.

-- each row below represent one account in one month with total MRR
CREATE OR REPLACE VIEW fact_account_mrr_monthly AS 
    SELECT 
        account_id, month_start, SUM(mrr_amount) AS Total_mrr
    FROM
        fact_subscription_monthly
    GROUP BY account_id , month_start
    ORDER BY account_id;
    select * from fact_account_mrr_monthly;
    
-- comparing mom mrr for each account
create or replace view account_mom_mrr as
	select *,lag(Total_mrr) over(partition by account_id order by month_start)
			as prev_mrr
	from fact_account_mrr_monthly;
SELECT 
    *
FROM
    account_mom_mrr;

 -- classification (what has happened and how much mrr moved)
 CREATE OR REPLACE VIEW mrr_movements AS
    SELECT 
        *,
        CASE
            WHEN prev_mrr IS NULL AND Total_mrr > 0 THEN 'New'
            WHEN prev_mrr > 0 AND Total_mrr = 0 THEN 'Churn'
            WHEN Total_mrr > prev_mrr THEN 'Expansion'
            WHEN Total_mrr < prev_mrr THEN 'Contraction'
            ELSE 'No Change'
        END AS mrr_type,
        CASE
            WHEN prev_mrr IS NULL THEN Total_mrr
            WHEN total_mrr = 0 THEN prev_mrr
            ELSE ABS(Total_mrr - prev_mrr)
        END AS mrr_amount
    FROM
        account_mom_mrr;
SELECT 
    *
FROM
    mrr_movements;

-- Monthly mrr
SELECT 
    month_start, mrr_type, SUM(mrr_amount) AS mrr
FROM
    mrr_movements
WHERE
    mrr_type <> 'No Change'
GROUP BY month_start , mrr_type
ORDER BY month_start,mrr_type;
        
-------------------------------------------------
 /* 
	NRR - Net revenue retnetion - revenue kept including expansion
	GRR - Gross revenue retention - last month’s revenue kept, ignoring expansion
*/

CREATE OR REPLACE VIEW monthly_mrr_components AS
SELECT
    month_start,

    SUM(CASE WHEN mrr_type = 'New' THEN mrr_amount ELSE 0 END) AS new_mrr,
    SUM(CASE WHEN mrr_type = 'Expansion' THEN mrr_amount ELSE 0 END) AS expansion_mrr,
    SUM(CASE WHEN mrr_type = 'Contraction' THEN mrr_amount ELSE 0 END) AS contraction_mrr,
    SUM(CASE WHEN mrr_type = 'Churned' THEN mrr_amount ELSE 0 END) AS churned_mrr
FROM mrr_movements
GROUP BY month_start;


CREATE OR REPLACE VIEW monthly_ending_mrr AS
SELECT 
    month_start, SUM(total_mrr) AS ending_mrr
FROM
    fact_account_mrr_monthly
GROUP BY month_start;
select * from monthly_ending_mrr;

CREATE OR REPLACE VIEW monthly_starting_mrr AS
select month_start,
		lag(ending_mrr) over(order by month_start)
			as starting_mrr
from monthly_ending_mrr;

CREATE OR REPLACE VIEW monthly_retention_base AS
SELECT
    s.month_start,
    s.starting_mrr,
    e.ending_mrr,
    c.new_mrr,
    c.expansion_mrr,
    c.contraction_mrr,
    c.churned_mrr
FROM monthly_starting_mrr s
JOIN monthly_ending_mrr e
    ON s.month_start = e.month_start
LEFT JOIN monthly_mrr_components c
    ON s.month_start = c.month_start;
    
select * from monthly_retention_base;

SELECT
    month_start,
    starting_mrr,
    ending_mrr,

    ROUND(
        (starting_mrr - churned_mrr - contraction_mrr)
        / starting_mrr * 100, 2
    ) AS grr_pct,

    ROUND(
        (starting_mrr - churned_mrr - contraction_mrr + expansion_mrr)
        / starting_mrr * 100, 2
    ) AS nrr_pct
FROM monthly_retention_base
WHERE starting_mrr IS NOT NULL;



--------------------
SELECT * FROM fact_subscription_monthly;
SELECT * FROM fact_account_mrr_monthly;
SELECT * FROM mrr_movements;
SELECT * FROM monthly_retention_base;
SELECT * FROM accounts;
SELECT * FROM cohort_retention;


