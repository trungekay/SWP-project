-- READ ONLY: 9 cases belonging to the existing Nguyen Van An patient.
USE eye_clinic_db;
DECLARE @PatientID int = 1, @FirstAPT int = 111, @LastAPT int = 119;

-- 1. Existing login/profile (never expose Password).
SELECT ac.Account_ID,ac.Email,ac.Role_ID,ac.Account_Status,p.Patient_ID,p.Full_Name,p.Phone
FROM Account ac JOIN Patient p ON p.Account_ID=ac.Account_ID WHERE p.Patient_ID=@PatientID;

-- 2. Appointment history and clinical states.
SELECT * FROM Appointment WHERE Patient_ID=@PatientID AND Appointment_ID BETWEEN @FirstAPT AND @LastAPT ORDER BY Appointment_ID;
SELECT ws.* FROM Work_Schedule ws JOIN Appointment a ON a.Schedule_ID=ws.Schedule_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT ORDER BY a.Appointment_ID;

-- 3. Exam/cancellation notes, details, prescriptions, extra procedures.
SELECT mr.* FROM Medical_Record mr JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT ORDER BY a.Appointment_ID;
SELECT ed.* FROM Examination_Detail ed JOIN Medical_Record mr ON mr.Record_ID=ed.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT;
SELECT pr.* FROM Prescription pr JOIN Medical_Record mr ON mr.Record_ID=pr.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT;
SELECT pd.* FROM Prescription_Detail pd JOIN Prescription pr ON pr.Prescription_ID=pd.Prescription_ID JOIN Medical_Record mr ON mr.Record_ID=pr.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT;
SELECT po.* FROM Procedure_Order po JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT;
SELECT pp.* FROM Procedure_Payment_Request pp JOIN Procedure_Order po ON po.Order_ID=pp.Order_ID JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT;
-- Procedure_Payment_Request may be empty: TP-LEO is a minor procedure, not PT-* prepayment surgery.

-- 4. Master invoice, receipts and refund.
SELECT i.* FROM Master_Invoice i JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT ORDER BY a.Appointment_ID;
SELECT pt.* FROM Payment_Transaction pt JOIN Master_Invoice i ON i.Invoice_ID=pt.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT ORDER BY pt.Transaction_ID;
SELECT rr.* FROM Refund_Request rr JOIN Master_Invoice i ON i.Invoice_ID=rr.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT;

-- 5. Finalization, immutable line items and QR requests.
SELECT co.* FROM Invoice_Checkout co JOIN Master_Invoice i ON i.Invoice_ID=co.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT;
SELECT ci.* FROM Invoice_Checkout_Item ci JOIN Master_Invoice i ON i.Invoice_ID=ci.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT;
SELECT cp.* FROM Invoice_Checkout_Payment cp JOIN Master_Invoice i ON i.Invoice_ID=cp.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID
WHERE a.Patient_ID=@PatientID AND a.Appointment_ID BETWEEN @FirstAPT AND @LastAPT;
-- QR table remains empty for this test set until you create a QR in the UI.

-- 6. Confirm old test records removed; preserve Nam's APT-96.
SELECT Account_ID,Email FROM Account WHERE Email='nam.flow.test@example.test';
SELECT Appointment_ID FROM Appointment WHERE Appointment_ID BETWEEN 97 AND 105;
SELECT Appointment_ID,Patient_ID,Status FROM Appointment WHERE Appointment_ID=96;
