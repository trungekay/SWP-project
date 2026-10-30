package com.visioncare.dao;
import java.sql.*;
import com.visioncare.model.StaffInvoice;
/** Final receipt is accessible only to its owner after medical and cashier completion. */
public class PatientInvoiceDAO {
 private final StaffInvoiceDAO.Connections connections;
 public PatientInvoiceDAO(){this(DBContext::getConnection);}public PatientInvoiceDAO(StaffInvoiceDAO.Connections c){connections=c;}
 public StaffInvoice completed(int id,int account)throws Exception {
  String sql="SELECT 1 FROM Master_Invoice i JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID JOIN Patient p ON p.Patient_ID=a.Patient_ID JOIN Invoice_Checkout co ON co.Invoice_ID=i.Invoice_ID WHERE i.Invoice_ID=? AND p.Account_ID=? AND a.Status='Completed' AND i.Status='Paid' AND co.Finalized_At IS NOT NULL AND NOT EXISTS(SELECT 1 FROM Refund_Request r WHERE r.Invoice_ID=i.Invoice_ID AND r.Status IN ('Pending','Approved'))";
  try(Connection c=connections.open();PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,id);p.setInt(2,account);try(ResultSet r=p.executeQuery()){if(!r.next())return null;}}
  StaffInvoice bill=new StaffInvoiceDAO(connections).get(id);
  return bill.finalized&&bill.isClinicalComplete()&&!bill.isBlocked()&&bill.paid==bill.getTotal()?bill:null;
 }
}
