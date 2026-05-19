-- 1. KHỞI TẠO CẤU TRÚC BẢNG VÀ DỮ LIỆU MẪU ĐỀ BÀI CHO
CREATE DATABASE IF NOT EXISTS RikkeiClinicDB;
USE RikkeiClinicDB;

CREATE TABLE IF NOT EXISTS Patients (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    age INT,
    room_number VARCHAR(10)
);

-- Làm sạch dữ liệu cũ trước khi chèn mới để test
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Patients;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO Patients (patient_id, full_name, age, room_number) VALUES
(1, 'Nguyen Van An', 36, 'Room 101'),
(2, 'Tran Thi B', 41, 'Room 202'),
(3, 'Le Hoang Cuong', 26, 'Room 303'),
(4, 'Nguyen Minh Tam', 28, 'Room 101'),
(5, 'Tran Thi Binh', 33, 'Room 105');


-- 2. XEM KẾ HOẠCH THỰC THI (EXECUTION PLAN) MẶC ĐỊNH KHI CHƯA TẠO INDEX
EXPLAIN SELECT patient_id, full_name, age, room_number
FROM patients
WHERE full_name = 'Tran Thi B';

/* CHÚ THÍCH KẾT QUẢ TRƯỚC KHI TỐI ƯU (BẢN GỐC):
   - Cột 'type': ALL (Nghĩa là Full Table Scan - MySQL bắt buộc phải quét qua toàn bộ bảng từ trên xuống dưới).
   - Cột 'rows': 5 (Hệ thống phải đọc toàn bộ 5 dòng dữ liệu hiện có trong bảng để tìm kiếm).
   => Đánh giá: Khi dữ liệu tăng lên hàng trăm nghìn dòng, việc quét ALL sẽ gây nghẽn và treo hệ thống.
*/


-- 3. VIẾT LỆNH SQL TẠO INDEX ĐỂ TỐI ƯU HÓA TRUY XUẤT
ALTER TABLE patients DROP INDEX IF EXISTS idx_patient_name;

CREATE INDEX idx_patient_name ON patients (full_name);


-- 4. CHẠY LẠI LỆNH EXPLAIN ĐỂ ĐÁNH GIÁ HIỆU NĂNG SAU KHI VÁ LỖ HỔNG
EXPLAIN SELECT patient_id, full_name, age, room_number
FROM patients
WHERE full_name = 'Tran Thi B';

/* CHÚ THÍCH KẾT QUẢ SAU KHI TỐI ƯU (CẬP NHẬT MỚI):
   - Cột 'type': ref (Hệ thống đã chuyển từ quét toàn bộ bảng sang tra cứu hằng số bằng index vô cùng nhanh chóng).
   - Cột 'possible_keys' & 'key': Hiển thị 'idx_patient_name' (Minh chứng MySQL đã sử dụng Index vừa tạo).
   - Cột 'rows': 1 (Hệ thống định vị trực tiếp và chỉ duyệt đúng 1 dòng thỏa mãn, không cần quét mò mẫm).
   => Kết luận: Truy vấn đã được tối ưu hóa hiệu năng, tốc độ xử lý trả về đạt mức mili-giây, giao diện không còn bị treo.
*/