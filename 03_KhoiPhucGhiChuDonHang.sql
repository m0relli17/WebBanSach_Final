-- Targeted repair for DonDatHang.GhiChu only.
-- This repair is already included in 01_NangCapDatabase.sql; use this file only if restoring the note column by itself.
USE [BSDB2];
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF COL_LENGTH('dbo.DonDatHang', 'GhiChu') IS NULL
    ALTER TABLE dbo.DonDatHang ADD GhiChu NVARCHAR(500) NULL;
COMMIT;
GO
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DonDatHang' AND COLUMN_NAME = 'GhiChu';
