-- Canonical payment methods for the application database only.
-- Normalize names; never alter amount, transaction outcome, IDs or appointment/refund state.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF DB_NAME() <> N'eye_clinic_db' THROW 51000, 'Unexpected database', 1;
IF EXISTS(SELECT 1 FROM Payment_Transaction WHERE Payment_Gateway NOT IN ('Cash','Cash_At_Counter','QR_Banking','VietQR_Banking','Bank_Transfer','PayOS_Checkout','VNPay','Test_Seed','Demo_Seed','Test_Deposit'))
 THROW 51001, 'Unknown transaction method; review before migration', 1;
IF EXISTS(SELECT 1 FROM Invoice_Checkout WHERE Payment_Method IS NOT NULL AND Payment_Method NOT IN ('Cash','Cash_At_Counter','QR_Banking','VietQR_Banking','Bank_Transfer','PayOS_Checkout','VNPay','Previously_Paid'))
 THROW 51002, 'Unknown checkout method; review before migration', 1;
IF EXISTS(SELECT 1 FROM Procedure_Payment_Request WHERE Payment_Method IS NOT NULL AND Payment_Method NOT IN ('Cash','Cash_At_Counter','QR_Banking','VietQR_Banking','Bank_Transfer','PayOS_Checkout','VNPay'))
 THROW 51003, 'Unknown procedure method; review before migration', 1;

UPDATE Payment_Transaction SET Payment_Gateway=CASE WHEN Payment_Gateway IN ('Cash','Cash_At_Counter') THEN 'Cash' ELSE 'QR_Banking' END
WHERE Payment_Gateway NOT IN ('Cash','QR_Banking');
-- A zero-balance close uses the method of its latest actual recorded receipt.
-- NULL remains valid when no receipt identifies the method; do not invent another cash receipt.
UPDATE co SET Payment_Method=(SELECT TOP 1 pt.Payment_Gateway FROM Payment_Transaction pt WHERE pt.Invoice_ID=co.Invoice_ID AND pt.Gateway_Status='Success' ORDER BY pt.Transaction_ID DESC)
FROM Invoice_Checkout co WHERE co.Payment_Method='Previously_Paid';
UPDATE Invoice_Checkout SET Payment_Method=CASE WHEN Payment_Method IN ('Cash','Cash_At_Counter') THEN 'Cash' ELSE 'QR_Banking' END
WHERE Payment_Method IS NOT NULL AND Payment_Method NOT IN ('Cash','QR_Banking');
UPDATE Procedure_Payment_Request SET Payment_Method=CASE WHEN Payment_Method IN ('Cash','Cash_At_Counter') THEN 'Cash' ELSE 'QR_Banking' END
WHERE Payment_Method IS NOT NULL AND Payment_Method NOT IN ('Cash','QR_Banking');

IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE name='CHK_Transaction_Payment_Method')
 ALTER TABLE Payment_Transaction WITH CHECK ADD CONSTRAINT CHK_Transaction_Payment_Method CHECK (Payment_Gateway COLLATE Latin1_General_100_BIN2 IN ('Cash','QR_Banking'));
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE name='CHK_Checkout_Payment_Method')
 ALTER TABLE Invoice_Checkout WITH CHECK ADD CONSTRAINT CHK_Checkout_Payment_Method CHECK (Payment_Method IS NULL OR Payment_Method COLLATE Latin1_General_100_BIN2 IN ('Cash','QR_Banking'));
IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE name='CHK_Procedure_Payment_Method')
 ALTER TABLE Procedure_Payment_Request WITH CHECK ADD CONSTRAINT CHK_Procedure_Payment_Method CHECK (Payment_Method IS NULL OR Payment_Method COLLATE Latin1_General_100_BIN2 IN ('Cash','QR_Banking'));
COMMIT TRANSACTION;
