using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using WebBanSach.Models.Data;

namespace WebBanSach.Models
{
    public class CatalogEditModel
    {
        public int Id { get; set; }
        [Required, RegularExpression("^(category|author|publisher)$")]
        public string Kind { get; set; }
        [Required(ErrorMessage = "Vui lòng nhập tên."), StringLength(50)]
        public string Name { get; set; }
        [StringLength(250)] public string Address { get; set; }
        [StringLength(50), Phone(ErrorMessage = "Số điện thoại không hợp lệ.")]
        public string Phone { get; set; }
        [DataType(DataType.Date)] public DateTime? BirthDate { get; set; }
        [DataType(DataType.Date)] public DateTime? DeathDate { get; set; }
        [StringLength(500)] public string Biography { get; set; }
    }
    public class CatalogRow
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public int ProductCount { get; set; }
    }
    public class AdminEditModel
    {
        public int Id { get; set; }
        [Required, StringLength(50), RegularExpression(@"^[A-Za-z0-9_.-]{3,50}$", ErrorMessage = "Tài khoản từ 3–50 ký tự, không dấu, không khoảng trắng.")]
        public string Username { get; set; }
        [Required, StringLength(50)] public string FullName { get; set; }
        [StringLength(128, MinimumLength = 8, ErrorMessage = "Mật khẩu từ 8–128 ký tự.")]
        [DataType(DataType.Password)] public string Password { get; set; }
        public bool Active { get; set; }
    }
    public class ProfileEditModel
    {
        [Required, StringLength(50)] public string Name { get; set; }
        [Required, StringLength(50), Phone] public string Phone { get; set; }
        [Required, StringLength(250)] public string Address { get; set; }
        [DataType(DataType.Date)] public DateTime? BirthDate { get; set; }
    }
    public class ProductDetailsModel
    {
        public Sach Book { get; set; }
        public bool IsAdmin { get; set; }
        public double Rating { get; set; }
        public int ReviewCount { get; set; }
    }
    public class InvoiceModel
    {
        public DonDatHang Order { get; set; }
        public List<ChiTietDDH> Lines { get; set; }
        public decimal Subtotal { get; set; }
        public decimal Total { get { return Subtotal + (Order.ShippingFee ?? 0); } }
    }
}
