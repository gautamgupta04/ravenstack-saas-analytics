# 📊 Ravenstack SaaS Revenue Analytics

## 🔹 Project Overview

This project simulates a real-world SaaS revenue analytics pipeline using MySQL and Power BI.

The objective was to transform raw subscription, account, churn, feature usage, and support ticket data into actionable SaaS KPIs and executive dashboards.

The project models the complete subscription lifecycle and implements industry-standard SaaS revenue metrics including MRR, ARPA, Churn, GRR, NRR,  and Trial-to-Paid conversion.

---

## 🔹 Tech Stack

**Database & Transformation**
- MySQL
- CTEs
- Window Functions (LAG, RANK)
- Time-expanded fact modeling
- Revenue movement classification logic

**Business Intelligence**
- Power BI
- DAX Measures
- KPI Cards & Trend Visuals
- Retention Analysis
- Interactive Slicers

---

## 🔹 Data Modeling Approach

### 1️⃣ Relational Schema Design
- Defined Primary & Foreign Keys
- Added CHECK constraints for data validation
- Standardized boolean fields
- Cleaned inconsistent and null values
- Ensured referential integrity across tables

### 2️⃣ Monthly Time-Expanded Fact Table

Built a time-expanded fact table:

```
fact_subscription_monthly
```

This generates one row per subscription per active month, enabling accurate:

- Monthly Recurring Revenue (MRR)
- Active customer tracking
- Cohort analysis
- Revenue movement classification

---

## 🔹 Revenue Movement Framework

Layered SQL views were created to classify Month-over-Month revenue changes:

1. `fact_account_mrr_monthly`
2. `account_mom_mrr` (using LAG window function)
3. `mrr_movements`
4. `monthly_retention_base`

Revenue was classified into:

- New MRR
- Expansion MRR
- Contraction MRR
- Churned MRR

This framework enables calculation of retention and growth metrics aligned with SaaS industry standards.

---

## 🔹 Key SaaS KPIs Implemented

### 📈 Revenue Metrics
- Monthly Recurring Revenue (MRR)
- Average Revenue Per Account (ARPA)
- Revenue Churn %
- Gross Revenue Retention (GRR)
- Net Revenue Retention (NRR)
- Month-over-Month Revenue Movement

### 📊 Retention & Growth Metrics
- Cohort Retention Analysis
- Trial-to-Paid Conversion Rate
- Signup-to-Paid Time Analysis
- Customer Lifetime Revenue Estimation

### 🌍 Business Insights
- Revenue by Country & Industry
- Most Popular Plan (Current vs Historical)
- Support Tickets vs Churn Analysis
- Beta Feature Usage vs Churn Analysis

---

## 🔹 Power BI Dashboard

The Power BI dashboard provides executive-level insights through:

### KPI Cards
- Total MRR
- Active Customers
- NRR

### Revenue Trend Visuals
- Monthly MRR trend
- MoM revenue movement breakdown
- Plan-level revenue distribution

### Retention Analysis
- Cohort retention matrix
- Revenue movement breakdown

### Interactive Filters
- Plan Tier
- Country
- Industry
- Year / Month slicers

---

## 🔹 Advanced SQL Concepts Used

- Common Table Expressions (CTEs)
- Window Functions (LAG, RANK)
- TIMESTAMPDIFF for lifecycle analysis
- Revenue classification logic
- Time-dimension modeling
- Cohort-based retention analysis

---

## 🔹 Business Value

This project demonstrates how SaaS companies:

- Monitor revenue health
- Track expansion vs churn
- Measure retention efficiency
- Analyze net revenue retention
- Identify revenue drivers by customer segment

---

## 📌 Project Structure

```
ravenstack-saas-analytics/
│
├── Ravenstack_Saas_prj.sql
├── ravenstack.pbix
└── README.md
```

---

## 🚀 Outcome

Developed an end-to-end SaaS analytics solution combining backend SQL modeling with interactive Power BI dashboards to simulate real-world revenue intelligence workflows.
