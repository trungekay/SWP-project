# Slot configuration migration

Run src/java/database/2026-10-24-time-slot-config.sql on the existing database in a transaction before deploying the updated classes.
The local development database has already been migrated.
Fresh databases created by database/eye_clinic_db.sql also include the new table.

- Time_Slot_Config owns the unique names, 30-minute ranges and Available/Canceled configuration status.
- Work_Schedule keeps each person's dates, appointment and leave statuses.
- Migration takes a snapshot in Work_Schedule_Before_Slot_Config.
- Existing ranges are retained. The most-used label for a range is selected; repeated labels across ranges receive a time suffix.
- A range is initially disabled only when all its existing schedules are Canceled. Mixed or previously overwritten statuses cannot establish an administrator's original intent; review these configurations manually.
- Renaming synchronizes schedule labels only. Disabling never cancels existing appointments.
- Referenced ranges cannot change time. Add another non-overlapping range instead.
- Registration validates both the posted configuration and the configuration inside the write transaction.
- The schedule view continues to display existing work when the configuration is disabled.

Verification:
Run Ant compile, then:
java -cp "build/web/WEB-INF/classes;build/web/WEB-INF/lib/*" test/integration/TimeSlotConfigIntegration.java

The integration test temporarily renames/disables the first configured slot, restores it in finally, and checks duplicate/overlap rejection, disabled registration rejection, schedule preservation and migration idempotency.
Use a local test database without concurrent editing.
