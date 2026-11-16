-- Run in SQLCMD mode in SSMS, or from repository root:
-- sqlcmd -S .\SQLEXPRESS -E -b -f 65001 -i database/setup.sql
-- Fresh local installation only; BSDB2 must not already exist.
:On Error exit
:r database/00_TaoDatabaseMoi.sql
:r database/01_NangCapDatabase.sql
:r database/05_LichSuKhoVaDonHang.sql
:r database/06_BaremMvc.sql
:r database/02_DuLieuMau.sql
