import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

public class FixRefund {
    public static void main(String[] args) {
        try {
            // Fix appointment-history.jsp
            String apptFile = "e:/Github/SWP-project/web/views/profile/appointment-history.jsp";
            String apptContent = new String(Files.readAllBytes(Paths.get(apptFile)), "UTF-8");
            
            // Replace the table structure
            apptContent = apptContent.replace("<div class=\"table-responsive mb-5\">\r\n                <table class=\"table table-borderless table-striped align-middle\">", "<div class=\"content-card mb-5\">\r\n                <div class=\"table-responsive\">\r\n                  <table class=\"custom-table\">");
            apptContent = apptContent.replace("<div class=\"table-responsive mb-5\">\n                <table class=\"table table-borderless table-striped align-middle\">", "<div class=\"content-card mb-5\">\n                <div class=\"table-responsive\">\n                  <table class=\"custom-table\">");
            
            // Close the extra div
            apptContent = apptContent.replace("</table>\r\n              </div>", "</table>\r\n                </div>\r\n              </div>");
            apptContent = apptContent.replace("</table>\n              </div>", "</table>\n                </div>\n              </div>");
            
            // Replace the badges
            apptContent = apptContent.replace("<span class=\"badge-warning-custom\">", "<span class=\"badge-status\" style=\"background: #fef3c7; color: #b45309;\">");
            apptContent = apptContent.replace("<span class=\"badge-success-custom\">", "<span class=\"badge-status status-active\">");
            apptContent = apptContent.replace("<span class=\"badge-danger-custom\">", "<span class=\"badge-status\" style=\"background: #fee2e2; color: #b91c1c;\">");
            
            Files.write(Paths.get(apptFile), apptContent.getBytes("UTF-8"));
            System.out.println("Fixed appointment-history.jsp table and badges");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
