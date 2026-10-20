package com.visioncare.util;

import com.visioncare.model.Appointment;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/** Clinic-local window for starting a scheduled examination. */
public final class ExaminationWindow {
    private static final int EARLY_START_APPOINTMENT_ID = 32;
    private static final LocalDate EARLY_START_DATE = LocalDate.of(2026, 10, 21);

    private ExaminationWindow() {}

    /** One-time early start exception for the checked-in appointment #32. */
    public static String startState(int appointmentId, LocalDate date, LocalTime time, LocalDateTime now) {
        if (appointmentId == EARLY_START_APPOINTMENT_ID && EARLY_START_DATE.equals(date)
                && now != null && EARLY_START_DATE.equals(now.toLocalDate())) {
            return "open";
        }
        return state(date, time, now);
    }

    public static String startState(Appointment appointment, LocalDateTime now) {
        if (appointment == null || appointment.getAppointmentDate() == null
                || appointment.getTimeSlot() == null) return "invalid";
        try {
            return startState(appointment.getId(), appointment.getAppointmentDate().toLocalDate(),
                    LocalTime.parse(appointment.getTimeSlot()), now);
        } catch (RuntimeException invalidTime) {
            return "invalid";
        }
    }

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

    public static String state(LocalDate date, LocalTime time, LocalDateTime now) {
        if (date == null || time == null || now == null) return "invalid";
        LocalDateTime scheduled = LocalDateTime.of(date, time);
        if (now.isBefore(scheduled.minusHours(1))) return "early";
        if (now.isAfter(scheduled.plusHours(1))) return "late";
        return "open";
    }
}
