import java.nio.file.*;import java.sql.*;import java.util.*;
/** Local fixture identity belongs in an external manifest, never in clinical free text. */
public final class FixtureRegistry {
 static final Path FILE=Path.of("docs/testing/user-flow-registry.properties");
 static Properties read()throws Exception{Properties p=new Properties();if(Files.exists(FILE))try(var r=Files.newBufferedReader(FILE)){p.load(r);}return p;}
 static String server(Connection c)throws Exception{try(Statement s=c.createStatement();ResultSet r=s.executeQuery("SELECT CONVERT(nvarchar(128),SERVERPROPERTY('ServerName'))")){r.next();return r.getString(1);}}
 static int find(Connection c,String code,int patient)throws Exception{
  Properties p=read();
  if(c.getCatalog().equals(p.getProperty("database"))&&server(c).equals(p.getProperty("server"))&&p.containsKey(code+".appointment")){
   try(PreparedStatement q=c.prepareStatement("SELECT a.Appointment_ID FROM Appointment a JOIN Master_Invoice i ON i.Appointment_ID=a.Appointment_ID JOIN Medical_Record m ON m.Appointment_ID=a.Appointment_ID WHERE a.Appointment_ID=? AND a.Patient_ID=? AND i.Invoice_ID=? AND m.Record_ID=? AND CONVERT(varchar(33),a.created_at,126)=?")){
    q.setInt(1,Integer.parseInt(p.getProperty(code+".appointment")));q.setInt(2,patient);q.setInt(3,Integer.parseInt(p.getProperty(code+".invoice")));q.setInt(4,Integer.parseInt(p.getProperty(code+".record")));q.setString(5,p.getProperty(code+".createdAt"));try(ResultSet r=q.executeQuery()){if(r.next())return r.getInt(1);}
   }
  }
  // The single SQL bootstrap identifies its nine visits by valid deterministic booking times.
  // This lets optional Java verification find SQL-created cases on any teammate's machine.
  int sequence=0;
  for(int n=0;n<SeedUserFlows.CASES.length;n++)if(SeedUserFlows.CASES[n][0].equals(code))sequence=n+1;
  if(sequence>0)try(PreparedStatement q=c.prepareStatement("SELECT a.Appointment_ID FROM Appointment a JOIN Medical_Record m ON m.Appointment_ID=a.Appointment_ID JOIN Master_Invoice i ON i.Appointment_ID=a.Appointment_ID JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID WHERE a.Patient_ID=? AND a.created_at=DATEADD(MINUTE,?,CONVERT(datetime2(7),'2026-10-24T18:00:00')) AND ws.Work_Date=?")){
   q.setInt(1,patient);q.setInt(2,sequence);q.setString(3,code.startsWith("EXAM_DONE")||code.equals("PAID_FINAL")?"2026-10-26":"2026-10-27");
   try(ResultSet r=q.executeQuery()){int id=0;if(r.next())id=r.getInt(1);if(r.next())throw new Exception("Ambiguous SQL fixture "+code);if(id>0)return id;}
  }
  // One-time compatibility for the already seeded cases; new seeds never write this marker.
  try(PreparedStatement q=c.prepareStatement("SELECT a.Appointment_ID FROM Appointment a JOIN Medical_Record m ON m.Appointment_ID=a.Appointment_ID WHERE a.Patient_ID=? AND m.Clinical_Diagnosis LIKE ?")){
   q.setInt(1,patient);q.setString(2,SeedUserFlows.marker(code).replace("[","[[]")+"%");try(ResultSet r=q.executeQuery()){int id=0;if(r.next())id=r.getInt(1);if(r.next())throw new Exception("Ambiguous legacy fixture "+code);return id;}
  }
 }
 static void save(Connection c,Map<String,Integer> ids)throws Exception{
  Properties p=new Properties();p.setProperty("database",c.getCatalog());p.setProperty("server",server(c));p.setProperty("patientEmail",SeedUserFlows.EMAIL);
  for(var entry:ids.entrySet())try(PreparedStatement q=c.prepareStatement("SELECT a.Appointment_ID,i.Invoice_ID,m.Record_ID,CONVERT(varchar(33),a.created_at,126) FROM Appointment a JOIN Master_Invoice i ON i.Appointment_ID=a.Appointment_ID JOIN Medical_Record m ON m.Appointment_ID=a.Appointment_ID WHERE a.Appointment_ID=?")){
   q.setInt(1,entry.getValue());try(ResultSet r=q.executeQuery()){if(!r.next())throw new Exception("Fixture missing");String key=entry.getKey();p.setProperty(key+".appointment",r.getString(1));p.setProperty(key+".invoice",r.getString(2));p.setProperty(key+".record",r.getString(3));p.setProperty(key+".createdAt",r.getString(4));}
  }
  Path temp=FILE.resolveSibling(FILE.getFileName()+".tmp");try(var w=Files.newBufferedWriter(temp)){p.store(w,"Fixture lookup only; not patient-facing clinical content");}Files.move(temp,FILE,StandardCopyOption.REPLACE_EXISTING);
 }
}
