# Bank Marketing Campaign Analysis

An end-to-end data analytics project exploring customer subscription outcomes in a bank's telemarketing campaign using **Python, MySQL, and Power BI**.

## Project Overview

This project analyzes how term-deposit subscription outcomes vary across contact methods, campaign timing, customer segments, and contact history. The workflow moves from data auditing and preparation to SQL-based business analysis and an interactive Power BI dashboard.

The analysis is descriptive. It identifies patterns and associations in the dataset but does not establish that a particular contact method, customer characteristic, or number of calls causes a subscription.

## Business Objectives

- Establish the campaign's overall subscription rate.
- Compare subscription outcomes across contact methods.
- Examine performance by month, job category, age group, and education level.
- Investigate subscription rates by the number of contacts made during the current campaign.
- Compare current outcomes by previous campaign outcome and contact history.
- Present findings in an interactive dashboard and identify areas for further investigation.

## Dataset

This project uses the **Bank Marketing** dataset from the UCI Machine Learning Repository, specifically `bank-additional-full.csv`.

- Original dataset: **41,188 rows and 21 columns**
- Prepared analysis dataset: **41,176 rows and 21 columns**
- Exact duplicate rows removed during preparation: **12**
- Outcome column: `y` (`yes` = subscribed; `no` = did not subscribe)

Relevant fields include `age`, `job`, `education`, `contact`, `month`, `campaign`, `previous`, `poutcome`, and `y`.

The original CSV is semicolon-delimited. The prepared CSV exported from pandas is comma-delimited.

**Data-preparation note:** The source does not provide a unique record identifier to establish whether identical rows are accidental duplicates or legitimate repeated observations. The 12 exact duplicate rows were removed from a separate analysis copy while preserving the raw source. This is an assumption that should be reconsidered if record-level provenance becomes available.

**Special-value note:** In this dataset, `pdays = 999` is a special code indicating that the customer was not previously contacted. It should not be interpreted as 999 actual days. `poutcome = nonexistent` is a valid recorded category.

## Tools and Technologies

- **Python and pandas** — data inspection, quality checks, duplicate review, and preparation
- **Jupyter Notebook** — documenting the data-audit workflow
- **MySQL and MySQL Workbench** — querying the prepared data and calculating business metrics
- **Power BI** — KPI cards, bar charts, a segmentation heatmap, slicers, and report pages

## Workflow

### 1. Data audit and preparation — Python

The notebook was used to:
- Load the source CSV with the correct delimiter.
- Inspect dimensions, column types, missing values, categories, and numeric ranges.
- Identify 12 exact duplicate rows.
- Create a separate analysis copy with those exact duplicates removed.
- Export the prepared data to `data/processed/bank_marketing_prepared.csv`.

The raw dataset was kept separate from the prepared output.

### 2. Business analysis — MySQL

The prepared CSV was imported into the `bank_marketing` table in the `marketing_campaign_analysis` database.

The SQL script, `market_campaign_analysis.sql`, covers:
- Record counts, outcome distribution, and selected missing-value checks
- Overall subscription and non-subscription rates
- Subscription rates by month and contact method
- Subscription rates and subscription contribution by job category
- Performance by exact campaign-attempt counts and grouped attempt bands
- Outcomes by previous campaign result and previous contact count
- Comparisons by job, contact method, month, age group, and education
- Customer-segment combinations using age group, job category, and contact method
- KPI results used to validate the Power BI dashboard

### 3. Interactive reporting — Power BI

The dashboard contains three pages.

#### Page 1 — Campaign Overview
Provides a high-level view of campaign performance, including KPI cards, monthly subscription rates, contact-method comparisons, subscription contribution, job-category performance, previous campaign outcomes, and slicers.

#### Page 2 — Customer Segmentation
Explores differences across age groups and job categories with a subscription-rate heatmap, compares subscription rates by education level, and examines results across grouped campaign contact attempts. A contact-method slicer allows users to explore cellular and telephone results.

#### Page 3 — Campaign Strategy & Recommendations
Highlights key metrics, compares current subscription rates across previous campaign outcomes, and summarizes evidence-based areas for further investigation and analytical limitations.

## Key Findings

The figures below are from the prepared dataset and SQL analysis. Power BI results can differ when report filters or slicers are active.

### Overall campaign performance

| Metric | Result |
|---|---:|
| Records analyzed | 41,176 |
| Subscriptions | 4,639 |
| Non-subscriptions | 36,537 |
| Overall subscription rate | 11.27% |

### Subscription rate by contact method

| Contact method | Records | Subscriptions | Subscription rate |
|---|---:|---:|---:|
| Cellular | 26,135 | 3,852 | 14.74% |
| Telephone | 15,041 | 787 | 5.23% |

Cellular contacts had a higher observed subscription rate than telephone contacts in this dataset. This comparison does not account for differences in customer mix, contact costs, preferences, or other factors.

### Subscription rate by previous campaign outcome

| Previous outcome | Records | Current subscriptions | Subscription rate |
|---|---:|---:|---:|
| Success | 1,373 | 894 | 65.11% |
| Failure | 4,252 | 605 | 14.23% |
| Nonexistent | 35,551 | 3,140 | 8.83% |

Customers with a previous successful campaign outcome had a substantially higher observed subscription rate in the current campaign. This is a useful pattern to investigate, but it does not guarantee the same result in future campaigns.

### Subscription rate by current campaign contact attempts

| Contact attempts | Records | Subscriptions | Subscription rate |
|---|---:|---:|---:|
| 1 attempt | 17,634 | 2,299 | 13.04% |
| 2–3 attempts | 15,908 | 1,785 | 11.22% |
| 4–5 attempts | 4,249 | 369 | 8.68% |
| 6–10 attempts | 2,516 | 159 | 6.32% |
| 11+ attempts | 869 | 27 | 3.11% |

Observed subscription rates decline across the grouped attempt bands. This does not demonstrate that repeated calls cause lower conversion: customers who are more difficult to convert may receive more contact attempts.

### Customer segmentation

The report compares subscription rates by age group, job category, and education. Some categories have small sample sizes. For example, the `illiterate` education category contains 18 records, so its observed rate should be interpreted cautiously. High rates in small age/job combinations should also be evaluated alongside the number of records and subscriptions.

## Business Recommendations

1. **Investigate previous campaign successes.** Examine which customer and campaign characteristics are associated with prior success before designing follow-up strategies.
2. **Evaluate contact-channel performance.** Consider customer mix, preferences, operational feasibility, and costs before changing channel allocation.
3. **Review repeated contact attempts.** Test alternative contact strategies and monitor future outcomes rather than assuming fewer attempts will improve subscription rates.
4. **Consider both rates and volume.** A high rate in a small group may be less actionable than a comparable rate supported by more records.
5. **Validate proposed changes.** Where possible, use controlled experiments or future campaign data to determine whether a proposed strategy improves results.

These are investigation priorities, not causal conclusions.

## Limitations

- The dataset is observational, so associations do not establish causation.
- Campaign spending and revenue are not provided; therefore ROI, profitability, and cost per acquisition cannot be calculated.
- Some categories and age/job combinations have small sample sizes.
- Removing exact duplicate rows is an assumption because a unique record identifier was unavailable.
- Findings may not generalize to other banks, time periods, or customer populations.
- `duration` is the duration of the current call and is only known after the call. It should not be used as a pre-call targeting variable.
- `pdays = 999` is a special code for no previous contact, not a literal elapsed-day value.

## Suggested Repository Structure

```text
market-campaign-analysis/
├── data/
│   ├── raw/
│   │   └── bank-additional-full.csv
│   └── processed/
│       └── bank_marketing_prepared.csv
├── notebooks/
│   └── 01_data_audit.ipynb
├── sql/
│   └── market_campaign_analysis.sql
├── powerbi/
│   └── bank_marketing_dashboard.pbix
├── results/
│   └── dashboard_screenshots/
└── README.md
```

Adjust this structure to match the files actually present in your repository. It is a suggested layout, not a claim that every file is already in those folders.

## How to Reproduce the Analysis

1. Download the dataset from the UCI Machine Learning Repository.
2. Run the Jupyter Notebook to inspect and prepare the data.
3. Import `bank_marketing_prepared.csv` into MySQL using the schema in the SQL script.
4. Run the SQL queries to reproduce the business metrics.
5. Open the Power BI `.pbix` file, confirm the data source, refresh if necessary, and test the slicers.

## Data Source

Moro, S., Rita, P., & Cortez, P. (2014). *Bank Marketing*. UCI Machine Learning Repository.

Dataset: https://archive.ics.uci.edu/dataset/222/bank+marketing

## Author

**Manoj Kumar**  
Aspiring Data Analyst

This project demonstrates an end-to-end analytics workflow: data auditing and preparation, SQL-based business analysis, interactive visualization, validation, and business interpretation.
