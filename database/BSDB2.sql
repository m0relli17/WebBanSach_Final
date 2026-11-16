-- WebBanSach: complete local database installation with demo data.
-- Open in SSMS and Execute; SQLCMD mode is not required.
-- Or run from repository root:
-- sqlcmd -S .\SQLEXPRESS -E -b -f 65001 -i database/BSDB2.sql
-- Requires permission to create a database on this SQL Server.
-- Fresh installation only. Do not run against an existing BSDB2 database.
USE [master];
GO
IF DB_ID(N'BSDB2') IS NOT NULL
BEGIN
    RAISERROR(N'BSDB2 already exists. Installation skipped. Use a new database/server or restore your backup separately.', 16, 1);
    SET NOEXEC ON;
END;
GO

-- ======================================================================
-- BASE SCHEMA AND CATALOG
-- ======================================================================
-- Fresh database only: complete current schema, including discounts, reviews, order notes, and BIGINT quantities.
-- Fresh database only: complete schema, demo catalog, discounts, reviews, order notes, and BIGINT quantities.
USE [master]
GO
/****** Object:  Database [BSDB2]    Script Date: 11/1/2016 11:25:55 PM ******/
CREATE DATABASE [BSDB2]
GO
ALTER DATABASE [BSDB2] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BSDB2].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BSDB2] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BSDB2] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BSDB2] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BSDB2] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BSDB2] SET ARITHABORT OFF 
GO
ALTER DATABASE [BSDB2] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [BSDB2] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BSDB2] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BSDB2] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BSDB2] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BSDB2] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BSDB2] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BSDB2] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BSDB2] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BSDB2] SET  ENABLE_BROKER 
GO
ALTER DATABASE [BSDB2] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BSDB2] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BSDB2] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BSDB2] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BSDB2] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BSDB2] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BSDB2] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BSDB2] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [BSDB2] SET  MULTI_USER 
GO
ALTER DATABASE [BSDB2] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BSDB2] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BSDB2] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BSDB2] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [BSDB2] SET DELAYED_DURABILITY = DISABLED 
GO
USE [BSDB2]
GO
/****** Object:  Table [dbo].[Admin]    Script Date: 11/1/2016 11:25:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Admin](
	[IDAdmin] [int] IDENTITY(1,1) NOT NULL,
	[TaiKhoan] [varchar](50) NULL,
	[MatKhau] [varchar](50) NULL,
	[HoTen] [nvarchar](50) NULL,
	[TrangThai] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDAdmin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ChiTietDDH]    Script Date: 11/1/2016 11:25:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChiTietDDH](
	[MaSach] [int] NOT NULL,
	[MaDDH] [int] NOT NULL,
	[SoLuong] [bigint] NULL,
	[DonGia] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaSach] ASC,
	[MaDDH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DonDatHang]    Script Date: 11/1/2016 11:25:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DonDatHang](
	[MaDDH] [int] IDENTITY(1,1) NOT NULL,
	[NgayDat] [smalldatetime] NULL DEFAULT (getdate()),
	[NgayGiao] [smalldatetime] NULL,
	[TinhTrang] [bit] NULL,
	[MaKH] [int] NOT NULL,
	[ThanhToan] [int] NULL,
	[Tracking] [int] NULL,
	[GhiChu] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaDDH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[KhachHang]    Script Date: 11/1/2016 11:25:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KhachHang](
	[MaKH] [int] IDENTITY(1,1) NOT NULL,
	[TenKH] [nvarchar](50) NULL,
	[Email] [varchar](50) NULL,
	[DiaChi] [nvarchar](250) NULL,
	[DienThoai] [varchar](50) NULL,
	[NgaySinh] [smalldatetime] NULL,
	[TaiKhoan] [varchar](50) NOT NULL,
	[MatKhau] [varchar](50) NOT NULL,
	[NgayTao] [datetime] NULL,
	[TrangThai] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaKH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LienHe]    Script Date: 11/1/2016 11:25:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LienHe](
	[MaLH] [int] IDENTITY(1,1) NOT NULL,
	[Ho] [nvarchar](50) NULL,
	[Ten] [nvarchar](50) NULL,
	[Email] [varchar](100) NULL,
	[DienThoai] [varchar](50) NULL,
	[NoiDung] [nvarchar](500) NULL,
	[NgayCapNhat] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaLH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NhaXuatBan]    Script Date: 11/1/2016 11:25:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NhaXuatBan](
	[MaNXB] [int] IDENTITY(1,1) NOT NULL,
	[TenNXB] [nvarchar](50) NULL,
	[DiaChi] [nvarchar](250) NULL,
	[DienThoai] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaNXB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Sach]    Script Date: 11/1/2016 11:25:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Sach](
	[MaSach] [int] IDENTITY(1,1) NOT NULL,
	[MaLoai] [int] NOT NULL,
	[MaNXB] [int] NOT NULL,
	[MaTG] [int] NOT NULL,
	[TenSach] [nvarchar](250) NULL,
	[GiaBan] [money] NULL,
	[GiamGia] [int] NOT NULL CONSTRAINT [DF_Sach_GiamGia] DEFAULT (0),
	[Mota] [nvarchar](500) NULL,
	[NguoiDich] [nvarchar](50) NULL,
	[AnhBia] [varchar](50) NULL,
	[NgayCapNhat] [smalldatetime] NULL DEFAULT (getdate()),
	[SoLuongTon] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaSach] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[DanhGiaSach](
	[MaDanhGia] [int] IDENTITY(1,1) NOT NULL,
	[MaSach] [int] NOT NULL,
	[MaKH] [int] NOT NULL,
	[SoSao] [int] NOT NULL,
	[NoiDung] [nvarchar](1000) NULL,
	[NgayDanhGia] [datetime] NOT NULL CONSTRAINT [DF_DanhGiaSach_NgayDanhGia] DEFAULT (getdate()),
	CONSTRAINT [CK_DanhGiaSach_SoSao] CHECK ([SoSao] >= 1 AND [SoSao] <= 5),
	CONSTRAINT [FK_DanhGiaSach_Sach] FOREIGN KEY ([MaSach]) REFERENCES [dbo].[Sach]([MaSach]),
	CONSTRAINT [FK_DanhGiaSach_KhachHang] FOREIGN KEY ([MaKH]) REFERENCES [dbo].[KhachHang]([MaKH]),
	CONSTRAINT [PK_DanhGiaSach] PRIMARY KEY CLUSTERED ([MaDanhGia] ASC)
) ON [PRIMARY]
GO
CREATE UNIQUE INDEX [UX_DanhGiaSach_MaSach_MaKH] ON [dbo].[DanhGiaSach]([MaSach], [MaKH])
GO
/****** Object:  Table [dbo].[TacGia]    Script Date: 11/1/2016 11:25:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TacGia](
	[MaTG] [int] IDENTITY(1,1) NOT NULL,
	[TenTG] [nvarchar](50) NULL,
	[QueQuan] [nvarchar](250) NULL,
	[NgaySinh] [smalldatetime] NULL,
	[NgayMat] [smalldatetime] NULL,
	[TieuSu] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaTG] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TheLoai]    Script Date: 11/1/2016 11:25:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TheLoai](
	[MaLoai] [int] IDENTITY(1,1) NOT NULL,
	[TenLoai] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaLoai] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Admin] ON 

INSERT [dbo].[Admin] ([IDAdmin], [TaiKhoan], [MatKhau], [HoTen], [TrangThai]) VALUES (1, N'admin', N'123456', N'Phong', 1)
INSERT [dbo].[Admin] ([IDAdmin], [TaiKhoan], [MatKhau], [HoTen], [TrangThai]) VALUES (3, N'vhp', N'123456', N'VHP', NULL)
SET IDENTITY_INSERT [dbo].[Admin] OFF
INSERT [dbo].[ChiTietDDH] ([MaSach], [MaDDH], [SoLuong], [DonGia]) VALUES (14, 2, 2, 475000.0000)
INSERT [dbo].[ChiTietDDH] ([MaSach], [MaDDH], [SoLuong], [DonGia]) VALUES (16, 1, 1, 60000.0000)
INSERT [dbo].[ChiTietDDH] ([MaSach], [MaDDH], [SoLuong], [DonGia]) VALUES (16, 2, 3, 60000.0000)
SET IDENTITY_INSERT [dbo].[DonDatHang] ON 

INSERT [dbo].[DonDatHang] ([MaDDH], [NgayDat], [NgayGiao], [TinhTrang], [MaKH]) VALUES (1, CAST(N'2016-07-05 13:22:00' AS SmallDateTime), CAST(N'2016-07-08 13:22:00' AS SmallDateTime), 1, 1)
INSERT [dbo].[DonDatHang] ([MaDDH], [NgayDat], [NgayGiao], [TinhTrang], [MaKH]) VALUES (2, CAST(N'2016-07-05 13:24:00' AS SmallDateTime), CAST(N'2016-07-08 13:24:00' AS SmallDateTime), 1, 1)
SET IDENTITY_INSERT [dbo].[DonDatHang] OFF
SET IDENTITY_INSERT [dbo].[KhachHang] ON 

INSERT [dbo].[KhachHang] ([MaKH], [TenKH], [Email], [DiaChi], [DienThoai], [NgaySinh], [TaiKhoan], [MatKhau], [NgayTao], [TrangThai]) VALUES (1, N'test1', N'test1@gmail.com', N'hcm', N'123456', CAST(N'1995-11-05 00:00:00' AS SmallDateTime), N'test', N'123', CAST(N'2016-07-01 11:14:10.630' AS DateTime), 1)
INSERT [dbo].[KhachHang] ([MaKH], [TenKH], [Email], [DiaChi], [DienThoai], [NgaySinh], [TaiKhoan], [MatKhau], [NgayTao], [TrangThai]) VALUES (7, N'admin', N'emty@gmail.com', N'TP.HCM', N'123456789', CAST(N'2016-10-04 00:00:00' AS SmallDateTime), N'admin', N'123456', CAST(N'2016-10-28 22:41:31.740' AS DateTime), 1)
INSERT [dbo].[KhachHang] ([MaKH], [TenKH], [Email], [DiaChi], [DienThoai], [NgaySinh], [TaiKhoan], [MatKhau], [NgayTao], [TrangThai]) VALUES (10, N'P', N'test2@gmail.com', N'TP.HCM', N'123456', CAST(N'2016-06-05 00:00:00' AS SmallDateTime), N'test2', N'123456', CAST(N'2016-10-28 22:49:00.000' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[KhachHang] OFF
SET IDENTITY_INSERT [dbo].[LienHe] ON 

INSERT [dbo].[LienHe] ([MaLH], [Ho], [Ten], [Email], [DienThoai], [NoiDung], [NgayCapNhat]) VALUES (2, N'a', N'a', N'a@gmail.com', N'123456', N'đây là nội dung thứ 2', CAST(N'2016-07-01 00:00:00' AS SmallDateTime))
INSERT [dbo].[LienHe] ([MaLH], [Ho], [Ten], [Email], [DienThoai], [NoiDung], [NgayCapNhat]) VALUES (3, N'b', N'b', N'test@gmail.com', N'1', N'nội dung 3', CAST(N'2016-07-01 00:00:00' AS SmallDateTime))
SET IDENTITY_INSERT [dbo].[LienHe] OFF
SET IDENTITY_INSERT [dbo].[NhaXuatBan] ON 

INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (1, N'Nxb Lao động', N'175 Giảng Võ, Q. Đống Đa, Hà Nội', N'04.38515380')
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (2, N'Nxb Thế giới', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (3, N'Nxb Tri thức', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (4, N'NXB Phụ Nữ', N'16 Alexandre de Rhodes, Bến Nghé, Quận 1, Hồ Chí Minh', N'08 3829 4459')
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (5, N'Nxb Phương Đông', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (6, N'Nxb Trẻ', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (7, N'ArtBook', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (8, N'CDIMex', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (9, N'Nxb Hội Nhà Văn', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (10, N'Nxb Khoa học xã hội', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (11, N' NXB Chính Trị Quốc Gia', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (12, N'NXB Kim Đồng', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (13, N'NXB Giáo Dục Việt Nam', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (14, N'NXB Văn Học', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (15, N'NXB Tổng Hợp TP.HCM', NULL, NULL)
INSERT [dbo].[NhaXuatBan] ([MaNXB], [TenNXB], [DiaChi], [DienThoai]) VALUES (16, N'NXB Dân Trí', NULL, NULL)
SET IDENTITY_INSERT [dbo].[NhaXuatBan] OFF
SET IDENTITY_INSERT [dbo].[Sach] ON 

INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (1, 1, 7, 12, N'Me Before You', 250000.0000, N'THE NEW YORK TIMES NUMBER 1 BESTSELLING NOVEL THAT IS LOVED AROUND THE WORLD, SOON TO BE RELEASED AS A FILM STARRING EMILIA CLARKE AND SAM CLAFLINLou Clark knows lots of things. She knows how many footsteps there are between the bus stop and home. ', NULL, N'me-before-you.jpg', CAST(N'2016-06-21 00:00:00' AS SmallDateTime), 10)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (8, 3, 2, 2, N'Combo Cứ Bình Tĩnh + Sẽ Có Cách, Đừng Lo', 113000.0000, N' Cứ Bình Tĩnh!Tuần hoàn cuộc sống, có yêu thì sẽ có ghét. Sẽ là bất khả thi nếu khuyên con người đừng ghét bỏ ai. Tôi cũng từng ghét người khác, vì tôi nghĩ rằng họ là tác nhân khiến tôi mất đi điều tôi yêu quý. Nhưng suy cho cùng, ', NULL, N'cu-binh-tinh.jpg', CAST(N'2016-06-29 00:00:00' AS SmallDateTime), 5)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (9, 7, 4, 5, N'Mỗi Buổi Sáng, Hãy Tạo Ra Một Điều Gì Đó Mới Mẻ', 90000.0000, N'Từ khi mới sinh ra, bạn đã là người vô cùng sáng tạo.Bạn nhìn thế giới này với một con mắt tò mò, ngạc nhiên đầy phấn khích.Bạn không hề biết sợ, không hề biết lùi bước, bạn luôn đặt mình vào trong những tình huống thử thách cao độ.Bạn ...', NULL, N'moi-buoi-sang-hay-tao-ra-mot-dieu-gi-do-moi-me.jpg', CAST(N'2016-06-29 00:00:00' AS SmallDateTime), 8)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (10, 3, 3, 9, N'Ngày Xưa Có Một Chuyện Tình', 118000.0000, N'Ngày xưa có một chuyện tình là một câu chuyện cảm động khi người ta yêu nhau, nỗi khát khao một hạnh phúc êm đềm ấm áp đến thế; hay đơn giản chỉ là chuyện ba người - anh, em, và người ấy…?', NULL, N'ngay-xua-co-mot-chuyen-tinh.jpg', CAST(N'2016-06-29 00:00:00' AS SmallDateTime), 12)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (11, 1, 8, 13, N'Harry Potter And The Cursed Child - Parts I & II ', 530000.0000, NULL, NULL, N'harrypotter.jpg', CAST(N'2016-07-01 00:00:00' AS SmallDateTime), 4)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (12, 2, 1, 14, N'Nhà Đào Tạo Sành Sỏi', 112000.0000, N'MỌI THỨ BẠN CẦN CHO ĐÀO TẠO & PHÁT TRIỂN“Ngày nay chỉ có một thứ không đổi đó chính là...sự thay đổi.”“Hãy đối mặt với sự thật rằng một nhà lãnh đạo muốn có các nhân viên tốt chỉ có hai sự lựa chọn: hoặc đi thuê hoặc phải đứng ..', NULL, N'nha-dao-tao-sanh-soi.jpg', CAST(N'2016-07-02 00:00:00' AS SmallDateTime), 12)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (13, 2, 1, 15, N'Dám Làm Giàu', 132000.0000, N'Có nhiều con đường khác nhau để trở nên giàu có, nhưng để đi như thế nào để đến được đích của sự giàu có thì đó mới là điều để chúng ta quan tâm. Trong thời đại sống với công nghệ, thì việc làm ra tiền là điều không hề khó, điều quan', NULL, N'dam-lam-giau.jpg', CAST(N'2016-07-03 00:00:00' AS SmallDateTime), 7)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (14, 3, 9, 16, N'Việt Nam Thi Ca Luận Và Văn Chương Xã Hội', 54000.0000, N'Với Lương Đức Thiệp, Văn học là sản phẩm và vũ khí của đấu tranh đẳng cấp. Văn chương dùng để gieo rắc những ý tưởng vào ý thức dân chúng. Xung đột đẳng cấp càng gắt gao, đâu cũng phải chịu sức chi phối âm u của quyền lợi đẳng', NULL, N'viet-nam.jpg', CAST(N'2016-07-05 00:00:00' AS SmallDateTime), 4)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (15, 10, 1, 8, N'Chuyên Đề Ôn Tập Và Luyện Thi Hóa Học 12 ', 77000.0000, N'Cuốn sách "Chuyên đề ôn tập và luyện thi hóa học 12" sẽ cung cấp tài liệu tham khảo cần thiết cho các thầy, cô giáo và các em học sinh ôn tập để nâng cao kiến thức chất lượng kỳ thi tốt nghiệp THPT và kỳ thi tuyển sinh Đại học, Cao đẳng, đảm ... Xem chi tiết', N'Nguyên Hương', N'hoa-hoc-12.jpg', CAST(N'2016-07-05 00:00:00' AS SmallDateTime), 34)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (16, 4, 9, 17, N'Đèn Không Hắt Bóng', 148000.0000, N'Tinh hoa văn học của nhân loại nào cũng cần được khám phá và tái khám phá. Mỗi tác phẩm lớn là một sự kỳ diệu và mỗi lần ta tìm đến là thực hiện những cuộc phiêu lưu hoan lạc. Đến với tiểu thuyết Đèn Không Hắt Bóng là chúng ta đang bước', NULL, N'den-khong-hat-bong.jpg', CAST(N'2016-07-07 00:00:00' AS SmallDateTime), 23)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (17, 9, 1, 4, N'Mộng Đổi Đời ', 419000.0000, N'Khát vọng đổi đời như một hạt giống được gieo mầm, truyền từ đời này sang đời khác.Đôi khi hạt giống nơi đất cằn cũng tự phát triển mập mạp, nhưng phần lớn nhanh chóng bị èo uột giữa chừng bởi những điều kiện khách quan. Vấn đề là ... Xem chi tiết', NULL, N'mong-doi-doi.jpg', CAST(N'2016-07-05 00:00:00' AS SmallDateTime), 22)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (18, 5, 6, 18, N'Combo Chào Con', 129000.0000, N'1. Chào Con! Ba Mẹ Đã Sẵn Sàng!"Chào con! Ba mẹ đã sẵn sàng!" - Cuốn sách không chỉ được viết trên nền tảng khoa học của một bác sĩ mà còn chứa chan tình yêu của một người mẹ.Chắc chắn bạn cũng sẽ cảm nhận được những điểm hay và thực', NULL, N'combo-chao-con.jpg', CAST(N'2016-07-06 00:00:00' AS SmallDateTime), 22)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (29, 13, 6, 11, N'Cô Gái Đan Mạch', 95000.0000, N'Cô gái đan mạch là một câu chuyện cảm động về người chuyển giới đầu tiên trên thế giới, một họa sĩ  người đan mạch đã dũng cảm đối diện và tìm về với bản ngã của chính mình. Đây cũng là câu chuyện về lòng vị tha, đức hy sinh trong tình yêu.Tất cả đều được thể hiện bằng một văn phong trong sáng, đẹp đẽ.', NULL, N'co-gai-dan-mach.jpg', CAST(N'2016-11-01 15:21:00' AS SmallDateTime), 6)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (30, 6, 4, 19, N'Phát Triển Khả Năng Ngôn Ngữ', 36000.0000, N'Bộ sách Phát Triển Trí Tuệ Của Trẻ Qua Trò Chơi Dán Hình (4-6 tuổi) giúp trẻ phát triển khả năng Sáng tạo, Toán học, Ngôn Ngữ, Tư duy, rèn trí thông minh, luyện tay khéo léo. Sách với 150-300 hình dán + câu chuyện + trò chơi giúp bé chơi mà học.Mời bạn ..', NULL, N'phat-trien-kha-nang-ngon-ngu.jpg', CAST(N'2016-11-01 20:51:00' AS SmallDateTime), 16)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (31, 8, 10, 20, N'Luyện Thi Toeic 750 Reading', 87000.0000, N'5 TIẾNG MỖI NGÀY, ĐẠT NGAY 750 ĐIỂM• CUNG CẤP ĐỀ THI VÀ CÂU MẪU PHONG PHÚ, ĐA DẠNG• PHÂN TÍCH CHI TIẾT, HIỆU QUẢ CÁCH LÀM PHẦN 7HIỆU QUẢ TỨC THÌ – TỰ TIN HOÀN THÀNH BÀI THI TOEIC1. Dũng cảm phá bỏ quan niệm ‘lý thuyết là cơ bản’!Dù học thuộc ', NULL, N'luyen-thi-toeic.jpg', CAST(N'2016-11-01 20:54:00' AS SmallDateTime), NULL)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (32, 9, 1, 21, N'Tam Tạng Pháp Số', 374000.0000, N'Tam Tạng Pháp Số còn gọi Đại Minh Pháp Số hay Phật Học Từ Điển… là bộ sách giúp người học Phật dễ dàng tra cứu giáo lí Phật đà, phù hợp cho nhiều tầng lớp đối tượng: từ sơ học đến người đã có trình độ cao, do Nhất Như, Đạo ...', NULL, N'tam-tang-phap.jpg', CAST(N'2016-11-01 20:56:00' AS SmallDateTime), NULL)
INSERT [dbo].[Sach] ([MaSach], [MaLoai], [MaNXB], [MaTG], [TenSach], [GiaBan], [Mota], [NguoiDich], [AnhBia], [NgayCapNhat], [SoLuongTon]) VALUES (33, 14, 11, 22, N'Lịch Bloc Siêu Đại (20x30)', 200000.0000, N'Lịch Bloc Siêu Đại (20x30) - Việt Nam Quê Hương Tôi', NULL, N'bloc-sieu-dai.jpg', CAST(N'2016-11-01 20:59:00' AS SmallDateTime), NULL)
SET IDENTITY_INSERT [dbo].[Sach] OFF
SET IDENTITY_INSERT [dbo].[TacGia] ON 

INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (1, N'Donald J. Trump ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (2, N'Xuân Quỳnh', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (3, N'Trịnh Huyền Trang', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (4, N'Nguyễn Nhật Ánh', N'Thăng Bình', CAST(N'1955-05-07 00:00:00' AS SmallDateTime), NULL, N'Nguyễn Nhật Ánh là tên và cũng là bút danh của một nhà văn Việt Nam chuyên viết cho tuổi mới lớn. Ông sinh ngày 7 tháng 5 năm 1955 tại huyện Thăng Bình, Quảng Nam.')
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (5, N'Nguyễn Kim Tuấn ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (6, N'Võ Văn Nhị', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (7, N'May McCarthy', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (8, N'Nguyễn Danh Lam', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (9, N'Ái vân', N'Hà nội', CAST(N'1954-05-20 00:00:00' AS SmallDateTime), NULL, N'Ái Vân là một ca sĩ nhạc nhẹ được nhiều người biết đến trong thập niên 1970 và 1980 tại Việt Nam qua các bài hát như Triệu bông hồng, Trăng chiều hay Bài ca xây dựng. Từ năm 1990 Ái Vân bắt đầu ở lại Đức và sau đó sang Hoa Kỳ sinh sống và biểu diễn.')
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (10, N'Mỹ Chi', N'Khánh Hòa', NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (11, N'David Ebershoff ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (12, N'Jojo Moyes ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (13, N'J. K. Rowling ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (14, N'Đỗ Huân ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (15, N'Phạm Tuấn Sơn ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (16, N' Lương Đức Thiệp ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (17, N'Watanabe Dzunichi ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (18, N'Trần Thị Huyên Thảo ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (19, N'Tiểu Hồng Hoa ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (20, N'Jo Gang-Soo ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (21, N'Thích Nhất Như ', NULL, NULL, NULL, NULL)
INSERT [dbo].[TacGia] ([MaTG], [TenTG], [QueQuan], [NgaySinh], [NgayMat], [TieuSu]) VALUES (22, N' NXB Chính Trị Quốc Gia', NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[TacGia] OFF
SET IDENTITY_INSERT [dbo].[TheLoai] ON 

INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (1, N'Sách Ngoại Văn')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (2, N'Sách Kinh Tế')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (3, N'Sách Văn Học Trong Nước')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (4, N'Sách Văn Học Nước Ngoài')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (5, N'Sách Thường Thức - Đời Sống')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (6, N'Sách Thiếu Nhi')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (7, N'Sách Phát Triển Bản Thân')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (8, N'Sách Tin Học - Ngoại Ngữ')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (9, N'Sách Chuyên Ngành')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (10, N'Sách Giáo Khoa - Giáo Trình')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (13, N'Sách Văn Học-Tiều Thuyết')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (14, N'Tạp Chí - Văn Phòng Phẩm')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (15, N'Manga - Truyện Tranh')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (16, N'Kinh Dị')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (17, N'Trinh Thám')
INSERT [dbo].[TheLoai] ([MaLoai], [TenLoai]) VALUES (18, N'Khoa Học Viễn Tưởng')
SET IDENTITY_INSERT [dbo].[TheLoai] OFF
ALTER TABLE [dbo].[ChiTietDDH]  WITH CHECK ADD FOREIGN KEY([MaDDH])
REFERENCES [dbo].[DonDatHang] ([MaDDH])
GO
ALTER TABLE [dbo].[ChiTietDDH]  WITH CHECK ADD FOREIGN KEY([MaSach])
REFERENCES [dbo].[Sach] ([MaSach])
GO
ALTER TABLE [dbo].[DonDatHang]  WITH CHECK ADD FOREIGN KEY([MaKH])
REFERENCES [dbo].[KhachHang] ([MaKH])
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD FOREIGN KEY([MaLoai])
REFERENCES [dbo].[TheLoai] ([MaLoai])
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD FOREIGN KEY([MaNXB])
REFERENCES [dbo].[NhaXuatBan] ([MaNXB])
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD FOREIGN KEY([MaTG])
REFERENCES [dbo].[TacGia] ([MaTG])
GO
USE [master]
GO
ALTER DATABASE [BSDB2] SET  READ_WRITE 
GO
GO

-- ======================================================================
-- SCHEMA UPGRADES
-- ======================================================================
-- Idempotent upgrade for existing BSDB2 databases. Includes the standalone repairs in scripts 03 and 04.
-- Idempotent upgrade for existing BSDB2 databases; includes the standalone repairs in scripts 03 and 04.
USE [BSDB2];
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Sach') AND name = 'SoLuongTon' AND TYPE_NAME(system_type_id) = 'int')
    ALTER TABLE dbo.Sach ALTER COLUMN SoLuongTon BIGINT NULL;
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ChiTietDDH') AND name = 'SoLuong' AND TYPE_NAME(system_type_id) = 'int')
    ALTER TABLE dbo.ChiTietDDH ALTER COLUMN SoLuong BIGINT NULL;

IF COL_LENGTH('dbo.KhachHang','EmailVerified') IS NULL
    ALTER TABLE dbo.KhachHang ADD EmailVerified BIT NOT NULL CONSTRAINT DF_KhachHang_EmailVerified DEFAULT(0);
ALTER TABLE dbo.KhachHang ALTER COLUMN MatKhau VARCHAR(256) NOT NULL;
IF COL_LENGTH('dbo.DonDatHang','ThanhToan') IS NULL
    ALTER TABLE dbo.DonDatHang ADD ThanhToan INT NULL;
IF COL_LENGTH('dbo.DonDatHang','Tracking') IS NULL
    ALTER TABLE dbo.DonDatHang ADD Tracking INT NULL;
IF COL_LENGTH('dbo.Sach','GiamGia') IS NULL
    ALTER TABLE dbo.Sach ADD GiamGia INT NOT NULL CONSTRAINT DF_Sach_GiamGia DEFAULT(0);
IF OBJECT_ID('dbo.DanhGiaSach','U') IS NULL
BEGIN
    CREATE TABLE dbo.DanhGiaSach(
        MaDanhGia INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DanhGiaSach PRIMARY KEY,
        MaSach INT NOT NULL,
        MaKH INT NOT NULL,
        SoSao INT NOT NULL CONSTRAINT CK_DanhGiaSach_SoSao CHECK(SoSao BETWEEN 1 AND 5),
        NoiDung NVARCHAR(1000) NULL,
        NgayDanhGia DATETIME NOT NULL CONSTRAINT DF_DanhGiaSach_NgayDanhGia DEFAULT(GETDATE()),
        CONSTRAINT FK_DanhGiaSach_Sach FOREIGN KEY(MaSach) REFERENCES dbo.Sach(MaSach),
        CONSTRAINT FK_DanhGiaSach_KhachHang FOREIGN KEY(MaKH) REFERENCES dbo.KhachHang(MaKH)
    );
    CREATE UNIQUE INDEX UX_DanhGiaSach_MaSach_MaKH ON dbo.DanhGiaSach(MaSach, MaKH);
END;
IF COL_LENGTH('dbo.DonDatHang','GhiChu') IS NULL
    ALTER TABLE dbo.DonDatHang ADD GhiChu NVARCHAR(500) NULL;
IF EXISTS(SELECT TaiKhoan FROM dbo.KhachHang GROUP BY TaiKhoan HAVING COUNT(*)>1)
    THROW 50001, 'Duplicate usernames: review before upgrading.', 1;
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_KhachHang_TaiKhoan' AND object_id=OBJECT_ID('dbo.KhachHang'))
    CREATE UNIQUE INDEX UX_KhachHang_TaiKhoan ON dbo.KhachHang(TaiKhoan);
COMMIT;
GO
-- Don cu: khong suy doan tinh trang giao hang/thanh toan. Admin kiem tra thuc te truoc khi cap nhat.
SELECT MaKH,TaiKhoan,DienThoai,TrangThai,EmailVerified FROM dbo.KhachHang;
GO

-- ======================================================================
-- STOCK AND ORDER HISTORY
-- ======================================================================
USE [BSDB2];
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID('dbo.StockHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.StockHistory (
        Id BIGINT IDENTITY PRIMARY KEY,
        BookId INT NOT NULL,
        OrderId INT NULL,
        BeforeQuantity BIGINT NOT NULL,
        AfterQuantity BIGINT NOT NULL,
        Actor NVARCHAR(150) NOT NULL,
        Reason NVARCHAR(500) NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT(SYSDATETIME())
    );
    CREATE INDEX IX_StockHistory_Book ON dbo.StockHistory(BookId, Id DESC);
END;
IF OBJECT_ID('dbo.OrderHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderHistory (
        Id BIGINT IDENTITY PRIMARY KEY,
        OrderId INT NOT NULL,
        PreviousStatus INT NULL,
        NewStatus INT NOT NULL,
        Actor NVARCHAR(150) NOT NULL,
        Reason NVARCHAR(500) NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT(SYSDATETIME())
    );
    CREATE INDEX IX_OrderHistory_Order ON dbo.OrderHistory(OrderId, Id DESC);
END;
COMMIT;
GO
GO

-- ======================================================================
-- ORDER DELIVERY DETAILS
-- ======================================================================
USE [BSDB2];
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
ALTER TABLE dbo.Admin ALTER COLUMN MatKhau VARCHAR(256) NOT NULL;
-- Authors may have been born before 1900; SQL smalldatetime cannot represent those dates.
ALTER TABLE dbo.TacGia ALTER COLUMN NgaySinh DATE NULL;
ALTER TABLE dbo.TacGia ALTER COLUMN NgayMat DATE NULL;
IF COL_LENGTH('dbo.DonDatHang','ShippingFee') IS NULL
    ALTER TABLE dbo.DonDatHang ADD ShippingFee DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.DonDatHang','ReceiverName') IS NULL
    ALTER TABLE dbo.DonDatHang ADD ReceiverName NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.DonDatHang','ReceiverPhone') IS NULL
    ALTER TABLE dbo.DonDatHang ADD ReceiverPhone NVARCHAR(50) NULL;
IF COL_LENGTH('dbo.DonDatHang','ReceiverAddress') IS NULL
    ALTER TABLE dbo.DonDatHang ADD ReceiverAddress NVARCHAR(250) NULL;
IF COL_LENGTH('dbo.DonDatHang','PaymentMethod') IS NULL
    ALTER TABLE dbo.DonDatHang ADD PaymentMethod VARCHAR(20) NULL;
COMMIT;
GO
GO

-- ======================================================================
-- DEMO DATA
-- ======================================================================
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
GO

SET NOEXEC OFF;
GO
