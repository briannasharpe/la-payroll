import mysql.connector
import csv
import time

CHUNK = 10_000
CSV_FILE = rf'..\data_original\City_Employee_Payroll__Current__20250128.csv'
DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''
DB_NAME = 'la_payroll'
TABLE_NAME = 'la_payroll_data'
COLUMN_TYPES = {
  'RECORD_NBR': 'VARCHAR(255)', 
	'PAY_YEAR': 'YEAR', 
	'LAST_NAME': 'VARCHAR(255)', 
	'FIRST_NAME': 'VARCHAR(255)', 
	'DEPARTMENT_NO': 'INT', 
	'DEPARTMENT_TITLE': 'VARCHAR(255)', 
	'JOB_CLASS_PGRADE': 'VARCHAR(255)', 
	'JOB_TITLE': 'VARCHAR(255)', 
	'EMPLOYMENT_TYPE': 'VARCHAR(255)', 
	'JOB_STATUS': 'VARCHAR(255)', 
	'MOU': 'VARCHAR(255)', 
	'MOU_TITLE': 'VARCHAR(255)', 
	'REGULAR_PAY': 'DECIMAL(19,2)', 
	'OVERTIME_PAY': 'DECIMAL(19,2)', 
	'ALL_OTHER_PAY': 'DECIMAL(19,2)', 
	'TOTAL_PAY': 'DECIMAL(19,2)', 
	'CITY_RETIREMENT_CONTRIBUTIONS': 'DECIMAL(19,2)', 
	'BENEFIT_PAY': 'DECIMAL(19,2)', 
	'GENDER': 'VARCHAR(255)', 
	'ETHNICITY': 'VARCHAR(255)', 
	'ROW_ID': 'VARCHAR(255)'
}

with open(CSV_FILE) as file:
  data = csv.reader(file)
  headers = next(data)
  columns = ', '.join([f'`{col}` {COLUMN_TYPES.get(col)}' for col in headers])

placeholders = ', '.join(['%s'] * len(headers))
insert_query = f'INSERT INTO {TABLE_NAME} ({', '.join(headers)}) VALUES ({placeholders})'

connection = mysql.connector.connect(
  user=DB_USER,
  password=DB_PASSWORD,
  host=DB_HOST
)

cursor = connection.cursor()

def createDatabase():
  print(f'Creating database')
  cursor.execute(f'CREATE DATABASE IF NOT EXISTS {DB_NAME}')
  cursor.execute(f'USE {DB_NAME}')

def createTable():
  print(f'Creating table')
  cursor.execute(f'DROP TABLE IF EXISTS {TABLE_NAME}')
  cursor.execute(f'CREATE TABLE {TABLE_NAME} ({columns})')

def doBulkInsert(data):
  print(f'Inserting rows')
  rows = []
  rows_inserted = 0

  for row in data:
    rows.append(tuple(row))

    if len(rows) == CHUNK:
      cursor.executemany(insert_query, rows)
      connection.commit()
      rows_inserted += len(rows)
      rows.clear()

  if rows:
    cursor.executemany(insert_query, rows)
    connection.commit()
    rows_inserted += len(rows)

  print(f'Inserted {rows_inserted} rows')

def main():
  _s = time.perf_counter()
  createDatabase()
  createTable()

  with open(CSV_FILE) as file:
    data = csv.reader(file)
    next(data)
    doBulkInsert(data)

  print(f'Duration = {time.perf_counter()-_s}')

  cursor.close()
  connection.close()

if __name__ == '__main__':
  main()