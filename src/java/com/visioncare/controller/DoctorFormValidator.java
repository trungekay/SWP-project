package com.visioncare.controller;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** Server-side validation; browser constraints are only a convenience. */
public final class DoctorFormValidator {
    private static final Set<String> UNITS = Set.of("chai", "hộp", "viên", "tuýp", "lọ", "khác");
    private static final Set<String> LENS_TYPES = Set.of("", "distance", "near", "progressive", "other");

    private DoctorFormValidator() {}

    public static List<String> examination(Map<String, String> values) {
        List<String> errors = new ArrayList<>();
        required(values, "clinicalDiagnosis", "Chẩn đoán lâm sàng", 255, errors);
        required(values, "examinationResult", "Kết quả khám", 4000, errors);
        required(values, "conclusion", "Kết luận", 4000, errors);
        optional(values, "chiefComplaint", "Triệu chứng chính", 1000, errors);
        optional(values, "medicalHistory", "Tiền sử", 1000, errors);
        optional(values, "odUncorrected", "Thị lực không kính OD", 20, errors);
        optional(values, "osUncorrected", "Thị lực không kính OS", 20, errors);
        optional(values, "odCorrected", "Thị lực có kính OD", 20, errors);
        optional(values, "osCorrected", "Thị lực có kính OS", 20, errors);
        optional(values, "anteriorFindings", "Bán phần trước", 2000, errors);
        optional(values, "posteriorFindings", "Bán phần sau", 2000, errors);
        decimal(values, "odIop", "Nhãn áp OD", "0", "80", 1, errors);
        decimal(values, "osIop", "Nhãn áp OS", "0", "80", 1, errors);
        date(values, "followUpDate", "Ngày tái khám", errors);
        return errors;
    }

    public static List<String> prescription(Map<String, String> values,
            List<Map<String, String>> medicines, boolean includeMedication, boolean includeGlasses) {
        List<String> errors = new ArrayList<>();
        if (!includeMedication && !includeGlasses) {
            errors.add("Chọn thuốc hoặc kính để kê đơn.");
        }
        optional(values, "doctorNotes", "Lời dặn", 2000, errors);
        date(values, "followUpDate", "Ngày tái khám", errors);
        if (includeMedication) {
            if (medicines.isEmpty() || medicines.size() > 20) {
                errors.add("Đơn thuốc phải có từ 1 đến 20 dòng thuốc.");
            }
            for (int i = 0; i < medicines.size(); i++) {
                Map<String, String> row = medicines.get(i);
                String prefix = "Thuốc " + (i + 1) + ": ";
                required(row, "medicineName", prefix + "tên thuốc", 255, errors);
                int selectedDoses = 0;
                for (String[] session : new String[][]{{"morning", "morningDose", "sáng"},
                        {"afternoon", "afternoonDose", "chiều"}, {"evening", "eveningDose", "tối"}}) {
                    String selected = row.getOrDefault(session[0], "");
                    if (!selected.isBlank() && !"true".equals(selected)) {
                        errors.add(prefix + "buổi " + session[2] + " không hợp lệ.");
                    } else if ("true".equals(selected)) {
                        selectedDoses++;
                        required(row, session[1], prefix + "liều buổi " + session[2], 100, errors);
                    }
                }
                if (selectedDoses == 0) errors.add(prefix + "chọn ít nhất một buổi dùng thuốc.");
                optional(row, "strength", prefix + "hàm lượng", 100, errors);
                optional(row, "duration", prefix + "thời gian", 100, errors);
                optional(row, "instructions", prefix + "hướng dẫn", 255, errors);
                String qty = row.getOrDefault("quantity", "");
                try {
                    int quantity = Integer.parseInt(qty);
                    if (quantity < 1 || quantity > 999) throw new NumberFormatException();
                } catch (NumberFormatException invalid) {
                    errors.add(prefix + "số lượng phải từ 1 đến 999.");
                }
                if (!UNITS.contains(row.getOrDefault("unit", ""))) {
                    errors.add(prefix + "đơn vị không hợp lệ.");
                }
            }
        }
        if (includeGlasses) {
            steppedDecimal(values, "odSph", "SPH mắt phải", "-30", "30", "0.25", errors);
            steppedDecimal(values, "osSph", "SPH mắt trái", "-30", "30", "0.25", errors);
            steppedDecimal(values, "odCyl", "CYL mắt phải", "-15", "15", "0.25", errors);
            steppedDecimal(values, "osCyl", "CYL mắt trái", "-15", "15", "0.25", errors);
            steppedDecimal(values, "odAdd", "ADD mắt phải", "0", "6", "0.25", errors);
            steppedDecimal(values, "osAdd", "ADD mắt trái", "0", "6", "0.25", errors);
            steppedDecimal(values, "pd", "PD", "40", "80", "0.5", errors);
            axis(values, "odAxis", "AXIS mắt phải", errors);
            axis(values, "osAxis", "AXIS mắt trái", errors);
            optional(values, "glassesNotes", "Ghi chú về kính", 1000, errors);
            if (!LENS_TYPES.contains(values.getOrDefault("lensType", ""))) {
                errors.add("Loại kính không hợp lệ.");
            }
            boolean hasPower = false;
            for (String key : new String[]{"odSph", "odCyl", "odAxis", "odAdd",
                    "osSph", "osCyl", "osAxis", "osAdd"}) {
                hasPower |= !values.getOrDefault(key, "").isBlank();
            }
            if (!hasPower) errors.add("Nhập ít nhất một thông số độ kính.");
        }
        return errors;
    }

    private static void required(Map<String, String> values, String key, String label, int max, List<String> errors) {
        String value = values.getOrDefault(key, "");
        if (value.isBlank()) errors.add(label + " không được để trống.");
        else if (value.length() > max) errors.add(label + " vượt quá " + max + " ký tự.");
    }

    private static void optional(Map<String, String> values, String key, String label, int max, List<String> errors) {
        if (values.getOrDefault(key, "").length() > max) {
            errors.add(label + " vượt quá " + max + " ký tự.");
        }
    }

    private static void decimal(Map<String, String> values, String key, String label,
            String min, String max, int scale, List<String> errors) {
        String raw = values.getOrDefault(key, "");
        if (raw.isBlank()) return;
        try {
            BigDecimal number = new BigDecimal(raw);
            if (number.compareTo(new BigDecimal(min)) < 0
                    || number.compareTo(new BigDecimal(max)) > 0
                    || number.scale() > scale) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException invalid) {
            errors.add(label + " không hợp lệ.");
        }
    }

    private static void steppedDecimal(Map<String, String> values, String key, String label,
            String min, String max, String step, List<String> errors) {
        String raw = values.getOrDefault(key, "");
        if (raw.isBlank()) return;
        try {
            BigDecimal number = new BigDecimal(raw);
            if (number.compareTo(new BigDecimal(min)) < 0
                    || number.compareTo(new BigDecimal(max)) > 0
                    || number.remainder(new BigDecimal(step)).compareTo(BigDecimal.ZERO) != 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException invalid) {
            errors.add(label + " không hợp lệ hoặc sai bước " + step + ".");
        }
    }

    private static void axis(Map<String, String> values, String key, String label, List<String> errors) {
        String raw = values.getOrDefault(key, "");
        if (raw.isBlank()) return;
        try {
            int axis = Integer.parseInt(raw);
            if (axis < 0 || axis > 180) throw new NumberFormatException();
        } catch (NumberFormatException invalid) {
            errors.add(label + " phải là số nguyên từ 0 đến 180.");
        }
    }

    private static void date(Map<String, String> values, String key, String label, List<String> errors) {
        String raw = values.getOrDefault(key, "");
        if (raw.isBlank()) return;
        try {
            LocalDate.parse(raw);
        } catch (DateTimeParseException invalid) {
            errors.add(label + " không hợp lệ.");
        }
    }
}
