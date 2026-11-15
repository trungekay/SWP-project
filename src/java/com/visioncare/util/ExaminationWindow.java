package com.visioncare.util;

import com.visioncare.model.Appointment;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/** Clinic-local window for starting a scheduled examination. */
public final class ExaminationWindow {
    private ExaminationWindow() {}

    /** Return the appointment window state so the UI can determine whether the examination can begin. */
    public static String startState(Appointment appointment, LocalDateTime now) {
        return state(appointment, now);
    }

    /** Read the appointment date and time; mark missing or invalid values as invalid. */
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

    /** Classify the appointment as early, on time, or late using a one-hour window. */
    public static String state(LocalDate date, LocalTime time, LocalDateTime now) {
        if (date == null || time == null || now == null) return "invalid";
        LocalDateTime scheduled = LocalDateTime.of(date, time);
        if (now.isBefore(scheduled.minusHours(1))) return "early";
        if (now.isAfter(scheduled.plusHours(1))) return "late";
        return "open";
    }
}
