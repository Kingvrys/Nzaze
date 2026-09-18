-- Create the database
CREATE DATABASE IF NOT EXISTS nzaze_db;
USE nzaze_db;

-- Create guests table
CREATE TABLE IF NOT EXISTS guests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    check_in_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Optional: Sample admin/staff table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL
);

-- Default admin user (password: Welcome123)
INSERT INTO users (username, password, role) 
VALUES ('admin', 'Welcome123', 'admin')
ON DUPLICATE KEY UPDATE username=username;
