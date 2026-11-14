-- Widen quantity columns without changing existing quantities.
USE [BSDB2];
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Sach') AND name = 'SoLuongTon' AND TYPE_NAME(system_type_id) = 'int')
    ALTER TABLE dbo.Sach ALTER COLUMN SoLuongTon BIGINT NULL;
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ChiTietDDH') AND name = 'SoLuong' AND TYPE_NAME(system_type_id) = 'int')
    ALTER TABLE dbo.ChiTietDDH ALTER COLUMN SoLuong BIGINT NULL;
COMMIT;
GO
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE (TABLE_NAME = 'Sach' AND COLUMN_NAME = 'SoLuongTon')
   OR (TABLE_NAME = 'ChiTietDDH' AND COLUMN_NAME = 'SoLuong');
