# Kiểm kê database phục vụ kiểm thử — 26/10/2026

Database ứng dụng: **eye_clinic_db**. Chỉ đọc database khác để lấy tên; không sửa/xóa/tạo database.

## Database nhìn thấy trên SQL Server

- Bookstore
- CineBook
- DBI_Lab45
- DBI202_SU25_Lab1
- EmpManagement
- eye_clinic_db
- FUH_COMPANY
- HE201631_ERD1
- HE201631_ERD2
- HE201631_ERD3
- HE201631_ERD4
- HE201631_ERD5
- HE201631_ERD6
- HE201631_ERD7
- HE201631_ERD8
- HRM_2026
- hrManagement
- HSF302
- HSF302_EclipseLink
- IndexEmployee
- jpaDemo
- Key_Constraint
- Lab3_Q1
- Lab3_Q3
- master
- model
- msdb
- northwind
- PE_DBI202_Fa2025
- PE_DBI202_Sp2026
- PE_DBI202_Su2025
- PE_Demo_S2019
- PERSONS
- PRJDB
- Q1_PE
- Q1_PE_second
- Q1_Trial
- QLDA
- SamplePE
- StudentDB
- tempdb
- TransactionEmployee
- ViewEmployee
- Y25SP1B1
- Y25SP1B5
- Y25SU1B1
- Y26SP1B5
- Y26SU1B1

## Toàn bộ bảng trong database ứng dụng

| Bảng | Số dòng |
|---|---:|
| dbo.Account | 17 |
| dbo.Appointment | 71 |
| dbo.Clinic_Gallery | 8 |
| dbo.Clinic_Setting | 1 |
| dbo.Employee_Profile | 12 |
| dbo.Examination_Detail | 3 |
| dbo.Invoice_Checkout | 3 |
| dbo.Invoice_Checkout_Item | 6 |
| dbo.Invoice_Checkout_Payment | 1 |
| dbo.Leave_Cancel_Request | 1 |
| dbo.Master_Invoice | 43 |
| dbo.Medical_Record | 44 |
| dbo.Medical_Supply | 4 |
| dbo.Patient | 12 |
| dbo.Payment_Transaction | 21 |
| dbo.Prescription | 11 |
| dbo.Prescription_Detail | 16 |
| dbo.Procedure_Order | 12 |
| dbo.Procedure_Payment_Request | 0 |
| dbo.Refund_Request | 5 |
| dbo.Role | 6 |
| dbo.Room | 9 |
| dbo.Service_Catalog | 16 |
| dbo.Work_Schedule | 914 |

## Đối chiếu dữ liệu hiện có (trước seed)

| Kiểm tra | Số dòng |
|---|---:|
| Lịch Confirmed thiếu hóa đơn | 15 |
| Lịch có nhiều hóa đơn tổng | 0 |
| Hóa đơn đóng đủ tiền nhưng thiếu dấu chốt checkout (bao gồm phí khám) | 22 |
| Yêu cầu refund đang chờ nhưng không đủ điều kiện hủy trước checkin | 1 |

## Cột và khóa ngoại

### Account

- `Account_ID` int (nullable=NO)
- `Role_ID` int (nullable=NO)
- `Email` nvarchar (nullable=NO)
- `Password` nvarchar (nullable=NO)
- `Auth_Provider` nvarchar (nullable=NO)
- `Account_Status` nvarchar (nullable=NO)
### Appointment

- `Appointment_ID` int (nullable=NO)
- `Patient_ID` int (nullable=NO)
- `Schedule_ID` int (nullable=NO)
- `Staff_Employee_ID` int (nullable=YES)
- `Status` nvarchar (nullable=NO)
- `created_at` datetime2 (nullable=NO)
- `checkin_time` datetime2 (nullable=YES)
- `doctor_completed_at` datetime2 (nullable=YES)
### Clinic_Gallery

- `Item_ID` int (nullable=NO)
- `Title` nvarchar (nullable=YES)
- `Description` nvarchar (nullable=YES)
- `Display_Order` int (nullable=NO)
- `Default_Filename` varchar (nullable=YES)
- `Image_Data` varbinary (nullable=YES)
- `Image_Mime_Type` varchar (nullable=YES)
- `Updated_At` datetime2 (nullable=NO)
### Clinic_Setting

- `Setting_Key` varchar (nullable=NO)
- `Setting_Value` nvarchar (nullable=NO)
- `Description` nvarchar (nullable=YES)
### Employee_Profile

- `Employee_ID` int (nullable=NO)
- `Account_ID` int (nullable=NO)
- `Room_ID` int (nullable=YES)
- `Full_Name` nvarchar (nullable=NO)
- `Phone` nvarchar (nullable=YES)
- `DOB` date (nullable=YES)
- `Address` nvarchar (nullable=YES)
- `Specialty` nvarchar (nullable=YES)
- `License_Number` nvarchar (nullable=YES)
- `Biography` nvarchar (nullable=YES)
### Examination_Detail

- `Record_ID` int (nullable=NO)
- `Chief_Complaint` nvarchar (nullable=YES)
- `Medical_History` nvarchar (nullable=YES)
- `OD_Uncorrected` nvarchar (nullable=YES)
- `OS_Uncorrected` nvarchar (nullable=YES)
- `OD_Corrected` nvarchar (nullable=YES)
- `OS_Corrected` nvarchar (nullable=YES)
- `OD_IOP` decimal (nullable=YES)
- `OS_IOP` decimal (nullable=YES)
- `Anterior_Findings` nvarchar (nullable=YES)
- `Posterior_Findings` nvarchar (nullable=YES)
- `Follow_Up_Date` date (nullable=YES)
### Invoice_Checkout

- `Invoice_ID` int (nullable=NO)
- `Base_Amount` decimal (nullable=NO)
- `Finalized_At` datetime2 (nullable=YES)
- `Finalized_By` int (nullable=YES)
- `Payment_Method` nvarchar (nullable=YES)
- `Opening_Paid` decimal (nullable=NO)
### Invoice_Checkout_Item

- `Invoice_ID` int (nullable=NO)
- `Item_Key` nvarchar (nullable=NO)
- `Item_Name` nvarchar (nullable=NO)
- `Item_Type` nvarchar (nullable=NO)
- `Quantity` int (nullable=NO)
- `Unit_Price` decimal (nullable=NO)
- `Removable` bit (nullable=NO)
- `Declined` bit (nullable=NO)
- `Unpriced` bit (nullable=NO)
- `Changed_By` int (nullable=YES)
- `Changed_At` datetime2 (nullable=NO)
### Invoice_Checkout_Payment

- `Order_Code` bigint (nullable=NO)
- `Invoice_ID` int (nullable=NO)
- `Amount` decimal (nullable=NO)
- `Fingerprint` varchar (nullable=NO)
- `Status` varchar (nullable=NO)
- `Checkout_Url` nvarchar (nullable=YES)
- `QR_Code` nvarchar (nullable=YES)
- `Created_By` int (nullable=NO)
- `Created_At` datetime2 (nullable=NO)
- `Updated_At` datetime2 (nullable=NO)
- `Transaction_ID` int (nullable=YES)
### Leave_Cancel_Request

- `Request_ID` int (nullable=NO)
- `Schedule_ID` int (nullable=NO)
- `Requester_Employee_ID` int (nullable=NO)
- `Approved_By_Employee_ID` int (nullable=YES)
- `leave_Date` date (nullable=NO)
- `Reason` nvarchar (nullable=NO)
- `request_status` nvarchar (nullable=NO)
- `created_at` datetime2 (nullable=NO)
- `approved_at` datetime2 (nullable=YES)
### Master_Invoice

- `Invoice_ID` int (nullable=NO)
- `Appointment_ID` int (nullable=NO)
- `Total_Amount` decimal (nullable=NO)
- `Deposit_Amount` decimal (nullable=YES)
- `Balance_Due` decimal (nullable=NO)
- `Status` nvarchar (nullable=NO)
- `Create_At` datetime2 (nullable=NO)
- `Close_At` datetime2 (nullable=YES)
### Medical_Record

- `Record_ID` int (nullable=NO)
- `Appointment_ID` int (nullable=NO)
- `Doctor_Employee_ID` int (nullable=NO)
- `Clinical_Diagnosis` nvarchar (nullable=YES)
- `examination_result` nvarchar (nullable=YES)
- `conclusion` nvarchar (nullable=YES)
- `Created_At` datetime2 (nullable=NO)
- `Staff_Notes` nvarchar (nullable=YES)
### Medical_Supply

- `Supply_ID` int (nullable=NO)
- `Supply_Name` nvarchar (nullable=NO)
- `Category` nvarchar (nullable=NO)
- `Price` decimal (nullable=NO)
- `Image_Data` varbinary (nullable=YES)
- `Image_Mime_Type` varchar (nullable=YES)
### Patient

- `Patient_ID` int (nullable=NO)
- `Account_ID` int (nullable=YES)
- `Full_Name` nvarchar (nullable=NO)
- `Phone` nvarchar (nullable=NO)
- `DOB` date (nullable=YES)
- `Address` nvarchar (nullable=YES)
### Payment_Transaction

- `Transaction_ID` int (nullable=NO)
- `Invoice_ID` int (nullable=NO)
- `Amount` decimal (nullable=NO)
- `Gateway_Status` nvarchar (nullable=NO)
- `Trans_Date` datetime2 (nullable=NO)
- `Payment_Gateway` nvarchar (nullable=NO)
### Prescription

- `Prescription_ID` int (nullable=NO)
- `Record_ID` int (nullable=NO)
- `Doctor_Notes` nvarchar (nullable=YES)
- `created_at` datetime2 (nullable=NO)
### Prescription_Detail

- `Detail_ID` int (nullable=NO)
- `Prescription_ID` int (nullable=NO)
- `Quantity` int (nullable=NO)
- `Dosage_Instruction` nvarchar (nullable=YES)
- `Medicine_Name` nvarchar (nullable=NO)
- `Morning_Dose` nvarchar (nullable=YES)
- `Afternoon_Dose` nvarchar (nullable=YES)
- `Evening_Dose` nvarchar (nullable=YES)
- `Is_Custom_Medicine` bit (nullable=NO)
### Procedure_Order

- `Order_ID` int (nullable=NO)
- `Specialist_Employee_ID` int (nullable=YES)
- `Record_ID` int (nullable=NO)
- `Service_ID` int (nullable=NO)
- `Actual_Price` decimal (nullable=NO)
- `Status` nvarchar (nullable=NO)
- `Result_Text` nvarchar (nullable=YES)
- `Result_Conclusion` nvarchar (nullable=YES)
- `Completed_At` datetime2 (nullable=YES)
- `Referral_Notes` nvarchar (nullable=YES)
### Procedure_Payment_Request

- `Order_ID` int (nullable=NO)
- `Amount` decimal (nullable=NO)
- `Credit_Amount` decimal (nullable=NO)
- `Status` nvarchar (nullable=NO)
- `Created_At` datetime2 (nullable=NO)
- `Confirmed_At` datetime2 (nullable=YES)
- `Confirmed_By_Employee_ID` int (nullable=YES)
- `Payment_Method` nvarchar (nullable=YES)
- `Transaction_ID` int (nullable=YES)
### Refund_Request

- `Refund_ID` int (nullable=NO)
- `Invoice_ID` int (nullable=NO)
- `created_by_employee_id` int (nullable=NO)
- `approved_by_employee_id` int (nullable=YES)
- `Patient_ID` int (nullable=NO)
- `Refund_Amount` decimal (nullable=NO)
- `Reason` nvarchar (nullable=YES)
- `Status` nvarchar (nullable=NO)
- `Created_At` datetime2 (nullable=NO)
- `Update_At` datetime2 (nullable=NO)
### Role

- `Role_ID` int (nullable=NO)
- `Role_Name` nvarchar (nullable=NO)
### Room

- `Room_ID` int (nullable=NO)
- `Room_Name` nvarchar (nullable=NO)
### Service_Catalog

- `Service_ID` int (nullable=NO)
- `Service_Code` varchar (nullable=YES)
- `Service_Name` nvarchar (nullable=NO)
- `Price` decimal (nullable=NO)
- `Category` nvarchar (nullable=NO)
- `Summary` nvarchar (nullable=YES)
- `Description` nvarchar (nullable=YES)
- `Image_Data` varbinary (nullable=YES)
- `Image_Mime_Type` varchar (nullable=YES)
- `Image_Path` varchar (nullable=YES)
### Work_Schedule

- `Schedule_ID` int (nullable=NO)
- `Doctor_Employee_ID` int (nullable=YES)
- `Specialist_Employee_ID` int (nullable=YES)
- `Staff_Employee_ID` int (nullable=YES)
- `Work_Date` date (nullable=NO)
- `Start_Time` time (nullable=NO)
- `End_Time` time (nullable=NO)
- `Slot` nvarchar (nullable=NO)
- `Status` nvarchar (nullable=NO)

## Trạng thái và danh mục phục vụ seed

2 / Director / 

3 / Doctor / 

4 / Medical_Specialist / 

6 / Patient / 

5 / Staff / 

1 / System_Admin / 

Canceled / 16 / 

Completed / 25 / 

Confirmed / 27 / 

In_Progress / 2 / 

Pending / 1 / 

507 / 6 / 2026-10-26 / 08:00:00 / 

522 / 4 / 2026-10-26 / 08:00:00 / 

529 / 7 / 2026-10-26 / 08:00:00 / 

508 / 6 / 2026-10-26 / 08:30:00 / 

523 / 4 / 2026-10-26 / 08:30:00 / 

530 / 7 / 2026-10-26 / 08:30:00 / 

509 / 6 / 2026-10-26 / 09:00:00 / 

524 / 4 / 2026-10-26 / 09:00:00 / 

531 / 7 / 2026-10-26 / 09:00:00 / 

510 / 6 / 2026-10-26 / 09:30:00 / 

525 / 4 / 2026-10-26 / 09:30:00 / 

532 / 7 / 2026-10-26 / 09:30:00 / 

1 / Thuốc nhỏ mắt Systane Ultra (10ml) / 95000 / 

2 / Tròng kính Essilor Crizal Alize 1.60 / 1250000 / 

3 / Nước mắt nhân tạo Sanlein 0.1% (5ml) / 88000 / 

4 / Que thử màu huỳnh quang Fluorescein Strips / 320000 / 

