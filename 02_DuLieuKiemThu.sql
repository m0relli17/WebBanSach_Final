-- Idempotent demo data seed: test accounts, extra categories/publishers, stock defaults, sample orders, new books, and reviews.
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

-- 1.5. Các tài khoản đánh giá khách hàng (Reviewer Accounts)
IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE TaiKhoan = 'hoangnam')
    INSERT INTO KhachHang (TaiKhoan, MatKhau, TenKH, Email, DiaChi, DienThoai, NgaySinh, NgayTao, TrangThai, EmailVerified)
    VALUES ('hoangnam', @Hash12345678, N'Hoàng Nam', 'nam.hoang@gmail.com', N'Quận Cầu Giấy, Hà Nội', '0912889900', '1994-03-12', GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE TaiKhoan = 'maianh')
    INSERT INTO KhachHang (TaiKhoan, MatKhau, TenKH, Email, DiaChi, DienThoai, NgaySinh, NgayTao, TrangThai, EmailVerified)
    VALUES ('maianh', @Hash12345678, N'Mai Anh', 'maianh.tran@gmail.com', N'Quận 1, TP. Hồ Chí Minh', '0933557799', '1997-08-25', GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE TaiKhoan = 'minhduc')
    INSERT INTO KhachHang (TaiKhoan, MatKhau, TenKH, Email, DiaChi, DienThoai, NgaySinh, NgayTao, TrangThai, EmailVerified)
    VALUES ('minhduc', @Hash12345678, N'Đặng Minh Đức', 'duc.dang@gmail.com', N'Hải Châu, Đà Nẵng', '0977112233', '1992-11-04', GETDATE(), 1, 1);

-- ====================================================================
-- 2. TÀI KHOẢN QUẢN TRỊ VIÊN (ADMIN ACCOUNTS)
-- ====================================================================
IF NOT EXISTS (SELECT 1 FROM Admin WHERE TaiKhoan = 'admin')
BEGIN
    INSERT INTO Admin (TaiKhoan, MatKhau, HoTen, TrangThai)
    VALUES ('admin', '123456', N'Quản Trị Viên Hệ Thống', 1);
END
ELSE
BEGIN
    UPDATE Admin SET MatKhau = '123456', HoTen = N'Quản Trị Viên Hệ Thống', TrangThai = 1 WHERE TaiKhoan = 'admin';
END;

IF NOT EXISTS (SELECT 1 FROM Admin WHERE TaiKhoan = 'manager')
BEGIN
    INSERT INTO Admin (TaiKhoan, MatKhau, HoTen, TrangThai)
    VALUES ('manager', '123456', N'Điều Phối Viên Đơn Hàng', 1);
END
ELSE
BEGIN
    UPDATE Admin SET MatKhau = '123456', HoTen = N'Điều Phối Viên Đơn Hàng', TrangThai = 1 WHERE TaiKhoan = 'manager';
END;

-- ====================================================================
-- 3. THỂ LOẠI, NXB & TÁC GIẢ BỔ SUNG
-- ====================================================================
-- Dọn dẹp danh mục trùng hoặc lỗi font nếu có trước khi thêm mới
UPDATE Sach SET MaLoai = 15 WHERE MaLoai = 19;
DELETE FROM TheLoai WHERE MaLoai >= 19 OR TenLoai LIKE '%?%' OR TenLoai LIKE '%Ã%' OR TenLoai LIKE '%á»%';

IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE TenLoai = N'Manga - Truyện Tranh')
    INSERT INTO TheLoai (TenLoai) VALUES (N'Manga - Truyện Tranh');
IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE TenLoai = N'Kinh Dị')
    INSERT INTO TheLoai (TenLoai) VALUES (N'Kinh Dị');
IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE TenLoai = N'Trinh Thám')
    INSERT INTO TheLoai (TenLoai) VALUES (N'Trinh Thám');
IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE TenLoai = N'Khoa Học Viễn Tưởng')
    INSERT INTO TheLoai (TenLoai) VALUES (N'Khoa Học Viễn Tưởng');
IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE TenLoai = N'Kỹ Năng Sống')
    INSERT INTO TheLoai (TenLoai) VALUES (N'Kỹ Năng Sống');
IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE TenLoai = N'Tâm Lý Học')
    INSERT INTO TheLoai (TenLoai) VALUES (N'Tâm Lý Học');

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

-- Tác giả
IF NOT EXISTS (SELECT 1 FROM TacGia WHERE TenTG = N'Napoleon Hill')
    INSERT INTO TacGia (TenTG) VALUES (N'Napoleon Hill');
IF NOT EXISTS (SELECT 1 FROM TacGia WHERE TenTG = N'Trịnh Công Sơn')
    INSERT INTO TacGia (TenTG) VALUES (N'Trịnh Công Sơn');
IF NOT EXISTS (SELECT 1 FROM TacGia WHERE TenTG = N'Walt Disney')
    INSERT INTO TacGia (TenTG) VALUES (N'Walt Disney');
IF NOT EXISTS (SELECT 1 FROM TacGia WHERE TenTG = N'Neil Gaiman')
    INSERT INTO TacGia (TenTG) VALUES (N'Neil Gaiman');
IF NOT EXISTS (SELECT 1 FROM TacGia WHERE TenTG = N'Ken Langdon')
    INSERT INTO TacGia (TenTG) VALUES (N'Ken Langdon');
IF NOT EXISTS (SELECT 1 FROM TacGia WHERE TenTG = N'Leonard Sax')
    INSERT INTO TacGia (TenTG) VALUES (N'Leonard Sax');

-- ====================================================================
-- 4. BỔ SUNG SÁCH MỚI ĐẦY ĐỦ THỂ LOẠI VÀ HÌNH ẢNH
-- ====================================================================
DECLARE @CatKinhTe INT = (SELECT TOP 1 MaLoai FROM TheLoai WHERE TenLoai = N'Sách Kinh Tế');
DECLARE @CatPhatTrien INT = (SELECT TOP 1 MaLoai FROM TheLoai WHERE TenLoai = N'Sách Phát Triển Bản Thân');
DECLARE @CatVanHocTN INT = (SELECT TOP 1 MaLoai FROM TheLoai WHERE TenLoai = N'Sách Văn Học Trong Nước');
DECLARE @CatManga INT = (SELECT TOP 1 MaLoai FROM TheLoai WHERE TenLoai = N'Manga - Truyện Tranh');
DECLARE @CatTieuThuyet INT = (SELECT TOP 1 MaLoai FROM TheLoai WHERE TenLoai = N'Sách Văn Học-Tiều Thuyết');
DECLARE @CatDoiSong INT = (SELECT TOP 1 MaLoai FROM TheLoai WHERE TenLoai = N'Sách Thường Thức - Đời Sống');
DECLARE @CatChuyenNganh INT = (SELECT TOP 1 MaLoai FROM TheLoai WHERE TenLoai = N'Sách Chuyên Ngành');
DECLARE @CatNgoaiNgu INT = (SELECT TOP 1 MaLoai FROM TheLoai WHERE TenLoai = N'Sách Tin Học - Ngoại Ngữ');

DECLARE @NxbLaoDong INT = (SELECT TOP 1 MaNXB FROM NhaXuatBan WHERE TenNXB LIKE N'%Lao động%');
DECLARE @NxbTre INT = (SELECT TOP 1 MaNXB FROM NhaXuatBan WHERE TenNXB LIKE N'%Trẻ%');
DECLARE @NxbKimDong INT = (SELECT TOP 1 MaNXB FROM NhaXuatBan WHERE TenNXB LIKE N'%Kim Đồng%');
DECLARE @NxbPhuNu INT = (SELECT TOP 1 MaNXB FROM NhaXuatBan WHERE TenNXB LIKE N'%Phụ Nữ%');
DECLARE @NxbChinhTri INT = (SELECT TOP 1 MaNXB FROM NhaXuatBan WHERE TenNXB LIKE N'%Chính Trị%');
DECLARE @NxbGiaoDuc INT = (SELECT TOP 1 MaNXB FROM NhaXuatBan WHERE TenNXB LIKE N'%Giáo Dục%');
DECLARE @NxbVanHoc INT = (SELECT TOP 1 MaNXB FROM NhaXuatBan WHERE TenNXB LIKE N'%Văn Học%');

DECLARE @TgNapoleon INT = (SELECT TOP 1 MaTG FROM TacGia WHERE TenTG = N'Napoleon Hill');
DECLARE @TgTrinhCongSon INT = (SELECT TOP 1 MaTG FROM TacGia WHERE TenTG = N'Trịnh Công Sơn');
DECLARE @TgDisney INT = (SELECT TOP 1 MaTG FROM TacGia WHERE TenTG = N'Walt Disney');
DECLARE @TgNeilGaiman INT = (SELECT TOP 1 MaTG FROM TacGia WHERE TenTG = N'Neil Gaiman');
DECLARE @TgKenLangdon INT = (SELECT TOP 1 MaTG FROM TacGia WHERE TenTG = N'Ken Langdon');
DECLARE @TgLeonardSax INT = (SELECT TOP 1 MaTG FROM TacGia WHERE TenTG = N'Leonard Sax');
DECLARE @TgDefault INT = (SELECT TOP 1 MaTG FROM TacGia);

-- 4.1. 100 Ý Tưởng Bán Hàng Tuyệt Vời
IF NOT EXISTS (SELECT 1 FROM Sach WHERE AnhBia = '100-y-tuong.jpg')
BEGIN
    INSERT INTO Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, GiamGia, Mota, AnhBia, NgayCapNhat, SoLuongTon)
    VALUES (ISNULL(@CatKinhTe, 2), ISNULL(@NxbLaoDong, 1), ISNULL(@TgKenLangdon, @TgDefault), N'100 Ý Tưởng Bán Hàng Tuyệt Vời', 125000, 15, N'Tập hợp 100 ý tưởng kinh doanh và bán hàng đột phá, dễ áp dụng vào thực tế từ những chuyên gia bán lẻ hàng đầu thế giới.', '100-y-tuong.jpg', GETDATE(), 80);
END
ELSE
BEGIN
    UPDATE Sach SET TenSach = N'100 Ý Tưởng Bán Hàng Tuyệt Vời', Mota = N'Tập hợp 100 ý tưởng kinh doanh và bán hàng đột phá, dễ áp dụng vào thực tế từ những chuyên gia bán lẻ hàng đầu thế giới.' WHERE AnhBia = '100-y-tuong.jpg';
END;

-- 4.2. Con Đường Dẫn Đến Sự Giàu Có
IF NOT EXISTS (SELECT 1 FROM Sach WHERE AnhBia = 'con-duong-dan-den-su-giau-co.jpg')
BEGIN
    INSERT INTO Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, GiamGia, Mota, AnhBia, NgayCapNhat, SoLuongTon)
    VALUES (ISNULL(@CatPhatTrien, 7), ISNULL(@NxbTre, 6), ISNULL(@TgNapoleon, @TgDefault), N'Con Đường Dẫn Đến Sự Giàu Có', 168000, 20, N'Tác phẩm kinh điển về tư duy tài chính cá nhân và bí quyết đạt được sự thịnh vượng bền vững của Napoleon Hill.', 'con-duong-dan-den-su-giau-co.jpg', GETDATE(), 120);
END
ELSE
BEGIN
    UPDATE Sach SET TenSach = N'Con Đường Dẫn Đến Sự Giàu Có', Mota = N'Tác phẩm kinh điển về tư duy tài chính cá nhân và bí quyết đạt được sự thịnh vượng bền vững của Napoleon Hill.' WHERE AnhBia = 'con-duong-dan-den-su-giau-co.jpg';
END;

-- 4.3. Để Gió Cuốn Đi
IF NOT EXISTS (SELECT 1 FROM Sach WHERE AnhBia = 'de-gio-cuon-di.jpg')
BEGIN
    INSERT INTO Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, GiamGia, Mota, AnhBia, NgayCapNhat, SoLuongTon)
    VALUES (ISNULL(@CatVanHocTN, 3), ISNULL(@NxbTre, 6), ISNULL(@TgTrinhCongSon, @TgDefault), N'Để Gió Cuốn Đi', 135000, 10, N'Những tản văn và triết lý sống an nhiên, vị tha của cố nhạc sĩ Trịnh Công Sơn dành cho tâm hồn người Việt.', 'de-gio-cuon-di.jpg', GETDATE(), 95);
END
ELSE
BEGIN
    UPDATE Sach SET TenSach = N'Để Gió Cuốn Đi', Mota = N'Những tản văn và triết lý sống an nhiên, vị tha của cố nhạc sĩ Trịnh Công Sơn dành cho tâm hồn người Việt.' WHERE AnhBia = 'de-gio-cuon-di.jpg';
END;

-- 4.4. Đi Tìm Dory - Cuộc Phiêu Lưu Đại Dương
IF NOT EXISTS (SELECT 1 FROM Sach WHERE AnhBia = 'di-tim-dory.jpg')
BEGIN
    INSERT INTO Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, GiamGia, Mota, AnhBia, NgayCapNhat, SoLuongTon)
    VALUES (ISNULL(@CatManga, 15), ISNULL(@NxbKimDong, 12), ISNULL(@TgDisney, @TgDefault), N'Đi Tìm Dory - Cuộc Phiêu Lưu Đại Dương', 65000, 0, N'Truyện tranh màu tuyệt đẹp về hành trình tìm lại gia đình của cô cá xanh Dory đáng yêu và hay quên.', 'di-tim-dory.jpg', GETDATE(), 150);
END
ELSE
BEGIN
    UPDATE Sach SET TenSach = N'Đi Tìm Dory - Cuộc Phiêu Lưu Đại Dương', Mota = N'Truyện tranh màu tuyệt đẹp về hành trình tìm lại gia đình của cô cá xanh Dory đáng yêu và hay quên.' WHERE AnhBia = 'di-tim-dory.jpg';
END;

-- 4.5. Đường Yêu Gập Khúc
IF NOT EXISTS (SELECT 1 FROM Sach WHERE AnhBia = 'duong-yeu-gap-khuc.jpg')
BEGIN
    INSERT INTO Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, GiamGia, Mota, AnhBia, NgayCapNhat, SoLuongTon)
    VALUES (ISNULL(@CatTieuThuyet, 13), ISNULL(@NxbVanHoc, 14), @TgDefault, N'Đường Yêu Gập Khúc', 110000, 12, N'Tiểu thuyết lãng mạn nhẹ nhàng về những thử thách và rung động ngọt ngào của tình yêu tuổi trẻ.', 'duong-yeu-gap-khuc.jpg', GETDATE(), 60);
END
ELSE
BEGIN
    UPDATE Sach SET TenSach = N'Đường Yêu Gập Khúc', Mota = N'Tiểu thuyết lãng mạn nhẹ nhàng về những thử thách và rung động ngọt ngào của tình yêu tuổi trẻ.' WHERE AnhBia = 'duong-yeu-gap-khuc.jpg';
END;

-- 4.6. Về Nhà Và Yêu Thương
IF NOT EXISTS (SELECT 1 FROM Sach WHERE AnhBia = 'go-home-and-love.jpg')
BEGIN
    INSERT INTO Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, GiamGia, Mota, AnhBia, NgayCapNhat, SoLuongTon)
    VALUES (ISNULL(@CatDoiSong, 5), ISNULL(@NxbPhuNu, 4), @TgDefault, N'Về Nhà Và Yêu Thương', 145000, 18, N'Cuốn sách sưởi ấm tâm hồn với thông điệp về mái ấm gia đình, nơi bình yên nhất sau những mỏi mệt cuộc sống.', 'go-home-and-love.jpg', GETDATE(), 110);
END
ELSE
BEGIN
    UPDATE Sach SET TenSach = N'Về Nhà Và Yêu Thương', Mota = N'Cuốn sách sưởi ấm tâm hồn với thông điệp về mái ấm gia đình, nơi bình yên nhất sau những mỏi mệt cuộc sống.' WHERE AnhBia = 'go-home-and-love.jpg';
END;

-- 4.7. Hành Trình Theo Chân Bác
IF NOT EXISTS (SELECT 1 FROM Sach WHERE AnhBia = 'hanh-trinh-theo-chan-bac.jpg')
BEGIN
    INSERT INTO Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, GiamGia, Mota, AnhBia, NgayCapNhat, SoLuongTon)
    VALUES (ISNULL(@CatChuyenNganh, 9), ISNULL(@NxbChinhTri, 11), @TgDefault, N'Hành Trình Theo Chân Bác', 195000, 10, N'Tập tài liệu và hình ảnh lịch sử quý báu ghi lại cuộc đời hoạt động cách mạng vĩ đại của Chủ tịch Hồ Chí Minh.', 'hanh-trinh-theo-chan-bac.jpg', GETDATE(), 75);
END
ELSE
BEGIN
    UPDATE Sach SET TenSach = N'Hành Trình Theo Chân Bác', Mota = N'Tập tài liệu và hình ảnh lịch sử quý báu ghi lại cuộc đời hoạt động cách mạng vĩ đại của Chủ tịch Hồ Chí Minh.' WHERE AnhBia = 'hanh-trinh-theo-chan-bac.jpg';
END;

-- 4.8. Người Đẹp Ngủ Và Con Thoi Ma Thuật
IF NOT EXISTS (SELECT 1 FROM Sach WHERE AnhBia = 'nguoi-dep-ngu-va-con-thoi-ma-thuat.jpg')
BEGIN
    INSERT INTO Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, GiamGia, Mota, AnhBia, NgayCapNhat, SoLuongTon)
    VALUES (ISNULL(@CatManga, 15), ISNULL(@NxbTre, 6), ISNULL(@TgNeilGaiman, @TgDefault), N'Người Đẹp Ngủ Và Con Thoi Ma Thuật', 130000, 15, N'Tác phẩm truyện cổ tích kỳ ảo đặc sắc được tái tưởng tượng đầy ma mị bởi bậc thầy văn học Neil Gaiman.', 'nguoi-dep-ngu-va-con-thoi-ma-thuat.jpg', GETDATE(), 85);
END
ELSE
BEGIN
    UPDATE Sach SET TenSach = N'Người Đẹp Ngủ Và Con Thoi Ma Thuật', Mota = N'Tác phẩm truyện cổ tích kỳ ảo đặc sắc được tái tưởng tượng đầy ma mị bởi bậc thầy văn học Neil Gaiman.' WHERE AnhBia = 'nguoi-dep-ngu-va-con-thoi-ma-thuat.jpg';
END;

-- 4.9. Sự Sụp Đổ Của Nghề Làm Cha Mẹ
IF NOT EXISTS (SELECT 1 FROM Sach WHERE AnhBia = 'su-sup-do-cua-nghe-lam-cha-me-15.5x23cm.jpg')
BEGIN
    INSERT INTO Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, GiamGia, Mota, AnhBia, NgayCapNhat, SoLuongTon)
    VALUES (ISNULL(@CatDoiSong, 5), ISNULL(@NxbTre, 6), ISNULL(@TgLeonardSax, @TgDefault), N'Sự Sụp Đổ Của Nghề Làm Cha Mẹ', 175000, 20, N'Cẩm nang nuôi dạy con hiện đại giúp cha mẹ giải quyết những khủng hoảng tâm lý và thấu hiểu con trẻ trong kỷ nguyên số.', 'su-sup-do-cua-nghe-lam-cha-me-15.5x23cm.jpg', GETDATE(), 90);
END
ELSE
BEGIN
    UPDATE Sach SET TenSach = N'Sự Sụp Đổ Của Nghề Làm Cha Mẹ', Mota = N'Cẩm nang nuôi dạy con hiện đại giúp cha mẹ giải quyết những khủng hoảng tâm lý và thấu hiểu con trẻ trong kỷ nguyên số.' WHERE AnhBia = 'su-sup-do-cua-nghe-lam-cha-me-15.5x23cm.jpg';
END;

-- 4.10. Tóc Dài Tự Tin
IF NOT EXISTS (SELECT 1 FROM Sach WHERE AnhBia = 'toc-dai-tu-tin.jpg')
BEGIN
    INSERT INTO Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, GiamGia, Mota, AnhBia, NgayCapNhat, SoLuongTon)
    VALUES (ISNULL(@CatPhatTrien, 7), ISNULL(@NxbPhuNu, 4), @TgDefault, N'Tóc Dài Tự Tin', 98000, 10, N'Truyền cảm hứng sống độc lập, tự tin và tỏa sáng dành cho các cô gái trẻ hiện đại.', 'toc-dai-tu-tin.jpg', GETDATE(), 70);
END
ELSE
BEGIN
    UPDATE Sach SET TenSach = N'Tóc Dài Tự Tin', Mota = N'Truyền cảm hứng sống độc lập, tự tin và tỏa sáng dành cho các cô gái trẻ hiện đại.' WHERE AnhBia = 'toc-dai-tu-tin.jpg';
END;

-- 4.11. Luyện Thi TOEFL iBT Cấp Tốc
IF NOT EXISTS (SELECT 1 FROM Sach WHERE AnhBia = 'TOEFL.jpg')
BEGIN
    INSERT INTO Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, GiamGia, Mota, AnhBia, NgayCapNhat, SoLuongTon)
    VALUES (ISNULL(@CatNgoaiNgu, 8), ISNULL(@NxbGiaoDuc, 13), @TgDefault, N'Luyện Thi TOEFL iBT Cấp Tốc', 220000, 25, N'Bộ giáo trình luyện thi TOEFL iBT toàn diện 4 kỹ năng Nghe - Nói - Đọc - Viết kèm đáp án chi tiết và mẹo làm bài đạt điểm cao.', 'TOEFL.jpg', GETDATE(), 105);
END
ELSE
BEGIN
    UPDATE Sach SET TenSach = N'Luyện Thi TOEFL iBT Cấp Tốc', Mota = N'Bộ giáo trình luyện thi TOEFL iBT toàn diện 4 kỹ năng Nghe - Nói - Đọc - Viết kèm đáp án chi tiết và mẹo làm bài đạt điểm cao.' WHERE AnhBia = 'TOEFL.jpg';
END;

-- Cập nhật tồn kho & giảm giá phong phú
UPDATE Sach SET SoLuongTon = 100 WHERE SoLuongTon IS NULL OR SoLuongTon < 10;
UPDATE Sach SET NgayCapNhat = GETDATE() WHERE NgayCapNhat IS NULL;
UPDATE Sach SET GiamGia = 20 WHERE MaSach = 1;
UPDATE Sach SET GiamGia = 15 WHERE MaSach = 8;
UPDATE Sach SET GiamGia = 25 WHERE MaSach = 10;
UPDATE Sach SET GiamGia = 30 WHERE MaSach = 11;
UPDATE Sach SET GiamGia = 10 WHERE MaSach = 13;
UPDATE Sach SET GiamGia = 18 WHERE MaSach = 16;
UPDATE Sach SET GiamGia = 22 WHERE MaSach = 31;
UPDATE Sach SET GiamGia = 15 WHERE MaSach = 33;

-- ====================================================================
-- 5. BỔ SUNG ĐÁNH GIÁ THỰC TẾ (BOOK REVIEWS & RATINGS)
-- ====================================================================
DECLARE @K1 INT = (SELECT MaKH FROM KhachHang WHERE TaiKhoan = 'testuser');
DECLARE @K2 INT = (SELECT MaKH FROM KhachHang WHERE TaiKhoan = 'customer_vip');
DECLARE @K3 INT = (SELECT MaKH FROM KhachHang WHERE TaiKhoan = 'hoangnam');
DECLARE @K4 INT = (SELECT MaKH FROM KhachHang WHERE TaiKhoan = 'maianh');
DECLARE @K5 INT = (SELECT MaKH FROM KhachHang WHERE TaiKhoan = 'minhduc');

-- Thêm review cho từng cuốn sách nếu chưa có
CREATE TABLE #SampleReviews (
    Image VARCHAR(50),
    UserId INT,
    Rating INT,
    Comment NVARCHAR(1000)
);

INSERT INTO #SampleReviews VALUES
('me-before-you.jpg', @K1, 5, N'Cuốn sách lấy đi của mình rất nhiều nước mắt. Một chuyện tình đẹp nhưng cũng đầy trăn trở về quyền được lựa chọn cuộc sống. WebBanSach giao hàng siêu tốc 2h rất ấn tượng!'),
('me-before-you.jpg', @K2, 5, N'Bìa sách đẹp, giấy xịn cầm rất êm tay. Bản dịch của NXB Trẻ rất mượt mà. Sách chính hãng 100%.'),
('me-before-you.jpg', @K4, 4, N'Nội dung rất cảm động, rất đáng đọc cho những ai đang tìm kiếm sự đồng cảm trong cuộc sống.'),

('cu-binh-tinh.jpg', @K1, 5, N'Đúng thời điểm mình đang stress công việc thì đọc được cuốn này. Rất nhiều góc nhìn tích cực giúp nhẹ lòng hơn.'),
('cu-binh-tinh.jpg', @K3, 4, N'Sách viết giản dị, gần gũi. Đóng gói cẩn thận có bọc chống sốc cẩn thận.'),

('harrypotter.jpg', @K1, 5, N'Kỷ niệm tuổi thơ ùa về. Bản in chất lượng cao, font chữ rõ ràng, đọc mê mẩn không dứt ra được!'),
('harrypotter.jpg', @K2, 5, N'Sách kinh điển không cần bàn cãi. Mua trên WebBanSach được giá ưu đãi kèm freeship cực kỳ hời.'),
('harrypotter.jpg', @K5, 5, N'Giao hàng đúng hẹn 2 tiếng, shipper nhiệt tình. Cho 5 sao chất lượng phục vụ.'),

('ngay-xua-co-mot-chuyen-tinh.jpg', @K4, 5, N'Văn phong bác Ánh lúc nào cũng ngọt ngào và day dứt như thế. Đọc xong thấy thương cho cả ba nhân vật.'),
('ngay-xua-co-mot-chuyen-tinh.jpg', @K3, 5, N'Một tác phẩm xuất sắc của văn học Việt Nam. Rất đáng có trong tủ sách gia đình.'),

('dam-lam-giau.jpg', @K2, 5, N'Tư duy thay đổi hoàn toàn sau khi đọc cuốn sách này. Nhiều bài tập thực hành tài chính cá nhân rất thực tế.'),
('dam-lam-giau.jpg', @K5, 4, N'Sách hay, truyền động lực mạnh mẽ cho ai muốn khởi nghiệp hoặc bứt phá tài chính.'),

('den-khong-hat-bong.jpg', @K3, 5, N'Tiểu thuyết y khoa kinh điển của Nhật Bản. Nhân vật bác sĩ Naoe để lại ấn tượng vô cùng sâu sắc.'),
('den-khong-hat-bong.jpg', @K1, 4, N'Bản dịch chất lượng, cốt truyện kịch tính và đầy chiều sâu nhân đạo.'),

('luyen-thi-toeic.jpg', @K4, 5, N'Sách có đáp án giải thích rất chi tiết từng câu. Mình luyện 2 tháng đã tăng từ 550 lên 780 điểm!'),
('luyen-thi-toeic.jpg', @K5, 5, N'Cực kỳ khuyên dùng cho các bạn đang tự ôn thi TOEIC cấp tốc.'),

('con-duong-dan-den-su-giau-co.jpg', @K1, 5, N'Những nguyên tắc làm giàu vượt thời gian của Napoleon Hill. Đọc đi đọc lại vẫn thấy nhiều bài học mới.'),
('con-duong-dan-den-su-giau-co.jpg', @K2, 5, N'Sách đẹp, đóng gói chỉn chu, giá tốt.'),

('de-gio-cuon-di.jpg', @K3, 5, N'Những câu từ của Trịnh Công Sơn làm dịu đi mọi muộn phiền. Rất thích hợp đọc vào những buổi tối yên tĩnh.'),
('di-tim-dory.jpg', @K4, 5, N'Bé nhà mình rất thích cuốn này, màu sắc in rực rỡ, truyện tranh dí dỏm và giàu tính giáo dục.');

-- Dọn dẹp các review bị lỗi font (nếu có) trước khi nạp lại
DELETE FROM DanhGiaSach WHERE NoiDung COLLATE Latin1_General_100_BIN2 LIKE N'%Ã%' OR NoiDung COLLATE Latin1_General_100_BIN2 LIKE N'%Â%';

-- Chèn dữ liệu review vào bảng DanhGiaSach
INSERT INTO DanhGiaSach (MaSach, MaKH, SoSao, NoiDung, NgayDanhGia)
SELECT s.MaSach, sr.UserId, sr.Rating, sr.Comment, DATEADD(DAY, -(s.MaSach % 10 + 1), GETDATE())
FROM #SampleReviews sr
JOIN Sach s ON s.AnhBia = sr.Image
WHERE NOT EXISTS (
    SELECT 1 FROM DanhGiaSach d WHERE d.MaSach = s.MaSach AND d.MaKH = sr.UserId
) AND sr.UserId IS NOT NULL;

DROP TABLE #SampleReviews;

-- ====================================================================
-- 6. TẠO CÁC ĐƠN HÀNG MẪU ĐẦY ĐỦ CÁC TRẠNG THÁI CHO 'testuser'
-- ====================================================================
DECLARE @UserId INT;
SELECT @UserId = MaKH FROM KhachHang WHERE TaiKhoan = 'testuser';

IF @UserId IS NOT NULL
BEGIN
    DECLARE @Book1 INT, @Book2 INT, @Book3 INT;
    SELECT TOP 1 @Book1 = MaSach FROM Sach ORDER BY MaSach ASC;
    SELECT TOP 1 @Book2 = MaSach FROM Sach WHERE MaSach > @Book1 ORDER BY MaSach ASC;
    SELECT TOP 1 @Book3 = MaSach FROM Sach WHERE MaSach > @Book2 ORDER BY MaSach ASC;

    -- 6.1. Đơn hàng 1: Trạng thái 0 (Chờ xử lý, Thanh toán COD)
    IF NOT EXISTS (SELECT 1 FROM DonDatHang WHERE MaKH = @UserId AND Tracking = 0 AND ThanhToan = 0)
    BEGIN
        INSERT INTO DonDatHang (NgayDat, NgayGiao, TinhTrang, MaKH, ThanhToan, Tracking)
        VALUES (DATEADD(HOUR, -2, GETDATE()), DATEADD(DAY, 3, GETDATE()), 0, @UserId, 0, 0);
        
        DECLARE @OrderId0 INT = SCOPE_IDENTITY();
        INSERT INTO ChiTietDDH (MaDDH, MaSach, SoLuong, DonGia)
        VALUES (@OrderId0, @Book1, 1, (SELECT ISNULL(GiaBan, 150000) FROM Sach WHERE MaSach = @Book1));
    END;

    -- 6.2. Đơn hàng 2: Trạng thái 1 (Đã đóng gói, Thanh toán COD)
    IF NOT EXISTS (SELECT 1 FROM DonDatHang WHERE MaKH = @UserId AND Tracking = 1)
    BEGIN
        INSERT INTO DonDatHang (NgayDat, NgayGiao, TinhTrang, MaKH, ThanhToan, Tracking)
        VALUES (DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, 2, GETDATE()), 0, @UserId, 0, 1);
        
        DECLARE @OrderId1 INT = SCOPE_IDENTITY();
        INSERT INTO ChiTietDDH (MaDDH, MaSach, SoLuong, DonGia)
        VALUES (@OrderId1, @Book2, 2, (SELECT ISNULL(GiaBan, 200000) FROM Sach WHERE MaSach = @Book2));
    END;

    -- 6.3. Đơn hàng 3: Trạng thái 2 (Đang giao hàng, Thanh toán COD)
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

    -- 6.4. Đơn hàng 4: Trạng thái 3 (Đã giao thành công, Thanh toán qua Thẻ tín dụng Credit Card - Đã thanh toán)
    IF NOT EXISTS (SELECT 1 FROM DonDatHang WHERE MaKH = @UserId AND Tracking = 3 AND ThanhToan = 1)
    BEGIN
        INSERT INTO DonDatHang (NgayDat, NgayGiao, TinhTrang, MaKH, ThanhToan, Tracking)
        VALUES (DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -2, GETDATE()), 1, @UserId, 1, 3);
        
        DECLARE @OrderId3 INT = SCOPE_IDENTITY();
        INSERT INTO ChiTietDDH (MaDDH, MaSach, SoLuong, DonGia)
        VALUES (@OrderId3, @Book3, 2, (SELECT ISNULL(GiaBan, 250000) FROM Sach WHERE MaSach = @Book3));
    END;

    -- 6.5. Đơn hàng 5: Trạng thái 4 (Đã hủy)
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
-- 7. HIỂN THỊ TÓM TẮT DỮ LIỆU ĐÃ KHỞI TẠO
-- ====================================================================
PRINT N'=== KHỞI TẠO DỮ LIỆU KIỂM THỬ THÀNH CÔNG ===';
SELECT MaKH, TaiKhoan, TenKH, Email, TrangThai, EmailVerified FROM KhachHang WHERE TaiKhoan IN ('testuser', 'customer_vip', 'hoangnam', 'maianh', 'minhduc');
SELECT COUNT(*) AS TongSoSach, AVG(SoLuongTon) AS TonKhoTrungBinh FROM Sach;
SELECT COUNT(*) AS TongSoDanhGia FROM DanhGiaSach;
SELECT MaDDH, MaKH, NgayDat, ThanhToan, Tracking FROM DonDatHang WHERE MaKH = (SELECT MaKH FROM KhachHang WHERE TaiKhoan = 'testuser');
