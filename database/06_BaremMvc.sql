USE [BSDB2];
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
ALTER TABLE dbo.Admin ALTER COLUMN MatKhau VARCHAR(256) NOT NULL;
-- Authors may have been born before 1900; SQL smalldatetime cannot represent those dates.
ALTER TABLE dbo.TacGia ALTER COLUMN NgaySinh DATE NULL;
ALTER TABLE dbo.TacGia ALTER COLUMN NgayMat DATE NULL;
IF COL_LENGTH('dbo.DonDatHang','ShippingFee') IS NULL
    ALTER TABLE dbo.DonDatHang ADD ShippingFee DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.DonDatHang','ReceiverName') IS NULL
    ALTER TABLE dbo.DonDatHang ADD ReceiverName NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.DonDatHang','ReceiverPhone') IS NULL
    ALTER TABLE dbo.DonDatHang ADD ReceiverPhone NVARCHAR(50) NULL;
IF COL_LENGTH('dbo.DonDatHang','ReceiverAddress') IS NULL
    ALTER TABLE dbo.DonDatHang ADD ReceiverAddress NVARCHAR(250) NULL;
IF COL_LENGTH('dbo.DonDatHang','PaymentMethod') IS NULL
    ALTER TABLE dbo.DonDatHang ADD PaymentMethod VARCHAR(20) NULL;
COMMIT;
GO
