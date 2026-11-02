package com.visioncare.controller;

import com.visioncare.dao.DoctorFormDAO;
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
 * Controller cho Màn hình Thực hiện Thủ thuật & Lập Biên bản Phẫu thuật (Screen
 * 36)
 * Dành riêng cho Kỹ thuật viên / Phẫu thuật viên Chuyên khoa (Specialist):
 * - Nhận các ca thuộc Category: 'Điều trị và thủ thuật'
 * - Hiển thị Read-only thông tin chẩn đoán lâm sàng & kết quả đo khám từ Bác sĩ
 * - Lập Biên bản Thủ thuật (Mắt can thiệp, Phương pháp vô cảm, Diễn biến kỹ
 * thuật, Tình trạng sau mổ, Lời dặn hậu phẫu)
 * - Hoàn tất thủ thuật và trả kết quả về ca khám cho Bác sĩ
 */
@WebServlet(name = "SpecialistProcedureDetailServlet", urlPatterns = { "/specialist/procedure-detail" })
public class SpecialistProcedureDetailServlet extends HttpServlet {

    private final ProcedureOrderDAO procedureOrderDAO = new ProcedureOrderDAO();
    private final com.visioncare.dao.SpecialistCompletionDAO completionDAO = new com.visioncare.dao.SpecialistCompletionDAO();

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
        if (!role.equals("medical_specialist") && !role.equals("doctor") && !role.equals("admin")
                && !role.equals("staff")) {
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

            // Feature 1: Lấy phiếu khám & chẩn đoán ban đầu của Bác sĩ
            MedicalRecord record = procedureOrderDAO.getMedicalRecordById(order.getRecordId());

            // Load chi tiết khám lâm sàng của Bác sĩ (Examination_Detail)
            Map<String, String> examForm = new HashMap<>();
            int apptId = (record != null && record.getAppointmentId() > 0)
                    ? record.getAppointmentId()
                    : (order != null ? order.getAppointmentId() : 0);
            if (apptId > 0) {
                try {
                    DoctorFormDAO doctorFormDAO = new DoctorFormDAO();
                    Map<String, String> loaded = doctorFormDAO.loadExamination(apptId);
                    if (loaded != null) {
                        examForm.putAll(loaded);
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            // Feature 2: Lấy To-do list các thủ thuật trong cùng ca khám này
            List<ProcedureOrder> todoList = procedureOrderDAO.getTodoListByRecordId(order.getRecordId());

            // Feature 3: Phân tích kết quả khám của Bác sĩ và Biên bản thủ thuật của
            // Specialist
            String rawExamText = (order.getExaminationResult() != null
                    && !order.getExaminationResult().trim().isEmpty())
                            ? order.getExaminationResult()
                            : (record != null ? record.getExaminationResult() : null);
            String rawConclusion = (order.getConclusion() != null && !order.getConclusion().trim().isEmpty())
                    ? order.getConclusion()
                    : (record != null ? record.getConclusion() : null);

            Map<String, String> protocolData = parseProtocolData(rawExamText, rawConclusion, order);

            // Khôi phục form tạm nếu có lỗi validation từ session
            @SuppressWarnings("unchecked")
            Map<String, String> tempProtocolData = (Map<String, String>) session.getAttribute("tempProtocolData");
            if (tempProtocolData != null) {
                session.removeAttribute("tempProtocolData");
                protocolData.putAll(tempProtocolData);
            }

            String readOnlyReason = procedureReadOnlyReason(currentUser, order, record);
            request.setAttribute("canEditProcedure", readOnlyReason.isEmpty());
            request.setAttribute("procedureReadOnlyReason", readOnlyReason);
            request.setAttribute("order", order);
            request.setAttribute("record", record);
            request.setAttribute("todoList", todoList);
            request.setAttribute("protocol", protocolData);
            request.setAttribute("examForm", examForm);

            request.getRequestDispatcher("/views/specialist/specialist-procedure-detail.jsp").forward(request,
                    response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi hệ thống khi tải thông tin ca thủ thuật: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
        }
    }

    static String procedureReadOnlyReason(User user, ProcedureOrder order, MedicalRecord record) {
        if (user.getRoleId() != 4 || user.getActorId() <= 0)
            return "Chỉ bác sĩ phẫu thuật phụ trách được chỉnh sửa biên bản.";
        if (record == null) return "Không tải được thông tin ca khám. Vui lòng tải lại trang.";
        if ("Completed".equals(record.getAppointmentStatus()))
            return "Ca khám đã kết thúc. Biên bản chỉ để xem và in.";
        if ("Canceled".equals(record.getAppointmentStatus()) || "Cancelled".equals(order.getStatus()))
            return "Ca khám hoặc chỉ định đã bị hủy. Biên bản chỉ để xem và in.";
        if (!"In_Progress".equals(record.getAppointmentStatus()))
            return "Ca khám chưa được bác sĩ tiếp nhận. Chưa thể thực hiện thủ thuật.";
        if (order.getSpecialistId() != null && order.getSpecialistId().intValue() != user.getActorId())
            return "Ca được phân công cho bác sĩ phẫu thuật khác. Biên bản chỉ để xem và in.";
        return "";
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
        if (currentUser.getRoleId() != 4 || currentUser.getActorId() <= 0) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
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
                action = "Completed".equalsIgnoreCase(order.getStatus()) ? "updateResults" : "complete";
            }

            // Lấy ID kỹ thuật viên (Employee_ID)
            Integer specialistEmployeeId = (currentUser.getActorId() > 0) ? currentUser.getActorId()
                    : order.getSpecialistId();

            if ("cancel".equalsIgnoreCase(action)) {
                // Hủy ca thủ thuật
                if (!completionDAO.cancel(orderId, specialistEmployeeId)) {
                    throw new IllegalStateException("Ca không còn khả dụng hoặc đã thay đổi trạng thái.");
                }
                session.setAttribute("infoMessage", "Đã hủy ca chỉ định #CD-" + orderId + ".");
                response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
                return;
            }

            // Kiểm tra tính hợp lệ khi bấm "Hoàn thành thủ thuật"
            String procedureOutcome = nvl(request.getParameter("procedure_outcome"));

            boolean closeVisit = "completeAndClose".equalsIgnoreCase(action);
            if ("complete".equalsIgnoreCase(action) || "updateResults".equalsIgnoreCase(action) || closeVisit) {
                if (procedureOutcome.isEmpty()) {
                    preserveFormInputs(request, session);
                    session.setAttribute("errorMessage",
                            "Vui lòng ghi nhận Tình trạng sau thủ thuật trước khi hoàn tất!");
                    response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);
                    return;
                }
            }

            // Đóng gói biên bản thủ thuật
            String serializedResult = buildSerializedProtocol(request, order, currentUser.getFullName());
            String conclusion = nvl(request.getParameter("conclusion"));
            if (("complete".equalsIgnoreCase(action) || closeVisit || "updateResults".equalsIgnoreCase(action))
                    && conclusion.isEmpty()) {
                preserveFormInputs(request, session);
                session.setAttribute("errorMessage", "Vui lòng nhập kết luận thủ thuật trước khi hoàn tất.");
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);
                return;
            }
            if (closeVisit && !"true".equals(request.getParameter("noFurtherDoctorWork"))) {
                preserveFormInputs(request, session);
                session.setAttribute("errorMessage", "Chỉ kết thúc ca khi không còn cần bác sĩ khám xử lý hoặc kê/điều chỉnh thuốc.");
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);
                return;
            }
            if ("saveDraft".equalsIgnoreCase(action) || "complete".equalsIgnoreCase(action)
                    || "updateResults".equalsIgnoreCase(action) || closeVisit) {
                String nextStatus = "saveDraft".equalsIgnoreCase(action) ? "Pending" : "Completed";
                completionDAO.save(orderId, specialistEmployeeId, serializedResult, conclusion, nextStatus, closeVisit);
                session.setAttribute("successMessage", closeVisit
                        ? "Đã hoàn tất thủ thuật và đóng ca khám thành công."
                        : "saveDraft".equalsIgnoreCase(action) ? "Đã lưu nháp biên bản thủ thuật."
                        : "updateResults".equalsIgnoreCase(action) ? "Cập nhật biên bản thủ thuật thành công."
                        : "Đã hoàn tất thủ thuật và bàn giao kết quả về Bác sĩ khám.");
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);

            } else {
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi khi xử lý thủ thuật: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
        }
    }

    /**
     * Tách dữ liệu giữa phần Khám của Bác sĩ và Biên bản của Specialist
     */
    private Map<String, String> parseProtocolData(String examText, String conclusionText, ProcedureOrder order) {
        Map<String, String> map = new HashMap<>();

        // Mặc định
        String doctorExamFindings = "";
        String procedureEye = guessTargetEye(order);
        String procedureSteps = "";
        String procedureOutcome = "";
        String postCare = "";
        String conclusion = "";

        if (examText != null && !examText.trim().isEmpty()) {
            // Kiểm tra xem đã có tag [SPECIALIST_PROTOCOL] chưa
            int protoStart = examText.indexOf("[SPECIALIST_PROTOCOL]");
            if (protoStart != -1) {
                // 1. Tách phần Doctor findings
                int docStart = examText.indexOf("[DOCTOR_EXAM]");
                int docEnd = examText.indexOf("[/DOCTOR_EXAM]");
                if (docStart != -1 && docEnd != -1 && docEnd > docStart) {
                    doctorExamFindings = examText.substring(docStart + "[DOCTOR_EXAM]".length(), docEnd).trim();
                } else {
                    doctorExamFindings = examText.substring(0, protoStart).trim();
                }

                // 2. Tách các tag trong [SPECIALIST_PROTOCOL]
                String protoBody = examText.substring(protoStart);
                procedureEye = extractTag(protoBody, "PROC_EYE", procedureEye);
                procedureSteps = extractBlock(protoBody, "PROC_STEPS");
                procedureOutcome = extractBlock(protoBody, "PROC_OUTCOME");
                postCare = extractBlock(protoBody, "POST_CARE");
                conclusion = extractBlock(protoBody, "PROC_CONCLUSION");

            } else {
                // Toàn bộ examText là kết quả khám của Bác sĩ (lược bỏ các tag đo đạc cũ nếu
                // có)
                doctorExamFindings = cleanDoctorExamText(examText);
            }
        }

        // Kết luận của KTV hoàn toàn độc lập, chỉ lấy từ PROC_CONCLUSION khi KTV đã tự
        // nhập trước đó.
        // Tuyệt đối không lấy đề xuất/kê đơn của Bác sĩ (conclusionText) làm giá trị
        // mặc định cho KTV.

        // Phân rã kết quả khám của Bác sĩ thành các trường có cấu trúc đẹp mắt
        String doctorVa = "";
        String doctorIop = "";
        String doctorSlitLamp = "";

        if (!doctorExamFindings.isEmpty()) {
            String text = doctorExamFindings;
            int vaIdx = text.indexOf("Thị lực:");
            int iopIdx = text.indexOf("Nhãn áp:");
            int examIdx = text.indexOf("Khám thực thể:");

            if (vaIdx != -1 && iopIdx != -1 && iopIdx > vaIdx) {
                doctorVa = text.substring(vaIdx + "Thị lực:".length(), iopIdx).trim();
                if (doctorVa.endsWith("."))
                    doctorVa = doctorVa.substring(0, doctorVa.length() - 1).trim();

                if (examIdx != -1 && examIdx > iopIdx) {
                    doctorIop = text.substring(iopIdx + "Nhãn áp:".length(), examIdx).trim();
                    doctorSlitLamp = text.substring(examIdx + "Khám thực thể:".length()).trim();
                } else {
                    doctorIop = text.substring(iopIdx + "Nhãn áp:".length()).trim();
                }
                if (doctorIop.endsWith("."))
                    doctorIop = doctorIop.substring(0, doctorIop.length() - 1).trim();
            } else {
                doctorSlitLamp = text;
            }
        }

        // Chuẩn hóa OD/OS thành Mắt phải / Mắt trái trong kết quả hiển thị
        doctorVa = replaceEyeTerms(doctorVa);
        doctorIop = replaceEyeTerms(doctorIop);

        map.put("doctor_exam_findings", doctorExamFindings);
        map.put("doctor_va", doctorVa);
        map.put("doctor_iop", doctorIop);
        map.put("doctor_slit_lamp", doctorSlitLamp);
        map.put("procedure_eye", procedureEye);
        map.put("procedure_steps", procedureSteps);
        map.put("procedure_outcome", procedureOutcome);
        map.put("post_care", postCare);
        map.put("conclusion", conclusion);
        map.put("ktv_conclusion", conclusion);

        return map;
    }

    /**
     * Đóng gói Biên bản thủ thuật thành chuỗi có cấu trúc lưu vào
     * Medical_Record.examination_result
     */
    private String buildSerializedProtocol(HttpServletRequest request, ProcedureOrder order, String specialistName) {
        String doctorFindings = nvl(request.getParameter("doctor_exam_findings"));
        String procedureEye = nvl(request.getParameter("procedure_eye"));
        if (procedureEye.isEmpty())
            procedureEye = "OD";

        // This field is no longer editable; retain existing historical report content only.
        String procedureSteps = extractBlock(nvl(order.getExaminationResult()), "PROC_STEPS");
        String procedureOutcome = nvl(request.getParameter("procedure_outcome"));
        String postCare = nvl(request.getParameter("post_care"));
        String conclusion = nvl(request.getParameter("conclusion"));

        String eyeLabel = "Mắt Phải";
        if ("OS".equalsIgnoreCase(procedureEye))
            eyeLabel = "Mắt Trái";
        else if ("OU".equalsIgnoreCase(procedureEye))
            eyeLabel = "Cả Hai Mắt";

        StringBuilder sb = new StringBuilder();

        // 1. Phần Kết quả khám ban đầu của Bác sĩ (được bảo tồn nguyên vẹn)
        sb.append("[DOCTOR_EXAM]\n");
        sb.append(doctorFindings).append("\n");
        sb.append("[/DOCTOR_EXAM]\n\n");

        // 2. Phần Biên bản thực hiện thủ thuật của Specialist
        sb.append("[SPECIALIST_PROTOCOL]\n");
        sb.append(String.format("[PROC_EYE:%s]\n", procedureEye));
        if (!procedureSteps.isEmpty()) {
            sb.append("<PROC_STEPS>\n").append(procedureSteps).append("\n</PROC_STEPS>\n");
        }
        sb.append("<PROC_OUTCOME>\n").append(procedureOutcome).append("\n</PROC_OUTCOME>\n");
        sb.append("<POST_CARE>\n").append(postCare).append("\n</POST_CARE>\n");
        if (!conclusion.isEmpty()) {
            sb.append("<PROC_CONCLUSION>\n").append(conclusion).append("\n</PROC_CONCLUSION>\n");
        }
        sb.append("\n");

        // 3. Nội dung văn bản nhân văn, rõ ràng để hiển thị tổng quan cho Bác sĩ & Bệnh
        // án
        sb.append("--- BIÊN BẢN THỰC HIỆN THỦ THUẬT & PHẪU THUẬT ---\n");
        sb.append("• Dịch vụ can thiệp: ").append(order.getServiceName()).append("\n");
        sb.append("• Kỹ thuật viên / Phẫu thuật viên: ")
                .append(specialistName != null ? specialistName : "KTV Chuyên khoa").append("\n");
        sb.append("• Mắt thực hiện: ").append(eyeLabel).append("\n");
        if (!procedureSteps.isEmpty()) {
            sb.append("\n• DIỄN BIẾN & QUY TRÌNH THỦ THUẬT:\n").append(procedureSteps).append("\n");
        }
        sb.append("\n• TÌNH TRẠNG SAU THỦ THUẬT:\n").append(procedureOutcome).append("\n");
        if (!postCare.isEmpty()) {
            sb.append("\n• LỜI DẶN HẬU PHẪU & CHĂM SÓC:\n").append(postCare).append("\n");
        }
        sb.append("[/SPECIALIST_PROTOCOL]");

        return sb.toString();
    }

    private void preserveFormInputs(HttpServletRequest request, HttpSession session) {
        Map<String, String> map = new HashMap<>();
        map.put("doctor_exam_findings", nvl(request.getParameter("doctor_exam_findings")));
        map.put("procedure_eye", nvl(request.getParameter("procedure_eye")));
        map.put("procedure_outcome", nvl(request.getParameter("procedure_outcome")));
        map.put("post_care", nvl(request.getParameter("post_care")));
        map.put("conclusion", nvl(request.getParameter("conclusion")));
        session.setAttribute("tempProtocolData", map);
    }

    private String guessTargetEye(ProcedureOrder order) {
        if (order == null)
            return "OD";
        String diag = nvl(order.getClinicalDiagnosis()).toLowerCase();
        String sname = nvl(order.getServiceName()).toLowerCase();
        if (diag.contains("hai mắt") || diag.contains("(ou)") || sname.contains("hai mắt")) {
            return "OU";
        }
        if (diag.contains("mắt trái") || diag.contains("(os)") || sname.contains("mắt trái")
                || sname.contains("(os)")) {
            return "OS";
        }
        return "OD";
    }

    private String extractTag(String text, String tag, String defaultVal) {
        Pattern p = Pattern.compile("\\[" + tag + ":([^\\]]*)\\]");
        Matcher m = p.matcher(text);
        if (m.find()) {
            return m.group(1).trim();
        }
        return defaultVal;
    }

    private String extractBlock(String text, String blockName) {
        String open = "<" + blockName + ">";
        String close = "</" + blockName + ">";
        int start = text.indexOf(open);
        int end = text.indexOf(close);
        if (start != -1 && end != -1 && end > start) {
            return text.substring(start + open.length(), end).trim();
        }
        return "";
    }

    private String cleanDoctorExamText(String text) {
        if (text == null)
            return "";
        // Lược bỏ các tag đo đạc máy cũ [OD_UCVA:...] nếu có
        return text.replaceAll("\\[[A-Z0-9_]+:[^\\]]*\\]", "").trim();
    }

    private boolean isDefaultDoctorOrderNote(String note, ProcedureOrder order) {
        if (note == null || note.trim().isEmpty())
            return true;
        String lower = note.toLowerCase().trim();
        if (lower.startsWith("chỉ định") || lower.startsWith("chi dinh")
                || lower.startsWith("đủ điều kiện phẫu thuật")) {
            return true;
        }
        if (order != null && order.getServiceName() != null) {
            if (lower.contains(order.getServiceName().toLowerCase().trim())) {
                return true;
            }
        }
        return false;
    }

    private String replaceEyeTerms(String text) {
        if (text == null)
            return "";
        return text.replaceAll("(?i)\\bOD\\b:?", "Mắt phải:")
                .replaceAll("(?i)\\bOS\\b:?", "Mắt trái:")
                .replaceAll("(?i)\\bOU\\b:?", "Hai mắt:")
                .replaceAll("(?i)\\(OD\\)", "(Mắt phải)")
                .replaceAll("(?i)\\(OS\\)", "(Mắt trái)")
                .replaceAll("(?i)\\(OU\\)", "(Hai mắt)")
                .replace("Mắt phải::", "Mắt phải:")
                .replace("Mắt trái::", "Mắt trái:")
                .replace("Mắt phải: ", "Mắt phải: ")
                .replace("Mắt trái: ", "Mắt trái: ");
    }

    private String nvl(String s) {
        return (s != null) ? s.trim() : "";
    }
}
