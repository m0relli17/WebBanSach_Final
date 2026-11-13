#!/bin/bash
# Shell script to seed/reseed test data into SQL Server container
echo "=== Đang nạp dữ liệu kiểm thử vào SQL Server (BSDB2) ==="

docker exec -i webbansach-db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "BookStore@123456" -C -i /dev/stdin < 02_DuLieuKiemThu.sql

if [ $? -eq 0 ]; then
    echo "=== Nạp dữ liệu kiểm thử thành công! ==="
else
    echo "=== Lỗi khi nạp dữ liệu kiểm thử! ==="
fi
