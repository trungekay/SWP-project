package com.visioncare.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminCatalogServlet", urlPatterns = {"/admin/catalog"})
public class AdminCatalogServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Object user = session == null ? null : session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!(user instanceof com.visioncare.model.User)
                || !"admin".equals(((com.visioncare.model.User) user).getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        // Frontend reference data. Replace with catalog DAO data when persistence is implemented.
        List<Map<String, String>> services = new ArrayList<>();
        services.add(item("NK-01", "general", "Gói cơ bản", "Nhãn khoa tổng quát", "30 - 45 phút", "ready", "250000", "250.000 VNĐ", "Khám và chẩn đoán toàn diện các bệnh lý về mắt, phù hợp với mọi lứa tuổi.", "Bao gồm đo thị lực, kiểm tra áp lực nhãn cầu, soi đáy mắt, đánh giá tình trạng giác mạc và thủy tinh thể. Bác sĩ tư vấn lộ trình điều trị phù hợp.", "departments-1.jpg"));
        services.add(item("KX-02", "refraction", "Khúc xạ kế", "Đo Khúc xạ & Kính", "20 - 30 phút", "ready", "150000", "150.000 VNĐ", "Khám sàng lọc và đo độ khúc xạ với hệ thống đo tự động chuẩn xác.", "Đo khúc xạ chính xác bằng máy tự động, thử thị lực và tư vấn tròng kính cận, viễn, loạn cùng kính áp tròng phù hợp.", "departments-2.jpg"));
        services.add(item("LS-03", "lasik", "Kỹ thuật cao", "Phẫu thuật LASIK", "60 - 90 phút", "scheduled", "18000000", "Từ 18.000.000 VNĐ", "Xóa cận không dao, thời gian phục hồi nhanh chóng và thị lực đạt đỉnh sau 24 giờ.", "Phẫu thuật khúc xạ laser LASIK/SMILE điều trị cận thị, viễn thị và loạn thị với công nghệ hiện đại.", "departments-3.jpg"));
        services.add(item("PE-04", "children", "Trẻ em & Học đường", "Nhãn khoa trẻ em & Nhược thị", "30 - 45 phút", "ready", "300000", "300.000 VNĐ", "Sàng lọc sớm các tật khúc xạ tiến triển, tật lé và suy giảm thị lực ở trẻ nhỏ.", "Sàng lọc cận thị sớm, điều trị nhược thị và lác mắt trong không gian khám thân thiện cho trẻ và gia đình.", "departments-4.jpg"));
        services.add(item("TT-05", "cataract", "Phẫu thuật Phaco", "Đục thủy tinh thể (Phaco)", "30 - 60 phút", "scheduled", "12000000", "Từ 12.000.000 VNĐ", "Tái tạo tầm nhìn trong sáng bằng phương pháp tán nhuyễn Phaco tiên tiến.", "Phẫu thuật thay thể thủy tinh nhân tạo (IOL) điều trị đục thủy tinh thể an toàn, đường mổ siêu nhỏ.", "departments-5.jpg"));
        services.add(item("GL-06", "retina", "Đáy mắt chuyên sâu", "Glaucoma & Võng mạc", "40 - 50 phút", "ready", "500000", "Từ 500.000 VNĐ", "Kiểm soát nhãn áp, bảo tồn thị trường thần kinh mắt và ngăn ngừa biến chứng mù lòa.", "Tầm soát và can thiệp bệnh Glaucoma, thoái hóa hoàng điểm và tổn thương võng mạc với hệ thống OCT.", "gallery/gallery-1.jpg"));
        request.setAttribute("catalogServices", services);
        request.getRequestDispatcher("/views/admin/catalog.jsp").forward(request, response);
    }

    private Map<String, String> item(String id, String specialty, String tag, String name,
            String duration, String status, String price, String priceLabel, String summary,
            String description, String image) {
        Map<String, String> item = new HashMap<>();
        item.put("id", id);
        item.put("specialty", specialty);
        item.put("tag", tag);
        item.put("name", name);
        item.put("duration", duration);
        item.put("status", status);
        item.put("price", price);
        item.put("priceLabel", priceLabel);
        item.put("summary", summary);
        item.put("description", description);
        item.put("image", image);
        return item;
    }
}
