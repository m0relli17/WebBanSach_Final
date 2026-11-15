using System;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using WebBanSach.Models;
using WebBanSach.Models.Data;

namespace WebBanSach.Controllers
{
    public class PortalController : Controller
    {
        private readonly BSDBContext db = new BSDBContext();
        [HttpGet]
        public ActionResult Page(string page)
        {
            var pages = new[] { "index", "admin", "cart", "checkout", "tracking", "book-details", "login", "register", "verify-email" };
            if (!pages.Contains(page)) return HttpNotFound();
            ViewBag.IsCatalog = page == "index";
            ViewBag.AdminDashboard = page == "admin";
            return View("~/Views/Portal/" + page + ".cshtml");
        }
        [HttpGet]
        public ActionResult ProductDetails(int id, bool admin = false)
        {
            if (admin && !HasAdmin()) return new HttpStatusCodeResult(401);
            var book = db.Saches.AsNoTracking().Include(b => b.TacGia).Include(b => b.TheLoai).Include(b => b.NhaXuatBan).FirstOrDefault(b => b.MaSach == id);
            if (book == null) return HttpNotFound();
            var reviews = db.DanhGiaSaches.Where(r => r.MaSach == id);
            return PartialView("~/Views/Shared/_ProductDetails.cshtml", new ProductDetailsModel {
                Book = book, IsAdmin = admin, ReviewCount = reviews.Count(), Rating = reviews.Select(r => (double?)r.SoSao).Average() ?? 0
            });
        }
        [HttpGet]
        public ActionResult Product(int id)
        {
            if (!HasAdmin()) return Redirect("~/admin.html");
            var book = db.Saches.AsNoTracking().Include(b => b.TacGia).Include(b => b.TheLoai).Include(b => b.NhaXuatBan).FirstOrDefault(b => b.MaSach == id);
            if (book == null) return HttpNotFound();
            return View(new ProductDetailsModel { Book = book, IsAdmin = true });
        }
        [HttpGet]
        public ActionResult Invoice(int id)
        {
            var order = db.DonDatHangs.AsNoTracking().Include(o => o.KhachHang).FirstOrDefault(o => o.MaDDH == id);
            if (order == null) return HttpNotFound();
            // An admin session may inspect any invoice; a customer can inspect only their own.
            if (!HasAdmin() && (Session["UserId"] == null || order.MaKH != (int)Session["UserId"]))
                return new HttpStatusCodeResult(403);
            var lines = db.ChiTietDDHs.AsNoTracking().Include(l => l.Sach).Where(l => l.MaDDH == id).ToList();
            return PartialView("~/Views/Shared/_Invoice.cshtml", new InvoiceModel { Order = order, Lines = lines, Subtotal = lines.Sum(l => (l.DonGia ?? 0) * (l.SoLuong ?? 0)) });
        }
        [HttpGet]
        public new ActionResult Profile()
        {
            var customer = CurrentCustomer();
            if (customer == null) return Redirect("~/login.html?redirect=Portal%2FProfile");
            ViewBag.Email = customer.Email; ViewBag.Username = customer.TaiKhoan;
            return View(new ProfileEditModel { Name = customer.TenKH, Phone = customer.DienThoai, Address = customer.DiaChi, BirthDate = customer.NgaySinh });
        }
        [HttpGet]
        public ActionResult Receipt(int id)
        {
            var result = Invoice(id);
            var partial = result as PartialViewResult;
            if (partial == null) return result;
            ViewBag.IsAdmin = HasAdmin();
            return View(partial.Model);
        }
        [HttpPost, ValidateAntiForgeryToken]
        public new ActionResult Profile(ProfileEditModel model)
        {
            var customer = CurrentCustomer();
            if (customer == null) return new HttpStatusCodeResult(401);
            model.Name = (model.Name ?? "").Trim(); model.Phone = (model.Phone ?? "").Trim(); model.Address = (model.Address ?? "").Trim();
            if (string.IsNullOrWhiteSpace(model.Name) || string.IsNullOrWhiteSpace(model.Address)) ModelState.AddModelError("", "Tên và địa chỉ không được chỉ chứa khoảng trắng.");
            if (model.BirthDate < new DateTime(1900, 1, 1) || model.BirthDate > DateTime.Today) ModelState.AddModelError("BirthDate", "Ngày sinh phải từ năm 1900 đến hiện tại.");
            if (ModelState.IsValid) {
                customer.TenKH = model.Name; customer.DienThoai = model.Phone; customer.DiaChi = model.Address; customer.NgaySinh = model.BirthDate;
                db.SaveChanges(); TempData["Notice"] = "Đã cập nhật hồ sơ."; return RedirectToAction("Profile");
            }
            ViewBag.Email = customer.Email; ViewBag.Username = customer.TaiKhoan;
            return View(model);
        }
        private KhachHang CurrentCustomer()
        {
            var username = Session["User"] as string;
            return username == null ? null : db.KhachHangs.FirstOrDefault(c => c.TaiKhoan == username && c.TrangThai);
        }
        private bool HasAdmin()
        {
            var username = Session["AdminUser"] as string;
            return username != null && db.Admins.Any(a => a.TaiKhoan == username && a.TrangThai == true);
        }
        protected override void Dispose(bool disposing) { if (disposing) db.Dispose(); base.Dispose(disposing); }
    }
}
