package com.visioncare.controller;

import com.visioncare.dao.ProcedureOrderDAO;
import com.visioncare.model.MedicalRecord;
import com.visioncare.model.ProcedureOrder;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Controller cho Màn hình Thực hiện Thủ thuật & Nhập kết quả (Screen 36 - Procedure Execution Detail Screen)
 * Phục vụ Kỹ thuật viên (Specialist) thực hiện chuẩn quy trình y khoa:
 * 1. Tiếp nhận ca (Pending -> In_Progress)
 * 2. Đo đạc & Nhập kết quả chuyên khoa Mắt theo 2 mắt OD (Phải) & OS (Trái)
 * 3. Hoàn tất thủ thuật & Trả kết quả về cho Bác sĩ khám chính (In_Progress -> Completed)
 * 4. In phiếu kết quả cận lâm sàng
 */
@WebServlet(name = "SpecialistProcedureDetailServlet", urlPatterns = {"/specialist/procedure-detail"})
public class SpecialistProcedureDetailServlet extends HttpServlet {

    private final ProcedureOrderDAO procedureOrderDAO = new ProcedureOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // 1. Kiểm tra đăng nhập
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Kiểm tra phân quyền
        String role = currentUser.getRole() != null ? currentUser.getRole().trim().toLowerCase() : "";
        if (!role.equals("medical_specialist") && !role.equals("doctor") && !role.equals("admin") && !role.equals("staff")) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // 3. Đọc orderId
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr.trim());
            ProcedureOrder order = procedureOrderDAO.getOrderById(orderId);
            if (order == null) {
                session.setAttribute("errorMessage", "Không tìm thấy thông tin ca thủ thuật #" + orderId);
                response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
                return;
            }

            // Khi KTV mở màn hình này (từ nút 'Thực hiện' ở Hàng đợi), ca tự động chuyển sang In_Progress nếu đang là Pending
            if ("Pending".equalsIgnoreCase(order.getStatus())) {
                try {
                    Integer specEmployeeId = (currentUser.getActorId() > 0) ? currentUser.getActorId() : null;
                    procedureOrderDAO.updateOrderStatus(orderId, specEmployeeId, "In_Progress");
                    order.setStatus("In_Progress");
                    if (currentUser.getFullName() != null) {
                        order.setSpecialistName(currentUser.getFullName());
                    }
                } catch (Exception ex) {
                    System.err.println("Warning: Không thể tự động chuyển trạng thái ca sang In_Progress: " + ex.getMessage());
                }
            }

            // Feature 1: View examination report (Lấy phiếu khám & chẩn đoán ban đầu của BS)
            MedicalRecord record = procedureOrderDAO.getMedicalRecordById(order.getRecordId());

            // Feature 2: View To-do list (Lấy toàn bộ các thủ thuật cần làm trong cùng ca khám này)
            List<ProcedureOrder> todoList = procedureOrderDAO.getTodoListByRecordId(order.getRecordId());

            // Feature 3: Phân rã kết quả đo sang cấu trúc OD/OS để hiển thị lên form
            Map<String, String> examData = parseExaminationResult(record != null ? record.getExaminationResult() : null);

            // Bỏ initial value ở trường kết luận (conclusion) nếu là ghi chú/chỉ định ban đầu của bác sĩ
            String initialConclusion = (record != null && record.getConclusion() != null) ? record.getConclusion().trim() : "";
            if (isDefaultOrDoctorInitialNote(initialConclusion, order)) {
                initialConclusion = "";
            }
            examData.put("conclusion", initialConclusion);

            // Khôi phục dữ liệu tạm nếu vừa submit gặp lỗi validation để tránh bị trắng form
            @SuppressWarnings("unchecked")
            Map<String, String> tempExamData = (Map<String, String>) session.getAttribute("tempExamData");
            if (tempExamData != null) {
                session.removeAttribute("tempExamData");
                examData.putAll(tempExamData);
                if (record != null && tempExamData.containsKey("conclusion")) {
                    record.setConclusion(tempExamData.get("conclusion"));
                }
            }

            request.setAttribute("order", order);
            request.setAttribute("record", record);
            request.setAttribute("todoList", todoList);
            request.setAttribute("examData", examData);

            request.getRequestDispatcher("/views/specialist/specialist-procedure-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi hệ thống khi tải thông tin ca thủ thuật: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderIdStr = request.getParameter("orderId");
        String action = request.getParameter("action");

        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr.trim());
            ProcedureOrder order = procedureOrderDAO.getOrderById(orderId);
            if (order == null) {
                session.setAttribute("errorMessage", "Không tìm thấy thông tin ca chỉ định.");
                response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
                return;
            }

            // Fallback action nếu form submit qua phím Enter hoặc nút không gửi name
            if (action == null || action.trim().isEmpty()) {
                action = "Completed".equalsIgnoreCase(order.getStatus()) ? "updateResults" : "saveDraft";
            }

            // Lấy ID kỹ thuật viên (Employee_ID)
            Integer specialistEmployeeId = (currentUser.getActorId() > 0) ? currentUser.getActorId() : null;

            // Kiểm tra tính hợp lệ của độ cầu (SPH) và độ loạn (CYL) cho các action cập nhật kết quả
            if ("saveDraft".equalsIgnoreCase(action) || "complete".equalsIgnoreCase(action) || "updateResults".equalsIgnoreCase(action)) {
                String odSph = nvl(request.getParameter("od_sph"));
                String odCyl = nvl(request.getParameter("od_cyl"));
                String osSph = nvl(request.getParameter("os_sph"));
                String osCyl = nvl(request.getParameter("os_cyl"));

                if (!isValidDiopter(odSph) || !isValidDiopter(odCyl) || !isValidDiopter(osSph) || !isValidDiopter(osCyl)) {
                    preserveFormInputs(request, session);
                    session.setAttribute("errorMessage", "Độ cầu (SPH) và độ loạn (CYL) chỉ chấp nhận các giá trị có đuôi .00, .25, .5, .75 (bước nhảy 0.25 D).");
                    response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);
                    return;
                }

                String pdStr = nvl(request.getParameter("pd"));
                if (!pdStr.isEmpty()) {
                    try {
                        int pdVal = Integer.parseInt(pdStr);
                        if (pdVal < 30 || pdVal > 100) {
                            preserveFormInputs(request, session);
                            session.setAttribute("errorMessage", "Khoảng cách đồng tử (PD) phải là số nguyên trong khoảng 30 - 100 mm.");
                            response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);
                            return;
                        }
                    } catch (NumberFormatException e) {
                        preserveFormInputs(request, session);
                        session.setAttribute("errorMessage", "Khoảng cách đồng tử (PD) phải là số nguyên (mm).");
                        response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);
                        return;
                    }
                }
            }

            // Xử lý các nghiệp vụ theo quy trình
            if ("start".equalsIgnoreCase(action)) {
                // Nghiệp vụ 1: Tiếp nhận ca và chuyển sang Đang thực hiện
                procedureOrderDAO.updateOrderStatus(orderId, specialistEmployeeId, "In_Progress");
                session.setAttribute("successMessage", "Đã tiếp nhận ca #CD-" + orderId + ". Bắt đầu thực hiện thủ thuật!");
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);

            } else if ("saveDraft".equalsIgnoreCase(action)) {
                // Nghiệp vụ 2: Lưu nháp kết quả trong quá trình đo
                String serializedExamResult = buildStructuredResult(request);
                String conclusion = request.getParameter("conclusion");

                procedureOrderDAO.updateOrderStatus(orderId, specialistEmployeeId, "In_Progress");
                procedureOrderDAO.updateMedicalRecordResults(
                        order.getRecordId(),
                        serializedExamResult,
                        conclusion != null ? conclusion.trim() : ""
                );

                session.setAttribute("successMessage", "Đã lưu nháp kết quả ca #CD-" + orderId + " thành công!");
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);

            } else if ("complete".equalsIgnoreCase(action)) {
                // Nghiệp vụ 3: Hoàn thành thủ thuật và Trả kết quả về cho Bác sĩ khám chính
                String serializedExamResult = buildStructuredResult(request);
                String conclusion = request.getParameter("conclusion");

                procedureOrderDAO.updateOrderStatus(orderId, specialistEmployeeId, "Completed");
                procedureOrderDAO.updateMedicalRecordResults(
                        order.getRecordId(),
                        serializedExamResult,
                        conclusion != null ? conclusion.trim() : ""
                );

                session.setAttribute("successMessage", "Đã hoàn thành thủ thuật và trả kết quả về cho Bác sĩ thành công cho ca #CD-" + orderId + "!");
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);

            } else if ("cancel".equalsIgnoreCase(action)) {
                // Nghiệp vụ 4: Hủy ca thủ thuật
                procedureOrderDAO.updateOrderStatus(orderId, specialistEmployeeId, "Cancelled");
                session.setAttribute("infoMessage", "Đã hủy ca chỉ định #CD-" + orderId + ".");
                response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");

            } else if ("updateResults".equalsIgnoreCase(action)) {
                // Nghiệp vụ 5: Cập nhật lại kết quả sau khi đã hoàn tất
                String serializedExamResult = buildStructuredResult(request);
                String conclusion = request.getParameter("conclusion");
                System.out.println(">>> [DEBUG doPost updateResults] recordId=" + order.getRecordId() + ", result length=" + serializedExamResult.length() + ", conclusion=" + conclusion);

                boolean updated = procedureOrderDAO.updateMedicalRecordResults(
                        order.getRecordId(),
                        serializedExamResult,
                        conclusion != null ? conclusion.trim() : ""
                );
                System.out.println(">>> [DEBUG doPost updateResults] updated=" + updated);
                session.setAttribute("successMessage", "Đã lưu cập nhật kết quả cận lâm sàng thành công!");
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);

            } else {
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi khi cập nhật trạng thái thủ thuật: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
        }
    }

    /**
     * Lưu tạm toàn bộ form inputs vào session để không bị mất khi gặp lỗi validation
     */
    private void preserveFormInputs(HttpServletRequest request, HttpSession session) {
        Map<String, String> map = new HashMap<>();
        map.put("od_ucva", nvl(request.getParameter("od_ucva")));
        map.put("od_bcva", nvl(request.getParameter("od_bcva")));
        map.put("od_sph", nvl(request.getParameter("od_sph")));
        map.put("od_cyl", nvl(request.getParameter("od_cyl")));
        map.put("od_axis", nvl(request.getParameter("od_axis")));
        map.put("od_iop", nvl(request.getParameter("od_iop")));

        map.put("os_ucva", nvl(request.getParameter("os_ucva")));
        map.put("os_bcva", nvl(request.getParameter("os_bcva")));
        map.put("os_sph", nvl(request.getParameter("os_sph")));
        map.put("os_cyl", nvl(request.getParameter("os_cyl")));
        map.put("os_axis", nvl(request.getParameter("os_axis")));
        map.put("os_iop", nvl(request.getParameter("os_iop")));

        map.put("pd", nvl(request.getParameter("pd")));
        map.put("detailed_findings", nvl(request.getParameter("detailed_findings")));
        map.put("conclusion", nvl(request.getParameter("conclusion")));
        session.setAttribute("tempExamData", map);
    }

    /**
     * Ghép dữ liệu từ các trường Mắt Phải (OD) và Mắt Trái (OS) thành chuỗi kết quả có cấu trúc
     */
    private String buildStructuredResult(HttpServletRequest request) {
        String odUcva = nvl(request.getParameter("od_ucva"));
        String odBcva = nvl(request.getParameter("od_bcva"));
        String odSph = normalizeDiopter(nvl(request.getParameter("od_sph")));
        String odCyl = normalizeDiopter(nvl(request.getParameter("od_cyl")));
        String odAxis = nvl(request.getParameter("od_axis"));
        String odIop = nvl(request.getParameter("od_iop"));

        String osUcva = nvl(request.getParameter("os_ucva"));
        String osBcva = nvl(request.getParameter("os_bcva"));
        String osSph = normalizeDiopter(nvl(request.getParameter("os_sph")));
        String osCyl = normalizeDiopter(nvl(request.getParameter("os_cyl")));
        String osAxis = nvl(request.getParameter("os_axis"));
        String osIop = nvl(request.getParameter("os_iop"));

        String pd = nvl(request.getParameter("pd"));
        String detailed = nvl(request.getParameter("detailed_findings"));

        StringBuilder sb = new StringBuilder();
        // Tag metadata để parse ngược lại form
        sb.append(String.format("[OD_UCVA:%s][OD_BCVA:%s][OD_SPH:%s][OD_CYL:%s][OD_AXIS:%s][OD_IOP:%s]\n",
                odUcva, odBcva, odSph, odCyl, odAxis, odIop));
        sb.append(String.format("[OS_UCVA:%s][OS_BCVA:%s][OS_SPH:%s][OS_CYL:%s][OS_AXIS:%s][OS_IOP:%s]\n",
                osUcva, osBcva, osSph, osCyl, osAxis, osIop));
        sb.append(String.format("[PD:%s]\n\n", pd));

        // Nội dung hiển thị đẹp mắt cho Bác sĩ và Bệnh nhân
        sb.append("--- THÔNG SỐ ĐO CẬN LÂM SÀNG CHUYÊN KHOA MẮT ---\n");
        sb.append(String.format("• MẮT PHẢI (OD):\n  - Thị lực: Không kính: %s | Có kính: %s\n  - Khúc xạ: Cầu (SPH): %s D | Loạn (CYL): %s D | Trục (AXIS): %s°\n  - Nhãn áp (IOP): %s mmHg\n\n",
                formatAcuity(odUcva), formatAcuity(odBcva), valOrDash(odSph), valOrDash(odCyl), valOrDash(odAxis), valOrDash(odIop)));

        sb.append(String.format("• MẮT TRÁI (OS):\n  - Thị lực: Không kính: %s | Có kính: %s\n  - Khúc xạ: Cầu (SPH): %s D | Loạn (CYL): %s D | Trục (AXIS): %s°\n  - Nhãn áp (IOP): %s mmHg\n\n",
                formatAcuity(osUcva), formatAcuity(osBcva), valOrDash(osSph), valOrDash(osCyl), valOrDash(osAxis), valOrDash(osIop)));

        if (!pd.isEmpty()) {
            sb.append("• Khoảng cách đồng tử (PD): ").append(pd).append(" mm\n");
        }
        if (!detailed.isEmpty()) {
            sb.append("\n• MÔ TẢ CHI TIẾT & HÌNH THÁI HỌC:\n").append(detailed);
        }

        return sb.toString();
    }

    /**
     * Tách ngược chuỗi kết quả để fill vào các ô input OD/OS
     */
    private Map<String, String> parseExaminationResult(String text) {
        Map<String, String> map = new HashMap<>();
        if (text == null || text.trim().isEmpty()) {
            return map;
        }

        Pattern tagPattern = Pattern.compile("\\[([A-Z0-9_]+):([^\\]]*)\\]");
        Matcher matcher = tagPattern.matcher(text);
        while (matcher.find()) {
            String key = matcher.group(1).toLowerCase();
            String val = matcher.group(2).trim();
            // Chuẩn hóa thị lực 0-10 nếu dữ liệu cũ có chứa /10
            if ((key.equals("od_ucva") || key.equals("od_bcva") || key.equals("os_ucva") || key.equals("os_bcva")) && val.contains("/")) {
                val = val.split("/")[0].trim();
            }
            map.put(key, val);
        }

        // Tách mô tả chi tiết: hỗ trợ cả dấu xuống dòng \r\n hoặc \n
        int descIdx = text.indexOf("MÔ TẢ CHI TIẾT & HÌNH THÁI HỌC:");
        if (descIdx != -1) {
            String after = text.substring(descIdx + "MÔ TẢ CHI TIẾT & HÌNH THÁI HỌC:".length()).trim();
            // Lọc bỏ các giá trị mẫu/khởi tạo ban đầu để không hiện lên form của KTV
            if (!after.equalsIgnoreCase("Mắt phải -2.50D, Mắt trái -3.00D.")
                    && !after.equalsIgnoreCase("Thị lực không kính: MP 2/10, MT 3/10.")
                    && !after.equalsIgnoreCase("Không có ghi nhận bất thường.")) {
                map.put("detailed_findings", after);
            } else {
                map.put("detailed_findings", "");
            }
        } else {
            // Khi chưa từng lưu kết quả thủ thuật thì để trống, tuyệt đối không lấy text khám sơ bộ của Bác sĩ làm initial value
            map.put("detailed_findings", "");
        }

        return map;
    }

    private String formatAcuity(String s) {
        if (s == null || s.trim().isEmpty()) return "--";
        String trimmed = s.trim();
        if (trimmed.matches("^(10|[0-9])$")) {
            return trimmed + "/10";
        }
        return trimmed;
    }

    private String nvl(String s) {
        return (s != null) ? s.trim() : "";
    }

    private String valOrDash(String s) {
        return (s != null && !s.trim().isEmpty()) ? s.trim() : "--";
    }

    private boolean isDefaultOrDoctorInitialNote(String note, ProcedureOrder order) {
        if (note == null || note.trim().isEmpty()) {
            return true;
        }
        String lower = note.toLowerCase().trim();
        if (lower.equals("đo khúc xạ máy tự động") || lower.equals("do khuc xa may tu dong")
                || lower.equals("đo khúc xạ máy và thử thị lực chi tiết trước chỉnh kính")
                || lower.equals("do khuc xa may va thu thi luc chi tiet truoc chinh kinh")) {
            return true;
        }
        if (lower.startsWith("chỉ định") || lower.startsWith("chi dinh")
                || lower.startsWith("đo nhãn áp & chụp oct") || lower.startsWith("đủ điều kiện phẫu thuật")) {
            return true;
        }
        if (order != null && order.getServiceName() != null && !order.getServiceName().trim().isEmpty()) {
            if (lower.contains(order.getServiceName().toLowerCase().trim())) {
                return true;
            }
        }
        return false;
    }

    public static String normalizeDiopter(String val) {
        if (val == null || val.trim().isEmpty()) return "";
        String s = val.trim().replace(',', '.');
        if (s.startsWith(".")) s = "0" + s;
        else if (s.startsWith("+.")) s = "+0." + s.substring(2);
        else if (s.startsWith("-.")) s = "-0." + s.substring(2);

        if (!s.contains(".")) {
            s = s + ".00";
        } else {
            String[] parts = s.split("\\.");
            if (parts.length == 2 && parts[1].length() == 1) {
                s = s + "0";
            }
        }
        return s;
    }

    private boolean isValidDiopter(String val) {
        if (val == null || val.trim().isEmpty()) return true;
        String norm = normalizeDiopter(val);
        return norm.matches("^[+-]?\\d+\\.(00|25|50|75)$");
    }
}
