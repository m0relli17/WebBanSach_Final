# PowerShell script to seed/reseed test data into SQL Server (Docker container or local)
param (
    [string]$Server = ".\SQLEXPRESS"
)

# Kiểm tra nếu Docker container webbansach-db đang chạy
$dockerRunning = $false
try {
    $containerStatus = docker inspect -f '{{.State.Running}}' webbansach-db 2>$null
    if ($containerStatus -eq "true") { $dockerRunning = $true }
} catch {}

if ($dockerRunning) {
    Write-Host "=== Nạp dữ liệu kiểm thử vào SQL Server Container (webbansach-db) ===" -ForegroundColor Cyan
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    Get-Content "02_DuLieuKiemThu.sql" -Encoding utf8 | docker exec -i webbansach-db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "BookStore@123456" -C -f 65001
    if ($LASTEXITCODE -eq 0) {
        Write-Host "=== Nạp dữ liệu kiểm thử vào Docker thành công! ===" -ForegroundColor Green
    } else {
        Write-Host "=== Lỗi khi nạp dữ liệu kiểm thử vào Docker! ===" -ForegroundColor Red
    }
} else {
    Write-Host "=== Đang nạp dữ liệu kiểm thử vào SQL Server cục bộ ($Server - BSDB2) ===" -ForegroundColor Cyan
    if (Get-Command sqlcmd -ErrorAction SilentlyContinue) {
        sqlcmd -S $Server -E -i 02_DuLieuKiemThu.sql
        if ($LASTEXITCODE -eq 0) {
            Write-Host "=== Nạp dữ liệu kiểm thử thành công! ===" -ForegroundColor Green
        } else {
            Write-Host "=== Lỗi khi nạp dữ liệu kiểm thử! Vui lòng kiểm tra lại kết nối SQL Server. ===" -ForegroundColor Red
        }
    } else {
        Write-Host "[Gợi ý] Không tìm thấy lệnh sqlcmd. Bạn hãy mở file 02_DuLieuKiemThu.sql trong SSMS và bấm F5." -ForegroundColor Yellow
    }
}
