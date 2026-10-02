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
                
                userDAO.updateUserRole(accountId, newRoleId);
                userDAO.updateUserProfile(accountId, fullName, phone);
                
                request.getSession().setAttribute("success", "Cập nhật thông tin và quyền thành công.");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/users/detail?id=" + accountId);
            
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi khi cập nhật.");
            response.sendRedirect(request.getContextPath() + "/admin/users/detail?id=" + idParam);
        }
    }
}
