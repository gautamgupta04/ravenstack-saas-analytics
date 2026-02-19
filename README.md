# 📊 Ravenstack SaaS Revenue Analytics

## 🔹 Project Overview

Ravenstack SaaS Revenue Analytics is an end-to-end revenue intelligence project built using **MySQL and Power BI** to simulate a real-world SaaS analytics environment.

The objective was to transform raw subscription, account, churn, feature usage, and support ticket data into executive-level SaaS KPIs through structured SQL modeling and interactive Power BI dashboards.

The project models the complete subscription lifecycle and implements industry-standard SaaS metrics including:

- MRR (Monthly Recurring Revenue)
- ARPA (Average Revenue Per Account)
- Revenue Churn %
- GRR (Gross Revenue Retention)
- NRR (Net Revenue Retention)
- Cohort Retention
- Trial-to-Paid Conversion
- Plan Upgrade Funnel Analysis

---

# 🛠 Tech Stack

## 🔹 Database & Transformation
- MySQL
- Common Table Expressions (CTEs)
- Window Functions (LAG, RANK)
- Time-Expanded Fact Modeling
- Revenue Movement Classification Logic

## 🔹 Business Intelligence
- Power BI
- DAX Measures
- KPI Cards
- Waterfall & Trend Visuals
- Retention Matrix
- Interactive Slicers
- Funnel & Segmentation Analysis

---

# 🗂 Dataset

The repository includes a synthetic SaaS subscription dataset containing:

- Customer ID
- Subscription Start & End Dates
- Plan Tier
- Monthly Recurring Revenue
- Industry & Country
- Trial vs Paid Classification
- Support Tickets
- Feature Usage Data

The dataset is modeled into a **monthly time-expanded fact table** to accurately track revenue lifecycle events.

---

# 🏗 Data Modeling Approach

## 1️⃣ Relational Schema Design
- Defined Primary & Foreign Keys
- Applied CHECK constraints
- Standardized boolean fields
- Cleaned null and inconsistent values
- Ensured referential integrity

## 2️⃣ Monthly Time-Expanded Fact Table

Built a central fact table:

fact_subscription_monthly

This generates one row per subscription per active month, enabling:

- Accurate Monthly Recurring Revenue calculation
- Active customer tracking
- Month-over-Month revenue comparison
- Cohort-based retention analysis

---

# 🔄 Revenue Movement Framework

Layered SQL views were designed to classify Month-over-Month revenue changes:

1. fact_account_mrr_monthly  
2. account_mom_mrr (using LAG window function)  
3. mrr_movements  
4. monthly_retention_base  

Revenue was classified into:

- New MRR
- Expansion MRR
- Contraction MRR
- Churned MRR

This framework enables accurate GRR and NRR computation aligned with SaaS industry standards.

---

# 📈 Key SaaS KPIs Implemented

## Revenue Metrics
- Monthly Recurring Revenue (MRR)
- Average Revenue Per Account (ARPA)
- Revenue Churn %
- Gross Revenue Retention (GRR)
- Net Revenue Retention (NRR)
- Month-over-Month Revenue Movement

## Retention & Growth Metrics
- Revenue Cohort Analysis
- Trial-to-Paid Conversion Rate
- Signup-to-Paid Time Analysis
- Customer Lifetime Revenue Estimation

## Segmentation & Behavioral Insights
- Revenue by Industry & Country
- Plan-Level Revenue Distribution
- Plan Upgrade Funnel by Industry
- Support Tickets vs Churn Analysis
- Feature Usage vs Retention

---

# 📊 Power BI Dashboard Pages

The Power BI report includes:

### 1️⃣ Overview
- Total MRR
- Net Revenue Retention (NRR)
- Monthly Revenue Trend

### 2️⃣ Revenue Movement Analysis
- New vs Expansion vs Contraction vs Churn
- MRR Growth %
- Waterfall Visualization

### 3️⃣ Net Revenue Retention (NRR) Analysis
- Revenue trend over time
- Revenue health monitoring

### 4️⃣ Revenue Cohort Analysis
- Revenue Cohort Matrix
- MRR by Referal source

### 5️⃣ Plan Upgrade Funnel by Industry
- Upgrade tracking
- Industry-level conversion insights

### 6️⃣ Customer & Plan Analysis
- Revenue by Plan Tier
- Revenue by Industry
- Top N Accounts by MRR

All dashboards are fully interactive with slicers for:
- Month / Year
- Plan Tier
- Industry
- Country

---

# 📂 Project Structure

ravenstack-saas-analytics/
│
├── data/
│   └── raw_saas_dataset.zip
│
├── sql/
│   └── Ravenstack_Saas_prj.sql
│
├── powerbi/
│   └── ravenstack.pbix
│
├── images/
│   └── dashboard screenshots
│
└── README.md

---

# 💼 Business Value

This project demonstrates how SaaS companies:

- Monitor revenue health
- Identify expansion vs churn drivers
- Analyze net revenue retention performance
- Track plan upgrade behavior
- Evaluate revenue by industry segment

---

# 🚀 Outcome

Developed a complete SaaS revenue analytics pipeline combining:

- Backend SQL modeling  
- Advanced revenue classification logic  
- Revenue cohort  
- Interactive executive dashboards in Power BI  

The project simulates real-world SaaS revenue intelligence workflows used by subscription-based technology companies.
