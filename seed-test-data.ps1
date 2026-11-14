# PowerShell script to seed test data into local SQL Server (BSDB2)
param (
    [string]$Server = ".\SQLEXPRESS"
)

Write-Host "=== Đang nạp dữ liệu kiểm thử vào SQL Server ($Server - BSDB2) ===" -ForegroundColor Cyan

sqlcmd -S $Server -E -i 02_DuLieuKiemThu.sql

if ($LASTEXITCODE -eq 0) {
    Write-Host "=== Nạp dữ liệu kiểm thử thành công! ===" -ForegroundColor Green
} else {
    Write-Host "=== Lỗi khi nạp dữ liệu kiểm thử! Vui lòng kiểm tra lại kết nối SQL Server. ===" -ForegroundColor Red
}
