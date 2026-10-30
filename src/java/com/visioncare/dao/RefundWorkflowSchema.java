package com.visioncare.dao;
import java.sql.*;
public final class RefundWorkflowSchema {
 private RefundWorkflowSchema(){}
 public static final String SQL="""
-- BEGIN REFUND LIFECYCLE UPGRADE
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF COL_LENGTH('dbo.Refund_Request','Decision_Note') IS NULL ALTER TABLE dbo.Refund_Request ADD Decision_Note nvarchar(1000) NULL;
IF COL_LENGTH('dbo.Refund_Request','Decision_At') IS NULL ALTER TABLE dbo.Refund_Request ADD Decision_At datetime2 NULL;
IF COL_LENGTH('dbo.Refund_Request','Completed_At') IS NULL ALTER TABLE dbo.Refund_Request ADD Completed_At datetime2 NULL;
IF COL_LENGTH('dbo.Refund_Request','Completed_By') IS NULL ALTER TABLE dbo.Refund_Request ADD Completed_By int NULL REFERENCES dbo.Employee_Profile(Employee_ID);
IF COL_LENGTH('dbo.Refund_Request','Completion_Note') IS NULL ALTER TABLE dbo.Refund_Request ADD Completion_Note nvarchar(1000) NULL;
IF COL_LENGTH('dbo.Refund_Request','Evidence_Image') IS NULL ALTER TABLE dbo.Refund_Request ADD Evidence_Image varbinary(max) NULL;
IF COL_LENGTH('dbo.Refund_Request','Evidence_Type') IS NULL ALTER TABLE dbo.Refund_Request ADD Evidence_Type varchar(30) NULL;
IF COL_LENGTH('dbo.Refund_Request','Notification_Status') IS NULL ALTER TABLE dbo.Refund_Request ADD Notification_Status varchar(20) NOT NULL CONSTRAINT DF_Refund_Mail DEFAULT 'NotRequired';
IF COL_LENGTH('dbo.Refund_Request','Notification_Attempts') IS NULL ALTER TABLE dbo.Refund_Request ADD Notification_Attempts int NOT NULL CONSTRAINT DF_Refund_Attempts DEFAULT 0;
IF COL_LENGTH('dbo.Refund_Request','Notification_Claimed_At') IS NULL ALTER TABLE dbo.Refund_Request ADD Notification_Claimed_At datetime2 NULL;
IF COL_LENGTH('dbo.Refund_Request','Notification_Sent_At') IS NULL ALTER TABLE dbo.Refund_Request ADD Notification_Sent_At datetime2 NULL;
IF COL_LENGTH('dbo.Refund_Request','Notification_Last_Error') IS NULL ALTER TABLE dbo.Refund_Request ADD Notification_Last_Error nvarchar(500) NULL;
IF EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID('dbo.Refund_Request') AND name='CHK_Refund_Status') ALTER TABLE dbo.Refund_Request DROP CONSTRAINT CHK_Refund_Status;
ALTER TABLE dbo.Refund_Request WITH CHECK ADD CONSTRAINT CHK_Refund_Status CHECK(Status IN ('Pending','Approved','Rejected','Completed'));
EXEC sp_executesql N'UPDATE r SET Status=''Completed'',Completed_At=COALESCE(r.Update_At,r.Created_At) FROM dbo.Refund_Request r JOIN dbo.Master_Invoice i ON i.Invoice_ID=r.Invoice_ID WHERE r.Status=''Approved'' AND i.Status=''Refunded'';';
COMMIT;
-- END REFUND LIFECYCLE UPGRADE
""";
 public static final String ITEM_SQL="""
-- BEGIN ITEM REFUND UPGRADE
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF COL_LENGTH('dbo.Refund_Request','Request_Kind') IS NULL ALTER TABLE dbo.Refund_Request ADD Request_Kind varchar(20) NOT NULL CONSTRAINT DF_Refund_Request_Kind DEFAULT 'Appointment';
IF COL_LENGTH('dbo.Refund_Request','Unused_Checked_By') IS NULL ALTER TABLE dbo.Refund_Request ADD Unused_Checked_By int NULL REFERENCES dbo.Employee_Profile(Employee_ID);
IF COL_LENGTH('dbo.Refund_Request','Unused_Checked_At') IS NULL ALTER TABLE dbo.Refund_Request ADD Unused_Checked_At datetime2 NULL;
IF OBJECT_ID('dbo.Refund_Request_Item','U') IS NULL
CREATE TABLE dbo.Refund_Request_Item(
 Refund_ID int NOT NULL REFERENCES dbo.Refund_Request(Refund_ID),
 Item_Key nvarchar(64) NOT NULL,
 Item_Name nvarchar(500) NOT NULL,
 Item_Type varchar(20) NOT NULL CHECK(Item_Type IN ('Medicine','Procedure')),
 Quantity int NOT NULL CHECK(Quantity>0),
 Unit_Price decimal(18,0) NOT NULL CHECK(Unit_Price>0),
 PRIMARY KEY(Refund_ID,Item_Key)
);
COMMIT;
-- END ITEM REFUND UPGRADE
""";
 public static void ensure(Connection c)throws SQLException {try(Statement s=c.createStatement()){s.execute(SQL);s.execute(ITEM_SQL);}}
}
