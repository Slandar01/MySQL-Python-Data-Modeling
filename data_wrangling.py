# PLEASE CHANGE USERNAME AND PASSWORD OF THE ENGINE SO PYTHON CAN ACCESS YOUR MYSQL
# THE ENGINE IS AROUND THE BOTTOM OF THE CODE
import pandas as pd
import yfinance as yf # please import yfinance if not yet install
from sqlalchemy import create_engine # please install the sqlalchemy if not yet install
from datetime import datetime, timedelta # please install the datetime if not yet install
import holidays

# Define the start and end dates
end_date = datetime.now().date()
start_date = end_date - timedelta(days=365 * 10)

# Define the US holidays
us_holidays = holidays.UnitedStates()

# Create an empty list to store the dates and day types
date_list = []
day_type_list = []

# Loop through the date range and append each date to the list
current_date = start_date
while current_date < end_date:
    date_list.append(current_date)
    if current_date.weekday() >= 5:
        day_type = 'Weekend'
    elif current_date in us_holidays:
        holiday_name = us_holidays.get(current_date)
        day_type = f'Holiday ({holiday_name})'
    else:
        day_type = 'Weekday'
    day_type_list.append(day_type)
    current_date += timedelta(days=1)

# Create a DataFrame from the lists
df = pd.DataFrame({'date': date_list, 'day_type': day_type_list})

# The list of stock tickers
stocks = ['^SPX', 'AAPL', 'ABBV', 'ADBE', 'AMD', 'AMZN', 'BBY', 'COKE', 'COST', 'CRM', 'CSCO', 'CVX', 'DPZ', 'GME',
          'GOOGL', 'GS', 'HD', 'HMC', 'JNJ', 'JPM', 'KDP', 'KR', 'LOW', 'MA', 'MCD', 'META', 'MSFT', 'MUFG', 'NFLX',
          'XOM', 'NTDOY', 'NVDA', 'ORCL', 'PEP', 'PG', 'SBUX', 'TM', 'TMUS', 'TSLA', 'UNH', 'WMT']

# Create an empty list to store the stock data
stock_data_list = []

# Retrieve stock data for each ticker and append to the list
for ticker in stocks:
    data = yf.download(ticker, group_by="Ticker", start=start_date, end=end_date)
    data['ticker'] = ticker
    stock_data_list.append(data)

# Concatenate the stock data into a single DataFrame and rename the columns
stock_data = pd.concat(stock_data_list)
stock_data = stock_data.reset_index()
stock_data.insert(0, 'stock_id', range(100000, 100000 + len(stock_data)))
stock_data = stock_data.rename(columns={'Date': 'stock_date', 'Open': 'stock_open', 'High': 'stock_high',
                                        'Low': 'stock_low', 'Close': 'stock_close', 'Adj Close': 'stock_adj_close',
                                        'Volume': 'stock_volume', 'ticker': 'stock_ticker'})

# Create a MySQL engine to export the data to MySQL
# ONLY CHANGE USERNAME AND PASSWORD, SCHEMA WILL BE CREATE BY THE CODE
engine = create_engine('mysql+pymysql://root:Hadesares2508!@localhost/')

try:
    engine.execute("CREATE DATABASE project2")
    print("Database 'project2' created successfully.")
except Exception as e:
    print(f"Error creating database: {e}")

engine = create_engine('mysql+pymysql://root:Hadesares2508!@localhost/project2')

# Insert the stock data and date information into the database
table_name = 'stock_data'
stock_data.to_sql(table_name, con=engine, if_exists='replace', index=False)
df.to_sql('date_info', con=engine, if_exists='replace', index=False)

# Print a success message
print("\nData inserted successfully.\n")