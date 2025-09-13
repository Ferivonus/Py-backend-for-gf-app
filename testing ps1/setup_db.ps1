# setup_db.ps1
# Secure and working script to ensure database and 'users' table exist on Windows

# Database configuration
$dbHost = "localhost"
$dbUser = "root"
$dbPassword = "password"
$dbName = "py-test"
$OutputEncoding = [System.Text.Encoding]::UTF8

# MySQL CLI full path (update this according to your MySQL installation)
$mysqlExe = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

# Function to run a SQL command using approved verb and secure password
function Invoke-SqlCommand {
    param (
        [string]$sql
    )
    try {
        # Use environment variable to securely pass password
        $env:MYSQL_PWD = $dbPassword
        & "$mysqlExe" -h $dbHost -u $dbUser -e $sql
        Remove-Item Env:\MYSQL_PWD  # Clean up environment variable
        return $true
    } catch {
        Remove-Item Env:\MYSQL_PWD  # Ensure cleanup even on error
        Write-Host "SQL command failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Step 1: Create the database if it doesn't exist
Write-Host "Checking/creating database '$dbName'..." -ForegroundColor Yellow
$createDbSql = "CREATE DATABASE IF NOT EXISTS `$dbName CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
if (Invoke-SqlCommand $createDbSql) {
    Write-Host "Database '$dbName' is ready." -ForegroundColor Green
} else {
    Write-Host "Failed to create/check database." -ForegroundColor Red
    exit 1
}

# Step 2: Create the 'users' table if it doesn't exist
Write-Host "Checking/creating 'users' table..." -ForegroundColor Yellow
$sqlCreateTable = @"
USE `$dbName;
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(255) NOT NULL UNIQUE,
    `hashed_password` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
"@

if (Invoke-SqlCommand $sqlCreateTable) {
    Write-Host "'users' table is ready in database '$dbName'." -ForegroundColor Green
} else {
    Write-Host "Failed to create/check 'users' table." -ForegroundColor Red
    exit 1
}

Write-Host "Database setup complete." -ForegroundColor Cyan
