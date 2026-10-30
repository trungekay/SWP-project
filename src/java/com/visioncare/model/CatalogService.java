package com.visioncare.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class CatalogService {
    private final int id;
    private final String code;
    private final String name;
    private final BigDecimal price;
    private final String category;
    private final String summary;
    private final String description;
    private final String imagePath;
    private final boolean uploadedImage;

    // Configurable Workflow & Booking properties
    private boolean requiresPreOp;
    private Integer prerequisiteServiceId;
    private String prerequisiteServiceName;
    private BigDecimal prerequisiteServicePrice;
    private boolean allowDirectBooking = true;
    private List<ServiceWorkflowStep> workflowSteps = new ArrayList<>();

    public CatalogService(int id, String code, String name, BigDecimal price,
            String category, String summary, String description,
            String imagePath, boolean uploadedImage,
            boolean requiresPreOp, Integer prerequisiteServiceId,
            String prerequisiteServiceName, boolean allowDirectBooking) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.price = price;
        this.category = category;
        this.summary = summary;
        this.description = description;
        this.imagePath = imagePath;
        this.uploadedImage = uploadedImage;
        this.requiresPreOp = requiresPreOp;
        this.prerequisiteServiceId = prerequisiteServiceId;
        this.prerequisiteServiceName = prerequisiteServiceName;
        this.allowDirectBooking = allowDirectBooking;
    }

    public CatalogService(int id, String code, String name, BigDecimal price,
            String category, String summary, String description,
            String imagePath, boolean uploadedImage) {
        this(id, code, name, price, category, summary, description, imagePath, uploadedImage, false, null, null, true);
    }

    public CatalogService(int id, String code, String name, BigDecimal price,
            String category, String summary, String description,
            boolean uploadedImage) {
        this(id, code, name, price, category, summary, description, null, uploadedImage);
    }

    public int getId() { return id; }
    public String getCode() { return code; }
    public String getName() { return name; }
    public BigDecimal getPrice() { return price; }
    public String getCategory() { return category; }
    public String getCategoryName() { return category; }
    public String getSummary() { return summary; }
    public String getDescription() { return description; }
    public String getImagePath() { return imagePath; }
    public boolean isUploadedImage() { return uploadedImage; }

    public boolean isRequiresPreOp() { return requiresPreOp; }
    public void setRequiresPreOp(boolean requiresPreOp) { this.requiresPreOp = requiresPreOp; }

    public Integer getPrerequisiteServiceId() { return prerequisiteServiceId; }
    public void setPrerequisiteServiceId(Integer prerequisiteServiceId) { this.prerequisiteServiceId = prerequisiteServiceId; }

    public String getPrerequisiteServiceName() { return prerequisiteServiceName; }
    public void setPrerequisiteServiceName(String prerequisiteServiceName) { this.prerequisiteServiceName = prerequisiteServiceName; }

    public BigDecimal getPrerequisiteServicePrice() { return prerequisiteServicePrice; }
    public void setPrerequisiteServicePrice(BigDecimal prerequisiteServicePrice) { this.prerequisiteServicePrice = prerequisiteServicePrice; }

    public long getOnlineDepositFee() {
        long total = price != null ? price.longValue() : 200000;
        if (requiresPreOp || total > 2000000) {
            long preOpDeposit = 500000;
            if (prerequisiteServicePrice != null && prerequisiteServicePrice.longValue() > 0) {
                preOpDeposit = prerequisiteServicePrice.longValue();
            }
            return (total > preOpDeposit) ? preOpDeposit : total;
        }
        return total > 0 ? total : 200000;
    }

    public long getOnlineBalanceDue() {
        long total = price != null ? price.longValue() : 200000;
        long fee = getOnlineDepositFee();
        return (total > fee) ? (total - fee) : 0;
    }

    public boolean isAllowDirectBooking() { return allowDirectBooking; }
    public void setAllowDirectBooking(boolean allowDirectBooking) { this.allowDirectBooking = allowDirectBooking; }

    public List<ServiceWorkflowStep> getWorkflowSteps() { return workflowSteps; }
    public void setWorkflowSteps(List<ServiceWorkflowStep> workflowSteps) {
        this.workflowSteps = workflowSteps != null ? workflowSteps : new ArrayList<>();
    }

    public boolean hasWorkflowSteps() {
        return workflowSteps != null && !workflowSteps.isEmpty();
    }

    public List<ServiceWorkflowStep> getPreExamSteps() {
        List<ServiceWorkflowStep> list = new ArrayList<>();
        if (workflowSteps != null) {
            for (ServiceWorkflowStep step : workflowSteps) {
                if ("PRE_EXAM".equalsIgnoreCase(step.getStepStage())) {
                    list.add(step);
                }
            }
        }
        return list;
    }

    public List<ServiceWorkflowStep> getInExamSteps() {
        List<ServiceWorkflowStep> list = new ArrayList<>();
        if (workflowSteps != null) {
            for (ServiceWorkflowStep step : workflowSteps) {
                if ("IN_EXAM".equalsIgnoreCase(step.getStepStage())) {
                    list.add(step);
                }
            }
        }
        return list;
    }

    public List<ServiceWorkflowStep> getPostExamSteps() {
        List<ServiceWorkflowStep> list = new ArrayList<>();
        if (workflowSteps != null) {
            for (ServiceWorkflowStep step : workflowSteps) {
                if ("POST_EXAM".equalsIgnoreCase(step.getStepStage())) {
                    list.add(step);
                }
            }
        }
        return list;
    }

    public String getDefaultImagePath() {
        if (imagePath != null && !imagePath.trim().isEmpty()) {
            return imagePath.trim();
        }
        if (code != null) {
            String c = code.toUpperCase(java.util.Locale.ROOT).trim();
            // 1. Khám tổng quát & Soi đáy mắt
            if (c.equals("NK-01") || c.startsWith("NK")) return "services/service-general.jpg";
            // 2. Đo khúc xạ và tư vấn kính
            if (c.equals("KX-02")) return "services/service-refraction.jpg";
            // 3. Khám tiền phẫu LASIK/SMILE
            if (c.equals("LS-03") || c.startsWith("LS")) return "services/service-lasik-consult.jpg";
            // 4. Khám mắt trẻ em và nhược thị
            if (c.equals("PE-04") || c.startsWith("PE")) return "services/service-pediatric.jpg";
            // 5. Khám tầm soát & Tư vấn phẫu thuật Phaco
            if (c.equals("TT-05") || c.startsWith("TT")) return "departments-5.jpg";
            // 6. Đo nhãn áp & Tầm soát Glaucoma
            if (c.equals("GL-06") || c.startsWith("GL")) return "services/service-glaucoma.jpg";
            // 7. Đo khúc xạ máy
            if (c.contains("KX-MAY") || c.contains("MAY")) return "services/service-autorefraction.jpg";
            // 8. Chụp OCT đáy mắt
            if (c.contains("OCT")) return "services/service-retina.jpg";
            // 9. Khám & Điều trị Khô mắt
            if (c.contains("CVS")) return "services/service-dry-eye.jpg";
            // 10. Khám đáy mắt - võng mạc tiểu đường
            if (c.contains("KM-DM") || (c.contains("KM") && c.contains("DM"))) return "services/service-fundus.jpg";
            // 11. Phẫu thuật Femto-LASIK
            if (c.contains("LASIK")) return "services/service-lasik.jpg";
            // 12. Phẫu thuật ReLEx SMILE
            if (c.contains("SMILE")) return "gallery/gallery-1.jpg";
            // 13. Phẫu thuật Phaco đục thủy tinh thể
            if (c.contains("PHACO")) return "services/service-cataract.jpg";
            // 14. Chích rạch chắp lẹo
            if (c.contains("LEO")) return "gallery/gallery-6.jpg";
            // 15. Bơm thông rửa lệ đạo
            if (c.contains("LEDAO")) return "gallery/gallery-8.jpg";
            // 16. Bắn Laser YAG
            if (c.contains("YAG")) return "services/service-procedure.jpg";
            // Fallback according to category/code patterns
            if (c.contains("KX")) return "services/service-refraction.jpg";
        }
        if (name != null) {
            String n = name.toLowerCase(java.util.Locale.ROOT);
            if (n.contains("tiền phẫu") || (n.contains("tư vấn") && n.contains("cận"))) return "services/service-lasik-consult.jpg";
            if (n.contains("khúc xạ máy") || n.contains("máy đo")) return "services/service-autorefraction.jpg";
            if (n.contains("khúc xạ") || n.contains("kính")) return "services/service-refraction.jpg";
            if (n.contains("smile")) return "gallery/gallery-1.jpg";
            if (n.contains("lasik") || n.contains("xóa cận")) return "services/service-lasik.jpg";
            if (n.contains("trẻ em") || n.contains("nhược thị")) return "services/service-pediatric.jpg";
            if (n.contains("tầm soát") && n.contains("phaco")) return "departments-5.jpg";
            if (n.contains("thủy tinh thể") || n.contains("phaco")) return "services/service-cataract.jpg";
            if (n.contains("khô mắt") || n.contains("màn hình")) return "services/service-dry-eye.jpg";
            if (n.contains("tiểu đường") || n.contains("võng mạc")) return "services/service-fundus.jpg";
            if (n.contains("glaucoma") || n.contains("nhãn áp")) return "services/service-glaucoma.jpg";
            if (n.contains("oct")) return "services/service-retina.jpg";
            if (n.contains("lẹo")) return "gallery/gallery-6.jpg";
            if (n.contains("lệ đạo")) return "gallery/gallery-8.jpg";
            if (n.contains("yag") || n.contains("laser")) return "services/service-procedure.jpg";
        }
        return "services/service-general.jpg";
    }

    public String getSpecialty() {
        if (code != null) {
            String c = code.toUpperCase(java.util.Locale.ROOT);
            if (c.contains("NK") || c.contains("CVS") || c.startsWith("TP-")) return "general";
            if (c.contains("KX")) return "refraction";
            if (c.contains("LS") || c.contains("LASIK") || c.contains("SMILE")) return "lasik";
            if (c.contains("PE")) return "children";
            if (c.contains("TT") || c.contains("PHACO")) return "cataract";
            if (c.contains("GL") || c.contains("DM") || c.contains("OCT")) return "retina";
        }
        if (name != null) {
            String n = name.toLowerCase(java.util.Locale.ROOT);
            if (n.contains("khúc xạ") || n.contains("kính")) return "refraction";
            if (n.contains("lasik") || n.contains("smile") || n.contains("xóa cận")) return "lasik";
            if (n.contains("trẻ em") || n.contains("nhược thị")) return "children";
            if (n.contains("thủy tinh thể") || n.contains("phaco")) return "cataract";
            if (n.contains("glaucoma") || n.contains("võng mạc") || n.contains("đáy mắt") || n.contains("nhãn áp")) return "retina";
            if (n.contains("tổng quát") || n.contains("khô mắt") || n.contains("thủ thuật") || n.contains("tiểu phẫu") || n.contains("lẹo") || n.contains("lệ đạo") || n.contains("yag")) return "general";
        }
        if (category != null && category.toLowerCase(java.util.Locale.ROOT).contains("thủ thuật")) {
            return "general";
        }
        return "general";
    }

    public String getTag() {
        return category != null ? category : "";
    }

    public boolean isSurgery() {
        if (requiresPreOp) return true;
        if (category != null && category.contains("thủ thuật")) {
            if (!allowDirectBooking) return true;
        }
        if (code != null) {
            String c = code.toUpperCase(java.util.Locale.ROOT);
            if (c.startsWith("PT-") || c.contains("LASIK") || c.contains("SMILE") || c.contains("PHACO")) {
                return true;
            }
        }
        if (name != null) {
            String n = name.toLowerCase(java.util.Locale.ROOT);
            return n.contains("phẫu thuật") || n.contains("femto") || n.contains("relex");
        }
        return false;
    }

    public boolean isProcedure() {
        if (code != null) {
            String c = code.toUpperCase(java.util.Locale.ROOT);
            if (c.startsWith("TP-") || c.equals("TP-LEO") || c.equals("TP-LEDAO") || c.equals("TP-YAG")) {
                return true;
            }
        }
        if (category != null && category.toLowerCase(java.util.Locale.ROOT).contains("thủ thuật")) {
            return !isSurgery();
        }
        if (name != null) {
            String n = name.toLowerCase(java.util.Locale.ROOT);
            return n.contains("thủ thuật") || n.contains("tiểu phẫu") || n.contains("chích") || n.contains("bơm thông") || n.contains("yag");
        }
        return false;
    }

    public boolean isPreOp() {
        if (code != null) {
            String c = code.toUpperCase(java.util.Locale.ROOT);
            if (c.equals("LS-03") || c.equals("TT-05")) return true;
        }
        if (name != null) {
            String n = name.toLowerCase(java.util.Locale.ROOT);
            return n.contains("tiền phẫu") || n.contains("tầm soát");
        }
        return false;
    }

    public String getMedicalNoticeTitle() {
        if (requiresPreOp || isSurgery()) {
            return "Lưu ý quy trình: Bắt buộc khám tiền phẫu trước";
        } else if (isProcedure()) {
            return "Lưu ý quy trình: Bắt buộc khám lâm sàng với Bác sĩ trước";
        } else if (isPreOp()) {
            return "Đặc quyền: Hoàn trừ 100% phí khám vào chi phí mổ";
        }
        return "Quy trình thăm khám tiêu chuẩn";
    }

    public String getMedicalNoticeText() {
        if (requiresPreOp || isSurgery()) {
            String preOpName = prerequisiteServiceName != null && !prerequisiteServiceName.isEmpty()
                    ? prerequisiteServiceName : "Khám tiền phẫu chuyên sâu";
            return "Theo quy chuẩn y khoa, bệnh nhân bắt buộc phải thực hiện gói " + preOpName + " trước để Bác sĩ đo các chỉ số sinh học mắt (bản đồ giác mạc, độ dày giác mạc, soi đáy mắt...) và kết luận chính xác mắt có đủ điều kiện can thiệp hay không. Sau khi có chỉ định chính thức từ Bác sĩ, bệnh viện mới xếp lịch phẫu thuật.";
        } else if (isProcedure()) {
            return "Để đảm bảo an toàn và vô trùng tuyệt đối, bệnh nhân không thể làm tiểu phẫu ngay mà bắt buộc phải qua bước Thăm khám lâm sàng trực tiếp với Bác sĩ chuyên khoa mắt trước. Bác sĩ sẽ dùng đèn sinh hiển vi đánh giá ổ viêm, giai đoạn bệnh và chỉ định thực hiện thủ thuật đúng quy trình y tế.";
        } else if (isPreOp()) {
            return "Gói khám chuyên sâu đánh giá toàn diện điều kiện mắt trước khi can thiệp phẫu thuật. Toàn bộ chi phí khám tiền phẫu sẽ được khấu trừ 100% vào chi phí ca mổ nếu quý khách tiến hành phẫu thuật tại VisionCare.";
        }
        return "Khám lâm sàng trực tiếp với Bác sĩ chuyên khoa giàu kinh nghiệm và hệ thống trang thiết bị nhãn khoa chuẩn quốc tế.";
    }
}
