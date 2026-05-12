-- =============================================================
-- BÀI TẬP: TỐI ƯU HIỆU NĂNG TIẾP NHẬN BỆNH NHÂN
-- Họ tên: Nguyễn Võ Gia Hân
-- =============================================================

-- 1. Tạo Database và Bảng
CREATE DATABASE IF NOT EXISTS HospitalPerformanceDB;
USE HospitalPerformanceDB;

CREATE TABLE Patients (
    Patient_ID INT PRIMARY KEY AUTO_INCREMENT,
    Full_Name VARCHAR(150),
    Phone VARCHAR(20),
    Age INT,
    Address VARCHAR(255)
);

-- 2. Procedure giả lập chèn 500.000 dòng dữ liệu
DELIMITER //
CREATE PROCEDURE SeedPatients()
BEGIN
    DECLARE i INT DEFAULT 1;
    SET autocommit = 0;
    WHILE i <= 500000 DO
        INSERT INTO Patients (Full_Name, Phone, Age, Address)
        VALUES (CONCAT('Patient ', i), CONCAT('090', i), FLOOR(RAND()*100), 'Ho Chi Minh City');
        SET i = i + 1;
        IF (i % 10000 = 0) THEN 
            COMMIT;
        END IF;
    END WHILE;
    COMMIT;
    SET autocommit = 1;
END //
DELIMITER ;

-- Gọi Procedure để nạp dữ liệu
CALL SeedPatients();

-- 3. Đo lường trước khi đánh Index (Sử dụng EXPLAIN)
-- Mục tiêu: Quan sát xem MySQL có phải quét toàn bộ bảng (Full Table Scan) không
EXPLAIN SELECT * FROM Patients WHERE Phone = '09012345';

-- 4. Thực hiện đánh Index cho cột Phone để tối ưu tìm kiếm
CREATE INDEX idx_phone ON Patients(Phone);

-- 5. Đo lường sau khi đánh Index
-- Mục tiêu: Xác nhận Index giúp giảm số dòng cần quét (rows) và tăng tốc độ
EXPLAIN SELECT * FROM Patients WHERE Phone = '09012345';

-- 6. Kiểm tra tốc độ ghi (Insert) khi đã có Index
INSERT INTO Patients (Full_Name, Phone, Age, Address) 
VALUES ('New Patient', '09999999', 30, 'Hanoi');