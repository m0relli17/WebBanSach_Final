# WebBanSach — Hệ thống Website Bán Sách Trực Tuyến

Dự án website thương mại điện tử bán sách trực tuyến được xây dựng theo kiến trúc phân tách hiện đại:
- **Backend**: C# ASP.NET MVC 5 (.NET Framework 4.8), Entity Framework 6 Code/Database First, RESTful JSON APIs, mã hóa mật khẩu an toàn PBKDF2-SHA256, xác thực Email OTP 6 số.
- **Frontend**: Single-Page / Multi-Page decoupled HTML5, Bootstrap 5, Vanilla JavaScript, tính toán giỏ hàng thời gian thực, tích hợp thanh toán COD và Thẻ tín dụng (Credit Card) với visual card preview, theo dõi đơn hàng và bảng điều khiển quản trị (Admin Dashboard).

---

## 📚 Tài liệu Hướng dẫn

- **[HUONG_DAN_MVS.md](HUONG_DAN_MVS.md)**: **Hướng dẫn khởi tạo dự án trên Microsoft Visual Studio (MVS)**, cấu hình chuỗi kết nối Database SQL Server và thứ tự chạy các script khởi tạo CSDL (`00` -> `01` -> `02`).
- **[user.md](user.md)**: Danh mục tài khoản kiểm thử (`testuser`, `admin`, `manager`), thông tin thẻ tín dụng test, và các kịch bản kiểm thử mẫu.
- **[structure.md](structure.md)**: Sơ đồ kiến trúc toàn bộ thư mục dự án, danh sách chi tiết các REST API endpoints và luồng xử lý dữ liệu.
- **[README_DOCKER.md](README_DOCKER.md)**: Hướng dẫn chạy nhanh toàn bộ dự án và cơ sở dữ liệu thông qua Docker Compose (`docker compose up -d`).

---

## 🚀 Khởi chạy Nhanh

### Cách 1: Chạy bằng Visual Studio (MVS) & SQL Server
1. Mở SSMS, chạy lần lượt 3 script: `00_TaoDatabaseMoi.sql` $\rightarrow$ `01_NangCapDatabase.sql` $\rightarrow$ `02_DuLieuKiemThu.sql`.
2. Mở `WebBanSach.sln` bằng Visual Studio.
3. Kiểm tra chuỗi kết nối trong `backend/Web.config` (mặc định trỏ đến `.\SQLEXPRESS`).
4. Rebuild Solution (`Ctrl + Shift + B`) và nhấn `Ctrl + F5` để chạy trên IIS Express.
5. Xem chi tiết tại [HUONG_DAN_MVS.md](HUONG_DAN_MVS.md).

### Cách 2: Chạy bằng Docker Compose
```bash
docker compose up -d --build
```
Truy cập:
- Khách hàng: [http://localhost:8089](http://localhost:8089)
- Quản trị viên: [http://localhost:8089/admin.html](http://localhost:8089/admin.html)
