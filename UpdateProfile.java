import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class UpdateProfile {
    public static void main(String[] args) {
        try {
            String[] files = {
                "e:/Github/SWP-project/web/views/profile/appointment-history.jsp",
                "e:/Github/SWP-project/web/views/profile/medical-history.jsp",
                "e:/Github/SWP-project/web/views/profile/refund-request.jsp",
                "e:/Github/SWP-project/web/views/profile/change-password.jsp"
            };

            String sidebarTemplate = 
                "          <div class=\"col-lg-3\">\n" +
                "            <div class=\"content-card text-center border-0 mb-4 mb-lg-0\" style=\"padding: 30px 20px;\">\n" +
                "              <div class=\"mb-3\">\n" +
                "                <span class=\"badge bg-light text-dark rounded-pill border px-3 py-1\">Avatar</span>\n" +
                "              </div>\n" +
                "              <h4 class=\"fw-bold\" style=\"color: #1e293b; font-size: 18px;\">${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Nguyễn Văn A'}</h4>\n" +
                "              <p class=\"text-muted small mb-4\">\n" +
                "                <c:choose>\n" +
                "                    <c:when test=\"${sessionScope.user.role == 'admin'}\">Super Admin</c:when>\n" +
                "                    <c:when test=\"${sessionScope.user.role == 'manager'}\">Manager</c:when>\n" +
                "                    <c:when test=\"${sessionScope.user.role == 'doctor'}\">Bác sĩ</c:when>\n" +
                "                    <c:when test=\"${sessionScope.user.role == 'medical_specialist'}\">Bác sĩ Chuyên khoa</c:when>\n" +
                "                    <c:when test=\"${sessionScope.user.role == 'staff'}\">Nhân viên</c:when>\n" +
                "                    <c:otherwise>Bệnh nhân</c:otherwise>\n" +
                "                </c:choose>\n" +
                "              </p>\n" +
                "              \n" +
                "              <ul class=\"sidebar-menu text-start\">\n" +
                "                <li>\n" +
                "                  <a href=\"${pageContext.request.contextPath}/views/profile/manage.jsp\" class=\"{manage_active}\"><i class=\"bi bi-person\"></i> Thông tin chung</a>\n" +
                "                </li>\n" +
                "                <c:if test=\"${sessionScope.user.role == 'patient'}\">\n" +
                "                    <li>\n" +
                "                    <a href=\"${pageContext.request.contextPath}/views/profile/appointment-history.jsp\" class=\"{appt_active}\"><i class=\"bi bi-calendar-check\"></i> Lịch sử hẹn khám</a>\n" +
                "                    </li>\n" +
                "                    <li>\n" +
                "                    <a href=\"${pageContext.request.contextPath}/views/profile/medical-history.jsp\" class=\"{med_active}\"><i class=\"bi bi-journal-medical\"></i> Lịch sử khám bệnh</a>\n" +
                "                    </li>\n" +
                "                    <li>\n" +
                "                    <a href=\"${pageContext.request.contextPath}/views/profile/refund-request.jsp\" class=\"{refund_active}\"><i class=\"bi bi-cash-coin\"></i> Yêu cầu hoàn tiền</a>\n" +
                "                    </li>\n" +
                "                </c:if>\n" +
                "                <li>\n" +
                "                  <a href=\"${pageContext.request.contextPath}/views/profile/change-password.jsp\" class=\"{pwd_active}\"><i class=\"bi bi-key\"></i> Đổi mật khẩu</a>\n" +
                "                </li>\n" +
                "                <li class=\"mt-3 pt-3\" style=\"border-top: 1px solid #f1f5f9;\">\n" +
                "                  <a href=\"${pageContext.request.contextPath}/logout\" class=\"text-danger\"><i class=\"bi bi-box-arrow-right\"></i> Đăng xuất</a>\n" +
                "                </li>\n" +
                "              </ul>\n" +
                "            </div>\n" +
                "          </div>";

            String cssAppend = 
                "    /* Admin UI Sync */\n" +
                "    .content-card {\n" +
                "        background: white;\n" +
                "        border-radius: 12px;\n" +
                "        box-shadow: 0 1px 3px rgba(0,0,0,0.05);\n" +
                "        border: 1px solid rgba(0,0,0,0.05);\n" +
                "        overflow: hidden;\n" +
                "    }\n" +
                "    .sidebar-menu {\n" +
                "        padding: 0;\n" +
                "        list-style: none;\n" +
                "        margin: 0;\n" +
                "    }\n" +
                "    .sidebar-menu li {\n" +
                "        margin-bottom: 4px;\n" +
                "    }\n" +
                "    .sidebar-menu li a {\n" +
                "        display: flex;\n" +
                "        align-items: center;\n" +
                "        padding: 12px 16px;\n" +
                "        color: #64748b;\n" +
                "        text-decoration: none;\n" +
                "        border-radius: 8px;\n" +
                "        font-weight: 500;\n" +
                "        font-size: 14px;\n" +
                "        transition: all 0.2s ease;\n" +
                "    }\n" +
                "    .sidebar-menu li a i {\n" +
                "        margin-right: 12px;\n" +
                "        font-size: 18px;\n" +
                "        color: #94a3b8;\n" +
                "    }\n" +
                "    .sidebar-menu li a:hover {\n" +
                "        background-color: #f8fafc;\n" +
                "        color: #0f172a;\n" +
                "    }\n" +
                "    .sidebar-menu li a:hover i {\n" +
                "        color: #64748b;\n" +
                "    }\n" +
                "    .sidebar-menu li a.active {\n" +
                "        background-color: #f0f7f6;\n" +
                "        color: #0d9488;\n" +
                "        font-weight: 600;\n" +
                "    }\n" +
                "    .sidebar-menu li a.active i {\n" +
                "        color: #0d9488;\n" +
                "    }\n" +
                "    .sidebar-menu li a.text-danger:hover {\n" +
                "        background-color: #fef2f2;\n" +
                "        color: #ef4444 !important;\n" +
                "    }\n" +
                "    .sidebar-menu li a.text-danger i {\n" +
                "        color: #ef4444;\n" +
                "    }\n" +
                "    /* Form overrides */\n" +
                "    .form-control, .form-select {\n" +
                "        border-radius: 8px;\n" +
                "        border: 1px solid #e2e8f0;\n" +
                "        padding: 10px 16px;\n" +
                "        font-size: 14px;\n" +
                "    }\n" +
                "    .form-control:focus, .form-select:focus {\n" +
                "        border-color: #0d9488;\n" +
                "        box-shadow: 0 0 0 3px rgba(13,148,136,0.1);\n" +
                "    }\n" +
                "    .btn-primary-custom {\n" +
                "        background-color: #0d9488;\n" +
                "        color: white;\n" +
                "        border: none;\n" +
                "        padding: 10px 20px;\n" +
                "        border-radius: 8px;\n" +
                "        font-weight: 500;\n" +
                "        font-size: 14px;\n" +
                "        transition: all 0.2s;\n" +
                "    }\n" +
                "    .btn-primary-custom:hover {\n" +
                "        background-color: #0f766e;\n" +
                "        color: white;\n" +
                "    }";

            for (String file : files) {
                String content = new String(Files.readAllBytes(Paths.get(file)), "UTF-8");
                
                String manage_active = file.contains("manage.jsp") ? "active" : "";
                String appt_active = file.contains("appointment-history.jsp") ? "active" : "";
                String med_active = file.contains("medical-history.jsp") ? "active" : "";
                String refund_active = file.contains("refund-request.jsp") ? "active" : "";
                String pwd_active = file.contains("change-password.jsp") ? "active" : "";

                String newSidebar = sidebarTemplate
                    .replace("{manage_active}", manage_active)
                    .replace("{appt_active}", appt_active)
                    .replace("{med_active}", med_active)
                    .replace("{refund_active}", refund_active)
                    .replace("{pwd_active}", pwd_active);

                Pattern p = Pattern.compile("<div class=\"col-lg-3\">.*?</div>\\s*</div>\\s*<div class=\"col-lg-9", Pattern.DOTALL);
                Matcher m = p.matcher(content);
                if (m.find()) {
                    content = m.replaceFirst(Matcher.quoteReplacement(newSidebar + "\n          <div class=\"col-lg-9"));
                }

                if (!content.contains("/* Admin UI Sync */")) {
                    content = content.replace("</style>", cssAppend + "\n  </style>");
                }

                if (file.contains("change-password.jsp")) {
                    content = content.replace("<hr class=\"mb-4\">\n              \n              <form", "<hr class=\"mb-4\">\n              <div class=\"content-card p-4\">\n              <form");
                    content = content.replace("<hr class=\"mb-4\">\n\n              <c:if", "<hr class=\"mb-4\">\n              <div class=\"content-card p-4 mb-5\">\n              <c:if");
                    content = content.replace("<button type=\"submit\" class=\"btn text-white w-100 py-2\" style=\"background-color: #0d9488; border-color: #0d9488; border-radius: 6px;\">\n                    Đổi mật khẩu\n                  </button>", "<button type=\"submit\" class=\"btn-primary-custom w-100\">\n                    Đổi mật khẩu\n                  </button>");
                    content = content.replace("</form>\n            </div>\n          </div>", "</form>\n              </div>\n            </div>\n          </div>");
                }

                if (file.contains("refund-request.jsp")) {
                    content = content.replace("<div class=\"table-responsive\">", "<div class=\"content-card mb-5\">\n                <div class=\"table-responsive\">");
                    content = content.replace("</table>\n              </div>", "</table>\n                </div>\n              </div>");
                    content = content.replace("<table class=\"table table-borderless table-striped align-middle\">", "<table class=\"custom-table\">");
                    content = content.replace("<thead class=\"table-light\">", "<thead>");
                    
                    content = content.replace("<button type=\"button\" class=\"btn btn-secondary\" data-bs-dismiss=\"modal\">Hủy</button>\n            <button type=\"submit\" class=\"btn btn-custom\">Gửi yêu cầu</button>", "<button type=\"button\" class=\"btn btn-secondary\" data-bs-dismiss=\"modal\">Hủy</button>\n            <button type=\"submit\" class=\"btn-primary-custom\">Gửi yêu cầu</button>");
                }

                if (file.contains("appointment-history.jsp")) {
                    content = content.replace("<table class=\"table table-borderless table-striped align-middle mt-3\">", "<div class=\"content-card mt-3\"><div class=\"table-responsive\"><table class=\"custom-table\">");
                    content = content.replace("</table>\n                  </div>", "</table></div></div>\n                  </div>");
                    content = content.replace("<thead class=\"table-light\">", "<thead>");
                    content = content.replace("<div class=\"table-responsive mt-3\">", "<div class=\"content-card mt-3\"><div class=\"table-responsive\">");
                    content = content.replace("<span class=\"badge bg-success\">", "<span class=\"badge-status status-active\">");
                    content = content.replace("<span class=\"badge bg-secondary\">", "<span class=\"badge-status\" style=\"background: #f1f5f9; color: #475569;\">");
                    content = content.replace("<span class=\"badge bg-warning text-dark\">", "<span class=\"badge-status\" style=\"background: #fef3c7; color: #b45309;\">");
                    content = content.replace("<span class=\"badge bg-danger\">", "<span class=\"badge-status\" style=\"background: #fee2e2; color: #b91c1c;\">");
                    content = content.replace("<span class=\"badge bg-info text-dark\">", "<span class=\"badge-status\" style=\"background: #dbeafe; color: #1d4ed8;\">");
                }
                
                Files.write(Paths.get(file), content.getBytes("UTF-8"));
                System.out.println("Updated " + file);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
