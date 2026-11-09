package com.visioncare.util;

import com.visioncare.model.Appointment;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/** Clinic-local window for starting a scheduled examination. */
public final class ExaminationWindow {
    private ExaminationWindow() {}

    /** Trả trạng thái khung giờ để giao diện quyết định có thể bắt đầu khám. */
    public static String startState(Appointment appointment, LocalDateTime now) {
        return state(appointment, now);
    }

    /** Đọc ngày giờ hẹn từ ca khám; dữ liệu thiếu hoặc sai được đánh dấu invalid. */
    public static String state(Appointment appointment, LocalDateTime now) {
        if (appointment == null || appointment.getAppointmentDate() == null
                || appointment.getTimeSlot() == null) return "invalid";
        try {
            return state(appointment.getAppointmentDate().toLocalDate(),
                    LocalTime.parse(appointment.getTimeSlot()), now);
        } catch (RuntimeException invalidTime) {
            return "invalid";
        }
    }

    /** Phân loại sớm, đúng giờ hoặc trễ theo cửa sổ một giờ quanh giờ hẹn. */
    public static String state(LocalDate date, LocalTime time, LocalDateTime now) {
        if (date == null || time == null || now == null) return "invalid";
        LocalDateTime scheduled = LocalDateTime.of(date, time);
        if (now.isBefore(scheduled.minusHours(1))) return "early";
        if (now.isAfter(scheduled.plusHours(1))) return "late";
        return "open";
    }
}
