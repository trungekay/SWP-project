package com.visioncare.util;

import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class PayOSUtil {

    private static String CLIENT_ID = "";
    private static String API_KEY = "";
    private static String CHECKSUM_KEY = "";
    private static String ENDPOINT = "https://api-merchant.payos.vn";

    static {
        loadConfig();
    }

    public static synchronized void loadConfig() {
        try (InputStream is = PayOSUtil.class.getClassLoader().getResourceAsStream("payos.properties")) {
            if (is != null) {
                Properties props = new Properties();
                props.load(is);
                CLIENT_ID = props.getProperty("payos.client_id", "").trim();
                API_KEY = props.getProperty("payos.api_key", "").trim();
                CHECKSUM_KEY = props.getProperty("payos.checksum_key", "").trim();
                ENDPOINT = props.getProperty("payos.endpoint", "https://api-merchant.payos.vn").trim();
            }
        } catch (Exception e) {
            System.err.println("Không thể đọc file payos.properties: " + e.getMessage());
        }
    }

    public static String getClientId() {
        return CLIENT_ID;
    }

    public static String getApiKey() {
        return API_KEY;
    }

    public static String getChecksumKey() {
        return CHECKSUM_KEY;
    }

    public static void updateKeys(String clientId, String apiKey, String checksumKey) {
        if (clientId != null && !clientId.isEmpty()) CLIENT_ID = clientId.trim();
        if (apiKey != null && !apiKey.isEmpty()) API_KEY = apiKey.trim();
        if (checksumKey != null && !checksumKey.isEmpty()) CHECKSUM_KEY = checksumKey.trim();
    }

    public static String hmacSHA256(String data, String key) {
        try {
            Mac sha256_HMAC = Mac.getInstance("HmacSHA256");
            SecretKeySpec secret_key = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            sha256_HMAC.init(secret_key);
            byte[] bytes = sha256_HMAC.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Lỗi sinh chữ ký HMAC-SHA256: " + e.getMessage(), e);
        }
    }

    public static class PaymentLinkResult {
        public boolean success;
        public String checkoutUrl;
        public String qrCode;
        public String paymentLinkId;
        public String status;
        public String errorMsg;
        public long orderCode;
    }

    /**
     * Tạo liên kết thanh toán và mã QR qua cổng PayOS
     */
    public static PaymentLinkResult createPaymentLink(long orderCode, int amount, String description, String cancelUrl, String returnUrl) {
        PaymentLinkResult result = new PaymentLinkResult();
        result.orderCode = orderCode;

        if (CLIENT_ID.isEmpty() || API_KEY.isEmpty() || CHECKSUM_KEY.isEmpty()) {
            result.success = false;
            result.errorMsg = "PayOS chưa được cấu hình đầy đủ Client ID, API Key hoặc Checksum Key.";
            return result;
        }

        try {
            // Chuỗi dữ liệu sắp xếp theo alphabet a-z theo chuẩn PayOS
            String signData = "amount=" + amount
                    + "&cancelUrl=" + cancelUrl
                    + "&description=" + description
                    + "&orderCode=" + orderCode
                    + "&returnUrl=" + returnUrl;

            String signature = hmacSHA256(signData, CHECKSUM_KEY);

            String jsonBody = "{"
                    + "\"orderCode\":" + orderCode + ","
                    + "\"amount\":" + amount + ","
                    + "\"description\":\"" + escapeJson(description) + "\","
                    + "\"cancelUrl\":\"" + escapeJson(cancelUrl) + "\","
                    + "\"returnUrl\":\"" + escapeJson(returnUrl) + "\","
                    + "\"signature\":\"" + signature + "\""
                    + "}";

            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(10))
                    .build();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(ENDPOINT + "/v2/payment-requests"))
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .header("x-client-id", CLIENT_ID)
                    .header("x-api-key", API_KEY)
                    .timeout(Duration.ofSeconds(15))
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            String respBody = response.body();

            String code = extractJsonField(respBody, "code");
            if ("00".equals(code)) {
                result.success = true;
                result.checkoutUrl = extractJsonField(respBody, "checkoutUrl");
                result.qrCode = extractJsonField(respBody, "qrCode");
                result.paymentLinkId = extractJsonField(respBody, "paymentLinkId");
                result.status = extractJsonField(respBody, "status");
            } else if ("231".equals(code)) {
                // Đơn hàng đã tồn tại trên PayOS: Truy vấn lại thông tin đơn hàng hiện tại
                try {
                    HttpRequest getReq = HttpRequest.newBuilder()
                            .uri(URI.create(ENDPOINT + "/v2/payment-requests/" + orderCode))
                            .header("x-client-id", CLIENT_ID)
                            .header("x-api-key", API_KEY)
                            .timeout(Duration.ofSeconds(6))
                            .GET()
                            .build();
                    HttpResponse<String> getRes = client.send(getReq, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
                    String getBody = getRes.body();
                    String getCode = extractJsonField(getBody, "code");
                    if ("00".equals(getCode)) {
                        result.success = true;
                        result.paymentLinkId = extractJsonField(getBody, "id");
                        result.status = extractJsonField(getBody, "status");
                        result.checkoutUrl = "https://pay.payos.vn/web/" + result.paymentLinkId;
                        result.qrCode = extractJsonField(getBody, "qrCode");
                    } else {
                        result.success = false;
                        result.errorMsg = extractJsonField(respBody, "desc");
                    }
                } catch (Exception ex) {
                    result.success = false;
                    result.errorMsg = extractJsonField(respBody, "desc");
                }
            } else {
                result.success = false;
                String desc = extractJsonField(respBody, "desc");
                result.errorMsg = (desc != null && !desc.isEmpty()) ? desc : ("Mã lỗi: " + code);
            }
        } catch (Exception e) {
            result.success = false;
            result.errorMsg = "Lỗi kết nối PayOS: " + e.getMessage();
            e.printStackTrace();
        }

        return result;
    }

    /**
     * Kiểm tra trạng thái thanh toán trực tiếp từ PayOS Server theo mã orderCode
     */
    public static String getPaymentStatus(long orderCode) {
        if (CLIENT_ID.isEmpty() || API_KEY.isEmpty()) {
            return "UNKNOWN";
        }
        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(6))
                    .build();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(ENDPOINT + "/v2/payment-requests/" + orderCode))
                    .header("x-client-id", CLIENT_ID)
                    .header("x-api-key", API_KEY)
                    .timeout(Duration.ofSeconds(10))
                    .GET()
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            String respBody = response.body();
            String code = extractJsonField(respBody, "code");
            if ("00".equals(code)) {
                return extractJsonField(respBody, "status"); // "PAID", "PENDING", "CANCELLED"
            }
        } catch (Exception e) {
            System.err.println("Lỗi kiểm tra trạng thái PayOS orderCode " + orderCode + ": " + e.getMessage());
        }
        return "UNKNOWN";
    }

    public static class VerifiedReceipt {
        public String status = "UNKNOWN";
        public long orderCode, amount, amountPaid;
    }

    /** Read receipt only from the configured PayOS server; never trust browser return parameters. */
    public static VerifiedReceipt getVerifiedReceipt(long orderCode) {
        VerifiedReceipt result = new VerifiedReceipt();
        if (CLIENT_ID.isEmpty() || API_KEY.isEmpty()) return result;
        try {
            HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(6)).build();
            HttpRequest request = HttpRequest.newBuilder().uri(URI.create(ENDPOINT + "/v2/payment-requests/" + orderCode))
                    .header("x-client-id", CLIENT_ID).header("x-api-key", API_KEY).timeout(Duration.ofSeconds(10)).GET().build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            String json = response.body();
            if (response.statusCode() != 200 || !"00".equals(extractJsonField(json, "code"))) return result;
            result.orderCode = Long.parseLong(extractJsonField(json, "orderCode"));
            result.amount = Long.parseLong(extractJsonField(json, "amount"));
            String paid = extractJsonField(json, "amountPaid");
            result.amountPaid = paid == null ? 0 : Long.parseLong(paid);
            if (result.orderCode == orderCode) result.status = extractJsonField(json, "status");
        } catch (Exception e) { System.err.println("Không xác minh được biên nhận checkout PayOS."); }
        return result;
    }

    private static String escapeJson(String raw) {
        if (raw == null) return "";
        return raw.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    public static String extractJsonField(String json, String field) {
        if (json == null) return null;
        Pattern pattern = Pattern.compile("\"" + field + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        Pattern numPattern = Pattern.compile("\"" + field + "\"\\s*:\\s*([0-9]+)");
        Matcher numMatcher = numPattern.matcher(json);
        if (numMatcher.find()) {
            return numMatcher.group(1);
        }
        return null;
    }
}
