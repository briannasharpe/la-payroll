# LA Payroll Data Analysis

1. [Data Information](#data-information)
2. [Data Cleaning](#data-cleaning)
3. [Data Analysis](#data-analysis)

Data cleaned with

* SQL (MySQL, PostgreSQL)
* Python

Visualized in

* Microsoft Power BI

## Data Information

The dataset contains payroll information for all Los Angeles City Employees including the City's three proprietary departments: Water and Power, Airports and Harbor. Sourced from [City Employee Payroll](https://controllerdata.lacity.org/Payroll/City-Employee-Payroll-Current-/g9h8-fvhu/about_data) when last updated on January 27, 2025.

## Data Cleaning

### Standardized Data

Revised columns:

* DEPARTMENT_TITLE
* JOB_CLASS_PGRADE
* JOB_TITLE
* EMPLOYMENT_TYPE
* JOB_STATUS
* MOU
* MOU_TITLE
* GENDER
* ETHNICITY

MOU and MOU_TITLE information from:

* The Official Website of the City of Los Angeles - [MOU](https://cao.lacity.gov/MOUs/)
* Los Angeles Department of Water & Power - [MOU](https://labrel.ladwp.com/Mou/Index), [Other MOU](https://labrel.ladwp.com/Mou/Other)

### Steps to Recreate Data Cleaning

Methods: **SQL + Python**, **SQL only**

1. Import dataset from `data_original`
    * **SQL**
      * Import `City_Employee_Payroll__Current__20250128.csv` from `data_original` through IDE
        * Database - `la_payroll`
        * Schema - `la_payroll`
        * Table - `la_payroll_data`

        ```sql
        RECORD_NBR VARCHAR(255), 
        -- MySQL: PAY_YEAR YEAR, 
        -- PostgreSQL: PAY_YEAR INT,
        LAST_NAME VARCHAR(255), 
        FIRST_NAME VARCHAR(255), 
        DEPARTMENT_NO INT, 
        DEPARTMENT_TITLE VARCHAR(255), 
        JOB_CLASS_PGRADE VARCHAR(255), 
        JOB_TITLE VARCHAR(255), 
        EMPLOYMENT_TYPE VARCHAR(255), 
        JOB_STATUS VARCHAR(255), 
        MOU VARCHAR(255), 
        MOU_TITLE VARCHAR(255), 
        REGULAR_PAY DECIMAL(19,2), 
        OVERTIME_PAY DECIMAL(19,2), 
        ALL_OTHER_PAY DECIMAL(19,2), 
        TOTAL_PAY DECIMAL(19,2), 
        CITY_RETIREMENT_CONTRIBUTIONS DECIMAL(19,2), 
        BENEFIT_PAY DECIMAL(19,2), 
        GENDER VARCHAR(255), 
        ETHNICITY VARCHAR(255), 
        ROW_ID VARCHAR(255)
        ```

        > **MySQL**
        > 1. Create a new schema in the connected server
        >     * **(Top bar)** Database icon > Name schema `la_payroll`
        >     * **(Sidebar)** Right click sidebar 'Create Schema' > Name schema `la_payroll`
        > 2. Import csv file data
        >     * Right click `la_payroll` > Table Data Import Wizard > File path
        >     * Create new table `la_payroll_data`
        >     * Configure import settings
        
        > **pgAdmin**
        > 1. Create a new server
        >     * Right click 'Servers' > Register > Server
        >       * General > Name server
        >       * Connection > Host name/address & Password
        > 2. Create a new database
        >     * Right click 'Databases' > Create
        >       * General > Name database
        > 3. Create a new schema
        >     * Right click 'Schemas' > Create
        >       * General > Name schema
        > 4. Create a new table
        >     * Right click 'Schemas' > Query Tool
        >     * Run `CREATE TABLE la_payroll_data (...)` with the values from above
        >     * Right click `la_payroll_data` table > Import/Export data

    * **Python**
      * **(MySQL)** Run `import_csv_to_mysql.py`

2. Run data cleaning files
    * **SQL + Python**
      * Run `la_payroll_mysql.sql` or `la_payroll_postgresql.sql`
      * Run `replace_job_title_mysql.py` or `replace_job_title_postgresql.py`
    * **SQL**
        * For SQL only implementation, `la_payroll_mysql.sql` and `la_payroll_postgresql.sql` contain instructions on adjusting the file
        * Run `la_payroll_mysql.sql` or `la_payroll_postgresql.sql`

3. Export dataset to `data_cleaned`
    * **SQL**
      * **MySQL**
        * Navigator > `la_payroll` Database > Table > Right click `la_payroll_data_copy` > Export
      * **pgAdmin**
        * Right click `la_payroll_data_copy` table > Import/Export data
    * **Python**
      * **(MySQL)** Run `export_mysql_to_csv.py`

## Data Analysis

This report will only account for 2017-2023 as the data for pay year 2024 is incomplete. Detailed report in `data_analysis/la_payroll.pdf`.

The Power BI file (`data_analysis/la_payroll.pbix`) includes 2024 data along with detailed visual graphics (drill downs) for four different categories: department, job, ethnicity, and gender.

### General

* Total payroll - **$42.95 billion**
* Highest payroll
  * 2023 - **$7.05 billion**
  * 2022 - **$6.48 billion**
  * 2020 - **$6.42 billion**
* Average total pay - **$85.51k**
  * Average regular pay - **$68.76k**
  * Average overtime pay - **$11.10k**
  * Average benefit pay - **$10.82k**
  * Average all other pay - **$5.65k**
* Average employee count - **71.76k employees**

### Department

Highest pay

1. Public Accountability (**$156.70k**)
2. Fire (**$155.07k**)
3. Water and Power (**$126.12k**)

Highest employee count

1. Police (**14.98k employees** or **20.88%**)
2. Water and Power (**12.41k employees** or **17.29%**)
3. Recreation and Parks (**9.49k employees** or **13.23%**)

### Job

Highest pay

1. Chief Port Pilot II (**$430.72k**)
2. General Manager and Chief Engineer - Water and Power (**$392.47k**)
3. General Manager - Harbor Department (**$387.40k**)

Highest employee count

1. Police Officer II (**4.26k employees** or **5.94%**)
2. Recreation Assistant (**2.49k employees** or **3.46%**)
3. Police Officer III (**2.39k employees** or **3.33%**)

### Ethnicity

Highest pay

1. Asian American (**$131.43k**)
2. Caucasian (**$106.65k**)
3. American Indian/Alaskan Native (**$99.06k**)

Highest employee count

1. Hispanic (**27.94k employees** or **38.94%**)
2. Caucasian (**12.60k employees** or **24.53%**)
3. Black (**10.98k employees** or **15.30%**)

### Gender

Highest Pay

1. Male (**$97.64k**)
2. Female (**$61.88k**)

Highest employee count

1. Male (**47.86k employees** or **66.70%**)
2. Female (**23.59k employees** or **32.88%**)
