-- READ ONLY: nine cases for the existing Nguyen Van An patient, on this machine.
USE eye_clinic_db;
DECLARE @PatientID int = (SELECT p.Patient_ID FROM Patient p JOIN Account ac ON ac.Account_ID=p.Account_ID WHERE ac.Email='patient.an@gmail.com');
DECLARE @FlowAppointments TABLE(Appointment_ID int PRIMARY KEY);
INSERT INTO @FlowAppointments
SELECT Appointment_ID FROM Appointment WHERE Patient_ID=@PatientID
AND created_at BETWEEN '2026-10-24T18:01:00' AND '2026-10-24T18:09:00';
-- Compatibility for the original local Java-created set; other machines use the SQL-created set above.
IF NOT EXISTS(SELECT 1 FROM @FlowAppointments)
 INSERT INTO @FlowAppointments SELECT Appointment_ID FROM Appointment
 WHERE Patient_ID=@PatientID AND Appointment_ID BETWEEN 111 AND 119;

-- 1. Existing login/profile (never expose Password).
SELECT ac.Account_ID,ac.Email,ac.Role_ID,ac.Account_Status,p.Patient_ID,p.Full_Name,p.Phone
FROM Account ac JOIN Patient p ON p.Account_ID=ac.Account_ID WHERE p.Patient_ID=@PatientID;

-- 2. Appointment history and clinical states.
SELECT * FROM Appointment WHERE Patient_ID=@PatientID AND Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments) ORDER BY Appointment_ID;
SELECT ws.* FROM Work_Schedule ws JOIN Appointment a ON a.Schedule_ID=ws.Schedule_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments) ORDER BY a.Appointment_ID;

-- 3. Exam/cancellation notes, details, prescriptions, extra procedures.
SELECT mr.* FROM Medical_Record mr JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments) ORDER BY a.Appointment_ID;
SELECT ed.* FROM Examination_Detail ed JOIN Medical_Record mr ON mr.Record_ID=ed.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments);
SELECT pr.* FROM Prescription pr JOIN Medical_Record mr ON mr.Record_ID=pr.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments);
SELECT pd.* FROM Prescription_Detail pd JOIN Prescription pr ON pr.Prescription_ID=pd.Prescription_ID JOIN Medical_Record mr ON mr.Record_ID=pr.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments);
SELECT po.* FROM Procedure_Order po JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments);
SELECT pp.* FROM Procedure_Payment_Request pp JOIN Procedure_Order po ON po.Order_ID=pp.Order_ID JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments);
-- Procedure_Payment_Request may be empty: TP-LEO is a minor procedure, not PT-* prepayment surgery.

-- 4. Master invoice, receipts and refund.
SELECT i.* FROM Master_Invoice i JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments) ORDER BY a.Appointment_ID;
SELECT pt.* FROM Payment_Transaction pt JOIN Master_Invoice i ON i.Invoice_ID=pt.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments) ORDER BY pt.Transaction_ID;
SELECT rr.* FROM Refund_Request rr JOIN Master_Invoice i ON i.Invoice_ID=rr.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments);

-- 5. Finalization, immutable line items and QR requests.
SELECT co.* FROM Invoice_Checkout co JOIN Master_Invoice i ON i.Invoice_ID=co.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments);
SELECT ci.* FROM Invoice_Checkout_Item ci JOIN Master_Invoice i ON i.Invoice_ID=ci.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments);
SELECT cp.* FROM Invoice_Checkout_Payment cp JOIN Master_Invoice i ON i.Invoice_ID=cp.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID IN (SELECT Appointment_ID FROM @FlowAppointments);
-- QR table remains empty for this test set until you create a QR in the UI.

-- 6. Confirm old test records removed; preserve Nam's APT-96.
SELECT Account_ID,Email FROM Account WHERE Email='nam.flow.test@example.test';
SELECT Appointment_ID FROM Appointment WHERE Appointment_ID BETWEEN 97 AND 105;
SELECT Appointment_ID,Patient_ID,Status FROM Appointment WHERE Appointment_ID=96;
