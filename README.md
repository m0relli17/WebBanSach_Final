# WebBanSach

Website bán sách dùng ASP.NET MVC 5 / .NET Framework 4.8, Entity Framework 6, SQL Server, HTML, Bootstrap và JavaScript.

## Tính năng

- Tài khoản khách hàng có xác minh email OTP.
- Danh mục sách, tìm kiếm, phân trang và sắp xếp theo giá, độ hot 30 ngày, đánh giá hoặc lượt bán.
- Đánh giá 1–5 sao; mỗi khách hàng đã xác minh có thể tạo hoặc cập nhật một đánh giá cho mỗi sách.
- Giá gốc, phần trăm giảm giá và giá sau giảm dùng thống nhất trong giỏ hàng/đơn hàng.
- Giỏ hàng giới hạn 1–999 cuốn mỗi sản phẩm, đồng thời kiểm tra tồn kho phía server.
- Admin quản lý sản phẩm (thêm, sửa, xóa có bảo vệ lịch sử đơn hàng), xem chi tiết đơn và kiểm duyệt đánh giá.
- Ảnh bìa hỗ trợ JPG/JFIF, PNG, GIF và BMP.

## Chạy nhanh

1. Database mới: chạy `00_TaoDatabaseMoi.sql`, `01_NangCapDatabase.sql`, rồi `02_DuLieuKiemThu.sql`.
2. Database hiện có: chạy `01_NangCapDatabase.sql`; chỉ chạy `02_DuLieuKiemThu.sql` nếu cần nạp/cập nhật dữ liệu demo.
3. Mở `WebBanSach.sln` trong Visual Studio, đặt project `backend` làm Startup Project, rồi chạy IIS Express.
4. Mở `/index.html`; trang admin ở `/admin.html`. Dùng cổng IIS Express hiển thị trong Visual Studio.

`03_KhoiPhucGhiChuDonHang.sql` và `04_SoLuongBigInt.sql` là script sửa riêng; các thay đổi này đã nằm trong `01_NangCapDatabase.sql`.

Tài khoản demo: `admin` / `123456`; `manager` / `123456`. Chỉ dùng mật khẩu demo trên máy phát triển.

## Tài liệu

- [Hướng dẫn chạy](HUONG_DAN_CHAY.md)
- [Hướng dẫn Visual Studio và SQL Server](HUONG_DAN_MVS.md)
- [Tài khoản và kịch bản kiểm thử](user.md)
- [Cấu trúc và API](structure.md)
