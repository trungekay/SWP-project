from pathlib import Path
from xml.etree.ElementTree import Element, SubElement, ElementTree


OUT = Path(__file__).with_name("medicare-hub-class-diagram.drawio")

mxfile = Element("mxfile", {
    "host": "app.diagrams.net", "modified": "2026-11-13T00:00:00.000Z",
    "agent": "Codex", "version": "24.7.17", "type": "device",
})
diagram = SubElement(mxfile, "diagram", {"id": "medicare-class", "name": "MediCare Hub - Class Diagram"})
model = SubElement(diagram, "mxGraphModel", {
    "dx": "1200", "dy": "900", "grid": "1", "gridSize": "10", "guides": "1",
    "tooltips": "1", "connect": "1", "arrows": "1", "fold": "1",
    "page": "1", "pageScale": "1", "pageWidth": "3100", "pageHeight": "1700",
    "math": "0", "shadow": "0",
})
root = SubElement(model, "root")
SubElement(root, "mxCell", {"id": "0"})
SubElement(root, "mxCell", {"id": "1", "parent": "0"})


def vertex(id, label, x, y, w, h, style):
    cell = SubElement(root, "mxCell", {
        "id": id, "value": label, "style": style, "vertex": "1", "parent": "1",
    })
    SubElement(cell, "mxGeometry", {
        "x": str(x), "y": str(y), "width": str(w), "height": str(h), "as": "geometry",
    })
    return cell


def klass(id, name, attrs, methods, x, y, w=285, fill="#ffffff", stroke="#345b82", stereotype=""):
    lines = [f"<div style='font-size:16px;text-align:center'><b>{name}</b></div>"]
    if stereotype:
        lines.insert(0, f"<div style='font-size:12px;text-align:center'><i>«{stereotype}»</i></div>")
    lines.append("<hr style='margin:5px 0;border:0;border-top:1px solid #a7b7c7'>")
    lines.extend(f"<div>{a}</div>" for a in attrs)
    lines.append("<hr style='margin:5px 0;border:0;border-top:1px solid #a7b7c7'>")
    lines.extend(f"<div>{m}</div>" for m in methods)
    h = 42 + (18 if stereotype else 0) + 19 * (len(attrs) + len(methods)) + 18
    style = (
        "rounded=0;whiteSpace=wrap;html=1;align=left;verticalAlign=top;"
        f"fillColor={fill};strokeColor={stroke};strokeWidth=2;"
        "fontColor=#172536;fontSize=13;spacing=11;overflow=fill;"
    )
    vertex(id, "".join(lines), x, y, w, h, style)
    return h


def edge(id, source, target, kind="association", label="", extra=""):
    styles = {
        "association": "endArrow=none;startArrow=none;strokeColor=#53677d;strokeWidth=2;",
        "inheritance": "endArrow=block;endFill=0;startArrow=none;strokeColor=#41617f;strokeWidth=2;",
        "aggregation": "startArrow=diamond;startFill=0;endArrow=none;strokeColor=#53677d;strokeWidth=2;",
        "composition": "startArrow=diamond;startFill=1;endArrow=none;strokeColor=#53677d;strokeWidth=2;",
        "realization": "endArrow=block;endFill=0;startArrow=none;dashed=1;dashPattern=7 5;strokeColor=#7b6b9d;strokeWidth=2;",
        "dependency": "endArrow=open;startArrow=none;dashed=1;dashPattern=7 5;strokeColor=#74875b;strokeWidth=2;",
    }
    style = "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" + styles[kind] + extra
    cell = SubElement(root, "mxCell", {
        "id": id, "value": label, "style": style, "edge": "1", "parent": "1",
        "source": source, "target": target,
    })
    SubElement(cell, "mxGeometry", {"relative": "1", "as": "geometry"})


def note(id, label, x, y, w, h, fill="#f5f8fc"):
    vertex(id, label, x, y, w, h,
           "rounded=1;whiteSpace=wrap;html=1;align=left;verticalAlign=middle;"
           f"fillColor={fill};strokeColor=#c3d1df;fontColor=#253c55;fontSize=13;spacing=9;")


# Main entities. The three horizontal regions form one complete class diagram.
klass("user", "User", ["- userId: UUID", "- fullName: String", "- email: String"],
      ["+ updateProfile(): void"], 470, 90, 290, "#eaf2ff")
klass("patient", "Patient", ["- dateOfBirth: Date", "- phone: String"],
      ["+ requestAppointment(): void"], 80, 360, 305, "#eaf2ff")
klass("doctor", "Doctor", ["- specialty: String", "- licenseNo: String"],
      ["+ updateAvailability(): void"], 465, 360, 305, "#eaf2ff")
klass("receptionist", "Receptionist", ["- staffCode: String"],
      ["+ confirmAppointment(): void", "+ checkInPatient(): void"], 850, 360, 305, "#eaf2ff")

klass("schedule", "DoctorSchedule", ["- scheduleId: UUID", "- date: Date", "- availableSlots: List&lt;TimeSlot&gt;"],
      ["+ isAvailable(slot): boolean", "+ reserve(slot): void"], 490, 755, 320, "#eef9f2", "#3f7754")
klass("appointment", "Appointment", ["- appointmentId: UUID", "- date: Date", "- timeSlot: TimeSlot", "- status: AppointmentStatus"],
      ["+ confirm(): void", "+ cancel(): void", "+ checkIn(): void"], 960, 755, 330, "#eef9f2", "#3f7754")
klass("payment", "Payment", ["- paymentId: UUID", "- amount: Decimal", "- status: PaymentStatus"],
      ["+ markSuccess(): void", "+ markFailed(): void"], 1370, 755, 305, "#eef9f2", "#3f7754")

klass("appointmentService", "AppointmentService", [],
      ["+ bookAppointment(): Appointment", "+ confirmAppointment(): void", "+ cancelAppointment(): void"],
      1765, 305, 340, "#fff3e3", "#b47728", "service")
klass("scheduleService", "ScheduleService", [],
      ["+ checkAvailability(): boolean", "+ reserveSlot(): void"],
      1765, 655, 340, "#fff3e3", "#b47728", "service")
klass("paymentService", "PaymentService", [],
      ["+ processPayment(): Payment", "+ getPaymentStatus(): PaymentStatus"],
      1765, 1005, 340, "#fff3e3", "#b47728", "service")

klass("appointmentRepo", "AppointmentRepository", [],
      ["+ findById(id): Appointment", "+ save(a: Appointment): void"],
      2270, 305, 330, "#f3edfc", "#7b60a5", "repository")
klass("scheduleRepo", "DoctorScheduleRepository", [],
      ["+ findByDoctorAndDate(): DoctorSchedule", "+ save(s: DoctorSchedule): void"],
      2270, 655, 330, "#f3edfc", "#7b60a5", "repository")
klass("paymentRepo", "PaymentRepository", [],
      ["+ findByAppointmentId(): Payment", "+ save(p: Payment): void"],
      2270, 1005, 330, "#f3edfc", "#7b60a5", "repository")
klass("repoInterface", "Repository&lt;T&gt;", [],
      ["+ findById(id): T", "+ save(entity: T): void", "+ update(entity: T): void"],
      2700, 655, 300, "#f3edfc", "#7b60a5", "interface")

# Inheritance: hollow triangle always points to User.
for who in ("patient", "doctor", "receptionist"):
    edge("inherits_" + who, who, "user", "inheritance")

# Domain relations. Labels state both multiplicities explicitly for easy checking.
edge("patient_appointment", "patient", "appointment", "aggregation",
     "creates", "exitX=0.75;exitY=1;entryX=0.15;entryY=0;")
edge("doctor_appointment", "doctor", "appointment", "association",
     "manages", "exitX=1;exitY=0.7;entryX=0;entryY=0.3;")
edge("doctor_schedule", "doctor", "schedule", "composition",
     "owns schedule", "exitX=0.5;exitY=1;entryX=0.5;entryY=0;")
edge("appointment_payment", "appointment", "payment", "association",
     "has payment", "exitX=1;exitY=0.55;entryX=0;entryY=0.55;")
edge("receptionist_appointment", "receptionist", "appointment", "association",
     "confirms / checks in", "exitX=0.6;exitY=1;entryX=0.55;entryY=0;")

# Multiplicities are separate editable labels positioned beside the relevant ends.
MULTIPLICITY_STYLE = (
    "text;html=1;align=center;verticalAlign=middle;whiteSpace=wrap;"
    "strokeColor=none;fillColor=#ffffff;fontColor=#26384a;fontSize=13;fontStyle=1;"
)
for id, label, x, y in [
    ("m_patient_1", "1", 285, 490), ("m_appointment_from_patient", "0..*", 960, 720),
    ("m_doctor_1", "1", 775, 455), ("m_appointment_from_doctor", "0..*", 920, 795),
    ("m_doctor_schedule_1", "1", 605, 495), ("m_schedule_many", "0..*", 615, 720),
    ("m_appointment_payment_1", "1", 1280, 820), ("m_payment_1", "1", 1350, 820),
    ("m_receptionist_optional", "0..1", 1025, 495),
    ("m_appointment_from_receptionist", "0..*", 1135, 720),
]:
    vertex(id, label, x, y, 45, 25, MULTIPLICITY_STYLE)

# Service-to-repository dependencies and generic interface implementation.
edge("appt_domain_dep", "appointmentService", "appointment", "dependency", "creates / updates",
     "exitX=0;exitY=0.7;entryX=1;entryY=0.15;")
edge("sched_domain_dep", "scheduleService", "schedule", "dependency", "checks / reserves",
     "exitX=0;exitY=0.5;entryX=1;entryY=0.2;")
edge("pay_domain_dep", "paymentService", "payment", "dependency", "processes",
     "exitX=0;exitY=0.25;entryX=1;entryY=0.8;")
edge("appt_dep", "appointmentService", "appointmentRepo", "dependency", "uses")
edge("sched_dep", "scheduleService", "scheduleRepo", "dependency", "uses")
edge("pay_dep", "paymentService", "paymentRepo", "dependency", "uses")
edge("appt_sched_dep", "appointmentService", "scheduleRepo", "dependency", "checks availability",
     "exitX=1;exitY=0.85;entryX=0;entryY=0.15;")
for repo in ("appointmentRepo", "scheduleRepo", "paymentRepo"):
    edge("implements_" + repo, repo, "repoInterface", "realization")

note("title", "<b>MediCare Hub — Design-level Class Diagram</b><br>Layered Architecture + Repository Pattern", 85, 45, 330, 75)
note("legend", "<b>Ký hiệu:</b> △ kế thừa / implements · ◇ aggregation · ◆ composition · ─ association · - - &gt; dependency", 90, 1235, 1050, 75)
note("assumption", "<b>Giả định để nhất quán với đề:</b> tạo Payment với status = Pending cùng lúc tạo Appointment. Thanh toán thất bại thì Payment = Failed, Appointment = Cancelled. Mỗi Appointment vẫn có đúng 1 Payment.", 90, 1350, 1510, 100, "#fff9e9")
note("layers", "<b>Đọc từ trái sang phải:</b> Domain entities → Services (xử lý nghiệp vụ) → Repositories (truy cập dữ liệu) → Repository&lt;T&gt; (giao diện chung).", 1765, 1260, 1235, 90)

ElementTree(mxfile).write(OUT, encoding="utf-8", xml_declaration=True)
print(OUT)
