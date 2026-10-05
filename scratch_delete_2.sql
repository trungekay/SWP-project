DECLARE @Acc1 INT = 17; -- lphng2201@gmail.com
DECLARE @Acc2 INT = 18; -- nglanphuong.fpt@gmail.com

-- Delete any records related to Patient 7 (lphng2201)
DELETE FROM Payment_Transaction WHERE Invoice_ID IN (
    SELECT Invoice_ID FROM Master_Invoice WHERE Appointment_ID IN (
        SELECT Appointment_ID FROM Appointment WHERE Patient_ID IN (SELECT Patient_ID FROM Patient WHERE Account_ID = @Acc1)
    )
);

DELETE FROM Refund_Request WHERE Patient_ID IN (SELECT Patient_ID FROM Patient WHERE Account_ID = @Acc1);

DELETE FROM Master_Invoice WHERE Appointment_ID IN (
    SELECT Appointment_ID FROM Appointment WHERE Patient_ID IN (SELECT Patient_ID FROM Patient WHERE Account_ID = @Acc1)
);

DELETE FROM Procedure_Order WHERE Record_ID IN (
    SELECT Record_ID FROM Medical_Record WHERE Appointment_ID IN (
        SELECT Appointment_ID FROM Appointment WHERE Patient_ID IN (SELECT Patient_ID FROM Patient WHERE Account_ID = @Acc1)
    )
);

DELETE FROM Prescription_Detail WHERE Prescription_ID IN (
    SELECT Prescription_ID FROM Prescription WHERE Record_ID IN (
        SELECT Record_ID FROM Medical_Record WHERE Appointment_ID IN (
            SELECT Appointment_ID FROM Appointment WHERE Patient_ID IN (SELECT Patient_ID FROM Patient WHERE Account_ID = @Acc1)
        )
    )
);

DELETE FROM Prescription WHERE Record_ID IN (
    SELECT Record_ID FROM Medical_Record WHERE Appointment_ID IN (
        SELECT Appointment_ID FROM Appointment WHERE Patient_ID IN (SELECT Patient_ID FROM Patient WHERE Account_ID = @Acc1)
    )
);

DELETE FROM Medical_Record WHERE Appointment_ID IN (
    SELECT Appointment_ID FROM Appointment WHERE Patient_ID IN (SELECT Patient_ID FROM Patient WHERE Account_ID = @Acc1)
);

DELETE FROM Appointment WHERE Patient_ID IN (SELECT Patient_ID FROM Patient WHERE Account_ID = @Acc1);

DELETE FROM Patient WHERE Account_ID = @Acc1;

-- Now delete the accounts
DELETE FROM Account WHERE Account_ID IN (@Acc1, @Acc2);
