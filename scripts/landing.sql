/*==============================================================
  LANDING LAYER TABLES
  Project : Banking Analytics ELT Platform
  Layer   : Landing
  Purpose : Store raw source data as received

  Description:
This script creates the Landing Layer tables for the Banking Analytics
Data Warehouse. The Landing Layer serves as the raw data ingestion zone,
storing source data in its original format prior to any cleansing,
transformation, or business rule application.

Layer:
    Landing (Raw Data Layer)

Source Entities:
    - Transactions
    - Clients
    - Cards
    - Merchant Category Codes (MCC)
    - Fraud Labels
==============================================================*/

use BankingAnalyticsDB;
go

/*==============================================================
  Transactions
==============================================================*/

if object_id('landing.transactions_raw', 'u') is not null
    drop table landing.transactions_raw
go

    create table landing.transactions_raw
    (
        id               int,
        date             datetime2(7),
        client_id        smallint,
        card_id          smallint,
        amount           varchar(50),
        use_chip         nvarchar(50),
        merchant_id      int,
        merchant_city    nvarchar(50),
        merchant_state   nvarchar(50),
        zip              varchar(50),
        mcc              smallint,
        errors           varchar(max)
    );
go

/*==============================================================
  Users as clients
==============================================================*/

if object_id('landing.clients_raw', 'u') is not null
drop table landing.clients_raw
go

    create table landing.clients_raw
    (
        id                  varchar(50),
        current_age         varchar(50),
        retirement_age      varchar(50),
        birth_year          varchar(50),
        birth_month         varchar(50),
        gender              nvarchar(50),
        address             nvarchar(50),
        latitude            varchar(50),
        longitude           varchar(50),
        per_capita_income   nvarchar(50),
        yearly_income       nvarchar(50),
        total_debt          nvarchar(50),
        credit_score        varchar(50),
        num_credit_cards    varchar(50)
    );
go

/*==============================================================
  Cards
==============================================================*/

if object_id('landing.cards_raw', 'u') is not null
drop table landing.cards_raw
go

    create table landing.cards_raw
    (
        id                      smallint, 
        client_id               smallint,
        card_brand              nvarchar(50),
        card_type               nvarchar(50),
        card_number             bigint,
        expires                 nvarchar(50),
        cvv                     smallint,
        has_chip                varchar(10),
        num_cards_issued        tinyint,
        credit_limit            nvarchar(50),
        acct_open_date          nvarchar(50),
        year_pin_last_changed   int,
        card_on_dark_web        nvarchar(50)
    );
go

/*==============================================================
  Mcc codes
==============================================================*/

if object_id('landing.mcc_codes_raw', 'u') is not null
drop table landing.mcc_codes_raw
go

    create table landing.mcc_codes_raw
    (
        mcc_code           int,
        mcc_description    varchar(255)
    );
go

/*==============================================================
  Fraud labels
==============================================================*/

if object_id('landing.fraud_labels_raw', 'u') is not null
drop table landing.fraud_labels_raw

    create table landing.fraud_labels_raw
    (
        transaction_id    bigint,
        fraud_flag        varchar(20)
    );
go
