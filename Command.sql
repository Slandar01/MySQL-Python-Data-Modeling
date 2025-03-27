# PLEASE RUN THE PYTHON FIRST AND THEN RUN EVERYTHING HERE ACCORDINGLY TO THE ORDER

# Only Run this once
USE project2;

# Only Run this once
ALTER TABLE `project2`.`stock_data` 
CHANGE COLUMN `stock_id` `stock_id` INT NOT NULL ,
CHANGE COLUMN `stock_date` `stock_date` DATE NULL DEFAULT NULL,
CHANGE COLUMN `stock_open` `stock_open` DECIMAL(10,2) NULL DEFAULT NULL ,
CHANGE COLUMN `stock_high` `stock_high` DECIMAL(10,2) NULL DEFAULT NULL ,
CHANGE COLUMN `stock_low` `stock_low` DECIMAL(10,2) NULL DEFAULT NULL ,
CHANGE COLUMN `stock_close` `stock_close` DECIMAL(10,2) NULL DEFAULT NULL ,
CHANGE COLUMN `stock_adj_close` `stock_adj_close` DECIMAL(10,2) NULL DEFAULT NULL ,
CHANGE COLUMN `stock_volume` `stock_volume` BIGINT NULL DEFAULT NULL ,
CHANGE COLUMN `stock_ticker` `stock_ticker` VARCHAR(10) NULL DEFAULT NULL ,
ADD PRIMARY KEY (`stock_id`);

# Only Run this once
ALTER TABLE `project2`.`date_info`
CHANGE COLUMN `date` `date` DATE NULL DEFAULT NULL ,
CHANGE COLUMN `day_type` `day_type` VARCHAR(100) NULL DEFAULT NULL;


SELECT * FROM project2.stock_data;


#Qa:
SELECT stock_ticker FROM stock_data
GROUP BY stock_ticker;

#Qb:
SELECT stock_ticker, round(sum(stock_close),2) AS closing_price, stock_date
FROM stock_data
WHERE stock_date = '2022-04-12'
GROUP BY stock_ticker
ORDER BY sum(stock_close);


#Qc:

SELECT stock_ticker, FLOOR(1000 / stock_close) AS whole_shares, ROUND((1000 - (FLOOR(1000 / stock_close) * stock_close)) / stock_close,2) AS fractional_shares
FROM stock_data
WHERE stock_date = (SELECT MAX(stock_date) FROM stock_data)
ORDER BY stock_ticker;


#Qd:

#Only run this once, it will temporarily change your @@cte_max_recursion_depth
SET @@cte_max_recursion_depth = 300000;


WITH recursive date_range AS (
    SELECT MIN(Date) AS date
    FROM date_info
    UNION ALL
    SELECT date + INTERVAL 1 DAY
    FROM date_range
    WHERE date < (SELECT MAX(Date) FROM date_info)
),
missing_dates AS (
    SELECT date_range.date
    FROM date_range
    LEFT JOIN stock_data ON date_range.date = stock_data.stock_date
    WHERE stock_data.stock_date IS NULL
)
SELECT
    missing_dates.date,
    date_info.day_type
FROM missing_dates
LEFT JOIN date_info ON missing_dates.date = date_info.Date
ORDER BY missing_dates.date;








#Qe:



SELECT t1.stock_ticker, t1.stock_date, t1.stock_close, t2.stock_close AS previous_close
FROM stock_data t1
LEFT JOIN stock_data t2 ON t1.stock_ticker = t2.stock_ticker
AND t1.stock_date = DATE_ADD(t2.stock_date, INTERVAL 1 DAY)
WHERE t1.stock_date = (SELECT MAX(stock_date) FROM stock_data)
AND t1.stock_close > COALESCE(t2.stock_close, 0)
ORDER BY t1.stock_close DESC;



#Qf


WITH cte AS (SELECT st.stock_ticker, round(((max(st.stock_close) - min(st.stock_close)) / min(st.stock_close)) * 100, 2) AS percentage_change,
        CASE
            WHEN st.stock_date >= (SELECT max(stock_date) - interval 7 day FROM stock_data) THEN 'last_7_days'
            WHEN st.stock_date >= (SELECT max(stock_date) - interval 30 day FROM stock_data) THEN 'last_30_days'
        END AS period
    FROM stock_data st
    WHERE st.stock_date >= (SELECT max(stock_date) - INTERVAL 30 DAY FROM stock_data)
    GROUP BY st.stock_ticker, period
)
select stock_ticker, percentage_change, period,
		RANK() OVER (PARTITION BY period ORDER BY percentage_change DESC) AS performance_rank
FROM cte
ORDER BY period, performance_rank;


#Qg


SELECT t1.stock_ticker, ROUND(t1.price_appreciation, 2) AS security_price_appreciation,
    ROUND(t2.price_appreciation, 2) AS sp500_price_appreciation
FROM
    (
        SELECT stock_ticker, stock_date,
            (stock_close / LAG(stock_close, 21) OVER (PARTITION BY stock_ticker ORDER BY stock_date) - 1) * 100 AS price_appreciation
        FROM stock_data
        WHERE stock_date >= '2014-01-01' AND MONTH(stock_date) = 1 AND DAY(stock_date) <= 21
    ) t1
    JOIN
    (
        SELECT stock_date,
            (stock_close / LAG(stock_close, 21) OVER (ORDER BY stock_date) - 1) * 100 AS price_appreciation
        FROM stock_data
        WHERE stock_ticker = '^SPX' AND stock_date >= '2014-01-01' AND MONTH(stock_date) = 1 AND DAY(stock_date) <= 21
    ) t2 ON t1.stock_date = t2.stock_date
WHERE t1.price_appreciation IS NOT NULL AND t2.price_appreciation IS NOT NULL
ORDER BY t1.price_appreciation DESC;



