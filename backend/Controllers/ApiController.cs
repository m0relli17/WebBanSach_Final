using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Net.Mail;
using System.Security.Cryptography;
using System.IO;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using WebBanSach.Models;
using WebBanSach.Models.Data;
using WebBanSach.Models.Process;

namespace WebBanSach.Controllers
{
    public class ApiController : Controller
    {
        private readonly BSDBContext db = new BSDBContext();
        private const string CartSession = "CartSession";

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            Response.Headers.Remove("Access-Control-Allow-Origin");
            Response.AddHeader("Access-Control-Allow-Origin", "*");
            Response.AddHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
            Response.AddHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With, X-Admin-Token");

            if (Request.HttpMethod == "OPTIONS")
            {
                filterContext.Result = new HttpStatusCodeResult(200);
                return;
            }

            var action = filterContext.ActionDescriptor.ActionName;
            if (action.StartsWith("Admin", StringComparison.OrdinalIgnoreCase) && action != "AdminLogin")
            {
                if (Session["AdminUser"] == null)
                {
                    Response.StatusCode = 401;
                    filterContext.Result = Json(new { status = false, message = "Vui lòng đăng nhập quản trị." }, JsonRequestBehavior.AllowGet);
                    return;
                }
                if (Request.HttpMethod == "POST" && action != "AdminUpdateOrderStatus" &&
                    (Session["AdminToken"] == null || Request.Headers["X-Admin-Token"] != (string)Session["AdminToken"]))
                {
                    Response.StatusCode = 403;
                    filterContext.Result = Json(new { status = false, message = "Phiên không hợp lệ. Hãy tải lại trang." });
                    return;
                }
            }

            base.OnActionExecuting(filterContext);
        }

        // ==========================================
        // 1. SÁCH & DANH MỤC (BOOKS & CATEGORIES)
        // ==========================================

        [HttpGet]
        public JsonResult Books(int? categoryId = null, string search = null, int? page = 1, int? pageSize = 12, bool? bestSeller = null, string sortBy = "newest")
        {
            try
            {
                var query = db.Saches.AsNoTracking().Include(s => s.TheLoai).Include(s => s.TacGia).Include(s => s.NhaXuatBan).AsQueryable();

                if (categoryId.HasValue && categoryId.Value > 0)
                {
                    query = query.Where(s => s.MaLoai == categoryId.Value);
                }

                if (!string.IsNullOrWhiteSpace(search))
                {
                    var kw = search.Trim().ToLower();
                    query = query.Where(s => s.TenSach.ToLower().Contains(kw) ||
                                             (s.TacGia != null && s.TacGia.TenTG.ToLower().Contains(kw)));
                }

                var hotSince = DateTime.Now.AddDays(-30);
                switch ((sortBy ?? "newest").Trim().ToLowerInvariant())
                {
                    case "price-asc":
                        query = query.OrderBy(s => (s.GiaBan ?? 0) * (100 - s.GiamGia) / 100m).ThenByDescending(s => s.MaSach);
                        break;
                    case "price-desc":
                        query = query.OrderByDescending(s => (s.GiaBan ?? 0) * (100 - s.GiamGia) / 100m).ThenByDescending(s => s.MaSach);
                        break;
                    case "hot":
                        query = query.OrderByDescending(s => db.ChiTietDDHs.Where(d => d.MaSach == s.MaSach && d.DonDatHang.Tracking != 4 && d.DonDatHang.NgayDat >= hotSince).Sum(d => (int?)d.SoLuong) ?? 0).ThenByDescending(s => s.MaSach);
                        break;
                    case "popular":
                        query = query.OrderByDescending(s => db.DanhGiaSaches.Where(r => r.MaSach == s.MaSach).Select(r => (double?)r.SoSao).Average() ?? 0).ThenByDescending(s => db.DanhGiaSaches.Count(r => r.MaSach == s.MaSach)).ThenByDescending(s => s.MaSach);
                        break;
                    case "sales":
                        query = query.OrderByDescending(s => db.ChiTietDDHs.Where(d => d.MaSach == s.MaSach && d.DonDatHang.Tracking != 4).Sum(d => (int?)d.SoLuong) ?? 0).ThenByDescending(s => s.MaSach);
                        break;
                    default:
                        if (bestSeller.HasValue && bestSeller.Value)
                        {
                            query = query.OrderByDescending(s => db.ChiTietDDHs.Where(d => d.MaSach == s.MaSach && d.DonDatHang.Tracking != 4).Sum(d => (int?)d.SoLuong) ?? 0).ThenByDescending(s => s.MaSach);
                        }
                        else
                        {
                            query = query.OrderByDescending(s => s.NgayCapNhat).ThenByDescending(s => s.MaSach);
                        }
                        break;
                }

                int totalItems = query.Count();
                int curPage = Math.Max(1, page ?? 1);
                int limit = Math.Max(1, Math.Min(100, pageSize ?? 12));

                var items = query.Skip((curPage - 1) * limit).Take(limit).ToList();
                var bookIds = items.Select(s => s.MaSach).ToList();
                var reviewStats = db.DanhGiaSaches.AsNoTracking().Where(r => bookIds.Contains(r.MaSach))
                    .GroupBy(r => r.MaSach)
                    .Select(g => new { BookId = g.Key, Average = g.Average(r => r.SoSao), Count = g.Count() })
                    .ToDictionary(x => x.BookId);
                var salesStats = db.ChiTietDDHs.AsNoTracking().Where(d => bookIds.Contains(d.MaSach) && d.DonDatHang.Tracking != 4)
                    .GroupBy(d => d.MaSach)
                    .Select(g => new { BookId = g.Key, Count = g.Sum(d => (int?)d.SoLuong) ?? 0 })
                    .ToDictionary(x => x.BookId, x => x.Count);
                var hotStats = db.ChiTietDDHs.AsNoTracking().Where(d => bookIds.Contains(d.MaSach) && d.DonDatHang.Tracking != 4 && d.DonDatHang.NgayDat >= hotSince)
                    .GroupBy(d => d.MaSach)
                    .Select(g => new { BookId = g.Key, Count = g.Sum(d => (int?)d.SoLuong) ?? 0 })
                    .ToDictionary(x => x.BookId, x => x.Count);

                var result = items.Select(s => new
                {
                    id = s.MaSach,
                    title = s.TenSach,
                    price = s.GiaSauGiam,
                    priceFormatted = string.Format("{0:N0} VND", s.GiaSauGiam),
                    originalPrice = s.GiaBan ?? 0,
                    originalPriceFormatted = string.Format("{0:N0} VND", s.GiaBan ?? 0),
                    discountPercent = s.GiamGia,
                    averageRating = reviewStats.ContainsKey(s.MaSach) ? reviewStats[s.MaSach].Average : 0,
                    reviewCount = reviewStats.ContainsKey(s.MaSach) ? reviewStats[s.MaSach].Count : 0,
                    salesCount = salesStats.ContainsKey(s.MaSach) ? salesStats[s.MaSach] : 0,
                    hotSalesCount = hotStats.ContainsKey(s.MaSach) ? hotStats[s.MaSach] : 0,
                    image = string.IsNullOrEmpty(s.AnhBia) ? "topSach.png" : s.AnhBia,
                    stock = s.SoLuongTon ?? 0,
                    categoryId = s.MaLoai,
                    categoryName = s.TheLoai != null ? s.TheLoai.TenLoai : "",
                    author = s.TacGia != null ? s.TacGia.TenTG : "Đang cập nhật",
                    publisher = s.NhaXuatBan != null ? s.NhaXuatBan.TenNXB : "Đang cập nhật",
                    description = s.Mota ?? ""
                }).ToList();

                return Json(new
                {
                    status = true,
                    totalItems = totalItems,
                    page = curPage,
                    pageSize = limit,
                    totalPages = (int)Math.Ceiling((double)totalItems / limit),
                    data = result
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public JsonResult BookDetails(int id)
        {
            try
            {
                var s = db.Saches.AsNoTracking().Include(x => x.TheLoai).Include(x => x.TacGia).Include(x => x.NhaXuatBan).FirstOrDefault(x => x.MaSach == id);
                if (s == null)
                {
                    return Json(new { status = false, message = "Không tìm thấy sách" }, JsonRequestBehavior.AllowGet);
                }

                var relatedBooks = db.Saches.AsNoTracking()
                    .Where(x => x.MaLoai == s.MaLoai && x.MaSach != s.MaSach)
                    .Take(4)
                    .ToList();
                var averageRating = db.DanhGiaSaches.Where(r => r.MaSach == id).Select(r => (double?)r.SoSao).Average() ?? 0;
                var reviewCount = db.DanhGiaSaches.Count(r => r.MaSach == id);
                var related = relatedBooks.Select(r => new
                    {
                        id = r.MaSach,
                        title = r.TenSach,
                        price = r.GiaSauGiam,
                        priceFormatted = string.Format("{0:N0} VND", r.GiaSauGiam),
                        originalPrice = r.GiaBan ?? 0,
                        originalPriceFormatted = string.Format("{0:N0} VND", r.GiaBan ?? 0),
                        discountPercent = r.GiamGia,
                        averageRating = db.DanhGiaSaches.Where(review => review.MaSach == r.MaSach).Select(review => (double?)review.SoSao).Average() ?? 0,
                        reviewCount = db.DanhGiaSaches.Count(review => review.MaSach == r.MaSach),
                        image = string.IsNullOrEmpty(r.AnhBia) ? "topSach.png" : r.AnhBia
                    }).ToList();

                return Json(new
                {
                    status = true,
                    data = new
                    {
                        id = s.MaSach,
                        title = s.TenSach,
                        price = s.GiaSauGiam,
                        priceFormatted = string.Format("{0:N0} VND", s.GiaSauGiam),
                        originalPrice = s.GiaBan ?? 0,
                        originalPriceFormatted = string.Format("{0:N0} VND", s.GiaBan ?? 0),
                        discountPercent = s.GiamGia,
                        averageRating = averageRating,
                        reviewCount = reviewCount,
                        image = string.IsNullOrEmpty(s.AnhBia) ? "topSach.png" : s.AnhBia,
                        stock = s.SoLuongTon ?? 0,
                        categoryId = s.MaLoai,
                        categoryName = s.TheLoai != null ? s.TheLoai.TenLoai : "",
                        author = s.TacGia != null ? s.TacGia.TenTG : "Đang cập nhật",
                        publisher = s.NhaXuatBan != null ? s.NhaXuatBan.TenNXB : "Đang cập nhật",
                        description = s.Mota ?? "Chưa có mô tả chi tiết cho sách này.",
                        updatedDate = s.NgayCapNhat.HasValue ? s.NgayCapNhat.Value.ToString("dd/MM/yyyy") : ""
                    },
                    related = related
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public JsonResult BookReviews(int id)
        {
            try
            {
                if (!db.Saches.Any(s => s.MaSach == id))
                {
                    return Json(new { status = false, message = "Không tìm thấy sách." }, JsonRequestBehavior.AllowGet);
                }

                var count = db.DanhGiaSaches.Count(r => r.MaSach == id);
                var average = db.DanhGiaSaches.Where(r => r.MaSach == id).Select(r => (double?)r.SoSao).Average() ?? 0;
                var reviews = db.DanhGiaSaches.AsNoTracking().Where(r => r.MaSach == id)
                    .OrderByDescending(r => r.NgayDanhGia).Take(100).ToList();
                var customerIds = reviews.Select(r => r.MaKH).Distinct().ToList();
                var customerNames = db.KhachHangs.AsNoTracking().Where(k => customerIds.Contains(k.MaKH))
                    .ToDictionary(k => k.MaKH, k => k.TenKH);

                var userId = Session["UserId"] as int?;
                var customer = userId.HasValue
                    ? db.KhachHangs.AsNoTracking().FirstOrDefault(k => k.MaKH == userId.Value && k.TrangThai && k.EmailVerified)
                    : null;
                var myReview = customer == null ? null : reviews.FirstOrDefault(r => r.MaKH == customer.MaKH);
                if (customer != null && myReview == null)
                {
                    myReview = db.DanhGiaSaches.AsNoTracking().FirstOrDefault(r => r.MaSach == id && r.MaKH == customer.MaKH);
                }

                return Json(new
                {
                    status = true,
                    averageRating = average,
                    reviewCount = count,
                    canReview = customer != null,
                    myReview = myReview == null ? null : new { rating = myReview.SoSao, comment = myReview.NoiDung },
                    data = reviews.Select(r => new
                    {
                        rating = r.SoSao,
                        comment = r.NoiDung,
                        date = r.NgayDanhGia.ToString("dd/MM/yyyy"),
                        customerName = customerNames.ContainsKey(r.MaKH) ? customerNames[r.MaKH] : "Khách hàng"
                    }).ToList()
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult SubmitBookReview(int bookId, int rating, string comment)
        {
            var userId = Session["UserId"] as int?;
            if (!userId.HasValue)
            {
                Response.StatusCode = 401;
                return Json(new { status = false, message = "Vui lòng đăng nhập để đánh giá sách." });
            }

            var customer = db.KhachHangs.FirstOrDefault(k => k.MaKH == userId.Value && k.TrangThai && k.EmailVerified);
            if (customer == null)
            {
                Response.StatusCode = 403;
                return Json(new { status = false, message = "Tài khoản cần hoạt động và xác minh email để đánh giá." });
            }

            if (rating < 1 || rating > 5 || (comment ?? "").Trim().Length > 1000)
            {
                return Json(new { status = false, message = "Điểm đánh giá phải từ 1 đến 5 sao; bình luận tối đa 1000 ký tự." });
            }

            if (!db.Saches.Any(s => s.MaSach == bookId))
            {
                return Json(new { status = false, message = "Không tìm thấy sách." });
            }

            var review = db.DanhGiaSaches.FirstOrDefault(r => r.MaSach == bookId && r.MaKH == customer.MaKH);
            if (review == null)
            {
                review = new DanhGiaSach { MaSach = bookId, MaKH = customer.MaKH };
                db.DanhGiaSaches.Add(review);
            }

            review.SoSao = rating;
            review.NoiDung = (comment ?? "").Trim();
            review.NgayDanhGia = DateTime.Now;
            db.SaveChanges();
            return Json(new { status = true, message = "Đã lưu đánh giá của bạn." });
        }

        [HttpGet]
        public JsonResult Categories()
        {
            try
            {
                var list = db.TheLoais.AsNoTracking().Select(t => new
                {
                    id = t.MaLoai,
                    name = t.TenLoai,
                    count = t.Saches.Count()
                }).ToList();

                return Json(new { status = true, data = list }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // ==========================================
        // 2. GIỎ HÀNG (SHOPPING CART)
        // ==========================================

        private List<CartModel> GetSessionCart()
        {
            var cart = Session[CartSession] as List<CartModel>;
            if (cart == null)
            {
                cart = new List<CartModel>();
                Session[CartSession] = cart;
            }
            return cart;
        }

        [HttpGet]
        public JsonResult Cart()
        {
            var cart = GetSessionCart();
            foreach (var item in cart)
            {
                var current = db.Saches.AsNoTracking().FirstOrDefault(x => x.MaSach == item.sach.MaSach);
                if (current != null) item.sach = current;
                else item.sach.SoLuongTon = 0;
            }
            decimal total = cart.Sum(x => x.Total).GetValueOrDefault(0);
            long count = cart.Sum(x => x.Quantity);
            decimal originalTotal = cart.Sum(x => ((x.sach.GiaBan ?? x.sach.GiaSauGiam) * x.Quantity)).GetValueOrDefault(0);
            decimal discount = Math.Max(0, originalTotal - total);

            return Json(new
            {
                status = true,
                items = cart.Select(x => new
                {
                    id = x.sach.MaSach,
                    title = x.sach.TenSach,
                    price = x.sach.GiaSauGiam,
                    priceFormatted = string.Format("{0:N0} VND", x.sach.GiaSauGiam),
                    originalPrice = x.sach.GiaBan ?? 0,
                    originalPriceFormatted = string.Format("{0:N0} VND", x.sach.GiaBan ?? 0),
                    discountPercent = x.sach.GiamGia,
                    image = string.IsNullOrEmpty(x.sach.AnhBia) ? "topSach.png" : x.sach.AnhBia,
                    quantity = x.Quantity,
                    stock = x.sach.SoLuongTon ?? 0,
                    subtotal = x.Total.GetValueOrDefault(0),
                    subtotalFormatted = string.Format("{0:N0} VND", x.Total.GetValueOrDefault(0))
                }).ToList(),
                total = total,
                totalFormatted = string.Format("{0:N0} VND", total),
                originalTotal = originalTotal,
                originalTotalFormatted = string.Format("{0:N0} VND", originalTotal),
                discount = discount,
                discountFormatted = string.Format("{0:N0} VND", discount),
                totalQuantity = count,
                itemCount = cart.Count
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult AddToCart(int id, long quantity = 1)
        {
            if (!ModelState.IsValid || quantity < 1 || quantity > 999) return Json(new { status = false, message = "Số lượng mỗi sản phẩm phải từ 1 đến 999." });
            var book = db.Saches.Find(id);
            if (book == null)
            {
                return Json(new { status = false, message = "Không tìm thấy cuốn sách này." });
            }

            var cart = GetSessionCart();
            var existing = cart.FirstOrDefault(x => x.sach.MaSach == id);
            long existingQuantity = existing != null ? existing.Quantity : 0;
            if (existingQuantity < 0 || existingQuantity > 999 || quantity > 999 - existingQuantity)
                return Json(new { status = false, message = "Số lượng mỗi sản phẩm không được vượt quá 999." });
            long available = book.SoLuongTon ?? 0;
            // Check the remaining capacity before adding, so long cannot overflow.
            if (available < existingQuantity || quantity > available - existingQuantity)
                return Json(new { status = false, message = string.Format("Sách '{0}' chỉ còn {1} cuốn. Giỏ hàng đã có {2} cuốn.", book.TenSach, available, existingQuantity) });
            long requested = existingQuantity + quantity;
            if (existing != null)
            {
                existing.Quantity = requested;
            }
            else
            {
                cart.Add(new CartModel { sach = book, Quantity = quantity });
            }
            Session[CartSession] = cart;

            return Cart();
        }

        [HttpPost]
        public JsonResult UpdateCart(string cartModel)
        {
            try
            {
                var jsonCart = new JavaScriptSerializer().Deserialize<List<CartModel>>(cartModel);
                var cart = GetSessionCart();
                if (jsonCart != null)
                {
                    foreach (var updated in jsonCart)
                    {
                        if (updated.sach == null || updated.Quantity < 1 || updated.Quantity > 999)
                            return Json(new { status = false, message = "Số lượng mỗi sản phẩm phải từ 1 đến 999." });
                        var current = db.Saches.AsNoTracking().FirstOrDefault(x => x.MaSach == updated.sach.MaSach);
                        if (current == null || updated.Quantity > (current.SoLuongTon ?? 0))
                            return Json(new { status = false, message = current == null ? "Sách không còn tồn tại." : string.Format("Sách '{0}' chỉ còn {1} cuốn.", current.TenSach, current.SoLuongTon ?? 0) });
                    }
                    foreach (var item in cart)
                    {
                        var updated = jsonCart.FirstOrDefault(x => x.sach != null && x.sach.MaSach == item.sach.MaSach);
                        if (updated != null && updated.Quantity >= 1)
                        {
                            item.Quantity = updated.Quantity;
                        }
                    }
                    Session[CartSession] = cart;
                }
                return Cart();
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpPost]
        public JsonResult DeleteCartItem(int id)
        {
            var cart = GetSessionCart();
            cart.RemoveAll(x => x.sach.MaSach == id);
            Session[CartSession] = cart;
            return Cart();
        }

        [HttpPost]
        public JsonResult ClearCart()
        {
            Session[CartSession] = new List<CartModel>();
            return Cart();
        }

        // ==========================================
        // 3. TÀI KHOẢN & XÁC THỰC (AUTH & USERS)
        // ==========================================

        private string HashPassword(string password)
        {
            byte[] salt = new byte[16];
            using (var rng = RandomNumberGenerator.Create()) rng.GetBytes(salt);
            using (var kdf = new Rfc2898DeriveBytes(password, salt, 210000, HashAlgorithmName.SHA256))
                return "PBKDF2$210000$" + Convert.ToBase64String(salt) + "$" + Convert.ToBase64String(kdf.GetBytes(32));
        }

        private bool CheckPassword(string input, string stored)
        {
            if (input == null || stored == null) return false;
            if (!stored.StartsWith("PBKDF2$")) return string.Equals(input, stored, StringComparison.Ordinal);
            try
            {
                var a = stored.Split('$');
                using (var kdf = new Rfc2898DeriveBytes(input, Convert.FromBase64String(a[2]), int.Parse(a[1]), HashAlgorithmName.SHA256))
                {
                    var actual = kdf.GetBytes(32);
                    var expected = Convert.FromBase64String(a[3]);
                    if (expected.Length != actual.Length) return false;
                    int diff = 0;
                    for (int i = 0; i < actual.Length; i++) diff |= actual[i] ^ expected[i];
                    return diff == 0;
                }
            }
            catch { return false; }
        }

        [HttpPost]
        public JsonResult Login(string username, string password)
        {
            try
            {
                username = (username ?? "").Trim();
                password = password ?? "";

                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                {
                    return Json(new { status = false, message = "Vui lòng nhập tên tài khoản và mật khẩu." });
                }

                var customer = db.KhachHangs.FirstOrDefault(x => x.TaiKhoan == username);
                if (customer == null || !CheckPassword(password, customer.MatKhau))
                {
                    return Json(new { status = false, message = "Tài khoản hoặc mật khẩu không chính xác." });
                }

                if (!customer.TrangThai)
                {
                    return Json(new { status = false, message = "Tài khoản đang bị khóa hoặc chưa được kích hoạt." });
                }

                // Tự động nâng cấp mật khẩu cũ sang PBKDF2 nếu cần
                if (!customer.MatKhau.StartsWith("PBKDF2$"))
                {
                    customer.MatKhau = HashPassword(password);
                    db.SaveChanges();
                }

                if (!customer.EmailVerified)
                {
                    Session["PendingUserId"] = customer.MaKH;
                    Session["User"] = null;
                    return Json(new
                    {
                        status = true,
                        requireOtp = true,
                        userId = customer.MaKH,
                        email = customer.Email,
                        message = "Tài khoản cần xác minh email trước khi tiếp tục."
                    });
                }

                Session["User"] = customer.TaiKhoan;
                Session["UserId"] = customer.MaKH;
                Session["PendingUserId"] = null;

                return Json(new
                {
                    status = true,
                    requireOtp = false,
                    user = new
                    {
                        id = customer.MaKH,
                        username = customer.TaiKhoan,
                        name = customer.TenKH,
                        email = customer.Email,
                        phone = customer.DienThoai,
                        address = customer.DiaChi
                    }
                });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpPost]
        public JsonResult Register(KhachHang model, string confirmPassword)
        {
            try
            {
                model.TaiKhoan = (model.TaiKhoan ?? "").Trim();
                model.Email = (model.Email ?? "").Trim().ToLowerInvariant();

                if (!Regex.IsMatch(model.TaiKhoan, @"^[A-Za-z0-9_.-]{3,50}$"))
                    return Json(new { status = false, message = "Tên đăng nhập phải từ 3–50 ký tự, không dấu và không chứa khoảng trắng." });

                if (string.IsNullOrEmpty(model.MatKhau) || model.MatKhau.Length < 8 || model.MatKhau.Length > 128 || model.MatKhau.Any(char.IsWhiteSpace))
                    return Json(new { status = false, message = "Mật khẩu phải từ 8–128 ký tự và không được chứa khoảng trắng." });

                if (model.MatKhau != confirmPassword)
                    return Json(new { status = false, message = "Mật khẩu xác nhận không khớp." });

                if (string.IsNullOrEmpty(model.Email) || !model.Email.Contains("@"))
                    return Json(new { status = false, message = "Địa chỉ email không hợp lệ." });

                if (string.IsNullOrEmpty(model.TenKH))
                    return Json(new { status = false, message = "Vui lòng nhập họ và tên." });

                if (string.IsNullOrEmpty(model.DienThoai))
                    return Json(new { status = false, message = "Vui lòng nhập số điện thoại." });

                if (db.KhachHangs.Any(x => x.TaiKhoan == model.TaiKhoan))
                    return Json(new { status = false, message = "Tên tài khoản này đã được sử dụng." });

                if (db.KhachHangs.Any(x => x.Email == model.Email))
                    return Json(new { status = false, message = "Địa chỉ email này đã được sử dụng." });

                var customer = new KhachHang
                {
                    TaiKhoan = model.TaiKhoan,
                    MatKhau = HashPassword(model.MatKhau),
                    TenKH = model.TenKH,
                    Email = model.Email,
                    DiaChi = model.DiaChi ?? "",
                    DienThoai = model.DienThoai,
                    NgaySinh = model.NgaySinh,
                    NgayTao = DateTime.Now,
                    TrangThai = true,
                    EmailVerified = false
                };

                db.KhachHangs.Add(customer);
                db.SaveChanges();

                Session["PendingUserId"] = customer.MaKH;
                Session["User"] = null;

                return Json(new
                {
                    status = true,
                    userId = customer.MaKH,
                    email = customer.Email,
                    message = "Đăng ký thành công! Vui lòng xác minh mã OTP gửi tới email."
                });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpPost]
        public JsonResult Logout()
        {
            Session.Clear();
            Session.Abandon();
            return Json(new { status = true, message = "Đã đăng xuất thành công." });
        }

        [HttpGet]
        public JsonResult Me()
        {
            var username = Session["User"] as string;
            if (string.IsNullOrEmpty(username))
            {
                var pendingId = Session["PendingUserId"] as int?;
                if (pendingId.HasValue)
                {
                    var pendingUser = db.KhachHangs.Find(pendingId.Value);
                    if (pendingUser != null)
                    {
                        return Json(new
                        {
                            isLoggedIn = false,
                            isPendingOtp = true,
                            email = pendingUser.Email,
                            userId = pendingUser.MaKH
                        }, JsonRequestBehavior.AllowGet);
                    }
                }
                return Json(new { isLoggedIn = false }, JsonRequestBehavior.AllowGet);
            }

            var customer = db.KhachHangs.AsNoTracking().FirstOrDefault(x => x.TaiKhoan == username);
            if (customer == null)
            {
                return Json(new { isLoggedIn = false }, JsonRequestBehavior.AllowGet);
            }

            return Json(new
            {
                isLoggedIn = true,
                user = new
                {
                    id = customer.MaKH,
                    username = customer.TaiKhoan,
                    name = customer.TenKH,
                    email = customer.Email,
                    phone = customer.DienThoai,
                    address = customer.DiaChi,
                    verified = customer.EmailVerified
                }
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult SendOtp()
        {
            try
            {
                int? userId = Session["PendingUserId"] as int? ?? Session["UserId"] as int?;
                if (!userId.HasValue)
                {
                    var username = Session["User"] as string;
                    if (!string.IsNullOrEmpty(username))
                    {
                        var user = db.KhachHangs.FirstOrDefault(x => x.TaiKhoan == username);
                        if (user != null) userId = user.MaKH;
                    }
                }

                if (!userId.HasValue)
                {
                    return Json(new { status = false, message = "Chưa đăng nhập tài khoản cần xác minh." });
                }

                var customer = db.KhachHangs.Find(userId.Value);
                if (customer == null)
                {
                    return Json(new { status = false, message = "Không tìm thấy người dùng." });
                }

                // Tạo mã ngẫu nhiên 6 chữ số
                string code = new Random().Next(100000, 999999).ToString();
                Session["OtpHash"] = HashPassword(code);
                Session["OtpUserId"] = customer.MaKH;
                Session["OtpEmail"] = customer.Email;
                Session["OtpExpires"] = DateTime.UtcNow.AddMinutes(5);

                // Ghi vào file trong App_Data/OtpEmails nếu ở chế độ LocalPickup
                try
                {
                    string dir = Server.MapPath("~/App_Data/OtpEmails");
                    if (!System.IO.Directory.Exists(dir)) System.IO.Directory.CreateDirectory(dir);
                    string filePath = System.IO.Path.Combine(dir, string.Format("otp_{0}_{1}.txt", customer.MaKH, DateTime.Now.ToString("yyyyMMdd_HHmmss")));
                    System.IO.File.WriteAllText(filePath, string.Format("Email: {0}\nOTP Code: {1}\nTime: {2}", customer.Email, code, DateTime.Now));
                }
                catch { }

                return Json(new
                {
                    status = true,
                    message = "Mã xác minh 6 số đã được gửi tới email của bạn (hoặc ghi nhận trong App_Data).",
                    email = customer.Email,
                    // Trong môi trường test local, hỗ trợ trả về mã test để tiện trải nghiệm:
                    testCode = code
                });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpPost]
        public JsonResult VerifyOtp(string code)
        {
            try
            {
                code = (code ?? "").Trim();
                var storedHash = Session["OtpHash"] as string;
                var expires = Session["OtpExpires"] as DateTime?;
                int? userId = Session["OtpUserId"] as int? ?? Session["PendingUserId"] as int?;

                if (string.IsNullOrEmpty(code) || code.Length != 6)
                {
                    return Json(new { status = false, message = "Vui lòng nhập đủ 6 chữ số mã xác minh." });
                }

                if (string.IsNullOrEmpty(storedHash) || !expires.HasValue || DateTime.UtcNow > expires.Value)
                {
                    return Json(new { status = false, message = "Mã OTP đã hết hạn hoặc chưa được tạo. Hãy bấm gửi lại mã mới." });
                }

                if (!CheckPassword(code, storedHash))
                {
                    return Json(new { status = false, message = "Mã xác minh không chính xác. Vui lòng kiểm tra lại." });
                }

                if (userId.HasValue)
                {
                    var customer = db.KhachHangs.Find(userId.Value);
                    if (customer != null)
                    {
                        customer.EmailVerified = true;
                        db.SaveChanges();
                        Session["User"] = customer.TaiKhoan;
                        Session["UserId"] = customer.MaKH;
                        Session["PendingUserId"] = null;
                        Session.Remove("OtpHash");
                        Session.Remove("OtpExpires");

                        return Json(new
                        {
                            status = true,
                            message = "Xác minh email thành công!",
                            user = new
                            {
                                id = customer.MaKH,
                                username = customer.TaiKhoan,
                                name = customer.TenKH
                            }
                        });
                    }
                }

                return Json(new { status = false, message = "Không tìm thấy thông tin tài khoản." });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        // ==========================================
        // 4. ĐẶT HÀNG & THEO DÕI (ORDERS & CHECKOUT)
        // ==========================================

        [HttpPost]
        public JsonResult Checkout(string receiverName, string receiverPhone, string receiverAddress, string note,
            string paymentMethod = "cod", string cardNumber = null, string cardHolder = null, string cardExpiry = null, string cardCvv = null)
        {
            try
            {
                var username = Session["User"] as string;
                if (string.IsNullOrEmpty(username))
                {
                    return Json(new { status = false, requireLogin = true, message = "Vui lòng đăng nhập trước khi thanh toán." });
                }

                var customer = db.KhachHangs.FirstOrDefault(x => x.TaiKhoan == username);
                if (customer == null || !customer.EmailVerified)
                {
                    return Json(new { status = false, requireOtp = true, message = "Tài khoản cần xác minh email trước khi đặt hàng." });
                }

                var cart = GetSessionCart();
                if (cart == null || cart.Count == 0)
                {
                    return Json(new { status = false, message = "Giỏ hàng của bạn đang trống." });
                }

                if (string.IsNullOrWhiteSpace(receiverName) || string.IsNullOrWhiteSpace(receiverAddress) || string.IsNullOrWhiteSpace(receiverPhone))
                {
                    return Json(new { status = false, message = "Vui lòng nhập đầy đủ thông tin giao hàng." });
                }

                paymentMethod = (paymentMethod ?? "cod").Trim().ToLowerInvariant();
                bool isCreditCard = (paymentMethod == "credit_card" || paymentMethod == "card");
                string maskedCardNumber = "";

                if (isCreditCard)
                {
                    var cleanNumber = Regex.Replace(cardNumber ?? "", @"[\s-]", "");
                    if (string.IsNullOrEmpty(cleanNumber) || cleanNumber.Length < 13 || cleanNumber.Length > 19 || !Regex.IsMatch(cleanNumber, @"^\d+$"))
                    {
                        return Json(new { status = false, message = "Số thẻ tín dụng không hợp lệ (yêu cầu từ 13 đến 19 chữ số)." });
                    }

                    if (string.IsNullOrWhiteSpace(cardHolder))
                    {
                        return Json(new { status = false, message = "Vui lòng nhập tên chủ thẻ in trên thẻ tín dụng." });
                    }

                    var cleanExpiry = (cardExpiry ?? "").Trim();
                    if (!Regex.IsMatch(cleanExpiry, @"^(0[1-9]|1[0-2])\/([0-9]{2}|[0-9]{4})$"))
                    {
                        return Json(new { status = false, message = "Ngày hết hạn thẻ không đúng định dạng MM/YY (ví dụ: 12/28)." });
                    }

                    var cleanCvv = (cardCvv ?? "").Trim();
                    if (!Regex.IsMatch(cleanCvv, @"^\d{3,4}$"))
                    {
                        return Json(new { status = false, message = "Mã bảo mật CVV/CVC không hợp lệ (yêu cầu 3 hoặc 4 chữ số)." });
                    }

                    maskedCardNumber = "•••• •••• •••• " + cleanNumber.Substring(cleanNumber.Length - 4);
                }

                if (cart.Any(x => x.Quantity < 1 || x.Quantity > 999))
                    return Json(new { status = false, message = "Số lượng mỗi sản phẩm phải từ 1 đến 999." });

                using (var trans = db.Database.BeginTransaction())
                {
                    if (!string.IsNullOrWhiteSpace(receiverAddress))
                    {
                        customer.DiaChi = receiverAddress.Trim();
                    }
                    if (!string.IsNullOrWhiteSpace(receiverPhone))
                    {
                        customer.DienThoai = receiverPhone.Trim();
                    }

                    var order = new DonDatHang
                    {
                        MaKH = customer.MaKH,
                        NgayDat = DateTime.Now,
                        NgayGiao = DateTime.Now.AddDays(3),
                        TinhTrang = isCreditCard, // true nếu đã thanh toán bằng thẻ
                        ThanhToan = isCreditCard ? 1 : 0, // 1: Thẻ tín dụng (Đã thanh toán), 0: COD
                        Tracking = 0, // 0: Chờ xử lý
                        GhiChu = string.IsNullOrWhiteSpace(note) ? null : note.Trim()
                    };

                    db.DonDatHangs.Add(order);
                    db.SaveChanges();

                    foreach (var item in cart)
                    {
                        var book = db.Saches.AsNoTracking().FirstOrDefault(x => x.MaSach == item.sach.MaSach);
                        if (book == null)
                        {
                            trans.Rollback();
                            return Json(new { status = false, message = string.Format("Sách '{0}' không tồn tại.", item.sach.TenSach) });
                        }

                        // Atomic conditional update also protects concurrent checkouts.
                        int reserved = db.Database.ExecuteSqlCommand(
                            "UPDATE dbo.Sach SET SoLuongTon = SoLuongTon - @p0 WHERE MaSach = @p1 AND SoLuongTon >= @p0",
                            item.Quantity, book.MaSach);
                        if (reserved != 1)
                        {
                            trans.Rollback();
                            return Json(new { status = false, message = string.Format("Sách '{0}' không đủ tồn kho. Vui lòng cập nhật giỏ hàng.", book.TenSach) });
                        }

                        var detail = new ChiTietDDH
                        {
                            MaDDH = order.MaDDH,
                            MaSach = item.sach.MaSach,
                            SoLuong = item.Quantity,
                            DonGia = book.GiaSauGiam
                        };
                        db.ChiTietDDHs.Add(detail);
                    }

                    db.SaveChanges();
                    trans.Commit();

                    // Xóa giỏ hàng sau khi đặt thành công
                    Session[CartSession] = new List<CartModel>();

                    return Json(new
                    {
                        status = true,
                        orderId = order.MaDDH,
                        paymentMethod = isCreditCard ? "credit_card" : "cod",
                        paymentMethodText = isCreditCard ? "Thẻ tín dụng (Credit Card)" : "Thanh toán khi nhận hàng (COD)",
                        isPaid = isCreditCard,
                        maskedCard = isCreditCard ? maskedCardNumber : null,
                        message = isCreditCard
                            ? string.Format("Thanh toán thành công qua Thẻ tín dụng! Mã đơn hàng của bạn là #{0}", order.MaDDH)
                            : string.Format("Đặt hàng thành công! Mã đơn của bạn là #{0}", order.MaDDH)
                    });
                }
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpGet]
        public JsonResult MyOrders()
        {
            try
            {
                var username = Session["User"] as string;
                if (string.IsNullOrEmpty(username))
                {
                    return Json(new { status = false, isLoggedIn = false, message = "Chưa đăng nhập." }, JsonRequestBehavior.AllowGet);
                }

                var customer = db.KhachHangs.FirstOrDefault(x => x.TaiKhoan == username);
                if (customer == null)
                {
                    return Json(new { status = false, isLoggedIn = false, message = "Người dùng không tồn tại." }, JsonRequestBehavior.AllowGet);
                }

                var orders = db.DonDatHangs.AsNoTracking()
                    .Where(o => o.MaKH == customer.MaKH)
                    .OrderByDescending(o => o.NgayDat)
                    .ToList();

                var list = orders.Select(o => {
                    var details = db.ChiTietDDHs.AsNoTracking().Where(d => d.MaDDH == o.MaDDH).Include(d => d.Sach).ToList();
                    decimal total = details.Sum(d => (decimal?)d.DonGia * d.SoLuong).GetValueOrDefault(0);
                    bool isPaid = (o.ThanhToan == 1);
                    return new
                    {
                        id = o.MaDDH,
                        customerName = customer.TenKH,
                        customerPhone = customer.DienThoai,
                        customerAddress = customer.DiaChi,
                        orderDate = o.NgayDat.ToString("dd/MM/yyyy HH:mm"),
                        deliveryDate = o.NgayGiao.ToString("dd/MM/yyyy"),
                        status = o.Tracking ?? 0,
                        statusText = GetTrackingStatusText(o.Tracking ?? 0),
                        canCancel = (o.Tracking == null || o.Tracking == 0),
                        paymentStatus = o.ThanhToan ?? 0,
                        paymentMethod = isPaid ? "credit_card" : "cod",
                        paymentMethodText = isPaid ? "Thẻ tín dụng (Đã thanh toán)" : "COD (Thu tiền khi nhận)",
                        isPaid = isPaid,
                        note = o.GhiChu ?? "",
                        total = total,
                        totalFormatted = string.Format("{0:N0} VND", total),
                        itemCount = details.Sum(d => d.SoLuong),
                        items = details.Select(d => new
                        {
                            bookId = d.MaSach,
                            title = d.Sach != null ? d.Sach.TenSach : "",
                            image = d.Sach != null ? d.Sach.AnhBia : "topSach.png",
                            quantity = d.SoLuong,
                            price = d.DonGia,
                            priceFormatted = string.Format("{0:N0} VND", d.DonGia),
                            subtotal = d.DonGia * d.SoLuong,
                            subtotalFormatted = string.Format("{0:N0} VND", d.DonGia * d.SoLuong)
                        }).ToList()
                    };
                }).ToList();

                return Json(new { status = true, isLoggedIn = true, data = list }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, isLoggedIn = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult CancelOrder(int id)
        {
            try
            {
                var username = Session["User"] as string;
                if (string.IsNullOrEmpty(username))
                {
                    return Json(new { status = false, message = "Chưa đăng nhập." });
                }

                var customer = db.KhachHangs.FirstOrDefault(x => x.TaiKhoan == username);
                var order = db.DonDatHangs.FirstOrDefault(o => o.MaDDH == id && o.MaKH == customer.MaKH);
                if (order == null)
                {
                    return Json(new { status = false, message = "Không tìm thấy đơn hàng." });
                }

                if ((order.Tracking ?? 0) != 0)
                {
                    return Json(new { status = false, message = "Chỉ có thể hủy đơn hàng khi đang ở trạng thái 'Chờ xử lý'." });
                }

                // Trả lại số lượng tồn kho
                var details = db.ChiTietDDHs.Where(d => d.MaDDH == id).ToList();
                foreach (var item in details)
                {
                    var book = db.Saches.Find(item.MaSach);
                    if (book != null)
                    {
                        book.SoLuongTon = (book.SoLuongTon ?? 0) + item.SoLuong;
                    }
                }

                order.Tracking = 4; // 4: Đã hủy
                db.SaveChanges();

                return Json(new { status = true, message = "Đã hủy đơn hàng #" + id + " thành công." });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        // ==========================================
        // 5. QUẢN TRỊ VIÊN (ADMIN APIS)
        // ==========================================

        [HttpPost]
        public JsonResult AdminLogin(string username, string password)
        {
            try
            {
                username = (username ?? "").Trim();
                password = (password ?? "").Trim();

                var admin = db.Admins.FirstOrDefault(a => a.TaiKhoan == username && a.MatKhau == password && a.TrangThai == true);
                if (admin == null)
                {
                    return Json(new { status = false, message = "Sai tài khoản hoặc mật khẩu quản trị." });
                }

                Session["AdminUser"] = admin.TaiKhoan;
                Session["AdminName"] = admin.HoTen;

                return Json(new
                {
                    status = true,
                    admin = new { username = admin.TaiKhoan, name = admin.HoTen }
                });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpGet]
        public JsonResult AdminCatalog()
        {
            if (!IsAdminAuthenticated())
            {
                Response.StatusCode = 401;
                return Json(new { status = false, message = "Vui lòng đăng nhập tài khoản admin." }, JsonRequestBehavior.AllowGet);
            }

            return Json(new
            {
                status = true,
                categories = db.TheLoais.AsNoTracking().OrderBy(x => x.TenLoai).Select(x => new { id = x.MaLoai, name = x.TenLoai }).ToList(),
                authors = db.TacGias.AsNoTracking().OrderBy(x => x.TenTG).Select(x => new { id = x.MaTG, name = x.TenTG }).ToList(),
                publishers = db.NhaXuatBans.AsNoTracking().OrderBy(x => x.TenNXB).Select(x => new { id = x.MaNXB, name = x.TenNXB }).ToList()
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult AdminBooks(string search = null, int page = 1)
        {
            try
            {
                var query = db.Saches.AsNoTracking()
                    .Include(s => s.TheLoai)
                    .Include(s => s.TacGia)
                    .Include(s => s.NhaXuatBan)
                    .AsQueryable();
                if (!string.IsNullOrWhiteSpace(search))
                {
                    var keyword = search.Trim().ToLowerInvariant();
                    query = query.Where(s => s.TenSach.ToLower().Contains(keyword) ||
                                             (s.TacGia != null && s.TacGia.TenTG.ToLower().Contains(keyword)));
                }

                var totalItems = query.Count();
                const int pageSize = 8;
                var totalPages = Math.Max(1, (int)Math.Ceiling(totalItems / (double)pageSize));
                var currentPage = Math.Max(1, Math.Min(page, totalPages));
                var books = query.OrderByDescending(s => s.MaSach)
                    .Skip((currentPage - 1) * pageSize)
                    .Take(pageSize)
                    .ToList()
                    .Select(s => new
                    {
                        id = s.MaSach,
                        title = s.TenSach,
                        author = s.TacGia != null ? s.TacGia.TenTG : "Đang cập nhật",
                        category = s.TheLoai != null ? s.TheLoai.TenLoai : "",
                        price = s.GiaSauGiam,
                        priceFormatted = string.Format("{0:N0} VND", s.GiaSauGiam),
                        stock = s.SoLuongTon ?? 0,
                        discountPercent = s.GiamGia
                    }).ToList();

                return Json(new { status = true, data = books, page = currentPage, totalPages = totalPages, totalItems = totalItems }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public JsonResult AdminBookDetails(int id)
        {
            var book = db.Saches.AsNoTracking()
                .Include(s => s.TheLoai)
                .Include(s => s.TacGia)
                .Include(s => s.NhaXuatBan)
                .FirstOrDefault(s => s.MaSach == id);
            if (book == null)
            {
                return Json(new { status = false, message = "Không tìm thấy sản phẩm." }, JsonRequestBehavior.AllowGet);
            }

            return Json(new
            {
                status = true,
                data = new
                {
                    id = book.MaSach,
                    title = book.TenSach,
                    author = book.TacGia != null ? book.TacGia.TenTG : "Đang cập nhật",
                    category = book.TheLoai != null ? book.TheLoai.TenLoai : "",
                    categoryId = book.MaLoai,
                    publisher = book.NhaXuatBan != null ? book.NhaXuatBan.TenNXB : "",
                    publisherId = book.MaNXB,
                    priceFormatted = string.Format("{0:N0} VND", book.GiaSauGiam),
                    originalPrice = book.GiaBan ?? 0,
                    originalPriceFormatted = string.Format("{0:N0} VND", book.GiaBan ?? 0),
                    discountPercent = book.GiamGia,
                    stock = book.SoLuongTon ?? 0,
                    translator = book.NguoiDich ?? "",
                    image = string.IsNullOrEmpty(book.AnhBia) ? "topSach.png" : book.AnhBia,
                    description = book.Mota ?? ""
                }
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult AdminCreateBook(string title, decimal? price, int? discountPercent, int? categoryId, string authorName, int? publisherId, int? stock, string translator, string description, HttpPostedFileBase cover)
        {
            if (!IsAdminAuthenticated())
            {
                Response.StatusCode = 401;
                return Json(new { status = false, message = "Vui lòng đăng nhập tài khoản admin." });
            }

            title = (title ?? "").Trim();
            authorName = (authorName ?? "").Trim();
            translator = (translator ?? "").Trim();
            description = (description ?? "").Trim();

            if (title.Length == 0 || title.Length > 250 || authorName.Length == 0 || authorName.Length > 50 || translator.Length > 50 || description.Length > 500 ||
                !price.HasValue || price.Value < 0 || !discountPercent.HasValue || discountPercent.Value < 0 || discountPercent.Value > 100 || !stock.HasValue || stock.Value < 0 ||
                !categoryId.HasValue || !publisherId.HasValue ||
                !db.TheLoais.Any(x => x.MaLoai == categoryId.Value) ||
                !db.NhaXuatBans.Any(x => x.MaNXB == publisherId.Value))
            {
                return Json(new { status = false, message = "Vui lòng kiểm tra các thông tin sản phẩm." });
            }

            if (cover == null || cover.ContentLength == 0 || cover.ContentLength > 4 * 1024 * 1024)
            {
                return Json(new { status = false, message = "Vui lòng chọn ảnh bìa hợp lệ, dung lượng tối đa 4 MB." });
            }

            var extension = Path.GetExtension(cover.FileName).ToLowerInvariant();
            if (extension != ".jpg" && extension != ".jpeg" && extension != ".jfif" && extension != ".png" && extension != ".gif" && extension != ".bmp")
            {
                return Json(new { status = false, message = "Ảnh bìa chỉ hỗ trợ JPG, JFIF, PNG, GIF hoặc BMP." });
            }

            string coverPath = null;
            try
            {
                Guid imageFormat;
                using (var image = System.Drawing.Image.FromStream(cover.InputStream))
                {
                    imageFormat = image.RawFormat.Guid;
                    if (image.Width > 8000 || image.Height > 8000 || (long)image.Width * image.Height > 40000000)
                    {
                        return Json(new { status = false, message = "Kích thước ảnh bìa quá lớn." });
                    }
                }

                var allowedFormats = new[]
                {
                    System.Drawing.Imaging.ImageFormat.Jpeg.Guid,
                    System.Drawing.Imaging.ImageFormat.Png.Guid,
                    System.Drawing.Imaging.ImageFormat.Gif.Guid,
                    System.Drawing.Imaging.ImageFormat.Bmp.Guid
                };
                var expectedFormat = extension == ".jpg" || extension == ".jpeg" || extension == ".jfif"
                    ? System.Drawing.Imaging.ImageFormat.Jpeg.Guid
                    : extension == ".png"
                        ? System.Drawing.Imaging.ImageFormat.Png.Guid
                        : extension == ".gif"
                            ? System.Drawing.Imaging.ImageFormat.Gif.Guid
                            : System.Drawing.Imaging.ImageFormat.Bmp.Guid;
                if (!allowedFormats.Contains(imageFormat) || imageFormat != expectedFormat)
                {
                    return Json(new { status = false, message = "Tệp tải lên không phải ảnh hợp lệ." });
                }

                cover.InputStream.Position = 0;
                var fileName = Guid.NewGuid().ToString("N") + extension;
                coverPath = Server.MapPath("~/images/" + fileName);
                cover.SaveAs(coverPath);

                using (var transaction = db.Database.BeginTransaction())
                {
                    var author = db.TacGias.FirstOrDefault(x => x.TenTG.Trim() == authorName);
                    if (author == null)
                    {
                        author = new TacGia { TenTG = authorName };
                        db.TacGias.Add(author);
                        db.SaveChanges();
                    }

                    var book = new Sach
                    {
                        TenSach = title,
                        GiaBan = price.Value,
                        GiamGia = discountPercent.Value,
                        MaLoai = categoryId.Value,
                        MaTG = author.MaTG,
                        MaNXB = publisherId.Value,
                        SoLuongTon = stock.Value,
                        NguoiDich = translator.Length == 0 ? null : translator,
                        Mota = description.Length == 0 ? null : description,
                        AnhBia = fileName,
                        NgayCapNhat = DateTime.Now
                    };

                    db.Saches.Add(book);
                    db.SaveChanges();
                    transaction.Commit();
                    return Json(new { status = true, message = "Thêm sản phẩm thành công.", id = book.MaSach });
                }
            }
            catch (Exception)
            {
                if (!string.IsNullOrEmpty(coverPath) && System.IO.File.Exists(coverPath))
                {
                    System.IO.File.Delete(coverPath);
                }
                return Json(new { status = false, message = "Không thể lưu sản phẩm. Vui lòng thử lại." });
            }
        }

        [HttpPost]
        public JsonResult AdminUpdateBook(int? bookId, string title, decimal? price, int? discountPercent, int? categoryId, string authorName, int? publisherId, int? stock, string translator, string description, HttpPostedFileBase cover)
        {
            title = (title ?? "").Trim();
            authorName = (authorName ?? "").Trim();
            translator = (translator ?? "").Trim();
            description = (description ?? "").Trim();

            if (!bookId.HasValue || title.Length == 0 || title.Length > 250 || authorName.Length == 0 || authorName.Length > 50 ||
                translator.Length > 50 || description.Length > 500 || !price.HasValue || price.Value < 0 ||
                !discountPercent.HasValue || discountPercent.Value < 0 || discountPercent.Value > 100 || !stock.HasValue || stock.Value < 0 ||
                !categoryId.HasValue || !publisherId.HasValue ||
                !db.TheLoais.Any(x => x.MaLoai == categoryId.Value) || !db.NhaXuatBans.Any(x => x.MaNXB == publisherId.Value))
            {
                return Json(new { status = false, message = "Vui lòng kiểm tra các thông tin sản phẩm." });
            }

            var book = db.Saches.Find(bookId.Value);
            if (book == null) return Json(new { status = false, message = "Không tìm thấy sản phẩm." });

            string newFileName = null;
            string newCoverPath = null;
            var oldFileName = book.AnhBia;
            try
            {
                if (cover != null && cover.ContentLength > 0)
                {
                    if (cover.ContentLength > 4 * 1024 * 1024)
                        return Json(new { status = false, message = "Ảnh bìa tối đa 4 MB." });

                    var extension = Path.GetExtension(cover.FileName).ToLowerInvariant();
                    if (extension != ".jpg" && extension != ".jpeg" && extension != ".jfif" && extension != ".png" && extension != ".gif" && extension != ".bmp")
                        return Json(new { status = false, message = "Ảnh bìa chỉ hỗ trợ JPG, JFIF, PNG, GIF hoặc BMP." });

                    Guid imageFormat;
                    using (var image = System.Drawing.Image.FromStream(cover.InputStream))
                    {
                        imageFormat = image.RawFormat.Guid;
                        if (image.Width > 8000 || image.Height > 8000 || (long)image.Width * image.Height > 40000000)
                            return Json(new { status = false, message = "Kích thước ảnh bìa quá lớn." });
                    }

                    var expectedFormat = extension == ".jpg" || extension == ".jpeg" || extension == ".jfif"
                        ? System.Drawing.Imaging.ImageFormat.Jpeg.Guid
                        : extension == ".png"
                            ? System.Drawing.Imaging.ImageFormat.Png.Guid
                            : extension == ".gif"
                                ? System.Drawing.Imaging.ImageFormat.Gif.Guid
                                : System.Drawing.Imaging.ImageFormat.Bmp.Guid;
                    if (imageFormat != expectedFormat)
                        return Json(new { status = false, message = "Tệp tải lên không phải ảnh hợp lệ." });

                    cover.InputStream.Position = 0;
                    newFileName = Guid.NewGuid().ToString("N") + extension;
                    newCoverPath = Server.MapPath("~/images/" + newFileName);
                    cover.SaveAs(newCoverPath);
                }

                using (var transaction = db.Database.BeginTransaction())
                {
                    var author = db.TacGias.FirstOrDefault(x => x.TenTG.Trim() == authorName);
                    if (author == null)
                    {
                        author = new TacGia { TenTG = authorName };
                        db.TacGias.Add(author);
                        db.SaveChanges();
                    }

                    book.TenSach = title;
                    book.GiaBan = price.Value;
                    book.GiamGia = discountPercent.Value;
                    book.MaLoai = categoryId.Value;
                    book.MaTG = author.MaTG;
                    book.MaNXB = publisherId.Value;
                    book.SoLuongTon = stock.Value;
                    book.NguoiDich = translator.Length == 0 ? null : translator;
                    book.Mota = description.Length == 0 ? null : description;
                    book.NgayCapNhat = DateTime.Now;
                    if (newFileName != null) book.AnhBia = newFileName;

                    db.SaveChanges();
                    transaction.Commit();
                }

                if (newFileName != null && !string.IsNullOrEmpty(oldFileName) &&
                    !db.Saches.Any(x => x.AnhBia == oldFileName))
                {
                    var oldCoverPath = Server.MapPath("~/images/" + Path.GetFileName(oldFileName));
                    if (System.IO.File.Exists(oldCoverPath)) System.IO.File.Delete(oldCoverPath);
                }

                return Json(new { status = true, message = "Cập nhật sản phẩm thành công." });
            }
            catch (Exception)
            {
                if (!string.IsNullOrEmpty(newCoverPath) && System.IO.File.Exists(newCoverPath))
                    System.IO.File.Delete(newCoverPath);
                return Json(new { status = false, message = "Không thể cập nhật sản phẩm. Vui lòng thử lại." });
            }
        }

        [HttpPost]
        public JsonResult AdminDeleteBook(int id)
        {
            var book = db.Saches.Find(id);
            if (book == null) return Json(new { status = false, message = "Không tìm thấy sản phẩm." });
            if (db.ChiTietDDHs.Any(x => x.MaSach == id))
                return Json(new { status = false, message = "Sách đã có trong lịch sử đơn hàng nên không thể xóa. Hãy đưa tồn kho về 0." });

            try
            {
                var imageName = book.AnhBia;
                db.DanhGiaSaches.RemoveRange(db.DanhGiaSaches.Where(x => x.MaSach == id));
                db.Saches.Remove(book);
                db.SaveChanges();
                if (!string.IsNullOrEmpty(imageName) && !db.Saches.Any(x => x.AnhBia == imageName))
                {
                    var imagePath = Server.MapPath("~/images/" + Path.GetFileName(imageName));
                    if (System.IO.File.Exists(imagePath)) System.IO.File.Delete(imagePath);
                }
                return Json(new { status = true, message = "Đã xóa sản phẩm." });
            }
            catch (Exception)
            {
                return Json(new { status = false, message = "Không thể xóa sản phẩm." });
            }
        }

        [HttpGet]
        public JsonResult AdminReviews(string search = null, int? rating = null, int page = 1)
        {
            try
            {
                var query = from review in db.DanhGiaSaches.AsNoTracking()
                            join book in db.Saches.AsNoTracking() on review.MaSach equals book.MaSach
                            join customer in db.KhachHangs.AsNoTracking() on review.MaKH equals customer.MaKH
                            select new { Review = review, BookTitle = book.TenSach, CustomerName = customer.TenKH, CustomerEmail = customer.Email };

                if (rating.HasValue && rating.Value >= 1 && rating.Value <= 5)
                    query = query.Where(x => x.Review.SoSao == rating.Value);
                if (!string.IsNullOrWhiteSpace(search))
                {
                    var keyword = search.Trim().ToLower();
                    query = query.Where(x => x.BookTitle.ToLower().Contains(keyword) || x.CustomerName.ToLower().Contains(keyword) ||
                                             (x.CustomerEmail != null && x.CustomerEmail.ToLower().Contains(keyword)) ||
                                             (x.Review.NoiDung != null && x.Review.NoiDung.ToLower().Contains(keyword)));
                }

                var totalItems = query.Count();
                const int pageSize = 10;
                var totalPages = Math.Max(1, (int)Math.Ceiling(totalItems / (double)pageSize));
                var currentPage = Math.Max(1, Math.Min(page, totalPages));
                var data = query.OrderByDescending(x => x.Review.NgayDanhGia)
                    .Skip((currentPage - 1) * pageSize)
                    .Take(pageSize)
                    .ToList()
                    .Select(x => new
                    {
                        id = x.Review.MaDanhGia,
                        bookId = x.Review.MaSach,
                        bookTitle = x.BookTitle,
                        customerName = x.CustomerName,
                        customerEmail = x.CustomerEmail,
                        rating = x.Review.SoSao,
                        comment = x.Review.NoiDung,
                        date = x.Review.NgayDanhGia.ToString("dd/MM/yyyy HH:mm")
                    }).ToList();

                return Json(new { status = true, data = data, page = currentPage, totalPages = totalPages, totalItems = totalItems }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult AdminDeleteReview(int id)
        {
            var review = db.DanhGiaSaches.Find(id);
            if (review == null) return Json(new { status = false, message = "Không tìm thấy đánh giá." });
            db.DanhGiaSaches.Remove(review);
            db.SaveChanges();
            return Json(new { status = true, message = "Đã xóa đánh giá." });
        }

        [HttpGet]
        public JsonResult AdminSession()
        {
            if (Session["AdminToken"] == null) Session["AdminToken"] = Guid.NewGuid().ToString("N");
            return Json(new { status = true, name = Session["AdminName"] ?? Session["AdminUser"], token = Session["AdminToken"] }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult AdminLogout()
        {
            Session.Remove("AdminUser"); Session.Remove("AdminName"); Session.Remove("AdminToken");
            return Json(new { status = true });
        }

        [HttpGet]
        public JsonResult AdminOrders()
        {
            if (!IsAdminAuthenticated())
            {
                Response.StatusCode = 401;
                return Json(new { status = false, message = "Vui lòng đăng nhập tài khoản admin." }, JsonRequestBehavior.AllowGet);
            }

            try
            {
                var orders = db.DonDatHangs.AsNoTracking().Include(o => o.KhachHang).OrderByDescending(o => o.NgayDat).ToList();
                var list = orders.Select(o => {
                    var details = db.ChiTietDDHs.AsNoTracking().Where(d => d.MaDDH == o.MaDDH).Include(d => d.Sach).ToList();
                    decimal total = details.Sum(d => (decimal?)d.DonGia * d.SoLuong).GetValueOrDefault(0);
                    bool isPaid = (o.ThanhToan == 1);
                    return new
                    {
                        id = o.MaDDH,
                        customerName = o.KhachHang != null ? o.KhachHang.TenKH : "Khách",
                        customerPhone = o.KhachHang != null ? o.KhachHang.DienThoai : "",
                        customerAddress = o.KhachHang != null ? o.KhachHang.DiaChi : "",
                        customerEmail = o.KhachHang != null ? o.KhachHang.Email : "",
                        orderDate = o.NgayDat.ToString("dd/MM/yyyy HH:mm"),
                        deliveryDate = o.NgayGiao.ToString("dd/MM/yyyy"),
                        status = o.Tracking ?? 0,
                        statusText = GetTrackingStatusText(o.Tracking ?? 0),
                        canCancel = (o.Tracking == null || o.Tracking == 0),
                        paymentStatus = o.ThanhToan ?? 0,
                        paymentMethod = isPaid ? "credit_card" : "cod",
                        paymentMethodText = isPaid ? "Thẻ tín dụng (Đã TT)" : "COD (Chưa TT)",
                        isPaid = isPaid,
                        note = o.GhiChu ?? "",
                        total = total,
                        totalFormatted = string.Format("{0:N0} VND", total),
                        itemCount = details.Sum(d => d.SoLuong),
                        items = details.Select(d => new
                        {
                            bookId = d.MaSach,
                            title = d.Sach != null ? d.Sach.TenSach : "",
                            image = d.Sach != null ? d.Sach.AnhBia : "topSach.png",
                            quantity = d.SoLuong,
                            price = d.DonGia,
                            priceFormatted = string.Format("{0:N0} VND", d.DonGia),
                            subtotal = d.DonGia * d.SoLuong,
                            subtotalFormatted = string.Format("{0:N0} VND", d.DonGia * d.SoLuong)
                        }).ToList()
                    };
                }).ToList();

                return Json(new { status = true, data = list }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult AdminUpdateOrderStatus(int id, int status)
        {
            if (!IsAdminAuthenticated())
            {
                Response.StatusCode = 401;
                return Json(new { status = false, message = "Vui lòng đăng nhập tài khoản admin." });
            }

            try
            {
                if (status < 0 || status > 4)
                    return Json(new { status = false, message = "Trạng thái đơn hàng không hợp lệ." });
                var order = db.DonDatHangs.Find(id);
                if (order == null)
                {
                    return Json(new { status = false, message = "Không tìm thấy đơn hàng." });
                }

                order.Tracking = status;
                if (status == 3) // Đã giao
                {
                    order.TinhTrang = true;
                    order.ThanhToan = 1;
                }
                db.SaveChanges();

                return Json(new { status = true, message = "Cập nhật trạng thái đơn hàng thành công." });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        private static string GetTrackingStatusText(int tracking)
        {
            switch (tracking)
            {
                case 0: return "Chờ xử lý";
                case 1: return "Đã đóng gói";
                case 2: return "Đang giao hàng";
                case 3: return "Đã giao thành công";
                case 4: return "Đã hủy";
                default: return "Đang xử lý";
            }
        }

        private bool IsAdminAuthenticated()
        {
            return Session["AdminUser"] != null;
        }
    }
}
