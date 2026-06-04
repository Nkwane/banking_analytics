/*===============================================================================
Project Name   : Banking Analytics Data Warehouse
Script Purpose : Build Core Layer Tables and Transform Source Data

Description:
This script creates and populates the Core Layer of the Banking Analytics
Data Warehouse.

The Core Layer transforms raw source data from the Landing Layer into
standardized, validated, and analytics-ready datasets.

Key Transformations:
    - Standardize data types
    - Convert currency values to numeric formats
    - Split transaction date and time
    - Handle missing values
    - Standardize categorical fields
    - Add audit load timestamps

Source Layer:
    Landing

Target Layer:
    Core

Tables Created:
    - core.transactions
    - core.clients
    - core.cards
    - core.mcc_codes
    - core.fraud_labels
===============================================================================*/

USE BankingAnalyticsDB;
GO

/*==============================================================
  Transactions
==============================================================*/

IF OBJECT_ID('core.transactions', 'U') IS NOT NULL
    DROP TABLE core.transactions;
GO

CREATE TABLE core.transactions
(
    trans_id         INT,
    trans_date       DATE,
    trans_time       TIME,
    client_id        SMALLINT,
    card_id          SMALLINT,
    amount           DECIMAL(18,2),
    use_chip         NVARCHAR(50),
    merchant_id      INT,
    merchant_city    NVARCHAR(50),
    merchant_state   NVARCHAR(50),
    zip              VARCHAR(50),
    mcc              SMALLINT,
    errors           VARCHAR(MAX),
    load_time        DATE NOT NULL DEFAULT SYSDATETIME()
);
GO

INSERT INTO core.transactions
(
    trans_id,
    trans_date,
    trans_time,
    client_id,
    card_id,
    amount,
    use_chip,
    merchant_id,
    merchant_city,
    merchant_state,
    zip,
    mcc,
    errors
)
SELECT
    id AS trans_id,
    CAST([date] AS DATE) AS trans_date,
    CAST([date] AS TIME) AS trans_time,
    client_id,
    card_id,
    CAST(REPLACE(amount, '$', '') AS DECIMAL(18,2)) AS amount,
    use_chip,
    merchant_id,
    merchant_city,
    ISNULL(merchant_state, 'N/A') AS merchant_state,
    ISNULL(zip, 'N/A') AS zip,
    mcc,
    ISNULL(errors, 'None') AS errors
FROM landing.transactions_raw;
GO
    
/*==============================================================
  Clients
==============================================================*/

IF OBJECT_ID('core.clients', 'U') IS NOT NULL
    DROP TABLE core.clients;
GO

CREATE TABLE core.clients
(
    clients_id          int,
    current_age         int,
    retirement_age      int,
    birth_year          int,
    birth_month         VARCHAR(20),
    gender              VARCHAR(20),
    address             VARCHAR(50),
    latitude            VARCHAR(50),
    longitude           VARCHAR(50),
    per_capita_income   DECIMAL(18,2),
    yearly_income       DECIMAL(18,2),
    total_debt          DECIMAL(18,2),
    credit_score        INT,
    num_credit_cards    INT,
    load_time           DATETIME2(7) NOT NULL DEFAULT SYSDATETIME()
);
GO
INSERT INTO core.clients
(
    clients_id,
    current_age,
    retirement_age,
    birth_year,
    birth_month,
    gender,
    address,
    latitude,
    longitude,
    per_capita_income,
    yearly_income,
    total_debt,
    credit_score,
    num_credit_cards
)
SELECT
    id AS clients_id,
    CAST(current_age AS INT) AS current_age,
    CAST(retirement_age AS INT) AS retirement_age,
    CAST(birth_year AS INT) AS birth_year,
    DATENAME
    (
        MONTH,
        DATEFROMPARTS(2000, CAST(birth_month AS INT), 1)
    ) AS birth_month,
    gender,
    address,
    CAST(latitude AS DECIMAL(10,6)) AS latitude,
    CAST(longitude AS DECIMAL(10,6)) AS longitude,
    CAST(REPLACE(per_capita_income, '$', '') AS DECIMAL(18,2)) AS per_capita_income,
    CAST(REPLACE(yearly_income, '$', '') AS DECIMAL(18,2)) AS yearly_income,
    CAST(REPLACE(total_debt, '$', '') AS DECIMAL(18,2)) AS total_debt,
    CAST(credit_score AS INT) AS credit_score,
    CAST(num_credit_cards AS INT) AS num_credit_cards
FROM landing.clients_raw;
GO

/*==============================================================
  Cards
==============================================================*/

IF OBJECT_ID('core.cards', 'U') IS NOT NULL
    DROP TABLE core.cards;
GO

CREATE TABLE core.cards
(
    card_id                 INT,
    client_id               INT,
    card_brand              VARCHAR(50),
    card_type               VARCHAR(50),
    card_number             BIGINT,
    expires                 VARCHAR(50),
    cvv                     INT,
    has_chip                VARCHAR(10),
    num_cards_issued        INT,
    credit_limit            DECIMAL(18,2),
    acct_open_date          NVARCHAR(50),
    year_pin_last_changed   VARCHAR(50),
    card_on_dark_web        VARCHAR(50),
    load_time               DATETIME2(7) NOT NULL DEFAULT SYSDATETIME()
);
GO
INSERT INTO core.cards
(
    card_id,
    client_id,
    card_brand,
    card_type,
    card_number,
    expires,
    cvv,
    has_chip,
    num_cards_issued,
    credit_limit,
    acct_open_date,
    year_pin_last_changed,
    card_on_dark_web
)

SELECT
    id AS card_id,
    client_id,
    UPPER(card_brand) AS card_brand,
    UPPER(card_type) AS card_type,
    card_number,
    expires,
    cvv,
    CASE
        WHEN has_chip = 'YES' THEN 'Yes'
        WHEN has_chip = 'NO' THEN 'No'
        ELSE 'Unknown'
    END AS has_chip,
    num_cards_issued,
    CAST(REPLACE(credit_limit, '$', '') AS DECIMAL(18,2)) AS credit_limit,
  acct_open_date,
    year_pin_last_changed,
   card_on_dark_web
FROM landing.cards_raw;
GO

/*==============================================================
  MCC codes
==============================================================*/

IF OBJECT_ID('core.mcc_codes', 'U') IS NOT NULL
    DROP TABLE core.mcc_codes;
GO
CREATE TABLE core.mcc_codes
(
    mcc_code           INT,
    mcc_description    VARCHAR(255),
    load_time          DATETIME2(7) NOT NULL DEFAULT SYSDATETIME()
);
GO
INSERT INTO core.mcc_codes
(
    mcc_code,
    mcc_description
)
SELECT
    mcc_code,
    mcc_description
FROM landing.mcc_codes_raw;
GO

/*==============================================================
  Fraud labels
==============================================================*/

IF OBJECT_ID('core.fraud_labels', 'U') IS NOT NULL
    DROP TABLE core.fraud_labels;
GO

CREATE TABLE core.fraud_labels
(
    transaction_id    BIGINT,
    fraud_flag        VARCHAR(20),
    load_time         DATETIME2(7) NOT NULL DEFAULT SYSDATETIME()
);
GO
INSERT INTO core.fraud_labels
(
    transaction_id,
    fraud_flag
)
SELECT
    transaction_id,
    fraud_flag
FROM landing.fraud_labels_raw;
GO