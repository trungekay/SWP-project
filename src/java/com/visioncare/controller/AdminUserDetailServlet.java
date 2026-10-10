package com.visioncare.controller;

import com.visioncare.dao.UserDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AdminUserDetailServlet", urlPatterns = {"/admin/users/detail"})
public class AdminUserDetailServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        try {
            int accountId = Integer.parseInt(idParam);
            User user = userDAO.getUserById(accountId);
            if (user != null) {
                request.setAttribute("user", user);
                request.getRequestDispatcher("/views/admin/user-detail.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/users");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        String action = request.getParameter("action");
        
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        try {
            int accountId = Integer.parseInt(idParam);
            
            if ("update".equals(action)) {
                int newRoleId = Integer.parseInt(request.getParameter("roleId"));
                String fullName = request.getParameter("fullName");
                String phone = request.getParameter("phone");
                
                if (phone != null) {
                    phone = phone.trim().replaceAll("\\s+", "");
                    if (!phone.matches("\\d{10}")) {
                        request.getSession().setAttribute("error", "Số điện thoại không hợp lệ. Phải bao gồm đúng 10 chữ số.");
                        response.sendRedirect(request.getContextPath() + "/admin/users/detail?id=" + accountId);
                        return;
                    }
                }
                
                userDAO.updateUserRole(accountId, newRoleId);
                
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
                }
                String address = request.getParameter("address");
                
                userDAO.updateUserProfile(accountId, fullName, phone, dob, address);
                
                // If it's a doctor (3) or medical specialist (4), also update their specific profile info
                if (newRoleId == 3 || newRoleId == 4) {
                    String license = request.getParameter("licenseNumber");
                    String specialty = request.getParameter("specialty");
                    String roomIdStr = request.getParameter("roomId");
                    String biography = request.getParameter("biography");
                    if (roomIdStr != null && !roomIdStr.trim().isEmpty()) {
                        try {
                            int rId = Integer.parseInt(roomIdStr.trim());
                            if (rId <= 0) {
                                request.getSession().setAttribute("error", "Lỗi: ID Phòng làm việc không được nhỏ hơn hoặc bằng 0!");
                                response.sendRedirect(request.getContextPath() + "/admin/users/detail?id=" + accountId);
                                return;
                            }
                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("error", "Lỗi: ID Phòng làm việc phải là một số nguyên!");
                            response.sendRedirect(request.getContextPath() + "/admin/users/detail?id=" + accountId);
                            return;
                        }
                    }
                    userDAO.updateDoctorProfile(accountId, license, specialty, roomIdStr, biography);
                }
                
                request.getSession().setAttribute("success", "Cập nhật thông tin và quyền thành công.");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/users/detail?id=" + accountId);
            
        } catch (Exception ex) {
            ex.printStackTrace();
            String errMsg = ex.getMessage();
            if (errMsg == null || errMsg.trim().isEmpty()) {
                errMsg = "Lỗi khi cập nhật.";
            }
            request.getSession().setAttribute("error", errMsg);
            response.sendRedirect(request.getContextPath() + "/admin/users/detail?id=" + idParam);
        }
    }
}
