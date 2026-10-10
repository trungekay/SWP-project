package com.visioncare.controller;

import com.visioncare.dao.UserDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminUserListServlet", urlPatterns = {"/admin/users"})
public class AdminUserListServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<User> users = userDAO.getAllUsers();
            request.setAttribute("users", users);
            request.getRequestDispatcher("/views/admin/user-list.jsp").forward(request, response);
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi tải danh sách người dùng.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        
        if (action == null || idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        try {
            int accountId = Integer.parseInt(idParam);
            
            switch (action) {
                case "delete":
                    boolean deleted = userDAO.deleteUser(accountId);
                    if (!deleted) {
                        request.getSession().setAttribute("error", "Không thể xóa do ràng buộc dữ liệu.");
                    } else {
                        request.getSession().setAttribute("success", "Xóa người dùng thành công.");
                    }
                    break;
                case "deactivate":
                    userDAO.updateAccountStatus(accountId, "Inactive");
                    request.getSession().setAttribute("success", "Vô hiệu hóa thành công.");
                    break;
                case "activate":
                    userDAO.updateAccountStatus(accountId, "Active");
                    request.getSession().setAttribute("success", "Kích hoạt thành công.");
                    break;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("error", ex.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
