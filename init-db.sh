#!/bin/bash
set -e

echo "=== Initializing Database for WebBanSach ==="

echo "Connecting to SQL Server..."
until /opt/mssql-tools18/bin/sqlcmd -S db,1433 -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" > /dev/null 2>&1; do
    echo "Waiting for SQL Server..."
    sleep 2
done

echo "Checking if BSDB2 database exists..."
DB_CHECK=$(/opt/mssql-tools18/bin/sqlcmd -S db,1433 -U sa -P "$MSSQL_SA_PASSWORD" -C -h -1 -W -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name = 'BSDB2'")

if [ "$DB_CHECK" -eq "0" ]; then
    echo "Creating BSDB2 database and seeding initial data..."
    /opt/mssql-tools18/bin/sqlcmd -S db,1433 -U sa -P "$MSSQL_SA_PASSWORD" -C -i /scripts/00_TaoDatabaseMoi.sql
    echo "Applying database schema upgrades..."
    /opt/mssql-tools18/bin/sqlcmd -S db,1433 -U sa -P "$MSSQL_SA_PASSWORD" -C -i /scripts/01_NangCapDatabase.sql
    echo "Database BSDB2 created and upgraded successfully!"
else
    echo "BSDB2 database already exists. Running upgrade script to ensure latest schema..."
    /opt/mssql-tools18/bin/sqlcmd -S db,1433 -U sa -P "$MSSQL_SA_PASSWORD" -C -i /scripts/01_NangCapDatabase.sql || true
    echo "Database BSDB2 schema is up to date."
fi

if [ -f "/scripts/02_DuLieuKiemThu.sql" ]; then
    echo "Seeding/updating test data from 02_DuLieuKiemThu.sql..."
    /opt/mssql-tools18/bin/sqlcmd -S db,1433 -U sa -P "$MSSQL_SA_PASSWORD" -C -i /scripts/02_DuLieuKiemThu.sql || true
    echo "Test data seeded successfully!"
fi

echo "=== Database initialization completed ==="
