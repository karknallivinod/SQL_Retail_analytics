# 💳 Retail & Fintech Transaction Analytics (SQL)

![SQL](https://img.shields.io/badge/Language-SQL-blue.svg)
![Database](https://img.shields.io/badge/Database-MySQL%20%2F%20PostgreSQL-orange.svg)
![Status](https://img.shields.io/badge/Status-Completed-success.svg)

An end-to-end relational database analytics project evaluating payment settlements, cross-border monetary flows, merchant volume tiering, and customer retention metrics across transaction records.

---

## 📌 Executive Summary & Business Objectives

Modern retail and payment platforms process diverse transaction streams with complex cross-border currency regulations and varied merchant profiles. This project provides data-driven answers to core commercial operations:

1. **Transaction Segmentation:** Identifying high-value accounts (> $10,000) vs. retail everyday usage to assess operational risk and revenue concentration.
2. **Cross-Border Monitoring:** Tracking domestic vs. international payment flows to optimize foreign exchange (FX) fee structures.
3. **Merchant Performance Tiering:** Categorizing merchants into performance tiers (`Excellent`, `Good`, `Average`, `Below Average`) based on quarterly and rolling revenue milestones ($50K+).
4. **Customer Retention & LTV:** Isolating power users based on transaction consistency (active across 6+ separate months) and average spend volume.

---

## 🏗️ Data Architecture & Relational Model

The analytical model relies on three central relational entities:

* **`users`**: Contains demographic details (`user_id`, `name`, `email`, `country_id`).

* **`merchants`**: B2B entity receiving settlement amounts (`merchant_id`, `business_name`).
* **`transactions`**: Core ledger table (`transaction_id`, `sender_id`, `recipient_id`, `transaction_amount`, `currency_code`, `transaction_date`).
  ---

## 🛠️ Key Technical SQL Implementations

* **Conditional Multi-Factor Aggregation:** Evaluated geographical boundaries between `sender` and `recipient` using multi-condition `CASE WHEN` logic joined on relational keys.
* **Temporal Grouping & Extraction:** Standardized date manipulation using `EXTRACT(YEAR/MONTH)`, `BETWEEN`, and ISO date filters for rolling 6-month and 12-month analysis.
* **Customer Retention Cohorts:** Filtered multi-period repeat behaviors utilizing `HAVING COUNT(DISTINCT DATE_FORMAT(..., '%Y-%m')) >= 6`.
* **Dynamic Merchant Scoring:** Built volume tiers to automate account classification for relationship management and credit risk monitoring.

---

## 📊 Core Business Queries & Analytical Insights

### 1. Cross-Border vs. Domestic Payment Exposure
Categorizing transactions based on cross-border rules (`sender.country_id != recipient.country_id`) and value brackets:

| Transaction Segment | Criteria | Business Focus |
| :--- | :--- | :--- |
| **High Value International** | Amount > $10K, Cross-border | High FX margin, strict AML/KYC checks |
| **High Value Domestic** | Amount > $10K, Domestic | Commercial ACH/Wire settlement monitoring |
| **Regular International** | Amount ≤ $10K, Cross-border | Consumer remittance fee optimization |
| **Regular Domestic** | Amount ≤ $10K, Domestic | High-frequency, low-latency processing |

### 2. Merchant Performance Tiering
Merchants are assigned service tiers based on rolling 6-month transaction intake:
* **Tier 1 (Excellent):** Total settlement > $50,000 (dedicated account manager, volume discounts)
* **Tier 2 (Good):** $20,000 to $50,000
* **Tier 3 (Average):** $10,000 to $20,000
* **Tier 4 (Below Average):** Under $10,000

---

## 📂 Repository File Structure
---

## 🚀 How to Run

1. Clone this repository or open the scripts folder.
2. Import the schema and dataset into your SQL workbench (MySQL Workbench, DBeaver, or pgAdmin).
3. Execute `scripts/retail_transaction_analytics.sql` sequentially to reproduce the metrics and tier classifications.
