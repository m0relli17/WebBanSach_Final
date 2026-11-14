USE [BSDB2];
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Sach') AND name = 'SoLuongTon' AND TYPE_NAME(system_type_id) = 'int')
    ALTER TABLE dbo.Sach ALTER COLUMN SoLuongTon BIGINT NULL;
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ChiTietDDH') AND name = 'SoLuong' AND TYPE_NAME(system_type_id) = 'int')
    ALTER TABLE dbo.ChiTietDDH ALTER COLUMN SoLuong BIGINT NULL;

IF COL_LENGTH('dbo.KhachHang','EmailVerified') IS NULL
    ALTER TABLE dbo.KhachHang ADD EmailVerified BIT NOT NULL CONSTRAINT DF_KhachHang_EmailVerified DEFAULT(0);
ALTER TABLE dbo.KhachHang ALTER COLUMN MatKhau VARCHAR(256) NOT NULL;
IF COL_LENGTH('dbo.DonDatHang','ThanhToan') IS NULL
    ALTER TABLE dbo.DonDatHang ADD ThanhToan INT NULL;
IF COL_LENGTH('dbo.DonDatHang','Tracking') IS NULL
    ALTER TABLE dbo.DonDatHang ADD Tracking INT NULL;
IF COL_LENGTH('dbo.DonDatHang','GhiChu') IS NULL
    ALTER TABLE dbo.DonDatHang ADD GhiChu NVARCHAR(500) NULL;
IF EXISTS(SELECT TaiKhoan FROM dbo.KhachHang GROUP BY TaiKhoan HAVING COUNT(*)>1)
    THROW 50001, 'Duplicate usernames: review before upgrading.', 1;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_KhachHang_TaiKhoan' AND object_id=OBJECT_ID('dbo.KhachHang'))
    CREATE UNIQUE INDEX UX_KhachHang_TaiKhoan ON dbo.KhachHang(TaiKhoan);
COMMIT;
GO
-- Don cu: khong suy doan tinh trang giao hang/thanh toan. Admin kiem tra thuc te truoc khi cap nhat.
SELECT MaKH,TaiKhoan,DienThoai,TrangThai,EmailVerified FROM dbo.KhachHang;
