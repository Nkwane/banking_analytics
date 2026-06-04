/*
===============================================================================
Project Name   : Banking Analytics Data Warehouse
Script Purpose  : Create database and schema structure

Description:
This script sets up the foundational environment for a layered data warehouse
architecture consisting of:
    - Landing (raw ingestion layer)
    - Core (cleaned and standardized layer)
    - Mart (business reporting layer)

Design Pattern:
    Medallion Architecture (Bronze → Silver → Gold equivalent)
===============================================================================
*/

USE master;
GO

if not exists (
    select 1 
    from sys.databases 
    where name = 'BankingAnalyticsDB'
)
begin
    create database BankingAnalyticsDB;
end;
go

use BankingAnalyticsDB;
go

-- ----------------------------
-- Landing Schema (Raw Data Layer)
-- ----------------------------
if not exists (
    select 1 
    from sys.schemas 
    where name = 'landing'
)
begin
    exec('create schema landing');
end;
go

-- ----------------------------
-- Core Schema (Cleaned Data Layer)
-- ----------------------------
if not exists (
    select 1 
    from sys.schemas 
    where name = 'core'
)
begin
    exec('create schema core');
end;
go

-- ----------------------------
-- Mart Schema (Business / Reporting Layer)
-- ----------------------------
if not exists (
    select 1 
    from sys.schemas 
    where name = 'mart'
)
begin
    exec('create schema mart');
end;
go
