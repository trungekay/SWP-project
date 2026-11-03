package com.visioncare.util;

import java.security.SecureRandom;
import java.util.Base64;
import java.util.concurrent.ConcurrentHashMap;

/** Short-lived, read-only display grants. Restarting the application invalidates them. */
public final class WalkinPaymentDisplay {
    private static final ConcurrentHashMap<String, Grant> GRANTS = new ConcurrentHashMap<>();
    private static final SecureRandom RANDOM = new SecureRandom();
    private WalkinPaymentDisplay() {}

    public static final class Grant {
        public final int appointmentId;
        public final String qrUrl, amount, description;
        public final long startedAt;
        public volatile long orderCode;
        public String getQrUrl() { return qrUrl; }
        public String getAmount() { return amount; }
        public String getDescription() { return description; }
        public long getHoldSeconds() { return com.visioncare.dao.TimeSlotDAO.getPendingHoldMinutes() * 60L; }
        public long getExpiresAt() { return startedAt + getHoldSeconds() * 1000L; }
        private Grant(int appointmentId, String qrUrl, String amount, String description) {
            this.appointmentId = appointmentId;
            this.qrUrl = qrUrl;
            this.amount = amount;
            this.description = description;
            long created = System.currentTimeMillis();
            try {
                com.visioncare.model.Appointment appointment = new com.visioncare.dao.AppointmentDAO().getAppointmentDetailById(appointmentId);
                if (appointment != null && appointment.getCreatedAt() != null)
                    created = java.sql.Timestamp.valueOf(appointment.getCreatedAt()).toLocalDateTime()
                            .atZone(java.time.ZoneId.of("Asia/Ho_Chi_Minh")).toInstant().toEpochMilli();
            } catch (Exception ignored) { /* Keep creation time if the stored timestamp is unavailable. */ }
            this.startedAt = created;
        }
    }

    public static String create(int appointmentId, String qrUrl, String amount, String description) {
        GRANTS.entrySet().removeIf(e -> e.getValue().startedAt + 172_800_000L <= System.currentTimeMillis());
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        GRANTS.put(token, new Grant(appointmentId, qrUrl, amount, description));
        return token;
    }

    public static Grant get(String token) {
        if (token == null) return null;
        Grant grant = GRANTS.get(token);
        if (grant != null && grant.getExpiresAt() <= System.currentTimeMillis()) {
            return null;
        }
        return grant;
    }

    public static long orderCodeFor(int appointmentId) {
        for (Grant grant : GRANTS.values()) {
            if (grant.appointmentId == appointmentId) return grant.orderCode;
        }
        return 0;
    }
}
