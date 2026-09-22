-- Create the database
CREATE DATABASE IF NOT EXISTS nzaze_db;
USE nzaze_db;

CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS guests (
    guest_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NULL,
    phone_number VARCHAR(15) NOT NULL,
    room_number VARCHAR(20),
    guest_code VARCHAR(10) NOT NULL UNIQUE,
    check_in_date DATETIME NOT NULL,
    check_out_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL,
    rating INT NOT NULL DEFAULT 0,
    host_comments TEXT NOT NULL,
    CONSTRAINT fk_guests_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS guest_stays (
    stay_id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL,
    check_in_date DATETIME NOT NULL,
    check_out_date DATETIME NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_guest_stays_guest FOREIGN KEY (guest_id) REFERENCES guests(guest_id)
);

-- Default admin user (password: Welcome123).
INSERT INTO users (username, password_hash, role)
VALUES ('admin', 'Welcome123', 'ADMIN')
ON DUPLICATE KEY UPDATE username = username;

-- Extend an existing installation without destroying guest records.
ALTER TABLE guests
    ADD COLUMN IF NOT EXISTS email VARCHAR(100) NULL AFTER last_name,
    ADD COLUMN IF NOT EXISTS room_number VARCHAR(20) NULL AFTER phone_number,
    ADD COLUMN IF NOT EXISTS host_comments TEXT NOT NULL DEFAULT '' AFTER rating;

-- Preserve existing stays when introducing history tracking.
INSERT INTO guest_stays (guest_id, check_in_date, check_out_date)
SELECT g.guest_id, g.check_in_date, g.check_out_date
FROM guests g
WHERE NOT EXISTS (SELECT 1 FROM guest_stays s WHERE s.guest_id = g.guest_id);
