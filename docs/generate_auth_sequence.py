"""Generate editable draw.io sequence diagrams from the authentication code paths."""
from datetime import datetime, timezone
from pathlib import Path
import xml.etree.ElementTree as ET


OUT = Path(__file__).with_name("VisionEyeClinic_Auth_Sequence_Diagrams.drawio")
FONT = "fontFamily=Arial;fontSize=12;fontColor=#333333;"


def cell(root, ident, value, style, x, y, w, h):
    item = ET.SubElement(root, "mxCell", id=str(ident), value=value, style=style,
                         vertex="1", parent="1")
    ET.SubElement(item, "mxGeometry", {"x": str(x), "y": str(y),
                                       "width": str(w), "height": str(h), "as": "geometry"})
    return item


def line(root, ident, x1, y1, x2, y2, style, value=""):
    item = ET.SubElement(root, "mxCell", id=str(ident), value=value, style=style,
                         edge="1", parent="1")
    geo = ET.SubElement(item, "mxGeometry", {"relative": "1", "as": "geometry"})
    ET.SubElement(geo, "mxPoint", {"x": str(x1), "y": str(y1), "as": "sourcePoint"})
    ET.SubElement(geo, "mxPoint", {"x": str(x2), "y": str(y2), "as": "targetPoint"})
    if value:
        ET.SubElement(geo, "mxPoint", {"x": "0", "y": "-12", "as": "offset"})


def page(mxfile, page_id, title, participants, steps, footnote):
    # Participants are placed in the same left-to-right layout as the supplied sample.
    spacing = 250
    xs = [105 + i * spacing for i in range(len(participants))]
    width = xs[-1] + 140
    height = 145 + len(steps) * 46 + 105
    diagram = ET.SubElement(mxfile, "diagram", id=page_id, name=title)
    model = ET.SubElement(diagram, "mxGraphModel", dx=str(width), dy=str(height),
                          grid="0", guides="1", page="1", pageScale="1",
                          pageWidth=str(width), pageHeight=str(height), background="#FFFFFF")
    root = ET.SubElement(model, "root")
    ET.SubElement(root, "mxCell", id="0")
    ET.SubElement(root, "mxCell", id="1", parent="0")
    n = 2
    cell(root, n, title, "text;html=0;align=left;verticalAlign=middle;" + FONT +
         "fontSize=20;fontStyle=1;fillColor=none;strokeColor=none;", 40, 12, width-80, 32)
    n += 1
    for i, name in enumerate(participants):
        x = xs[i]
        if i == 0:
            # UML stick figure, as in the reference image.
            cell(root, n, "", "shape=umlActor;whiteSpace=wrap;html=0;fillColor=none;"
                 "strokeColor=#444444;strokeWidth=1;", x-14, 48, 28, 42)
            n += 1
            cell(root, n, name, "text;html=0;align=center;verticalAlign=middle;" + FONT +
                 "fontStyle=1;fillColor=none;strokeColor=none;", x-90, 92, 180, 25)
            n += 1
        else:
            cell(root, n, name, "rounded=0;whiteSpace=wrap;html=0;align=center;"
                 "verticalAlign=middle;fillColor=#FFFFFF;strokeColor=#444444;"
                 "strokeWidth=1;" + FONT + "fontStyle=1;", x-86, 60, 172, 34)
            n += 1
        line(root, n, x, 119, x, height-65,
             "endArrow=none;dashed=1;dashPattern=2 3;strokeColor=#777777;strokeWidth=1;")
        n += 1

    y0 = 146
    # Activation bars mark the servlet/DAO/DB work and remain individually editable.
    spans = {}
    for j, (src, dst, label, kind) in enumerate(steps):
        y = y0 + j * 46
        for p in (src, dst):
            if p > 0:
                spans.setdefault(p, []).append(y)
    for p, ys in spans.items():
        for start, end in _activity_runs(ys):
            cell(root, n, "", "rounded=0;fillColor=#FFFFFF;strokeColor=#777777;"
                 "strokeWidth=1;", xs[p]-5, start-5, 10, end-start+18)
            n += 1

    for j, (src, dst, label, kind) in enumerate(steps):
        y = y0 + j * 46
        if src == dst:
            # A compact self-call loop at the right of the lifeline.
            x = xs[src]
            for a, b, c, d, last in [(x+5,y,x+58,y,False),
                                     (x+58,y,x+58,y+20,False),
                                     (x+58,y+20,x+5,y+20,True)]:
                line(root, n, a,b,c,d,
                     ("endArrow=classic;endFill=1;" if last else "endArrow=none;") +
                     "strokeColor=#333333;strokeWidth=1;")
                n += 1
            cell(root, n, label, "text;html=0;align=left;verticalAlign=middle;"
                 "fillColor=none;strokeColor=none;" + FONT,
                 x+64, y-15, 170, 30)
            n += 1
        else:
            a, b = xs[src], xs[dst]
            inset = 6
            x1 = a + (inset if dst > src else -inset)
            x2 = b - (inset if dst > src else -inset)
            style = ("endArrow=classic;endFill=1;" if kind == "call" else
                     "endArrow=open;endFill=0;dashed=1;dashPattern=3 3;")
            line(root, n, x1,y,x2,y, style + "strokeColor=#333333;strokeWidth=1;"
                 "fontFamily=Arial;fontSize=12;fontColor=#333333;labelPosition=center;"
                 "verticalLabelPosition=top;verticalAlign=bottom;", f"{j+1}: {label}")
            n += 1
    cell(root, n, footnote, "text;html=0;align=left;verticalAlign=middle;"
         "whiteSpace=wrap;fillColor=none;strokeColor=none;" + FONT +
         "fontSize=11;fontColor=#666666;", 40, height-48, width-80, 34)


def _activity_runs(ys):
    # Keep short bars on each interaction rather than one continuous block.
    return [(y, y) for y in ys]


mxfile = ET.Element("mxfile", host="app.diagrams.net",
                    modified=datetime.now(timezone.utc).isoformat(),
                    agent="Codex", version="24.7.17", type="device")

page(mxfile, "auth-login", "01 - Login", ["User", "LoginView", "LoginServlet", "UserDAO", "DBContext", "Account / Role / Profile DB", "HttpSession"], [
    (0,1,"Nhập email, password", "call"),
    (1,2,"POST /login", "call"),
    (2,3,"login(email, password)", "call"),
    (3,4,"getConnection()", "call"),
    (4,3,"Connection", "return"),
    (3,5,"SELECT Account JOIN Role, Patient, Employee_Profile, Room", "call"),
    (5,3,"User / null (password hoặc NEW_password; status != Deleted)", "return"),
    (3,2,"User / null", "return"),
    (2,1,"[null] Error: email hoặc mật khẩu sai", "return"),
    (2,1,"[Inactive] Error: tài khoản bị khóa", "return"),
    (2,6,"[hợp lệ] setAttribute(user); timeout 30 phút", "call"),
    (2,1,"[firstLogin] redirect change-password.jsp?force=true", "return"),
    (2,1,"[redirectAfterLogin] redirect URL đã lưu", "return"),
    (2,1,"[khác] redirect theo role: dashboard / schedule / home", "return"),
], "Nguồn: LoginServlet.java, UserDAO.login(), Account/Role/Patient/Employee_Profile trong eye_clinic_db.sql.")

page(mxfile, "auth-register", "02 - Register", ["Guest", "RegisterView / OTPView", "RegisterServlet", "UserDAO", "DBContext", "Account / Patient DB", "HttpSession", "EmailUtil"], [
    (0,1,"Nhập tên, phone, email, password", "call"),
    (1,2,"POST /register", "call"),
    (2,2,"Kiểm tra phone 10 số; xác nhận / chính sách password", "call"),
    (2,3,"getByEmail(email), getByPhone(phone)", "call"),
    (3,4,"getConnection()", "call"),
    (3,5,"SELECT Account/Patient/Employee_Profile", "call"),
    (5,3,"Đã tồn tại / chưa tồn tại", "return"),
    (3,2,"Kết quả kiểm tra", "return"),
    (2,1,"[không hợp lệ / trùng] forward register.jsp + error", "return"),
    (2,6,"[hợp lệ] lưu pendingUser, registerOtp", "call"),
    (2,7,"sendOtpEmail(email, otp)", "call"),
    (2,1,"redirect /verify-otp", "return"),
    (0,1,"Nhập OTP 6 số", "call"),
    (1,2,"POST /verify-otp", "call"),
    (2,6,"Đọc registerOtp và pendingUser", "call"),
    (2,1,"[OTP sai] forward verify-otp.jsp + error", "return"),
    (2,3,"[OTP đúng] kiểm tra lại email / phone", "call"),
    (3,5,"SELECT Account, Patient, Employee_Profile", "call"),
    (5,3,"Không trùng", "return"),
    (2,3,"register(pendingUser)", "call"),
    (3,5,"BEGIN; INSERT Account(Role=Patient)", "call"),
    (3,5,"UPDATE Patient chưa có Account hoặc INSERT Patient; COMMIT", "call"),
    (5,3,"Tài khoản đã tạo (lỗi thì ROLLBACK)", "return"),
    (2,6,"Xóa OTP/pendingUser; lưu user", "call"),
    (2,1,"redirect URL đã lưu hoặc /home", "return"),
], "Nguồn: RegisterServlet.java, UserDAO.register()/getByEmail()/getByPhone(), EmailUtil, Account/Patient DB. OTP lưu trong session.")

page(mxfile, "auth-reset", "03 - Reset password", ["User", "Forgot / OTP / Reset View", "ForgotPasswordServlet", "UserDAO", "DBContext", "Account DB", "HttpSession", "EmailUtil"], [
    (0,1,"Nhập email", "call"),
    (1,2,"POST /forgot-password", "call"),
    (2,3,"getByEmail(email)", "call"),
    (3,4,"getConnection()", "call"),
    (3,5,"SELECT Account LEFT JOIN Patient", "call"),
    (5,3,"User / null", "return"),
    (3,2,"User / null", "return"),
    (2,1,"[null] forward forgot-password.jsp + error", "return"),
    (2,6,"[tồn tại] lưu resetEmail, resetOtp; xóa verified", "call"),
    (2,7,"sendOtpEmail(email, otp)", "call"),
    (2,1,"redirect /forgot-password/verify", "return"),
    (0,1,"Nhập OTP", "call"),
    (1,2,"POST /forgot-password/verify", "call"),
    (2,6,"Đối chiếu resetOtp", "call"),
    (2,1,"[sai] forward verify-reset-otp.jsp + error", "return"),
    (2,6,"[đúng] set resetOtpVerified=true", "call"),
    (2,1,"redirect /forgot-password/reset", "return"),
    (0,1,"Nhập password mới và xác nhận", "call"),
    (1,2,"POST /forgot-password/reset", "call"),
    (2,6,"Kiểm tra resetEmail + resetOtpVerified", "call"),
    (2,2,"Kiểm tra confirm; >=8 ký tự, hoa và thường", "call"),
    (2,1,"[sai] forward reset-password.jsp + error", "return"),
    (2,3,"getByEmail(email); updatePassword(accountId, newPassword)", "call"),
    (3,5,"UPDATE Account SET Password = ? WHERE Account_ID = ?", "call"),
    (5,3,"Kết quả UPDATE", "return"),
    (2,6,"Xóa resetEmail, resetOtp, resetOtpVerified", "call"),
    (2,1,"redirect /login + successMsg", "return"),
], "Nguồn: ForgotPasswordServlet.java, UserDAO.getByEmail()/updatePassword(), EmailUtil, bảng Account. OTP lưu trong session.")

page(mxfile, "auth-change", "04 - Change password", ["Authenticated user", "ChangePasswordView", "ProfileServlet", "HttpSession", "UserDAO", "DBContext", "Account DB"], [
    (0,1,"Nhập oldPassword, newPassword, confirmPassword", "call"),
    (1,2,"POST /profile/change-password", "call"),
    (2,3,"getAttribute(user)", "call"),
    (3,2,"User / null", "return"),
    (2,1,"[null] redirect /login", "return"),
    (2,2,"So oldPassword với session user (kể cả NEW_)", "call"),
    (2,1,"[sai] redirect change-password.jsp + error", "return"),
    (2,2,"So confirm; regex: chữ hoa đầu, có số, >=8 ký tự", "call"),
    (2,1,"[sai] redirect change-password.jsp + error", "return"),
    (2,4,"updatePassword(user.id, newPassword)", "call"),
    (4,5,"getConnection()", "call"),
    (4,6,"UPDATE Account SET Password = ? WHERE Account_ID = ?", "call"),
    (6,4,"Kết quả UPDATE", "return"),
    (4,2,"boolean", "return"),
    (2,3,"Cập nhật user.password, firstLogin=false; setAttribute(user)", "call"),
    (2,1,"redirect /home + success", "return"),
], "Nguồn: ProfileServlet.java, UserDAO.updatePassword(), bảng Account. Nhánh firstLogin từ LoginServlet cũng dùng trang này.")

ET.indent(mxfile, space="  ")
ET.ElementTree(mxfile).write(OUT, encoding="utf-8", xml_declaration=True)
print(OUT)
