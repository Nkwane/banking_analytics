/*
===============================================================================
Project Name   : Banking Analytics Data Warehouse
Script Purpose : Create Mart Layer Views
Author         : Your Name
Created Date   : 2026-06-04

Description:
This script creates the Mart Layer views for the Banking Analytics
Data Warehouse.

The Mart Layer provides business-ready datasets optimized for reporting,
dashboarding, and analytical consumption in Power BI.

These views expose:
    - Transaction facts
    - Customer dimensions
    - Card dimensions
    - Merchant category dimensions
    - Customer analytics
    - Fraud analytics
    - Merchant performance metrics
    - Customer segmentation
    - Monthly transaction trends

Source Layer:
    Core

Target Layer:
    Mart

Views Created:
    - mart.fact_transactions
    - mart.dim_customer
    - mart.dim_card
    - mart.dim_mcc
    - mart.customer_summary
    - mart.fraud_summary
    - mart.merchant_summary
    - mart.category_summary
    - mart.card_performance
    - mart.customer_segments
    - mart.monthly_transaction_trend
    - mart.state_summary
===============================================================================
*/

USE BankingAnalyticsDB;
GO

/*=============================================================================
    VIEW: mart.fact_transactions

    DESCRIPTION:
    Central fact view containing transaction activity enriched with
    merchant category and fraud information.
=============================================================================*/
create or alter view mart.fact_transactions
as
select
    t.trans_id,
    t.trans_date,
    t.trans_time,
    t.client_id,
    t.card_id,
    t.amount,
    t.use_chip,
    t.merchant_id,
    t.merchant_city,
    t.merchant_state,
    t.zip,
    t.mcc,
    m.mcc_description,
    f.fraud_flag
from core.transactions t
left join core.mcc_codes m
    on t.mcc = m.mcc_code
left join core.fraud_labels f
    on t.trans_id = f.transaction_id;
go

/*=============================================================================
    VIEW: mart.dim_customer

    DESCRIPTION:
    Customer dimension containing demographic and financial attributes.
=============================================================================*/

create or alter view mart.dim_customer
as
select
    clients_id as client_id,
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
from core.clients;
go

/*=============================================================================
    VIEW: mart.dim_card

    DESCRIPTION:
    Card dimension containing card attributes and ownership information.
=============================================================================*/

create or alter view mart.dim_card
as
select
    card_id,
    client_id,
    card_brand,
    card_type,
    has_chip,
    credit_limit,
    acct_open_date,
    card_on_dark_web
from core.cards;
go

/*=============================================================================
    VIEW: mart.dim_mcc

    DESCRIPTION:
    Merchant Category Code reference dimension.
=============================================================================*/

create or alter view mart.dim_mcc
as
select
    mcc_code,
    mcc_description
from core.mcc_codes;
go


/*=============================================================================
    VIEW: mart.customer_summary

    DESCRIPTION:
    Customer-level transaction and spending summary.
=============================================================================*/

create or alter view mart.customer_summary
as
select
    c.clients_id,
    c.gender,
    c.current_age,
    c.credit_score,
    c.yearly_income,
    c.total_debt,
    count(t.trans_id) as total_transactions,
    sum(t.amount) as total_spend,
    avg(t.amount) as avg_transaction_amount,
    min(t.trans_date) as first_transaction_date,
    max(t.trans_date) as last_transaction_date
from core.clients c
left join core.transactions t
    on c.clients_id = t.client_id
group by
    c.clients_id,
    c.gender,
    c.current_age,
    c.credit_score,
    c.yearly_income,
    c.total_debt;
go


/*=============================================================================
    VIEW: mart.fraud_summary

    DESCRIPTION:
    Fraud transaction performance and analysis summary.
=============================================================================*/

create or alter view mart.fraud_summary
as
select
    isnull(f.fraud_flag,'unknown') as fraud_flag,
    count(*) as transaction_count,
    sum(t.amount) as total_amount,
    avg(t.amount) as avg_amount
from core.transactions t
left join core.fraud_labels f
    on t.trans_id = f.transaction_id
group by
    isnull(f.fraud_flag,'unknown');
go

/*=============================================================================
    VIEW: mart.merchant_summary

    DESCRIPTION:
    Merchant performance summary by city and state.
=============================================================================*/

create or alter view mart.merchant_summary
as
select
    merchant_id,
    merchant_city,
    merchant_state,
    count(*) as transaction_count,
    sum(amount) as total_sales,
    avg(amount) as avg_transaction_amount
from core.transactions
group by
    merchant_id,
    merchant_city,
    merchant_state;
go


/*=============================================================================
    VIEW: mart.category_summary

    DESCRIPTION:
    Spending analysis by Merchant Category Code.
=============================================================================*/
create or alter view mart.category_summary
as
select
    m.mcc_description,
    count(*) as transaction_count,
    sum(t.amount) as total_spend,
    avg(t.amount) as avg_spend
from core.transactions t
inner join core.mcc_codes m
    on t.mcc = m.mcc_code
group by
    m.mcc_description;
go

/*=============================================================================
    VIEW: mart.card_performance

    DESCRIPTION:
    Card usage and spending performance analysis.
=============================================================================*/

create or alter view mart.card_performance
as
select
    c.card_brand,
    c.card_type,
    c.has_chip,
    count(t.trans_id) as transaction_count,
    sum(t.amount) as total_spend,
    avg(t.amount) as avg_transaction_amount
from core.transactions t
inner join core.cards c
    on t.card_id = c.card_id
group by
    c.card_brand,
    c.card_type,
    c.has_chip;
go

/*=============================================================================
    View: mart.customer_segments

    Description:
    Customer segmentation based on income and credit score.
=============================================================================*/

create or alter view mart.customer_segments
as
select
    clients_id as client_id,
    yearly_income,
    credit_score,
    total_debt,
    case
        when yearly_income < 30000 then 'low income'
        when yearly_income < 80000 then 'middle income'
        else 'high income'
    end as income_band,
    case
        when credit_score < 600 then 'poor'
        when credit_score < 700 then 'fair'
        when credit_score < 800 then 'good'
        else 'excellent'
    end as credit_band
from core.clients;
go

/*=============================================================================
    View: mart.monthly_transaction_trend

    Description:
    monthly transaction volume and spending trend analysis.
=============================================================================*/

create or alter view mart.monthly_transaction_trend
as
select
    year(trans_date) as transaction_year,
    month(trans_date) as transaction_month,
    datename(month, trans_date) as month_name,
    count(*) as transaction_count,
    sum(amount) as total_amount
from core.transactions
group by
    year(trans_date),
    month(trans_date),
    datename(month, trans_date);
go

/*=============================================================================
    View: mart.state_summary

    Description:
    state-level transaction and spending analysis.
=============================================================================*/

create or alter view mart.state_summary
as
select
    merchant_state,
    count(*) as transaction_count,
    sum(amount) as total_spend,
    avg(amount) as avg_spend
from core.transactions
group by
    merchant_state;
go



