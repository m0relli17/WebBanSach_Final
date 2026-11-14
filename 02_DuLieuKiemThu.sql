-- Idempotent demo data seed: test accounts, extra categories/publishers, stock defaults, and sample orders.
-- Idempotent demo seed: customer/admin accounts, extra categories/publishers, stock, and sample orders.
USE [BSDB2];
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- ====================================================================
-- 1. TÀI KHOẢN KHÁCH HÀNG KIỂM THỬ (TEST USERS)
-- ====================================================================
-- Mật khẩu chuẩn '12345678' (Hash PBKDF2-SHA256, 210,000 iterations)
DECLARE @Hash12345678 VARCHAR(256) = 'PBKDF2$210000$aedfuzYd7rD3NwTCYpwXKQ==$4TM9+ICO+hDYBMOH3KezsOHqaHk5YalOno3dMRsr+LI=';

-- 1.1. Tài khoản 'testuser' (Khách hàng chuẩn, đã xác minh email, sẵn sàng mua sắm)
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE TaiKhoan = 'testuser')
BEGIN
    INSERT INTO KhachHang (TaiKhoan, MatKhau, TenKH, Email, DiaChi, DienThoai, NgaySinh, NgayTao, TrangThai, EmailVerified)
    VALUES ('testuser', @Hash12345678, N'Nguyễn Văn Test', 'testuser@gmail.com', N'123 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', '0912345678', '1995-05-15', GETDATE(), 1, 1);
END
ELSE
BEGIN
    UPDATE KhachHang 
    SET MatKhau = @Hash12345678, TrangThai = 1, EmailVerified = 1, TenKH = N'Nguyễn Văn Test', DienThoai = '0912345678', DiaChi = N'123 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh'
    WHERE TaiKhoan = 'testuser';
END;

-- 1.2. Tài khoản 'testotp' (Chưa xác minh email, dùng để test luồng nhập mã OTP)
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE TaiKhoan = 'testotp')
BEGIN
    INSERT INTO KhachHang (TaiKhoan, MatKhau, TenKH, Email, DiaChi, DienThoai, NgaySinh, NgayTao, TrangThai, EmailVerified)
    VALUES ('testotp', @Hash12345678, N'Trần Văn OTP', 'testotp@gmail.com', N'456 Lê Lợi, Quận 1, TP. Hồ Chí Minh', '0987654321', '1998-10-20', GETDATE(), 1, 0);
END
ELSE
BEGIN
    UPDATE KhachHang 
    SET MatKhau = @Hash12345678, TrangThai = 1, EmailVerified = 0, TenKH = N'Trần Văn OTP'
    WHERE TaiKhoan = 'testotp';
END;

-- 1.3. Tài khoản 'customer_vip' (Khách hàng thân thiết có sẵn lịch sử nhiều đơn hàng)
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE TaiKhoan = 'customer_vip')
BEGIN
    INSERT INTO KhachHang (TaiKhoan, MatKhau, TenKH, Email, DiaChi, DienThoai, NgaySinh, NgayTao, TrangThai, EmailVerified)
    VALUES ('customer_vip', @Hash12345678, N'Lê Hoàng VIP', 'vip@webbansach.local', N'789 Nam Kỳ Khởi Nghĩa, Quận 3, TP. Hồ Chí Minh', '0903112233', '1990-01-01', GETDATE(), 1, 1);
END
ELSE
BEGIN
    UPDATE KhachHang 
    SET MatKhau = @Hash12345678, TrangThai = 1, EmailVerified = 1, TenKH = N'Lê Hoàng VIP'
    WHERE TaiKhoan = 'customer_vip';
END;

-- 1.4. Tài khoản 'customer_locked' (Tài khoản bị khóa để test thông báo lỗi đăng nhập)
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE TaiKhoan = 'customer_locked')
BEGIN
    INSERT INTO KhachHang (TaiKhoan, MatKhau, TenKH, Email, DiaChi, DienThoai, NgaySinh, NgayTao, TrangThai, EmailVerified)
    VALUES ('customer_locked', @Hash12345678, N'Phạm Khóa', 'locked@gmail.com', N'Hà Nội', '0933445566', '1996-06-06', GETDATE(), 0, 1);
END
ELSE
BEGIN
    UPDATE KhachHang 
    SET MatKhau = @Hash12345678, TrangThai = 0
    WHERE TaiKhoan = 'customer_locked';
END;

-- ====================================================================
-- 2. TÀI KHOẢN QUẢN TRỊ VIÊN (ADMIN ACCOUNTS)
-- ====================================================================
-- 2.1. Admin chính: 'admin' / '123456'
IF NOT EXISTS (SELECT 1 FROM Admin WHERE TaiKhoan = 'admin')
BEGIN
    INSERT INTO Admin (TaiKhoan, MatKhau, HoTen, TrangThai)
    VALUES ('admin', '123456', N'Quản Trị Viên Hệ Thống', 1);
END
ELSE
BEGIN
    UPDATE Admin SET MatKhau = '123456', HoTen = N'Quản Trị Viên Hệ Thống', TrangThai = 1 WHERE TaiKhoan = 'admin';
END;

-- 2.2. Admin quản lý đơn hàng: 'manager' / '123456'
IF NOT EXISTS (SELECT 1 FROM Admin WHERE TaiKhoan = 'manager')
BEGIN
    INSERT INTO Admin (TaiKhoan, MatKhau, HoTen, TrangThai)
    VALUES ('manager', '123456', N'Điều Phối Viên Đơn Hàng', 1);
END
ELSE
BEGIN
    UPDATE Admin SET MatKhau = '123456', HoTen = N'Điều Phối Viên Đơn Hàng', TrangThai = 1 WHERE TaiKhoan = 'manager';
END;

-- Thêm các thể loại và nhà xuất bản phổ biến nếu chưa có
IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE TenLoai = N'Manga - Truyện Tranh')
    INSERT INTO TheLoai (TenLoai) VALUES (N'Manga - Truyện Tranh');
IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE TenLoai = N'Kinh Dị')
    INSERT INTO TheLoai (TenLoai) VALUES (N'Kinh Dị');
IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE TenLoai = N'Trinh Thám')
    INSERT INTO TheLoai (TenLoai) VALUES (N'Trinh Thám');
IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE TenLoai = N'Khoa Học Viễn Tưởng')
    INSERT INTO TheLoai (TenLoai) VALUES (N'Khoa Học Viễn Tưởng');

IF NOT EXISTS (SELECT 1 FROM NhaXuatBan WHERE LTRIM(RTRIM(TenNXB)) = N'NXB Kim Đồng')
    INSERT INTO NhaXuatBan (TenNXB) VALUES (N'NXB Kim Đồng');
IF NOT EXISTS (SELECT 1 FROM NhaXuatBan WHERE LTRIM(RTRIM(TenNXB)) = N'NXB Giáo Dục Việt Nam')
    INSERT INTO NhaXuatBan (TenNXB) VALUES (N'NXB Giáo Dục Việt Nam');
IF NOT EXISTS (SELECT 1 FROM NhaXuatBan WHERE LTRIM(RTRIM(TenNXB)) = N'NXB Văn Học')
    INSERT INTO NhaXuatBan (TenNXB) VALUES (N'NXB Văn Học');
IF NOT EXISTS (SELECT 1 FROM NhaXuatBan WHERE LTRIM(RTRIM(TenNXB)) = N'NXB Tổng Hợp TP.HCM')
    INSERT INTO NhaXuatBan (TenNXB) VALUES (N'NXB Tổng Hợp TP.HCM');
IF NOT EXISTS (SELECT 1 FROM NhaXuatBan WHERE LTRIM(RTRIM(TenNXB)) = N'NXB Dân Trí')
    INSERT INTO NhaXuatBan (TenNXB) VALUES (N'NXB Dân Trí');

-- ====================================================================
-- 3. CẬP NHẬT TỒN KHO & GIÁ BÁN SÁCH
-- ====================================================================
-- Bổ sung số lượng tồn kho dồi dào cho toàn bộ sách trong hệ thống
UPDATE Sach 
SET SoLuongTon = 100 
WHERE SoLuongTon IS NULL OR SoLuongTon < 10;

-- Đảm bảo sách có ngày cập nhật gần đây
UPDATE Sach 
SET NgayCapNhat = GETDATE()
WHERE NgayCapNhat IS NULL;

-- ====================================================================
-- 4. TẠO CÁC ĐƠN HÀNG MẪU ĐẦY ĐỦ CÁC TRẠNG THÁI CHO 'testuser'
-- ====================================================================
DECLARE @UserId INT;
SELECT @UserId = MaKH FROM KhachHang WHERE TaiKhoan = 'testuser';

IF @UserId IS NOT NULL
BEGIN
    DECLARE @Book1 INT, @Book2 INT, @Book3 INT;
    SELECT TOP 1 @Book1 = MaSach FROM Sach ORDER BY MaSach ASC;
    SELECT TOP 1 @Book2 = MaSach FROM Sach WHERE MaSach > @Book1 ORDER BY MaSach ASC;
    SELECT TOP 1 @Book3 = MaSach FROM Sach WHERE MaSach > @Book2 ORDER BY MaSach ASC;

    -- 4.1. Đơn hàng 1: Trạng thái 0 (Chờ xử lý, Thanh toán COD)
    IF NOT EXISTS (SELECT 1 FROM DonDatHang WHERE MaKH = @UserId AND Tracking = 0 AND ThanhToan = 0)
    BEGIN
        INSERT INTO DonDatHang (NgayDat, NgayGiao, TinhTrang, MaKH, ThanhToan, Tracking)
        VALUES (DATEADD(HOUR, -2, GETDATE()), DATEADD(DAY, 3, GETDATE()), 0, @UserId, 0, 0);
        
        DECLARE @OrderId0 INT = SCOPE_IDENTITY();
        INSERT INTO ChiTietDDH (MaDDH, MaSach, SoLuong, DonGia)
        VALUES (@OrderId0, @Book1, 1, (SELECT ISNULL(GiaBan, 150000) FROM Sach WHERE MaSach = @Book1));
    END;

    -- 4.2. Đơn hàng 2: Trạng thái 1 (Đã đóng gói, Thanh toán COD)
    IF NOT EXISTS (SELECT 1 FROM DonDatHang WHERE MaKH = @UserId AND Tracking = 1)
    BEGIN
        INSERT INTO DonDatHang (NgayDat, NgayGiao, TinhTrang, MaKH, ThanhToan, Tracking)
        VALUES (DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, 2, GETDATE()), 0, @UserId, 0, 1);
        
        DECLARE @OrderId1 INT = SCOPE_IDENTITY();
        INSERT INTO ChiTietDDH (MaDDH, MaSach, SoLuong, DonGia)
        VALUES (@OrderId1, @Book2, 2, (SELECT ISNULL(GiaBan, 200000) FROM Sach WHERE MaSach = @Book2));
    END;

    -- 4.3. Đơn hàng 3: Trạng thái 2 (Đang giao hàng, Thanh toán COD)
    IF NOT EXISTS (SELECT 1 FROM DonDatHang WHERE MaKH = @UserId AND Tracking = 2)
    BEGIN
        INSERT INTO DonDatHang (NgayDat, NgayGiao, TinhTrang, MaKH, ThanhToan, Tracking)
        VALUES (DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, 1, GETDATE()), 0, @UserId, 0, 2);
        
        DECLARE @OrderId2 INT = SCOPE_IDENTITY();
        INSERT INTO ChiTietDDH (MaDDH, MaSach, SoLuong, DonGia)
        VALUES (@OrderId2, @Book1, 1, (SELECT ISNULL(GiaBan, 150000) FROM Sach WHERE MaSach = @Book1));
        INSERT INTO ChiTietDDH (MaDDH, MaSach, SoLuong, DonGia)
        VALUES (@OrderId2, @Book2, 1, (SELECT ISNULL(GiaBan, 200000) FROM Sach WHERE MaSach = @Book2));
    END;

    -- 4.4. Đơn hàng 4: Trạng thái 3 (Đã giao thành công, Thanh toán qua Thẻ tín dụng Credit Card - Đã thanh toán)
    IF NOT EXISTS (SELECT 1 FROM DonDatHang WHERE MaKH = @UserId AND Tracking = 3 AND ThanhToan = 1)
    BEGIN
        INSERT INTO DonDatHang (NgayDat, NgayGiao, TinhTrang, MaKH, ThanhToan, Tracking)
        VALUES (DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -2, GETDATE()), 1, @UserId, 1, 3);
        
        DECLARE @OrderId3 INT = SCOPE_IDENTITY();
        INSERT INTO ChiTietDDH (MaDDH, MaSach, SoLuong, DonGia)
        VALUES (@OrderId3, @Book3, 2, (SELECT ISNULL(GiaBan, 250000) FROM Sach WHERE MaSach = @Book3));
    END;

    -- 4.5. Đơn hàng 5: Trạng thái 4 (Đã hủy)
    IF NOT EXISTS (SELECT 1 FROM DonDatHang WHERE MaKH = @UserId AND Tracking = 4)
    BEGIN
        INSERT INTO DonDatHang (NgayDat, NgayGiao, TinhTrang, MaKH, ThanhToan, Tracking)
        VALUES (DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -4, GETDATE()), 0, @UserId, 0, 4);
        
        DECLARE @OrderId4 INT = SCOPE_IDENTITY();
        INSERT INTO ChiTietDDH (MaDDH, MaSach, SoLuong, DonGia)
        VALUES (@OrderId4, @Book1, 1, (SELECT ISNULL(GiaBan, 150000) FROM Sach WHERE MaSach = @Book1));
    END;
END;

COMMIT;
GO

-- ====================================================================
-- 5. HIỂN THỊ TÓM TẮT DỮ LIỆU ĐÃ KHỞI TẠO
-- ====================================================================
PRINT N'=== KHỞI TẠO DỮ LIỆU KIỂM THỬ THÀNH CÔNG ===';
SELECT MaKH, TaiKhoan, TenKH, Email, TrangThai, EmailVerified FROM KhachHang WHERE TaiKhoan IN ('testuser', 'testotp', 'customer_vip', 'customer_locked');
SELECT IDAdmin, TaiKhoan, HoTen, TrangThai FROM Admin;
SELECT COUNT(*) AS TongSoSach, AVG(SoLuongTon) AS TonKhoTrungBinh FROM Sach;
SELECT MaDDH, MaKH, NgayDat, ThanhToan, Tracking FROM DonDatHang WHERE MaKH = (SELECT MaKH FROM KhachHang WHERE TaiKhoan = 'testuser');
