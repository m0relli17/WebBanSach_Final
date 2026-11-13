# Hướng dẫn chạy WebBanSach bằng Docker

Hệ thống đã được đóng gói hoàn chỉnh bằng Docker Compose, tự động khởi tạo SQL Server và cấu hình môi trường ASP.NET MVC 5 trên Linux container (Mono runtime).

---

## 1. Khởi động hệ thống

Chỉ cần mở terminal tại thư mục gốc của dự án (`c:\Project\WebBanSach_Final`) và chạy:

```bash
docker compose up -d
```

Hệ thống sẽ tự động:
1. Khởi động container CSDL **SQL Server 2022** (`webbansach-db`).
2. Khởi động tiến trình khởi tạo (`webbansach-db-init`) chạy script [00_TaoDatabaseMoi.sql](00_TaoDatabaseMoi.sql) và [01_NangCapDatabase.sql](01_NangCapDatabase.sql) để tạo bảng và nạp dữ liệu sách mẫu.
3. Khởi động máy chủ ứng dụng web ASP.NET MVC (`webbansach-web`).

---

## 2. Truy cập website

Mở trình duyệt và truy cập:

* **Trang chủ (Khách hàng):** [http://localhost:8084](http://localhost:8084) (hoặc [http://localhost:8089](http://localhost:8089))
* **Trang Đăng ký thành viên:** [http://localhost:8084/User/Register](http://localhost:8084/User/Register)
* **Trang Quản trị (Admin):** [http://localhost:8084/Admin/Login](http://localhost:8084/Admin/Login)
  * Tài khoản: `admin`
  * Mật khẩu: `admin`

---

## 3. Các lệnh thường dùng

* **Xem trạng thái các container:**
  ```bash
  docker compose ps
  ```
* **Xem nhật ký hoạt động (Logs):**
  ```bash
  docker compose logs -f web
  ```
* **Dừng hệ thống:**
  ```bash
  docker compose down
  ```
* **Khởi động lại:**
  ```bash
  docker compose restart
  ```
