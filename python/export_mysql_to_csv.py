import mysql.connector
import csv
import time
import os

DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''
DB_NAME = 'la_payroll'
TABLE_NAME = 'la_payroll_data_copy'
CSV_FILE = 'la_payroll_mysql.csv'
OUTPUT_FOLDER = rf'..\data_cleaned'
OUTPUT_PATH = os.path.join(OUTPUT_FOLDER, CSV_FILE)

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

connection = mysql.connector.connect(
  user=DB_USER,
  password=DB_PASSWORD,
  host=DB_HOST,
  database=DB_NAME
)

cursor = connection.cursor()
_s = time.perf_counter()

print(f'Fetching table data')
cursor.execute(f'SELECT * FROM {TABLE_NAME}')
rows = cursor.fetchall()
columns = [i[0] for i in cursor.description]

print(f'Writing to file')
with open(OUTPUT_PATH, mode='w', newline='') as file:
  data = csv.writer(file)
  data.writerow(columns)
  data.writerows(rows)

cursor.close()
connection.close()

print(f'Exported {TABLE_NAME} to {OUTPUT_PATH}')
print(f'Duration = {time.perf_counter()-_s}')