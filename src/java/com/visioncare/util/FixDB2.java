package com.visioncare.util;

import com.visioncare.dao.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class FixDB2 {
    public static void main(String[] args) {
        String[] queries = {
            "UPDATE Employee_Profile SET Full_Name = N'Quản trị viên Hệ thống', Specialty = N'Quản trị hệ thống', Biography = NULL WHERE Employee_ID = 1;",
            "UPDATE Employee_Profile SET Full_Name = N'Nguyễn Văn Giám Đốc', Specialty = N'Giám đốc', Biography = NULL WHERE Employee_ID = 2;",
            "UPDATE Employee_Profile SET Full_Name = N'BS. Trần Văn Nam', Specialty = N'Nhãn khoa tổng quát', Biography = N'Hơn 12 năm kinh nghiệm trong chẩn đoán và điều trị toàn diện các bệnh lý mắt. Từng công tác tại Bệnh viện Mắt TP.HCM và tích cực tham gia các hội thảo nhãn khoa quốc tế.' WHERE Employee_ID = 3;",
            "UPDATE Employee_Profile SET Full_Name = N'TS.BS. Nguyễn Xuân Tịnh', Specialty = N'Đo Khúc xạ & Kính', Biography = N'Tiến sĩ Nhãn khoa với hơn 15 năm chuyên sâu về tật khúc xạ, kiểm soát tiến triển cận thị học đường và ứng dụng công nghệ đo thị lực hiện đại từ Đức.' WHERE Employee_ID = 4;",
            "UPDATE Employee_Profile SET Full_Name = N'BS. Lê Hoàng Lan', Specialty = N'Phẫu thuật LASIK', Biography = N'Chuyên gia phẫu thuật khúc xạ hàng đầu, thực hiện thành công hơn 6,000 ca phẫu thuật Femto-LASIK và SMILE. Tận tâm, chu đáo và luôn đồng hành cùng bệnh nhân.' WHERE Employee_ID = 5;",
            "UPDATE Employee_Profile SET Full_Name = N'BS. Phạm Bảo Ngọc', Specialty = N'Nhãn khoa trẻ em & Nhược thị', Biography = N'Bác sĩ giàu kinh nghiệm trong điều trị nhược thị, lác mắt và các bệnh lý mắt bẩm sinh ở trẻ em. Được đào tạo chuyên sâu tại Bệnh viện Mắt Trung ương và Singapore.' WHERE Employee_ID = 6;",
            "UPDATE Employee_Profile SET Full_Name = N'BS. Trần Quang Huy', Specialty = N'Đục thủy tinh thể (Phaco)', Biography = N'Bàn tay vàng trong phẫu thuật Phaco tán nhuyễn thể thủy tinh đục, phục hồi thị lực sáng rõ cho hàng ngàn bệnh nhân cao tuổi với kỹ thuật đường mổ siêu nhỏ.' WHERE Employee_ID = 7;",
            "UPDATE Employee_Profile SET Full_Name = N'BS. Ngô Tiến Dũng', Specialty = N'Glaucoma & Võng mạc', Biography = NULL WHERE Employee_ID = 8;",
            "UPDATE Employee_Profile SET Full_Name = N'ThS.BS. Lê Hoàng Lan', Specialty = N'Medical Specialist tiểu phẫu', Biography = NULL WHERE Employee_ID = 9;",
            "UPDATE Employee_Profile SET Full_Name = N'BSCKII. Trần Quang Huy', Specialty = N'Medical Specialist tiểu phẫu', Biography = NULL WHERE Employee_ID = 10;",
            "UPDATE Employee_Profile SET Full_Name = N'ThS. Lê Văn C', Specialty = N'Medical Specialist tiểu phẫu', Biography = NULL WHERE Employee_ID = 11;",
            "UPDATE Employee_Profile SET Full_Name = N'Lễ Tân Phạm Thị Lan', Specialty = N'Thu Ngân & Tiếp Đón', Biography = NULL WHERE Employee_ID = 12;",
            
            "UPDATE Room SET Room_Name = N'Phòng Khám Nhãn khoa tổng quát' WHERE Room_ID = 1;",
            "UPDATE Room SET Room_Name = N'Phòng Khám Đo Khúc xạ & Kính' WHERE Room_ID = 2;",
            "UPDATE Room SET Room_Name = N'Phòng Khám Phẫu thuật LASIK' WHERE Room_ID = 3;",
            "UPDATE Room SET Room_Name = N'Phòng Khám Nhãn khoa trẻ em & Nhược thị' WHERE Room_ID = 4;",
            "UPDATE Room SET Room_Name = N'Phòng Khám Đục thủy tinh thể (Phaco)' WHERE Room_ID = 5;",
            "UPDATE Room SET Room_Name = N'Phòng Khám Glaucoma & Võng mạc' WHERE Room_ID = 6;",
            "UPDATE Room SET Room_Name = N'Phòng Tiểu Phẫu 1' WHERE Room_ID = 7;",
            "UPDATE Room SET Room_Name = N'Phòng Tiểu Phẫu 2' WHERE Room_ID = 8;",
            "UPDATE Room SET Room_Name = N'Phòng Tiểu Phẫu 3' WHERE Room_ID = 9;"
        };

        try (Connection conn = DBContext.getConnection()) {
            for (String sql : queries) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.executeUpdate();
                }
            }
            System.out.println("FIX2 SUCCESS!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
