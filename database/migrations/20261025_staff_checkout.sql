SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID('dbo.Invoice_Checkout','U') IS NULL
CREATE TABLE dbo.Invoice_Checkout (
 Invoice_ID int NOT NULL PRIMARY KEY REFERENCES dbo.Master_Invoice(Invoice_ID),
 Base_Amount decimal(18,0) NOT NULL CHECK (Base_Amount >= 0),
 Opening_Paid decimal(18,0) NOT NULL DEFAULT 0 CHECK (Opening_Paid >= 0),
 Finalized_At datetime2 NULL, Finalized_By int NULL REFERENCES dbo.Employee_Profile(Employee_ID),
 Payment_Method nvarchar(50) NULL CONSTRAINT CHK_Checkout_Payment_Method CHECK(Payment_Method IS NULL OR Payment_Method COLLATE Latin1_General_100_BIN2 IN ('Cash','QR_Banking'))
);
IF COL_LENGTH('dbo.Invoice_Checkout','Opening_Paid') IS NULL
ALTER TABLE dbo.Invoice_Checkout ADD Opening_Paid decimal(18,0) NOT NULL DEFAULT 0;
IF OBJECT_ID('dbo.Invoice_Checkout_Item','U') IS NULL
CREATE TABLE dbo.Invoice_Checkout_Item (
 Invoice_ID int NOT NULL REFERENCES dbo.Invoice_Checkout(Invoice_ID), Item_Key nvarchar(64) NOT NULL,
 Item_Name nvarchar(500) NOT NULL, Item_Type nvarchar(30) NOT NULL,
 Quantity int NOT NULL CHECK(Quantity > 0), Unit_Price decimal(18,0) NOT NULL CHECK(Unit_Price >= 0),
 Removable bit NOT NULL, Declined bit NOT NULL DEFAULT 0, Unpriced bit NOT NULL DEFAULT 0,
 Changed_By int NULL REFERENCES dbo.Employee_Profile(Employee_ID), Changed_At datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
 PRIMARY KEY(Invoice_ID, Item_Key)
);
IF OBJECT_ID('dbo.Invoice_Checkout_Payment','U') IS NULL
BEGIN
 CREATE TABLE dbo.Invoice_Checkout_Payment (
  Order_Code bigint NOT NULL PRIMARY KEY, Invoice_ID int NOT NULL REFERENCES dbo.Invoice_Checkout(Invoice_ID),
  Amount decimal(18,0) NOT NULL CHECK(Amount > 0), Fingerprint varchar(64) NOT NULL,
  Status varchar(20) NOT NULL CHECK(Status IN ('Creating','Pending','Paid','Failed','Cancelled')),
  Checkout_Url nvarchar(1000) NULL, QR_Code nvarchar(max) NULL,
  Created_By int NOT NULL REFERENCES dbo.Employee_Profile(Employee_ID), Created_At datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
  Updated_At datetime2 NOT NULL DEFAULT SYSUTCDATETIME(), Transaction_ID int NULL REFERENCES dbo.Payment_Transaction(Transaction_ID)
 );
 CREATE UNIQUE INDEX UX_Checkout_ActivePayment ON dbo.Invoice_Checkout_Payment(Invoice_ID) WHERE Status IN ('Creating','Pending');
END;
COMMIT;
