import java.sql.*;import java.nio.file.*;import java.util.*;import com.visioncare.dao.DBContext;
/** Executes only integrated checkout DDL and normalization, inside a transaction always rolled back. */
public class ValidateIntegratedSql {
 public static void main(String[]args)throws Exception{
  String sql=Files.readString(Path.of("database/eye_clinic_db.sql"));
  int start=sql.indexOf("IF OBJECT_ID('dbo.Invoice_Checkout','U') IS NULL");int end=sql.indexOf("-- Table: [Clinic_Gallery]",start);
  String ddl=sql.substring(start,end).replace("[dbo].[Invoice_Checkout","[validate_checkout].[Invoice_Checkout").replace("dbo.Invoice_Checkout","validate_checkout.Invoice_Checkout");
  int p=sql.indexOf("-- BEGIN INTEGRATED PAYMENT NORMALIZATION"),q=sql.indexOf("-- END INTEGRATED PAYMENT NORMALIZATION",p);
  String normalization=sql.substring(p,q);
  try(Connection c=DBContext.getConnection()){
   if(!"eye_clinic_db".equals(c.getCatalog()))throw new Exception("Wrong DB");c.setAutoCommit(false);
   try(Statement s=c.createStatement()){
    s.execute("CREATE SCHEMA validate_checkout");
    for(String batch:ddl.split("(?im)^GO\\s*$"))if(!batch.isBlank())s.execute(batch);
    try(ResultSet r=s.executeQuery("SELECT COUNT(*) FROM sys.tables WHERE schema_id=SCHEMA_ID('validate_checkout')")){r.next();if(r.getInt(1)!=3)throw new Exception("Checkout schema incomplete");}
    s.execute(normalization);
    try(ResultSet r=s.executeQuery("SELECT COUNT(*) FROM sys.check_constraints WHERE name IN ('CHK_Transaction_Payment_Method','CHK_Procedure_Payment_Method','CHK_Checkout_Payment_Method') AND is_disabled=0")){r.next();if(r.getInt(1)<3)throw new Exception("Missing payment constraints");}
    System.out.println("PASS: merged checkout DDL (3 tables + keys/checks/index), normalization batch and canonical constraints.");
   }finally{c.rollback();}
  }
  try(Connection c=DBContext.getConnection();Statement s=c.createStatement();ResultSet r=s.executeQuery("SELECT COUNT(*) FROM sys.schemas WHERE name='validate_checkout'")){r.next();if(r.getInt(1)!=0)throw new Exception("Temporary validation schema remained");}
  System.out.println("PASS: validation rolled back completely; no database created and no temporary schema/tables remain.");
 }
}
