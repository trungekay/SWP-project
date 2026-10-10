package com.visioncare.controller;
import com.visioncare.dao.UserDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
@WebServlet(name = "AdminUserAddServlet", urlPatterns = {"/admin/users/add"})
public class AdminUserAddServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/admin/user-add.jsp").forward(request, response);
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = "NEW_" + request.getParameter("password");
        String phone = request.getParameter("phone");
        if (phone != null) {
            phone = phone.trim();
            if (phone.startsWith("+84")) {
                phone = "0" + phone.substring(3);
            }
            phone = phone.replaceAll("\\s+", ""); 
            if (!phone.matches("\\d{10}")) {
                request.setAttribute("error", "Số điện thoại không hợp lệ. Phải bao gồm đúng 10 chữ số.");
                request.getRequestDispatcher("/views/admin/user-add.jsp").forward(request, response);
                return;
            }
        }
        int roleId = Integer.parseInt(request.getParameter("roleId"));
        User user = new User();
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPassword(password);
        user.setPhone(phone);
        user.setRoleId(roleId);
        
        String dob = request.getParameter("dob");
        if (dob != null && !dob.trim().isEmpty()) {
            dob = dob.trim();
            if (dob.matches("\\d{2}/\\d{2}/\\d{4}")) {
                String[] parts = dob.split("/");
                dob = parts[2] + "-" + parts[1] + "-" + parts[0];
            } else if (dob.matches("\\d{2}-\\d{2}-\\d{4}")) {
                String[] parts = dob.split("-");
                dob = parts[2] + "-" + parts[1] + "-" + parts[0];
            }
            user.setDob(dob);
        }
        
        String address = request.getParameter("address");
        if (address != null && !address.trim().isEmpty()) {
            user.setAddress(address.trim());
        }
        
        if (roleId == 3 || roleId == 4) {
            String licenseNumber = request.getParameter("licenseNumber");
            if (licenseNumber != null && !licenseNumber.trim().isEmpty()) {
                user.setLicenseNumber(licenseNumber.trim());
            }
            String specialty = request.getParameter("specialty");
            if (specialty != null && !specialty.trim().isEmpty()) {
                user.setSpecialty(specialty.trim());
            }
            String roomId = request.getParameter("roomId");
            if (roomId != null && !roomId.trim().isEmpty()) {
                user.setRoomName(roomId.trim());
            }
        }
        
        try {
            // Check if email exists
            if (userDAO.getByEmail(email) != null) {
                request.setAttribute("error", "Lỗi: Email '" + email + "' đã được sử dụng trong hệ thống. Vui lòng nhập một email khác.");
                request.getRequestDispatcher("/views/admin/user-add.jsp").forward(request, response);
                return;
            }
            
            // Check if phone exists
            if (userDAO.getByPhone(phone) != null) {
                request.setAttribute("error", "Lỗi: Số điện thoại '" + phone + "' đã tồn tại trong hệ thống. Vui lòng kiểm tra lại.");
                request.getRequestDispatcher("/views/admin/user-add.jsp").forward(request, response);
                return;
            }
            
            boolean success = userDAO.addSystemUser(user);
            if (success) {
                try {
                    com.visioncare.util.EmailUtil.sendAccountCredentialsEmail(email, password);
                } catch (Exception e) {
                    e.printStackTrace();
                    System.out.println("Failed to send credentials email to: " + email);
                }
                request.getSession().setAttribute("success", "Thêm người dùng thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            } else {
                request.setAttribute("error", "Lỗi khi thêm người dùng.");
                request.getRequestDispatcher("/views/admin/user-add.jsp").forward(request, response);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            String errorMsg = ex.getMessage();
            if (errorMsg != null && (errorMsg.contains("UNIQUE KEY") || errorMsg.contains("duplicate key"))) {
                errorMsg = "Lỗi: Email '" + email + "' đã được sử dụng trong hệ thống. Vui lòng nhập một email khác.";
            } else {
                errorMsg = "Lỗi hệ thống: " + errorMsg;
            }
            request.setAttribute("error", errorMsg);
            request.getRequestDispatcher("/views/admin/user-add.jsp").forward(request, response);
        }
    }
}
