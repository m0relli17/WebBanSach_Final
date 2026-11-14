namespace WebBanSach.Models.Data
{
    using System;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;

    [Table("DanhGiaSach")]
    public partial class DanhGiaSach
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int MaDanhGia { get; set; }

        public int MaSach { get; set; }

        public int MaKH { get; set; }

        [Range(1, 5)]
        public int SoSao { get; set; }

        [StringLength(1000)]
        public string NoiDung { get; set; }

        public DateTime NgayDanhGia { get; set; }
    }
}