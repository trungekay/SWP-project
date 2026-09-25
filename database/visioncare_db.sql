-- =============================================
-- VisionCare Database Schema
-- Hệ thống đặt lịch khám mắt trực tuyến
-- MySQL 8.0+
-- =============================================

-- Tạo database
CREATE DATABASE IF NOT EXISTS visioncare_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE visioncare_db;

-- =============================================
-- 1. Bảng Users (Người dùng)
-- =============================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    role ENUM('patient', 'doctor', 'admin') DEFAULT 'patient',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 2. Bảng Departments (Chuyên khoa)
-- =============================================
CREATE TABLE IF NOT EXISTS departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dept_key VARCHAR(30) NOT NULL UNIQUE,
    name NVARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    description NVARCHAR(500)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 3. Bảng Doctors (Bác sĩ)
-- =============================================
CREATE TABLE IF NOT EXISTS doctors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    title NVARCHAR(30),
    specialty NVARCHAR(100),
    department_key VARCHAR(30),
    description NVARCHAR(500),
    image VARCHAR(100),
    rating DOUBLE DEFAULT 5.0,
    FOREIGN KEY (department_key) REFERENCES departments(dept_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 4. Bảng Appointments (Lịch hẹn)
-- =============================================
CREATE TABLE IF NOT EXISTS appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_name NVARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(150),
    dob DATE,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    time_slot VARCHAR(10) NOT NULL,
    department VARCHAR(30),
    payment VARCHAR(20) DEFAULT 'clinic',
    reason NVARCHAR(500),
    status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
    user_id INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- 5. Bảng Time Slots (Khung giờ) — optional, dùng cho quản lý nâng cao
-- =============================================
CREATE TABLE IF NOT EXISTS time_slots (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    slot_date DATE NOT NULL,
    start_time VARCHAR(10) NOT NULL,
    is_booked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id),
    UNIQUE KEY unique_slot (doctor_id, slot_date, start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- DỮ LIỆU MẪU
-- =============================================

-- Chuyên khoa
INSERT INTO departments (dept_key, name, icon, description) VALUES
('general',    'Nhãn khoa tổng quát',    'fa-solid fa-eye',                'Khám và chẩn đoán toàn diện các bệnh lý về mắt'),
('refraction', 'Khúc xạ & Kính',         'fa-solid fa-glasses',            'Đo khúc xạ, tư vấn kính cận/viễn/loạn, kính áp tròng'),
('lasik',      'Phẫu thuật LASIK',       'fa-solid fa-wand-magic-sparkles','Phẫu thuật khúc xạ laser LASIK/SMILE'),
('pediatric',  'Nhãn khoa trẻ em',       'fa-solid fa-child',              'Sàng lọc và điều trị bệnh mắt ở trẻ em'),
('glaucoma',   'Glaucoma & Võng mạc',    'fa-solid fa-notes-medical',      'Chẩn đoán và điều trị glaucoma, bệnh võng mạc');

-- Bác sĩ
INSERT INTO doctors (name, title, specialty, department_key, description, image, rating) VALUES
('ThS.BS. Nguyễn Văn An',  'ThS.BS.',  'Phẫu thuật LASIK & Khúc xạ', 'lasik',
 'Hơn 12 năm kinh nghiệm phẫu thuật LASIK, SMILE và điều trị các tật khúc xạ phức tạp.',
 'doctors/doctors-1.jpg', 5.0),

('TS.BS. Trần Thị Mai',    'TS.BS.',   'Glaucoma & Võng mạc',         'glaucoma',
 'Chuyên gia hàng đầu về chẩn đoán và điều trị glaucoma, bệnh lý võng mạc tiểu đường.',
 'doctors/doctors-2.jpg', 4.5),

('BS.CKI. Lê Hoàng Minh',  'BS.CKI.',  'Nhãn khoa tổng quát',         'general',
 'Khám tổng quát, đo thị lực, đánh giá sức khoẻ mắt và tư vấn chăm sóc định kỳ.',
 'doctors/doctors-3.jpg', 4.0),

('BS. Phạm Thu Hà',         'BS.',      'Nhãn khoa trẻ em',            'pediatric',
 'Sàng lọc nhược thị, lác mắt, kiểm soát cận thị cho trẻ em và thanh thiếu niên.',
 'doctors/doctors-4.jpg', 5.0);

-- User mẫu (password: 123456 — plaintext, nên hash trong production)
INSERT INTO users (full_name, email, password, phone, role) VALUES
('Admin VisionCare',  'admin@visioncare.vn',   '123456', '0901000001', 'admin'),
('Nguyễn Văn Tester', 'patient@visioncare.vn', '123456', '0901000002', 'patient');

-- Appointment mẫu
INSERT INTO appointments (patient_name, phone, email, dob, doctor_id, appointment_date, time_slot, department, payment, reason, status, user_id) VALUES
('Nguyễn Văn Tester', '0901000002', 'patient@visioncare.vn', '1995-05-15',
 1, CURDATE(), '09:00', 'lasik', 'vnpay', 'Tư vấn phẫu thuật LASIK', 'confirmed', 2),
('Trần Thị B', '0909123456', 'tranb@gmail.com', '1988-12-01',
 2, CURDATE(), '14:00', 'glaucoma', 'momo', 'Kiểm tra áp lực nhãn cầu định kỳ', 'confirmed', 0);

SELECT 'VisionCare database created successfully!' AS Status;
