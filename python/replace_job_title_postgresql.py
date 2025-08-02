import psycopg2
import psycopg2.extras
import re
import time

DB_HOST = 'localhost'
DB_USER = 'postgres'
DB_PASSWORD = ''
DB_NAME = 'la_payroll'
TABLE_NAME = 'la_payroll_data_copy'

abbrev_replacement_query = f'''
SELECT abbreviation, full_word 
FROM {DB_NAME}.job_title_abbrev_replacement 
ORDER BY CHAR_LENGTH(abbreviation) DESC
'''

word_replacement_query = f'''
SELECT incorrect_word, correct_word, match_condition 
FROM {DB_NAME}.job_title_word_replacement
'''

job_title_query = f'''
SELECT JOB_TITLE 
FROM {DB_NAME}.{TABLE_NAME} 
'''

update_job_title_query = f'''
UPDATE {DB_NAME}.{TABLE_NAME} 
SET JOB_TITLE = %s 
WHERE JOB_TITLE = %s
'''

chunk = 10000
updated_rows = []

connection = psycopg2.connect(
  user=DB_USER,
  password=DB_PASSWORD,
  host=DB_HOST,
  database=DB_NAME
)

cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)

# table query
print(f'Fetching table data')

cursor.execute(abbrev_replacement_query)
abbrev_replacement = cursor.fetchall()
abbrev_replacement_dict = []
for row in abbrev_replacement:
  abbrev_replacement_dict.append(dict(row))

cursor.execute(word_replacement_query)
word_replacement = cursor.fetchall()
word_replacement_dict = []
for row in word_replacement:
  word_replacement_dict.append(dict(row))

cursor.execute(job_title_query)
job_title = cursor.fetchall()
job_title_dict = []
for row in job_title:
  job_title_dict.append(dict(row))

# update
print(f'Updating table data')
_s = time.perf_counter()

for row in job_title_dict:
  original_title = row['job_title']
  new_title = original_title

  for item in abbrev_replacement_dict:
    abbreviation = item['abbreviation']
    full_word = item['full_word']
    new_title = re.sub(rf'\b{re.escape(abbreviation)}\b', full_word, new_title)

  for item in word_replacement_dict:
    incorrect_word = item['incorrect_word']
    correct_word = item['correct_word']
    match_condition = item['match_condition'].strip('%')

    if match_condition in original_title or match_condition == '':
      new_title = re.sub(rf'\b{re.escape(incorrect_word)}\b', correct_word, new_title)

  if new_title != original_title:
    updated_rows.append((new_title, original_title))
  
if updated_rows:
  for i in range(0, len(updated_rows), chunk):
    cursor.executemany(update_job_title_query, updated_rows[i:i + chunk])
    connection.commit()

cursor.close()
connection.close()

print(f'Updated {len(updated_rows)} rows')
print(f'Duration = {time.perf_counter()-_s}')