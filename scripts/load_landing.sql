/*
===============================================================================
Project Name   : Banking Analytics Data Warehouse
Script Purpose : Load Raw Data into Landing Layer

Description:
This script loads raw source data files into the Landing Layer of the
Banking Analytics Data Warehouse.

The process performs the following actions:
    1. Clears existing Landing Layer data.
    2. Loads transaction data from CSV files.
    3. Loads client data from CSV files.
    4. Loads card data from CSV files.
    5. Loads Merchant Category Code (MCC) reference data from JSON.
    6. Loads fraud classification labels from JSON.

Layer:
    Landing (Raw Data Layer)

Source Files:
    - transactions_data.csv
    - users_data.csv
    - cards_data.csv
    - mcc_codes.json
    - train_fraud_labels.json
===============================================================================
*/

USE BankingAnalyticsDB;
GO

/*=============================================================================
    LOAD: Transactions
    SOURCE: transactions_data.csv
=============================================================================*/

Truncate table landing.transactions_raw;
bulk insert landing.transactions_raw
from 'c:\sqldata\financial_dateset\transactions_data.csv'
with
(
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '0x0a',
    tablock
);
go


/*=============================================================================
    LOAD: Clients
    SOURCE: users_data.csv
=============================================================================*/

Truncate table landing.clients_raw;
bulk insert landing.clients_raw
from 'c:\sqldata\financial_dateset\users_data.csv'
with
(
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '0x0a',
    tablock
);
go


/*=============================================================================
    LOAD: Cards
    SOURCE: cards_data.csv
=============================================================================*/

Truncate table landing.cards_raw;

bulk insert landing.cards_raw
from 'c:\sqldata\financial_dateset\cards_data.csv'
with
(
    firstrow = 2,
    fieldterminator = ',',
    rowterminator = '0x0a',
    tablock
);
go
/*=============================================================================
    LOAD: Merchant Category Codes (MCC)
    SOURCE: mcc_codes.json
=============================================================================*/

Truncate table landing.mcc_codes_raw;
insert into landing.mcc_codes_raw
(
    mcc_code,
    mcc_description
)
select
    try_cast([key] as int) as mcc_code,
    [value] as mcc_description
from openjson
(
    (
        select bulkcolumn
        from openrowset
        (
            bulk 'c:\sqldata\mcc_codes.json',
            single_clob
        ) as json_file
    )
);
go

/*=============================================================================
    LOAD: Fraud Labels
    SOURCE: train_fraud_labels.json
=============================================================================*/

Truncate table landing.fraud_labels_raw;
go

declare @json nvarchar(max);

select @json = bulkcolumn
from openrowset
(
    bulk 'c:\sqldata\train_fraud_labels.json',
    single_clob
) as json_file;

insert into landing.fraud_labels_raw
(
    transaction_id,
    fraud_flag
)
select
    try_cast(j2.[key] as bigint) as transaction_id,
    cast(j2.[value] as varchar(20)) as fraud_flag
from openjson(@json) j1
cross apply openjson
(
    cast(j1.[value] as nvarchar(max))
) j2;
go
