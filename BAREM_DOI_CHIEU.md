# Đối chiếu 7 nhóm chức năng vừa triển khai

Chạy project ASP.NET trong Visual Studio/IIS Express. Các URL `.html` vẫn giữ nguyên, nhưng được `PortalController.Page` xử lý và render Razor. Không dùng Live Server tĩnh để demo MVC.

| Nhóm | Cách demo | Code cần mở khi vấn đáp |
|---|---|---|
| Layout/Partial View | Mở trang khách, admin, danh mục; cùng header/footer theo từng khu vực | `Views/Shared/_MasterLayout.cshtml`, `_Layout.cshtml`, `PortalController.Page`, `RouteConfig.cs` |
| Danh mục | Admin → Quản lý danh mục → Thể loại/Tác giả/NXB; thêm/sửa; bấm số sách; thử xóa danh mục đang có sách | `ManageController.Catalog`, `CatalogEdit`, `CatalogDelete`, `CatalogDetails`; model `CatalogEditModel` |
| Quản trị viên và khách | Admin → Quản trị viên: thêm/sửa/xóa; Admin → Khách hàng: chỉ xem, tìm kiếm, mở chi tiết và đơn | `ManageController.AdminEdit`, `AdminDelete`, `Customers`, `Customer`; `_OrderList.cshtml` |
| Kho | Admin → Quản lý kho → Hàng tồn hoặc Hàng cần nhập | `ManageController.Inventory`, `_Products.cshtml`; điều kiện tồn > 0 và tồn = 0 |
| Hóa đơn chung | Xem chi tiết đơn ở admin hoặc lịch sử mua của khách; xem tiền hàng, phí ship, từng dòng, tổng cộng | `PortalController.Invoice`, `Receipt`, `_Invoice.cshtml`, `InvoiceModel` |
| Hồ sơ khách | Đăng nhập khách → menu tài khoản → Hồ sơ khách hàng → lưu thông tin | `PortalController.Profile`, `ProfileEditModel`, `Views/Portal/Profile.cshtml` |
| Các mục nhỏ | Home chỉ còn hàng, admin có ảnh, thêm từ chi tiết chuyển tới giỏ, số bán thật, phí ship đồng bộ | `ApiController.Books`, `Checkout`, `MyOrders`, `AdminOrders`; `index.html`, `book-details.html` |

## Những điều cần giải thích được

- `_Layout` và `_MasterLayout` chứa khung trang; `RenderBody()` đặt nội dung riêng vào khung. Header/footer cũng là partial. Đây là render MVC thật, không chỉ đặt tên file giống Layout.
- `_ProductDetails` là một partial dùng cho cả khách và admin; `IsAdmin` quyết định có dựng số lượng/nút mua hay không. Quyền đọc phần quản trị vẫn được kiểm tra ở controller.
- `_Invoice` dùng cùng một model và cùng một mã giao diện cho khách/admin. Khách chỉ được xem đơn có `MaKH` của mình; admin phải có tài khoản còn hoạt động.
- Data Annotation ở view model kiểm tra trường bắt buộc, độ dài, định dạng; controller kiểm tra thêm tên trùng, ngày hợp lệ, ràng buộc liên quan và quyền. `AntiForgeryToken`/`ValidateAntiForgeryToken` bảo vệ các form MVC ghi dữ liệu.
- Danh mục có sách không bị xóa. Không có nút Details riêng cho thể loại/NXB ít hơn 5 cột; liên kết số sách mở danh sách liên quan. Tác giả có chi tiết thông tin và danh sách sách.
- Khách hàng trong admin chỉ được tra cứu, không có form thêm/sửa/xóa. Hồ sơ khách là form riêng, lấy người dùng từ session, không nhận mã khách tùy ý từ trình duyệt.
- Admin mới/đổi mật khẩu dùng PBKDF2. Admin cũ nâng cấp khi đăng nhập đúng. Không cho xóa/khóa chính tài khoản đang dùng hoặc quản trị viên hoạt động cuối cùng.
- Khi checkout, backend lấy lại giá, trừ kho có điều kiện, tạo đơn/chi tiết/lịch sử trong transaction. Phí ship được tính trên tiền hàng sau giảm: dưới 150.000 là 25.000; từ 150.000 miễn phí. Không nhận phí ship do client tự quyết.
- Thông tin người nhận và phí ship được chụp lại vào đơn mới. Sửa hồ sơ sau đó không đổi hóa đơn đã đặt. Đơn cũ thiếu dữ liệu được ghi chú rõ; không tự đoán phí ship lịch sử.
- Số đã bán trên index lấy từ thống kê đơn chưa bị hủy, không dùng công thức demo theo mã sách nữa.
- Kiểu ngày tác giả đổi sang SQL `DATE` để lưu được ngày sinh trước năm 1900.

## Database và kiểm thử

Trên database mới hoặc máy khác, chạy các script theo README; bản này bổ sung `06_BaremMvc.sql`. Database local đã được áp dụng script.

```powershell
python tools/sync_razor_views.py
# Build project bằng Visual Studio/MSBuild, rồi chạy IIS Express.
./test-barem.ps1
./test-order-cancellation.ps1
```

`sync_razor_views.py` chỉ sinh các view trang từ nguồn HTML và các phần khung được quản lý bởi script; không ghi đè các view quản lý, hồ sơ hay partial nghiệp vụ viết tay. Các script test dùng dữ liệu thử riêng và tự dọn; tài khoản demo admin mặc định phải còn dùng được.

## Phạm vi của đợt này

Đây là 7 nhóm được chọn triển khai, không phải chứng nhận đạt toàn bộ điểm barem. Luồng đăng ký vẫn có bước OTP; thanh toán thẻ vẫn mô phỏng. Controller MVC cũ còn trong source không phải luồng demo chính; không trộn quy ước trạng thái đơn cũ với API hiện tại.
