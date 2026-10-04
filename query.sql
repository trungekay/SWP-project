SELECT e.Employee_ID, e.Full_Name, a.Role_ID FROM Employee_Profile e JOIN Account a ON e.Account_ID = a.Account_ID WHERE a.Role_ID = 4
