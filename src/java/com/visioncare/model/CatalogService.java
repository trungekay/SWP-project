package com.visioncare.model;

import java.math.BigDecimal;

public class CatalogService {
    private final int id;
    private final String code;
    private final String name;
    private final BigDecimal price;
    private final String category;
    private final String summary;
    private final String description;
    private final boolean uploadedImage;

    public CatalogService(int id, String code, String name, BigDecimal price,
            String category, String summary, String description,
            boolean uploadedImage) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.price = price;
        this.category = category;
        this.summary = summary;
        this.description = description;
        this.uploadedImage = uploadedImage;
    }

    public int getId() { return id; }
    public String getCode() { return code; }
    public String getName() { return name; }
    public BigDecimal getPrice() { return price; }
    public String getCategory() { return category; }
    public String getCategoryName() { return category; }
    public String getSummary() { return summary; }
    public String getDescription() { return description; }
    public boolean isUploadedImage() { return uploadedImage; }

    public String getDefaultImagePath() {
        if (code != null) {
            String c = code.toUpperCase(java.util.Locale.ROOT);
            if (c.contains("NK") || c.contains("CVS")) return "departments-1.jpg";
            if (c.contains("KX")) return "departments-2.jpg";
            if (c.contains("LS") || c.contains("LASIK") || c.contains("SMILE")) return "departments-3.jpg";
            if (c.contains("PE")) return "departments-4.jpg";
            if (c.contains("TT") || c.contains("PHACO")) return "departments-5.jpg";
            if (c.contains("GL") || c.contains("DM") || c.contains("OCT")) return "gallery/gallery-1.jpg";
        }
        return "departments-1.jpg";
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
        if (isSurgery()) {
            return "Lưu ý quy trình: Bắt buộc khám tiền phẫu trước";
        } else if (isProcedure()) {
            return "Lưu ý quy trình: Bắt buộc khám lâm sàng với Bác sĩ trước";
        } else if (isPreOp()) {
            return "Đặc quyền: Hoàn trừ 100% phí khám vào chi phí mổ";
        }
        return "Quy trình thăm khám tiêu chuẩn";
    }

    public String getMedicalNoticeText() {
        if (isSurgery()) {
            return "Theo quy chuẩn y khoa, bệnh nhân bắt buộc phải thực hiện gói Khám tiền phẫu chuyên sâu trước để Bác sĩ đo các chỉ số sinh học mắt (bản đồ giác mạc, độ dày giác mạc, soi đáy mắt...) và kết luận chính xác mắt có đủ điều kiện phẫu thuật hay không. Sau khi có chỉ định chính thức từ Bác sĩ, bệnh viện mới xếp lịch phẫu thuật.";
        } else if (isProcedure()) {
            return "Để đảm bảo an toàn và vô trùng tuyệt đối, bệnh nhân không thể làm tiểu phẫu ngay mà bắt buộc phải qua bước Thăm khám lâm sàng trực tiếp với Bác sĩ chuyên khoa mắt trước. Bác sĩ sẽ dùng đèn sinh hiển vi đánh giá ổ viêm, giai đoạn bệnh và chỉ định thực hiện thủ thuật đúng quy trình y tế.";
        } else if (isPreOp()) {
            return "Gói khám chuyên sâu đánh giá toàn diện điều kiện mắt trước khi can thiệp phẫu thuật. Toàn bộ chi phí khám tiền phẫu sẽ được khấu trừ 100% vào chi phí ca mổ nếu quý khách tiến hành phẫu thuật tại VisionCare.";
        }
        return "Khám lâm sàng trực tiếp với Bác sĩ chuyên khoa giàu kinh nghiệm và hệ thống trang thiết bị nhãn khoa chuẩn quốc tế.";
    }
}

