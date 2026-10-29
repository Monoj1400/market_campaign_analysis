CREATE DATABASE marketing_campaign_analysis;

USE marketing_campaign_analysis;

CREATE TABLE bank_marketing (
    age INT,
    job VARCHAR(50),
    marital VARCHAR(20),
    education VARCHAR(50),
    `default` VARCHAR(10),
    housing VARCHAR(10),
    loan VARCHAR(10),
    contact VARCHAR(20),
    `month` VARCHAR(10),
    day_of_week VARCHAR(10),
    duration INT,
    campaign INT,
    pdays INT,
    previous INT,
    poutcome VARCHAR(20),
    emp_var_rate DECIMAL(5,2),
    cons_price_idx DECIMAL(7,3),
    cons_conf_idx DECIMAL(6,2),
    euribor3m DECIMAL(6,3),
    nr_employed DECIMAL(7,1),
    y VARCHAR(5)
);
USE marketing_campaign_analysis;

SELECT COUNT(*) AS total_records
FROM bank_marketing;

SELECT
    y AS subscription_status,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_marketing), 2) AS percentage
FROM bank_marketing
GROUP BY y;

SELECT
    SUM(y IS NULL OR TRIM(y) = '') AS missing_outcomes,
    SUM(age IS NULL) AS missing_age,
    SUM(job IS NULL OR TRIM(job) = '') AS missing_job,
    SUM(contact IS NULL OR TRIM(contact) = '') AS missing_contact
FROM bank_marketing;


-- Business Question:
-- What is the overall performance of the marketing campaign?

-- Step 1: Count all customer records.
-- Step 2: Count customers who subscribed.
-- Step 3: Calculate the subscription rate.
-- Step 4: Calculate the number and percentage of customers who did not subscribe.

SELECT
    COUNT(*) AS total_customers,

    SUM(CASE
        WHEN y = 'yes' THEN 1
        ELSE 0
    END) AS successful_subscriptions,

    SUM(CASE
        WHEN y = 'no' THEN 1
        ELSE 0
    END) AS unsuccessful_contacts,

    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct,

    ROUND(
        SUM(CASE WHEN y = 'no' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS non_subscription_rate_pct

FROM bank_marketing;


-- Business Question:
-- Which months have the highest and lowest subscription rates?
--
-- COUNT(*) calculates the number of records for each month.
-- SUM(CASE...) counts successful subscriptions in each month.
-- The subscription rate measures the percentage of records
-- that resulted in a subscription.
-- GROUP BY separates the records by month.
-- ORDER BY sorts the months from highest to lowest rate.

SELECT
    `month`,
    COUNT(*) AS total_contacts,

    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

GROUP BY `month`

ORDER BY subscription_rate_pct DESC;


-- Business Question:
-- Which contact method is associated with the highest subscription rate?
--
-- COUNT(*) measures the number of records for each contact method.
-- SUM(CASE...) counts successful subscriptions.
-- The subscription rate allows us to compare methods fairly
-- despite differences in the number of contacts.

SELECT
    contact,

    -- Count all records for each contact method.
    COUNT(*) AS total_contacts,

    -- Count successful subscriptions for each method.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the subscription rate as a percentage.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

-- Calculate metrics separately for each contact method.
GROUP BY contact

-- Display the highest subscription rate first.
ORDER BY subscription_rate_pct DESC;


-- Business Question:
-- Which job categories have the highest subscription rates?
--
-- COUNT(*) measures the number of records in each job category.
-- SUM(CASE...) counts successful subscriptions.
-- The percentage makes the categories comparable despite
-- having different numbers of records.
-- HAVING COUNT(*) >= 100 excludes very small groups from the
-- initial ranking to reduce the risk of overinterpreting
-- percentages based on only a few records.

SELECT
    job,

    -- Count all records in each job category.
    COUNT(*) AS total_contacts,

    -- Count successful subscriptions within each category.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the subscription rate for each job category.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

-- Calculate the metrics separately for each job category.
GROUP BY job

-- Keep categories with at least 100 records for this comparison.
HAVING COUNT(*) >= 100

-- Rank categories from highest to lowest subscription rate.
ORDER BY subscription_rate_pct DESC;


-- Business Question:
-- How does the number of contacts during the current campaign
-- relate to the subscription rate?
--
-- campaign represents the number of contacts performed for
-- the customer during the current campaign.
--
-- GROUP BY campaign compares each number of attempts.
-- COUNT(*) shows the volume of records at each attempt count.
-- The subscription rate measures the percentage resulting
-- in a successful subscription.
--
-- HAVING excludes groups with fewer than 100 records from
-- this initial comparison to avoid overinterpreting tiny groups.

SELECT
    campaign AS contact_attempts,

    -- Count records with this number of campaign contacts.
    COUNT(*) AS total_contacts,

    -- Count subscriptions within each attempt-count group.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the subscription rate for each group.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

-- Compare records with the same number of campaign contacts.
GROUP BY campaign

-- Retain groups with at least 100 records.
HAVING COUNT(*) >= 100

-- Display the groups with the highest rate first.
ORDER BY subscription_rate_pct DESC;


-- Business Question:
-- Is the outcome of the previous campaign associated
-- with subscription success in the current campaign?
--
-- poutcome contains the previous campaign outcome:
-- success, failure, or nonexistent.
--
-- COUNT(*) measures the number of records in each group.
-- SUM(CASE...) counts current-campaign subscriptions.
-- The subscription rate allows comparisons across groups.

SELECT
    poutcome AS previous_campaign_outcome,

    -- Count records associated with each previous outcome.
    COUNT(*) AS total_contacts,

    -- Count current-campaign subscriptions in each group.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the current subscription rate by group.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

-- Group records by their previous campaign outcome.
GROUP BY poutcome

-- Show the highest current subscription rate first.
ORDER BY subscription_rate_pct DESC;


-- Business Question:
-- How do subscription rates for cellular and telephone contact
-- differ across job categories?
--
-- GROUP BY job, contact creates one group for each combination
-- of job category and contact method.
-- COUNT(*) measures the number of records in each group.
-- SUM(CASE...) counts current subscriptions.
-- The subscription rate enables comparison across groups.
--
-- HAVING COUNT(*) >= 100 excludes very small groups from this
-- initial comparison to reduce the risk of overinterpreting
-- unstable rates.

SELECT
    job,
    contact,

    -- Count records for this job and contact-method combination.
    COUNT(*) AS total_contacts,

    -- Count subscriptions for this combination.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the subscription rate as a percentage.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

-- Compare each contact method within each job category.
GROUP BY job, contact

-- Keep combinations with at least 100 records.
HAVING COUNT(*) >= 100

-- Sort by job category, then highest rate within each category.
ORDER BY job, subscription_rate_pct DESC;

-- Business Question:
-- Which age groups have the highest subscription rates?
--
-- CASE divides customers into five age bands.
-- COUNT(*) measures the number of records in each age band.
-- SUM(CASE...) counts successful subscriptions.
-- The subscription rate enables fairer comparisons across groups.
--
-- GROUP BY age_group calculates the metrics for each band.
-- ORDER BY MIN(age) presents the age bands in ascending order.

SELECT
    CASE
        WHEN age BETWEEN 17 AND 25 THEN '17-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,

    -- Count records in each age group.
    COUNT(*) AS total_contacts,

    -- Count subscriptions in each age group.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the subscription rate as a percentage.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

-- Aggregate the records into the five age bands.
GROUP BY age_group

-- Sort age bands from youngest to oldest.
ORDER BY MIN(age);

-- Business Question:
-- Which education categories have the highest subscription rates?
--
-- COUNT(*) measures the number of records in each category.
-- SUM(CASE...) counts successful subscriptions.
-- The subscription rate enables comparison across categories.
-- Unknown is retained as a category rather than treated as NULL,
-- because it is a recorded value in this dataset.

SELECT
    education,

    -- Count records for each education category.
    COUNT(*) AS total_contacts,

    -- Count successful subscriptions in each category.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the subscription rate as a percentage.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

-- Calculate performance separately for each education category.
GROUP BY education

-- Show the highest subscription rate first.
ORDER BY subscription_rate_pct DESC;



-- Business Question:
-- How does the number of contacts before the current campaign
-- relate to the current subscription rate?
--
-- previous records the number of contacts performed before
-- the current campaign for each record.
-- COUNT(*) measures the number of records at each count.
-- SUM(CASE...) counts current-campaign subscriptions.
-- The subscription rate compares outcomes across groups.
--
-- A value of zero means no previous contacts were recorded.

SELECT
    previous AS previous_contact_count,

    -- Count records for each previous-contact count.
    COUNT(*) AS total_contacts,

    -- Count successful subscriptions in each group.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the current subscription rate as a percentage.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

-- Group records by their number of previous contacts.
GROUP BY previous

-- Sort by previous-contact count from lowest to highest.
ORDER BY previous_contact_count;


-- Business Question:
-- How do subscription rates vary by month within each contact method?
--
-- GROUP BY month, contact calculates metrics for every
-- month-and-contact-method combination.
-- COUNT(*) measures the record volume for each combination.
-- SUM(CASE...) counts successful subscriptions.
-- The subscription rate allows comparisons across groups.
--
-- This analysis is descriptive; it does not establish that
-- the month or contact method causes a change in performance.

SELECT
    `month`,
    contact,

    -- Count records for this month and contact method.
    COUNT(*) AS total_contacts,

    -- Count successful subscriptions in this group.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the subscription rate as a percentage.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

-- Calculate metrics for each month and contact method.
GROUP BY `month`, contact

-- Sort by month and then by the highest subscription rate.
ORDER BY `month`, subscription_rate_pct DESC;


-- Business Question:
-- How does subscription performance vary across bands of
-- contact attempts during the current campaign?
--
-- CASE groups the campaign count into practical bands.
-- COUNT(*) measures records in each band.
-- SUM(CASE...) counts subscriptions.
-- The subscription rate compares outcomes across bands.
--
-- This query uses the campaign column, which represents
-- contacts during the current campaign, not previous campaigns.

SELECT
    CASE
        WHEN campaign = 1 THEN '1 attempt'
        WHEN campaign BETWEEN 2 AND 3 THEN '2-3 attempts'
        WHEN campaign BETWEEN 4 AND 5 THEN '4-5 attempts'
        WHEN campaign BETWEEN 6 AND 10 THEN '6-10 attempts'
        ELSE '11+ attempts'
    END AS attempt_band,

    -- Count records within each attempt band.
    COUNT(*) AS total_contacts,

    -- Count successful subscriptions in each band.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the subscription rate for each band.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

-- Aggregate records into the five contact-attempt bands.
GROUP BY attempt_band

-- Sort bands into their intended numeric order.
ORDER BY
    CASE attempt_band
        WHEN '1 attempt' THEN 1
        WHEN '2-3 attempts' THEN 2
        WHEN '4-5 attempts' THEN 3
        WHEN '6-10 attempts' THEN 4
        WHEN '11+ attempts' THEN 5
    END;
    
    
    -- Business Question:
-- Which job categories contribute the most subscriptions overall?
--
-- The first calculation counts subscriptions within each job.
-- The second calculation measures what percentage of all
-- subscriptions came from that job category.
--
-- A high contribution can reflect a large customer segment,
-- even if its subscription rate is not the highest.

SELECT
    job,

    -- Count all records in each job category.
    COUNT(*) AS total_contacts,

    -- Count successful subscriptions within each job.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the subscription rate within each job category.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct,

    -- Calculate each job category's share of all subscriptions.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0
        / (SELECT COUNT(*)
           FROM bank_marketing
           WHERE y = 'yes'),
        2
    ) AS share_of_all_subscriptions_pct

FROM bank_marketing

-- Calculate the metrics separately for each job category.
GROUP BY job

-- Rank job categories by their subscription contribution.
ORDER BY successful_subscriptions DESC;


-- Business Question:
-- Which contact method contributes the largest share of subscriptions?
--
-- COUNT(*) measures the number of records per contact method.
-- SUM(CASE...) counts subscriptions within each method.
-- The subscription rate measures the proportion of records
-- that resulted in a subscription within that method.
-- The contribution percentage measures each method's share
-- of all subscriptions in the dataset.

SELECT
    contact,

    -- Count all records for each contact method.
    COUNT(*) AS total_contacts,

    -- Count subscriptions for each contact method.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the subscription rate within each method.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct,

    -- Calculate each method's percentage of all subscriptions.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0
        / (SELECT COUNT(*)
           FROM bank_marketing
           WHERE y = 'yes'),
        2
    ) AS share_of_all_subscriptions_pct

FROM bank_marketing

-- Calculate the metrics separately for each contact method.
GROUP BY contact

-- Rank methods by the number of subscriptions they generated.
ORDER BY successful_subscriptions DESC;



-- Business Question:
-- Which combinations of age group, job category, and contact
-- method have the highest observed subscription rates?
--
-- CASE creates age bands to make the results easier to interpret.
-- GROUP BY compares combinations of the three dimensions.
-- COUNT(*) measures the sample size for each combination.
-- SUM(CASE...) counts successful subscriptions.
-- HAVING excludes groups with fewer than 100 records.
-- The results show associations, not causal effects.

SELECT
    -- Categorize customers into age bands.
    CASE
        WHEN age BETWEEN 17 AND 25 THEN '17-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,

    -- Include the customer's recorded job category.
    job,

    -- Include the method used to contact the customer.
    contact,

    -- Count records in this customer-segment combination.
    COUNT(*) AS total_contacts,

    -- Count subscriptions within this combination.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS successful_subscriptions,

    -- Calculate the subscription rate for this combination.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct

FROM bank_marketing

-- Compare records sharing the same age band, job, and contact method.
GROUP BY
    age_group,
    job,
    contact

-- Exclude combinations with fewer than 100 records.
HAVING COUNT(*) >= 100

-- Rank the largest observed subscription rates first.
ORDER BY subscription_rate_pct DESC

-- Show the top 20 qualifying combinations.
LIMIT 20;



-- Business Question:
-- What are the overall campaign KPIs for the final report?
--
-- COUNT(*) returns the total number of records.
-- Conditional SUM expressions count subscriptions and
-- non-subscriptions.
-- The percentage calculations measure the subscription
-- and non-subscription rates.
-- This query provides the overall baseline for the dashboard.

SELECT
    -- Total number of records in the prepared dataset.
    COUNT(*) AS total_records,

    -- Number of records that resulted in subscriptions.
    SUM(
        CASE
            WHEN y = 'yes' THEN 1
            ELSE 0
        END
    ) AS total_subscriptions,

    -- Number of records that did not result in subscriptions.
    SUM(
        CASE
            WHEN y = 'no' THEN 1
            ELSE 0
        END
    ) AS total_non_subscriptions,

    -- Percentage of records resulting in subscriptions.
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS subscription_rate_pct,

    -- Percentage of records not resulting in subscriptions.
    ROUND(
        SUM(CASE WHEN y = 'no' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS non_subscription_rate_pct

FROM bank_marketing;