# Stock Data Analysis Project

This project involves retrieving historical stock data, storing it in a MySQL database, and performing various analytical queries to analyze stock performance over time.

## Overview

The primary goal of this project is to collect stock market data for a range of tickers, save it to a MySQL database, and perform SQL queries to analyze this data. The analysis includes calculating stock price performance, identifying missing data, comparing stock performance to indices, and computing stock price changes over specified periods.

## Steps Overview

### 1. Fetching Historical Stock Data

The project uses the `yfinance` library to download historical stock data for a list of stock tickers. The data retrieved includes daily stock prices such as the open, high, low, close, adjusted close, and volume. The stock data spans a period of 10 years, and this data is collected for multiple stock tickers.

### 2. Data Preparation

The data includes information about weekends and holidays, which are classified separately. The project uses the `holidays` library to account for US national holidays. Each date in the collected stock data is labeled as a 'Weekday', 'Weekend', or 'Holiday' based on the date and the corresponding holiday calendar.

### 3. MySQL Database Setup

After the stock data is fetched, the data is stored in a MySQL database. A connection to the MySQL server is established using the `sqlalchemy` library, and the stock data is saved in a table within the database. If the database does not already exist, it is created programmatically.

### 4. Modifying Database Schema

Once the data is inserted, the schema of the tables is modified to set appropriate data types for the columns. For example:
- The `stock_id` column is set as an integer and primary key.
- The `stock_date`, `stock_open`, `stock_high`, `stock_low`, `stock_close`, `stock_adj_close`, and `stock_volume` columns are appropriately defined with their respective data types.

Additionally, another table for date information is created, which includes the holiday and weekday classification for each date.

### 5. SQL Queries for Data Analysis

Once the data is stored in MySQL, various SQL queries are run to analyze the data, including:

1. **Stock Ticker Retrieval**: Query to get a list of unique stock tickers in the database.
2. **Stock Closing Prices on a Specific Date**: Query to retrieve the closing prices for all tickers on a particular date.
3. **Fractional Shares Calculation**: Query to calculate how many whole shares and fractional shares could be bought for a $1000 investment on the latest stock data.
4. **Missing Dates in Stock Data**: A recursive query to find any missing dates where stock data is not available.
5. **Stock Price Comparison (Previous Day)**: Query to compare the latest stock closing prices with those from the previous day.
6. **Price Performance Over Time**: A query to calculate the percentage change in stock prices over the last 7 and 30 days and rank stocks by their performance.
7. **Stock vs S&P 500 Price Appreciation**: Query to compare the price appreciation of individual stocks with the S&P 500 index over the first 21 trading days of January.

### 6. Performance Metrics

In addition to basic stock data, the project also calculates:
- **Percentage Change**: How much a stock's price has changed over a given period (e.g., 7 days, 30 days).
- **Performance Ranking**: Ranking stocks based on their performance over a specified period.
- **Price Appreciation**: Comparing the price appreciation of stocks to the performance of the S&P 500 index.

### 7. Recursive Query for Missing Dates

A recursive Common Table Expression (CTE) is used to generate a date range, identifying dates where stock data might be missing. This helps identify any gaps in the data.

### 8. Data Integrity Checks

SQL queries ensure the integrity and consistency of the data by checking for missing records, comparing historical prices, and validating stock data for specific periods.

## Requirements

- **Python Libraries**:
  - `pandas`: For data manipulation.
  - `yfinance`: For retrieving stock data.
  - `sqlalchemy`: For database connection and data insertion.
  - `holidays`: For handling holiday dates in the US.
- **MySQL Database**:
  - A local or remote MySQL server is required for storing the stock data.

# Contributor: Huy Nguyen
