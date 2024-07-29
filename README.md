
# Project Report: E-Commerce Data Analysis


The primary objective of this project is to analyze e-commerce data to extract meaningful insights regarding customer behavior, product popularity, session duration, and conversion ratios. This report summarizes the findings from various SQL queries executed on the dataset.



## Table Creation

The E_COMM table was created to store e-commerce transaction data, including user interactions, session details, product IDs, transaction amounts, and outcomes.

## Table Creation : 


```bash
  CREATE TABLE SQL_PROJECT.PUBLIC.E_COMM (
    USER_ID INT,
    SessionID varchar(50),
    Timestamp DATETIME,
    Event_type varchar(20),
    Product_ID varchar(20),
    amount bigint,
    outcome varchar(20)
);

```
Customer Segmentation Based on Sessions and Revenue:
```bash
SELECT USER_ID, count(SESSIONID) as Total_Visits ,SUM(AMOUNT) as Total_Rev 
FROM E_COMM
GROUP BY USER_ID
```
Revenue-Based Customer Segmentation:

```bash
SELECT *, NTILE(4) OVER(ORDER BY TOTAL_REV DESC) as PERCENTILE 
FROM (
    SELECT USER_ID, count(SESSIONID) as Total_Visits ,SUM(AMOUNT) as Total_Rev  
    FROM E_COMM
    GROUP BY USER_ID
)
```
Popular Products Among Top Percentile Customers:
```bash
WITH CX_GROUP AS (
    SELECT *, NTILE(4) OVER(ORDER BY TOTAL_REV DESC) as PERCENTILE 
    FROM (
        SELECT USER_ID, count(SESSIONID) as Total_Visits ,SUM(AMOUNT) as Total_Rev  
        FROM E_COMM
        GROUP BY USER_ID
    )
    WHERE PERCENTILE=1
)
SELECT P.PRODUCT_ID, COUNT(P.PRODUCT_ID) AS PURCHASE_COUNT 
FROM E_COMM AS P 
JOIN CX_GROUP AS C ON P.USER_ID=C.USER_ID
GROUP BY P.PRODUCT_ID
ORDER BY PURCHASE_COUNT DESC
```
Average Session Duration Based on Purchase Status:

```bash
WITH SessionDurations AS (
    SELECT USER_ID, SESSIONID, MIN(timestamp) AS session_start, MAX(timestamp) AS session_end, 
           MAX(timestamp) - MIN(timestamp) AS duration,
           SUM(CASE WHEN EVENT_TYPE = 'purchase' THEN 1 ELSE 0 END) AS purchases
    FROM E_COMM
    GROUP BY USER_ID, SESSIONID
)
SELECT CASE WHEN purchases > 0 THEN 'With Purchase' ELSE 'Without Purchase' END AS purchase_status,
       AVG(duration) AS avg_session_duration
FROM SessionDurations
GROUP BY purchase_status;
```
Recommended Products for Users:
```bash
SELECT USER_ID, PRODUCT_ID, COUNT(1) AS VIEW_FREQ 
FROM E_COMM 
WHERE EVENT_TYPE != 'purchase'
GROUP BY USER_ID, PRODUCT_ID
HAVING PRODUCT_ID IS NOT NULL
```
Highest View-to-Purchase Conversion Ratio:
```bash
SELECT P.*, F.Frequency_view / P.Frequency_pur AS ratio 
FROM (
    SELECT PRODUCT_ID, COUNT(EVENT_TYPE) AS Frequency_pur 
    FROM E_COMM 
    WHERE EVENT_TYPE = 'purchase'
    GROUP BY PRODUCT_ID
) P 
JOIN (
    SELECT PRODUCT_ID, COUNT(EVENT_TYPE) AS Frequency_view 
    FROM E_COMM 
    WHERE EVENT_TYPE = 'product_view'
    GROUP BY PRODUCT_ID
) F ON P.PRODUCT_ID = F.PRODUCT_ID
ORDER BY ratio DESC
```
Average Order Value per User:
```bash
SELECT USER_ID, AVG(AMOUNT) AS AVERAGE_REV 
FROM E_COMM
GROUP BY USER_ID
ORDER BY AVERAGE_REV DESC
LIMIT 5
```
Determined the time of day with the highest user engagement (views, purchases, add to cart)
```bash
SELECT HOUR(TIMESTAMP) AS TIME, COUNT(EVENT_TYPE) AS ENG 
FROM E_COMM 
WHERE EVENT_TYPE IN ('add_to_cart', 'purchase', 'product_view') 
GROUP BY TIME
ORDER BY ENG
```
Identified product combinations that are commonly purchased together.
```bash
SELECT P1.*, P2.PRODUCT_ID 
FROM (
    SELECT USER_ID, PRODUCT_ID 
    FROM E_COMM 
    WHERE EVENT_TYPE = 'purchase'
) AS P1 
JOIN (
    SELECT USER_ID, PRODUCT_ID 
    FROM E_COMM 
    WHERE EVENT_TYPE = 'purchase'
) AS P2 
ON P1.USER_ID = P2.USER_ID 
AND P1.PRODUCT_ID != P2.PRODUCT_ID
```


## Summary of Findings : 

**Customer Segmentation:** Customers were effectively segmented based on their session count and revenue contribution, enabling targeted marketing strategies.

**Top Percentile Analysis:** The most popular products among high-spending customers were identified, which can inform inventory and marketing decisions.

**Session Duration Insights:** Users who made purchases tended to have longer session durations, highlighting the importance of engagement for conversion.

**Product Recommendations:** Frequently viewed but not purchased products were identified for potential recommendations to users.

**Conversion Ratios:** Products with high view-to-purchase ratios were highlighted as high performers.

**Average Order Value:** The top users by average order value were identified, useful for loyalty programs or targeted promotions.

**User Engagement:** Peak engagement times were determined, which can optimize marketing and operational activities.
Product Combinations: Commonly purchased product combinations were found, useful for bundling strategies.

## Tech Stack

**Warehouse:** Snowflake



