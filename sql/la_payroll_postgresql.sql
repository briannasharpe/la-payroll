/*
! File is commented for SQL + Python implementation
* Run this file before replace_job_title_postgresql.py

! Uncomment "SQL ONLY IMPLEMENTATION" sections for SQL only implementation
*/

SET search_path TO la_payroll;

DROP TABLE IF EXISTS la_payroll_data_copy;
CREATE TABLE la_payroll_data_copy AS
SELECT *
FROM la_payroll_data;

-- SELECT *
-- FROM la_payroll_data_copy;

/* -------------------------------------------------------------------------- */
/*                              DEPARTMENT_TITLE                              */
/* -------------------------------------------------------------------------- */
UPDATE la_payroll_data_copy
SET DEPARTMENT_TITLE = REPLACE(DEPARTMENT_TITLE, 'HUMAN RIGHTS,', 'HUMAN RIGHTS')
WHERE DEPARTMENT_TITLE LIKE 'CIVIL, HUMAN RIGHTS, AND EQUITY DEPARTMENT';

/* -------------------------------------------------------------------------- */
/*                               EMPLOYMENT_TYPE                              */
/* -------------------------------------------------------------------------- */
UPDATE la_payroll_data_copy
SET EMPLOYMENT_TYPE = 
	CONCAT(
    CONCAT(LEFT(SPLIT_PART(EMPLOYMENT_TYPE, '_', 1), 1), RIGHT(SPLIT_PART(EMPLOYMENT_TYPE, '_', 1), CHAR_LENGTH(SPLIT_PART(EMPLOYMENT_TYPE, '_', 1)) - 1)),
		' ',
		CONCAT(LEFT(SPLIT_PART(EMPLOYMENT_TYPE, '_', -1), 1), RIGHT(SPLIT_PART(EMPLOYMENT_TYPE, '_', -1), CHAR_LENGTH(SPLIT_PART(EMPLOYMENT_TYPE, '_', -1)) - 1))
  );

/* -------------------------------------------------------------------------- */
/*                                 JOB_STATUS                                 */
/* -------------------------------------------------------------------------- */
UPDATE la_payroll_data_copy
SET JOB_STATUS = 
	CONCAT(
    CONCAT(LEFT(SPLIT_PART(JOB_STATUS, '_', 1), 1), RIGHT(SPLIT_PART(JOB_STATUS, '_', 1), CHAR_LENGTH(SPLIT_PART(JOB_STATUS, '_', 1)) - 1)),
		' ',
		CONCAT(LEFT(SPLIT_PART(JOB_STATUS, '_', -1), 1), RIGHT(SPLIT_PART(JOB_STATUS, '_', -1), CHAR_LENGTH(SPLIT_PART(JOB_STATUS, '_', -1)) - 1))
  )
WHERE JOB_STATUS LIKE '%\_%';

/* -------------------------------------------------------------------------- */
/*                                   GENDER                                   */
/* -------------------------------------------------------------------------- */
UPDATE la_payroll_data_copy
SET GENDER = 'N/A'
WHERE GENDER LIKE 'UNKNOWN' OR GENDER LIKE 'NA';

/* -------------------------------------------------------------------------- */
/*                                  ETHNICITY                                 */
/* -------------------------------------------------------------------------- */
UPDATE la_payroll_data_copy
SET ETHNICITY = 'N/A'
WHERE ETHNICITY IS NULL OR ETHNICITY LIKE 'NA' OR ETHNICITY LIKE 'NOT APPLICABLE' OR ETHNICITY LIKE 'UNKNOWN';

UPDATE la_payroll_data_copy
SET ETHNICITY = 'AMERICAN INDIAN/ALASKAN NATIVE'
WHERE ETHNICITY LIKE 'AMERICAN INDIAN';

/* -------------------------------------------------------------------------- */
/*                              JOB_CLASS_PGRADE                              */
/* -------------------------------------------------------------------------- */
UPDATE la_payroll_data_copy
SET JOB_CLASS_PGRADE = 'N/A'
WHERE JOB_CLASS_PGRADE IS NULL OR JOB_CLASS_PGRADE LIKE 'NA';

/* -------------------------------------------------------------------------- */
/*                                     MOU                                    */
/*                                  MOU_TITLE                                 */
/* -------------------------------------------------------------------------- */
UPDATE la_payroll_data_copy
SET MOU = 'N/A'
WHERE MOU LIKE 'NA' OR MOU LIKE 'nan';

UPDATE la_payroll_data_copy
SET MOU_TITLE = 'N/A'
WHERE MOU_TITLE IS NULL OR MOU_TITLE LIKE 'NA';

UPDATE la_payroll_data_copy
SET MOU_TITLE = REPLACE(MOU_TITLE, '.', '')
WHERE MOU_TITLE LIKE '%.%';

UPDATE la_payroll_data_copy
SET MOU_TITLE = REPLACE(MOU_TITLE, ',', ' -')
WHERE MOU_TITLE LIKE '%,%';

UPDATE la_payroll_data_copy
SET MOU_TITLE = REPLACE(MOU_TITLE, '/', ' -')
WHERE MOU_TITLE LIKE '%HIRING HALL%';

UPDATE la_payroll_data_copy
SET MOU_TITLE = REPLACE(MOU_TITLE, 'ASSOC', 'ASSOCIATION')
WHERE MOU_TITLE LIKE 'LOS ANGELES PORT POLICE ASSOC';

UPDATE la_payroll_data_copy
SET MOU_TITLE = REPLACE(MOU_TITLE, 'NON MANAGEMENT', 'NON-MANAGEMENT')
WHERE MOU_TITLE LIKE 'UNREPRESENTED UNIT - NON MANAGEMENT BENEFITS';

DROP TABLE IF EXISTS mou_replacement;
CREATE TABLE mou_replacement (
  new_mou VARCHAR(255),
  old_mou VARCHAR(255),
  mou_title VARCHAR(255)
);

INSERT INTO mou_replacement (new_mou, old_mou, mou_title) VALUES
('00', '0', 'NON-REPRESENTED'),
('00', '0.0', 'NON-REPRESENTED'),
('01', '1', 'ADMINISTRATIVE'),
('01', '1.0', 'ADMINISTRATIVE'),
('02', '2', 'BUILDING TRADES'),
('03', '3', 'CLERICAL'),
('03', '3.0', 'CLERICAL'),
('04', '4', 'EQUIPMENT OPERATION AND LABOR'),
('05', '5', 'INSPECTORS'),
('06', '6', 'LIBRARIANS'),
('07', '7', 'RECREATION ASSISTANTS'),
('08', '8', 'PROFESSIONAL ENGINEERING AND SCIENTIFIC'),
('09', '9', 'PLANT EQUIPMENT OPERATION AND REPAIR'),
('10', '3', 'PROFESSIONAL MEDICAL'),
('24', '24.0', 'POLICE OFFICERS - LIEUTENANT AND BELOW'),
('Z', '9', 'DAILY RATE'),
('V', '9', 'UNREPRESENTED UNIT - MANAGEMENT BENEFITS'),
('U', '9', 'UNREPRESENTED UNIT - NON-MANAGEMENT BENEFITS');

UPDATE la_payroll_data_copy p
SET MOU = r.new_mou
FROM mou_replacement r
WHERE p.MOU_TITLE = r.mou_title AND p.MOU = r.old_mou;

-- LADWP specific mou
DROP TABLE IF EXISTS ladwp_mou_title_replacement;
CREATE TABLE ladwp_mou_title_replacement (
  old_mou VARCHAR(255),
  new_mou VARCHAR(255),
  old_mou_title VARCHAR(255),
  new_mou_title VARCHAR(255)
);

INSERT INTO ladwp_mou_title_replacement (old_mou, new_mou, old_mou_title, new_mou_title) VALUES
('4', '41', 'ADMINISTRATIVE REPRESENTATION UNIT', 'ADMINISTRATIVE'),
('9', '41', 'ADMINISTRATIVE REPRESENTATION UNIT', 'ADMINISTRATIVE'),
('7', '42', 'CLERICAL UNIT', 'CLERICAL'),
('9', '42', 'CLERICAL UNIT', 'CLERICAL'),
('9', '44', 'LOAD DISPATCHERS UNIT', 'LOAD DISPATCHERS'),
('9', '46', 'MANAGEMENT EMPLOYEES UNIT', 'MANAGEMENT EMPLOYEES'),
('M', '46', 'MANAGEMENT EMPLOYEES UNIT', 'MANAGEMENT EMPLOYEES'),
('8', '47', 'OPERATING MAINTENANCE AND SERVICE UNIT', 'OPERATING, MAINTENANCE AND SERVICE'),
('9', '47', 'OPERATING MAINTENANCE AND SERVICE UNIT', 'OPERATING, MAINTENANCE AND SERVICE'),
('3', '48', 'PROFESSIONAL UNIT', 'PROFESSIONAL'),
('9', '48', 'PROFESSIONAL UNIT', 'PROFESSIONAL'),
('0', '49', 'SECURITY UNIT', 'SECURITY'),
('6', '50', 'STEAM PLANT AND WATER SUPPLY UNIT', 'STEAM PLANT AND WATER SUPPLY'),
('9', '50', 'STEAM PLANT AND WATER SUPPLY UNIT', 'STEAM PLANT AND WATER SUPPLY'),
('9', '51', 'SUPERVISORY BLUE COLLAR UNIT', 'SUPERVISORY BLUE COLLAR'),
('B', '51', 'SUPERVISORY BLUE COLLAR UNIT', 'SUPERVISORY BLUE COLLAR'),
('W', '52', 'SUPERVISORY CLERICAL AND ADMINISTRATIVE UNIT', 'SUPERVISORY CLERICAL AND ADMINISTRATIVE'),
('9', '53', 'SUPERVISORY PROFESSIONAL UNIT', 'SUPERVISORY PROFESSIONAL'),
('P', '53', 'SUPERVISORY PROFESSIONAL UNIT', 'SUPERVISORY PROFESSIONAL'),
('2', '54', 'TECHNICAL REPRESENTATION UNIT', 'TECHNICAL'),
('9', '54', 'TECHNICAL REPRESENTATION UNIT', 'TECHNICAL');

UPDATE la_payroll_data_copy p
SET MOU_TITLE = r.new_mou_title,
  MOU = r.new_mou
FROM ladwp_mou_title_replacement r
WHERE p.MOU_TITLE = r.old_mou_title AND p.MOU = r.old_mou;

/* -------------------------------------------------------------------------- */
/*                                  JOB_TITLE                                 */
/* -------------------------------------------------------------------------- */
CREATE INDEX idx_job_title ON la_payroll_data_copy(JOB_TITLE);
-- SHOW INDEX FROM la_payroll_data_copy;
-- DROP INDEX idx_job_title ON la_payroll_data_copy;

-- blank values
UPDATE la_payroll_data_copy
SET JOB_TITLE = 'N/A'
WHERE JOB_TITLE IS NULL OR JOB_TITLE LIKE 'NA';

-- abbreviations
DROP TABLE IF EXISTS job_title_abbrev_replacement;
CREATE TABLE job_title_abbrev_replacement (
  abbreviation VARCHAR(255) NOT NULL UNIQUE,
  full_word VARCHAR(255) NOT NULL,
  PRIMARY KEY (abbreviation)
  -- INDEX idx_abbreviation (abbreviation)
);
CREATE INDEX idx_abbreviation ON job_title_abbrev_replacement(abbreviation);
-- SHOW INDEX FROM job_title_abbrev_replacement;

INSERT INTO job_title_abbrev_replacement (abbreviation, full_word) VALUES
('ADMN', 'ADMINISTRATIVE'),
('ARCHT', 'ARCHITECT'),
('ARCHL', 'ARCHITECTURAL'),
('AQ', 'AQUEDUCT'),
('APPR', 'APPRENTICE'),
('ASST', 'ASSISTANT'),
('ATO', 'AUTO'),
('ATOV', 'AUTOMOTIVE'),
('AUDTR', 'AUDITOR'),
('ASBSTS', 'ASBESTOS'),
('ASSO', 'ASSOCIATE'),
('ASSOC', 'ASSOCIATE'),
('APPLTNS', 'APPLICATIONS'),
('AFF', 'AFFAIRS'),
('ATDT', 'ATTENDANT'),
('ANLST', 'ANALYST'),
('ACCT', 'ACCOUNTANT'),
('BUYR', 'BUYER'),
('BDY', 'BODY'),
('BLDR', 'BUILDER'),
('BLDGS', 'BUILDING'),
('BLDG', 'BUILDING'),
('BLKSMTH', 'BLACKSMITH'),
('BLRMKR', 'BOILERMAKER'),
('BRKLYR', 'BRICKLAYER'),
('BTRY', 'BATTERY'),
('CONDTG', 'CONDITIONING'),
('COMMUNIC', 'COMMUNICATIONS'),
('COMM', 'COMMISSION'),
('CBL', 'CABLE'),
('CHF', 'CHIEF'),
('CLK', 'CLERK'),
('CVL', 'CIVIL'),
('CMNT', 'CEMENT'),
('CMPUTR', 'COMPUTER'),
('CONSTR', 'CONSTRUCTION'),
('CNSTR', 'CONSTRUCTION'),
('CONST', 'CONSTRUCTION'),
('COML', 'COMMERCIAL'),
('CRPNTR', 'CARPENTER'),
('CRFT', 'CRAFT'),
('COORD', 'COORDINATOR'),
('CRTKR', 'CARETAKER'),
('CTG', 'COATING'),
('CLMS', 'CLAIMS'),
('CMPNSTN', 'COMPENSATION'),
('COMP', 'COMPENSATION'),
('DRFTG', 'DRAFTING'),
('DSPR', 'DISPATCHER'),
('DSGNR', 'DESIGNER'),
('DSGN', 'DESIGN'),
('DSTRBN', 'DISTRIBUTION'),
('DISTRIB', 'DISTRIBUTION'),
('DISTRBN', 'DISTRIBUTION'),
('DIV', 'DIVISION'),
('DLVRY', 'DELIVERY'),
('DRVR', 'DRIVER'),
('DOCMNTN', 'DOCUMENTATION'),
('DEPT', 'DEPARTMENT'),
('DUPL', 'DUPLICATING'),
('DIST', 'DISTRICT'),
('DTY', 'DUTY'),
('ENGG', 'ENGINEERING'),
('ENGRG', 'ENGINEERING'),
('ENGR', 'ENGINEER'),
('ELTN', 'ELECTRICIAN'),
('ELTC', 'ELECTRIC'),
('ELEC', 'ELECTRIC'),
('ELTL', 'ELECTRICAL'),
('EQPT', 'EQUIPMENT'),
('ERECTR', 'ERECTOR'),
('ELVR', 'ELEVATOR'),
('ENV', 'ENVIRONMENTAL'),
('ENVRNMNTL', 'ENVIRONMENTAL'),
('EXEC', 'EXECUTIVE'),
('EWDD', 'ECONOMIC AND WORKFORCE DEVELOPMENT DEPARTMENT'),
('EXMNR', 'EXAMINER'),
('FNSHR', 'FINISHER'),
('FLD', 'FIELD'),
('FABRICATR', 'FABRICATOR'),
('GEOLGST', 'GEOLOGIST'),
('GNL', 'GENERAL'),
('GEN', 'GENERAL'),
('GM', 'GENERAL MANAGER'),
('GPHCS', 'GRAPHICS'),
('GRDNR', 'GARDENER'),
('GRG', 'GARAGE'),
('GSD', 'GENERAL SERVICES DEPARTMENT'),
('HLPR', 'HELPER'),
('HVY', 'HEAVY'),
('HYDROGRPHR', 'HYDROGRAPHER'),
('HLTH', 'HEALTH'),
('INDL', 'INDUSTRIAL'),
('INDUS', 'INDUSTRIAL'),
('INFO', 'INFORMATION'),
('IRNWKR', 'IRON WORKER'),
('INSTRMT', 'INSTRUMENT'),
('KPR', 'KEEPER'),
('LABY', 'LABORATORY'),
('LAB', 'LABORATORY'),
('LEGSLTV', 'LEGISLATIVE'),
('LBR', 'LABOR'),
('LD', 'LOAD'),
('LN', 'LINE'),
('LOCKSMTH', 'LOCKSMITH'),
('MCHC', 'MECHANIC'),
('MKR', 'MAKER'),
('MGR', 'MANAGER'),
('MANA', 'MANAGER'),
('MTNC', 'MAINTENANCE'),
('MAILG', 'MAILING'),
('MTR', 'METER'),
('MGMT', 'MANAGEMENT'),
('MGT', 'MANAGEMENT'),
('MCHL', 'MECHANICAL'),
('MCHT', 'MACHINIST'),
('MCHN', 'MACHINE'),
('MNGG', 'MANAGING'),
('MSGR', 'MESSENGER'),
('MTLS', 'MATERIALS'),
('MTL', 'METAL'),
('OPRNS', 'OPERATIONS'),
('OPRG', 'OPERATING'),
('OPR', 'OPERATOR'),
('OFCR', 'OFFICER'),
('OFC', 'OFFICE'),
('OCPTNL', 'OCCUPATIONAL'),
('POLUTN', 'POLLUTION'),
('PAINTR', 'PAINTER'),
('PHOTOGRPHR', 'PHOTOGRAPHER'),
('PUB', 'PUBLIC'),
('PIPFTR', 'PIPEFITTER'),
('PLMBR', 'PLUMBER'),
('PWR', 'POWER'),
('PREP', 'PREPAREDNESS'),
('PRSR', 'PRESSURE'),
('PRSNL', 'PERSONNEL'),
('PK', 'PARK'),
('PL', 'PRINCIPAL'),
('PR', 'PRINCIPAL'),
('PRGMR', 'PROGRAMMER'),
('PROCSG', 'PROCESSING'),
('PRCSG', 'PROCESSING'),
('PRNTG', 'PRINTING'),
('PRTV', 'PROTECTIVE'),
('PLN', 'PLAN'),
('PTY', 'PARTY'),
('PLT', 'PLANT'),
('PRFSNL', 'PROFESSIONAL'),
('RPRR', 'REPAIRER'),
('RPR', 'REPAIR'),
('REPTV', 'REPRESENTATIVE'),
('REP', 'REPRESENTATIVE'),
('RNFCG', 'REINFORCING'),
('RDR', 'READER'),
('ROOFR', 'ROOFER'),
('RES', 'RESEARCH'),
('RELS', 'RELATIONS'),
('RETIRE', 'RETIREMENT'),
('RL', 'REAL'),
('RESV', 'RESERVOIR'),
('SPLST', 'SPECIALIST'),
('SPCLT', 'SPECIALIST'),
('SUPVG', 'SUPERVISING'),
('SUPV', 'SUPERVISOR'),
('SUP', 'SUPERVISOR'),
('SUPER', 'SUPERVISOR'),
('SU', 'SUPERVISOR'),
('SUPERINTEND', 'SUPERINTENDENT'),
('SECTY', 'SECURITY'),
('SECY', 'SECRETARY'),
('SFTY', 'SAFETY'),
('SRVCS', 'SERVICES'),
('SERV', 'SERVICES'),
('SRVC', 'SERVICE'),
('SHVL', 'SHOVEL'),
('STL', 'STEEL'),
('STRL', 'STRUCTURAL'),
('SHP', 'SHOP'),
('SETR', 'SETTER'),
('STN', 'STATION'),
('SYS', 'SYSTEMS'),
('SRVYG', 'SURVEYING'),
('SRVY', 'SURVEY'),
('STATL', 'STATISTICAL'),
('SHT', 'SHEET'),
('SR', 'SENIOR'),
('STENO', 'STENOGRAPHER'),
('STRKPR', 'STOREKEEPER'),
('STM', 'STEAM'),
('SURGN', 'SURGEON'),
('TCHN', 'TECHNICIAN'),
('TECH', 'TECHNICIAN'),
('TRK', 'TRUCK'),
('TRBL', 'TROUBLE'),
('TSTR', 'TESTER'),
('TSTG', 'TESTING'),
('TNEE', 'TRAINEE'),
('TLRM', 'TOOLROOM'),
('TRTMT', 'TREATMENT'),
('UTLTY', 'UTILITY'),
('UG', 'UNDERGROUND'),
('UPHLSTR', 'UPHOLSTERER'),
('VSLS', 'VESSELS'),
('WKR', 'WORKER'),
('WKRS', 'WORKERS'),
('WLDR', 'WELDER'),
('WHSE', 'WAREHOUSE'),
('WTRWKS', 'WATERWORKS'),
('WTR', 'WATER'),
('WP', 'WATER AND POWER');
/* SQL ONLY IMPLEMENTATION:
CREATE TEMPORARY TABLE temp_job_replacement AS
	SELECT abbreviation, full_word
	FROM job_title_abbrev_replacement
	ORDER BY CHAR_LENGTH(abbreviation) DESC;

UPDATE la_payroll_data_copy p
SET JOB_TITLE = TRIM(REGEXP_REPLACE(
  JOB_TITLE,
  ('(\m|\s)' || r.abbreviation || '(\s|\M)'),
  (' ' || r.full_word || ' '),
  'g'))
FROM temp_job_replacement r
WHERE JOB_TITLE ~ ('(\m|\s)' || r.abbreviation || '(\s|\M)');
*/
-- duplicate abbreviations and specific fixes
CREATE TYPE replacement_type AS ENUM ('ABBREVIATION', 'REPLACEMENT', 'SPELLING');

DROP TABLE IF EXISTS job_title_word_replacement;
CREATE TABLE job_title_word_replacement (
  incorrect_word VARCHAR(255),
  correct_word VARCHAR(255),
  match_condition VARCHAR(255) NOT NULL,
  replacement_type REPLACEMENT_TYPE NOT NULL,
  PRIMARY KEY (incorrect_word, match_condition)
);

INSERT INTO job_title_word_replacement (incorrect_word, correct_word, match_condition, replacement_type) VALUES
('CLASS CODE NOT IN TABLE 305', 'N/A', 'CLASS CODE NOT IN TABLE 305', 'REPLACEMENT'),
('AFFAIR', 'AFFAIRS', '% AFFAIR', 'SPELLING'),
('AID', 'AIDE', '% AID %', 'SPELLING'),
('EST', 'ESTIMATOR', '% EST', 'ABBREVIATION'),
('EST', 'ESTATE', '%REAL EST %', 'ABBREVIATION'),
('EST', 'ESTATE', '%RL EST %', 'ABBREVIATION'),
('PLUMBER 1', 'PLUMBER I', '%PLUMBER 1%', 'REPLACEMENT'),
('SYSTEM', 'SYSTEMS', '%SYSTEM %', 'SPELLING'),
('ENGINEER-AIRPORT', 'ENGINEER - AIRPORT', 'CHIEF BUILDING OPERATING ENGINEER-AIRPORT', 'SPELLING'),
('MECHANIC-HARBOR', 'MECHANIC - HARBOR', 'EQUIPMENT MECHANIC-HARBOR', 'SPELLING'),
('ENGINEER-SURVEYOR', 'ENGINEER - SURVEYOR', 'OPERATING ENGINEER-SURVEYOR GROUP I', 'SPELLING'),
('AIRPORTS/1', 'AIRPORTS I', 'DEPUTY GENERAL MANAGER AIRPORTS/1', 'REPLACEMENT'),
('AIRPORTS/2', 'AIRPORTS II', 'DEPUTY GENERAL MANAGER AIRPORTS/2', 'REPLACEMENT');
/* SQL ONLY IMPLEMENTATION:
UPDATE la_payroll_data_copy p
SET JOB_TITLE = TRIM(REGEXP_REPLACE(
  JOB_TITLE,
  ('(\m|\s)' || r.incorrect_word || '(\s|\M)'),
  (' ' || r.correct_word || ' '),
  'g'))
FROM joB_title_word_replacement r
WHERE JOB_TITLE LIKE r.match_condition;
*/
UPDATE la_payroll_data_copy
SET JOB_TITLE = REPLACE(JOB_TITLE, ' (PART TIME)', '')
WHERE JOB_TITLE LIKE '%(PART TIME)%';

UPDATE la_payroll_data_copy
SET JOB_TITLE = REPLACE(JOB_TITLE, '&', 'AND')
WHERE JOB_TITLE LIKE '%&%';

/* --------------------------- DROP HELPER TABLES --------------------------- */
/*
DROP TABLE IF EXISTS 
  mou_replacement, 
  ladwp_mou_title_replacement, 
  job_title_abbrev_replacement, 
  job_title_word_replacement;

DROP TYPE replacement_type;
*/