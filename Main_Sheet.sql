CREATE TABLE SQL_PROJECT.PUBLIC.E_COMM (
    USER_ID INT,
    SessionID varchar(50),
    Timestamp DATETIME,
    Event_type varchar(20),
    Product_ID varchar(20),
    amount bigint,
    outcome varchar(20)
);

DROP TABLE SQL_PROJECT.PUBLIC.E_COMM

USE DATABASE SQL_PROJECT

SELECT * FROM E_COMM

--Segmenting Customers Against No of Sessions and Revenue

SELECT USER_ID, count(SESSIONID) as Total_Visits ,SUM(AMOUNT) as Total_Rev  from E_COMM
GROUP BY USER_ID

--Segmenting Customers Against No of Sessions and Revenue in 4 parts based on revenue

SELECT *,NTILE(4) OVER(ORDER BY TOTAL_REV DESC) as PERCENTILE FROM (SELECT USER_ID, count(SESSIONID) as Total_Visits ,SUM(AMOUNT) as Total_Rev  from E_COMM
GROUP BY USER_ID

-- Proiducts that are famous among the Percentile 1 Customers
WITH CX_GROUP(USER_ID,TOTAL_VISITS,TOTAL_REV,PERCENTILE) AS
(
SELECT * FROM (SELECT *,NTILE(4) OVER(ORDER BY TOTAL_REV DESC) as PERCENTILE FROM (SELECT USER_ID, count(SESSIONID) as Total_Visits ,SUM(AMOUNT) as Total_Rev  from E_COMM
GROUP BY USER_ID)) WHERE PERCENTILE=1
)
SELECT P.PRODUCT_ID,COUNT(P.PRODUCT_ID) AS PURCHASE_COUNT FROM E_COMM AS P JOIN CX_GROUP AS C ON P.USER_ID=C.USER_ID
GROUP BY P.PRODUCT_ID
ORDER BY PURCHASE_COUNT DESC

--What is the average session duration for users who make a purchase versus those who don't?
WITH SessionDurations AS (
    SELECT
        USER_ID,
        SESSIONID,
        MIN(timestamp) AS session_start,
        MAX(timestamp) AS session_end,
        MAX(timestamp) - MIN(timestamp) AS duration,
        SUM(CASE WHEN EVENT_TYPE = 'purchase' THEN 1 ELSE 0 END) AS purchases
    FROM
        E_COMM
    GROUP BY
        USER_ID, SESSIONID
)

SELECT
    CASE WHEN purchases > 0 THEN 'With Purchase' ELSE 'Without Purchase' END AS purchase_status,
    AVG(duration) AS avg_session_duration
FROM
    SessionDurations
GROUP BY
    purchase_status;


-- Recommended Products for users
SELECT USER_ID,PRODUCT_ID,COUNT(1) AS VIEW_FREQ FROM E_COMM WHERE EVENT_TYPE !='purchase'
GROUP BY USER_ID,PRODUCT_ID
HAVING PRODUCT_ID IS NOT NULL


--Which products have the highest view-to-purchase conversion ratio?

SELECT P.*,P.Frequency_pur, F.Frequency_view/P.Frequency_pur as ratio FROM (SELECT PRODUCT_ID, count(EVENT_TYPE) as Frequency_pur FROM E_COMM where EVENT_TYPE='purchase'
GROUP BY PRODUCT_ID) P 
JOIN (SELECT PRODUCT_ID, count(EVENT_TYPE) as Frequency_view FROM E_COMM where EVENT_TYPE='product_view'
GROUP BY PRODUCT_ID) F
ON P.PRODUCT_ID=F.PRODUCT_ID
ORDER BY RATIO DESC

--What is the average order value for different user 
SELECT USER_ID, AVG(AMOUNT) AS AVERAGE_REV FROM E_COMM
GROUP BY USER_ID
ORDER BY AVERAGE_REV DESC
LIMIT 5

--What time of day sees the highest user engagement (views and purchases and add to cart)?
SELECT HOUR(TIMESTAMP) AS TIME, COUNT(EVENT_TYPE) as ENG FROM E_COMM WHERE EVENT_TYPE IN('add_to_cart','purchase','product_view') 
GROUP BY TIME
ORDER BY ENG

--What product combinations are commonly purchased together

SELECT P1.*,P2.PRODUCT_ID FROM (SELECT USER_ID,PRODUCT_ID FROM E_COMM WHERE EVENT_TYPE='purchase') as P1 JOIN (SELECT USER_ID,PRODUCT_ID FROM E_COMM WHERE EVENT_TYPE='purchase') AS P2
ON P1.USER_ID=P2.USER_ID AND P1.PRODUCT_ID !=P2.PRODUCT_ID


