import com.visioncare.dao.DBContext;
import com.visioncare.dao.TimeSlotDAO;
import com.visioncare.model.TimeSlotConfig;
import java.sql.*;
import java.nio.file.*;

/** Run against the local migrated test database. Restores configuration in finally. */
public class TimeSlotConfigIntegration {
    interface Action { void run() throws Exception; }
    static void reject(Action action) throws Exception {
        try { action.run(); } catch (IllegalArgumentException expected) { return; }
        throw new AssertionError("Invalid configuration was accepted");
    }
    static int scalar(Connection c, String sql) throws Exception {
        try (Statement s=c.createStatement(); ResultSet r=s.executeQuery(sql)) { r.next(); return r.getInt(1); }
    }
    public static void main(String[] args) throws Exception {
        TimeSlotDAO dao=new TimeSlotDAO();
        var slots=dao.getConfiguredSlots();
        if(slots.size()<2) throw new AssertionError("Need seeded configurations");
        TimeSlotConfig first=slots.get(0), second=slots.get(1);
        String renamed="Integration test "+System.nanoTime();
        try(Connection c=DBContext.getConnection()) {
            int before=scalar(c,"SELECT COUNT(*) FROM Work_Schedule");
            try {
                reject(()->dao.updateTimeSlotConfig(first.getSlotId(),second.getSlotName(),first.getStartTime(),first.getEndTime(),"Available"));
                reject(()->dao.addTimeSlot(renamed,first.getStartTime(),first.getEndTime()));
                reject(()->dao.addTimeSlot(renamed,"22:00","22:45"));
                dao.updateTimeSlotConfig(first.getSlotId(),renamed,first.getStartTime(),first.getEndTime(),"Canceled");
                var changed=dao.getConfiguredSlots().stream().filter(x->x.getSlotId()==first.getSlotId()).findFirst().orElseThrow();
                if(!changed.getSlotName().equals(renamed) || !changed.getStatus().equals("Canceled"))
                    throw new AssertionError("Rename/disable failed");
                var request=java.util.List.of(new com.visioncare.model.ScheduleRegistrationDTO(
                    "2099-01-01", renamed, first.getStartTime(), first.getEndTime(), first.getSession()));
                if(new com.visioncare.dao.WorkScheduleDAO().registerScheduleBatch(-1,"doctor",request))
                    throw new AssertionError("Disabled slot accepted a registration");
                // The migration snapshot excludes labels intentionally normalized during migration.
                int differences=scalar(c,
                    "SELECT COUNT(*) FROM (SELECT Schedule_ID,Work_Date,Start_Time,End_Time,Status FROM Work_Schedule "
                    +"EXCEPT SELECT Schedule_ID,Work_Date,Start_Time,End_Time,Status FROM Work_Schedule_Before_Slot_Config) d");
                if(differences!=0 || before!=scalar(c,"SELECT COUNT(*) FROM Work_Schedule"))
                    throw new AssertionError("Existing schedules were modified");
                System.out.println("PASS: duplicate names, overlap, duration, rename, disable, schedule preservation");
            } finally {
                dao.updateTimeSlotConfig(first.getSlotId(),first.getSlotName(),first.getStartTime(),first.getEndTime(),first.getStatus());
            }
            // Idempotency: applying the migration again must preserve the configurations.
            try(Statement s=c.createStatement()) {
                boolean result=s.execute(Files.readString(Path.of("src/java/database/2026-10-24-time-slot-config.sql")));
                while(result || s.getUpdateCount()!=-1) result=s.getMoreResults();
            }
            if(dao.getConfiguredSlots().size()!=slots.size()) throw new AssertionError("Migration is not idempotent");
            System.out.println("PASS: migration rerun and configuration restored; slots="+slots.size());
        }
    }
}

