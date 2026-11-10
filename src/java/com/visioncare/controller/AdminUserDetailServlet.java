package com.visioncare.controller;

import com.visioncare.dao.UserDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.format.ResolverStyle;

@WebServlet(name = "AdminUserDetailServlet", urlPatterns = {"/admin/users/detail"})
public class AdminUserDetailServlet extends HttpServlet {

    private static final DateTimeFormatter DISPLAY_DATE = DateTimeFormatter.ofPattern("dd-MM-uuuu")
            .withResolverStyle(ResolverStyle.STRICT);
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
                HttpSession session = request.getSession(false);
                User operator = session == null ? null : (User) session.getAttribute("user");
                request.setAttribute("user", user);
                request.setAttribute("canAssignRole", operator != null
                        && UserDAO.canAssignManagedRole(operator.getRoleId(), user.getRoleId()));
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
        HttpSession session = request.getSession(false);
        User operator = session == null ? null : (User) session.getAttribute("user");
        if (operator == null || (operator.getRoleId() != 1 && operator.getRoleId() != 2)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
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
                if (newRoleId < 1 || newRoleId > 6) {
                    throw new IllegalArgumentException("Quyền người dùng không hợp lệ.");
                }
                String fullName = request.getParameter("fullName");
                if (fullName == null || fullName.isBlank() || fullName.length() > 150) {
                    throw new IllegalArgumentException("Họ và tên là bắt buộc và không được vượt quá 150 ký tự.");
                }
                String phone = request.getParameter("phone");
                phone = phone == null ? "" : phone.replaceAll("\\s+", "");
                if (!phone.matches("\\d{10}")) {
                    throw new IllegalArgumentException("Số điện thoại không hợp lệ. Phải bao gồm đúng 10 chữ số.");
                }
                String address = request.getParameter("address");
                if (address != null && address.length() > 255) {
                    throw new IllegalArgumentException("Địa chỉ không được vượt quá 255 ký tự.");
                }

                User updated = new User();
                updated.setId(accountId);
                updated.setRoleId(newRoleId);
                updated.setFullName(fullName);
                updated.setPhone(phone);
                updated.setDob(parseDateOfBirth(request.getParameter("dob")));
                updated.setAddress(address == null ? "" : address);

                Integer roomId = null;
                if (newRoleId == 3 || newRoleId == 4) {
                    String license = request.getParameter("licenseNumber");
                    String specialty = request.getParameter("specialty");
                    if ((license != null && license.length() > 100) || (specialty != null && specialty.length() > 100)) {
                        throw new IllegalArgumentException("Số chứng chỉ và chuyên khoa không được vượt quá 100 ký tự.");
                    }
                    updated.setLicenseNumber(license);
                    updated.setSpecialty(specialty);
                    updated.setBiography(request.getParameter("biography"));
                    roomId = parseRoomId(request.getParameter("roomId"));
                }

                userDAO.updateManagedUser(operator.getId(), updated, roomId);
                session.setAttribute("success", "Cập nhật người dùng thành công.");
                String type = newRoleId == 6 ? "patient" : "staff";
                response.sendRedirect(request.getContextPath() + "/admin/users?type=" + type);
                return;
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/users/detail?id=" + accountId);
            
        } catch (SecurityException ex) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, ex.getMessage());
        } catch (Exception ex) {
            ex.printStackTrace();
            String errMsg = ex.getMessage();
            if (errMsg == null || errMsg.trim().isEmpty()) {
                errMsg = "Lỗi khi cập nhật.";
            }
            session.setAttribute("error", errMsg);
            response.sendRedirect(request.getContextPath() + "/admin/users/detail?id=" + idParam);
        }
    }

    private String parseDateOfBirth(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        String date = value.trim().replace('/', '-');
        try {
            LocalDate parsed = date.matches("\\d{4}-\\d{2}-\\d{2}")
                    ? LocalDate.parse(date) : LocalDate.parse(date, DISPLAY_DATE);
            if (parsed.getYear() >= 1) {
                return parsed.toString();
            }
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException("Ngày sinh không hợp lệ.", ex);
        }
        throw new IllegalArgumentException("Ngày sinh không hợp lệ.");
    }

    private Integer parseRoomId(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        int roomId;
        try {
            roomId = Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("ID phòng làm việc phải là một số nguyên.", ex);
        }
        if (roomId <= 0) {
            throw new IllegalArgumentException("ID phòng làm việc phải lớn hơn 0.");
        }
        return roomId;
    }
}
