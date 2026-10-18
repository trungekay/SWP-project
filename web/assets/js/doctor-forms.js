(() => {
    "use strict";

    const page = document.querySelector("[data-doctor-form]");
    if (!page) return;

    const form = page.querySelector("form");
    const modal = document.querySelector("[data-preview-modal]");
    const previewContent = modal?.querySelector("[data-preview-content]");
    let returnFocus = null;

    // The POST handlers are not implemented yet. Keep browser Enter from implying a save.
    form.addEventListener("submit", event => event.preventDefault());

    function renumberMedicines() {
        const rows = [...document.querySelectorAll("[data-medicine-list] .doctor-form-medicine")];
        rows.forEach((row, index) => {
            row.querySelector("[data-medicine-number]").textContent = String(index + 1);
            row.querySelectorAll("[data-name]").forEach(input => {
                input.name = "medicines[" + index + "]." + input.dataset.name;
            });
            row.querySelector("[data-remove-medicine]").disabled = rows.length === 1;
        });
    }

    function addMedicine(focusNewRow = true) {
        const template = document.querySelector("#medicine-row-template");
        const list = document.querySelector("[data-medicine-list]");
        if (!template || !list) return;
        list.appendChild(template.content.cloneNode(true));
        renumberMedicines();
        if (focusNewRow) list.lastElementChild.querySelector("[data-name='medicineName']").focus();
    }

    document.querySelector("[data-add-medicine]")?.addEventListener("click", () => addMedicine());
    document.querySelector("[data-medicine-list]")?.addEventListener("click", event => {
        const button = event.target.closest("[data-remove-medicine]");
        if (!button) return;
        button.closest(".doctor-form-medicine").remove();
        renumberMedicines();
    });

    document.querySelectorAll("[data-section-toggle]").forEach(toggle => {
        const section = document.getElementById(toggle.dataset.sectionToggle + "-section");
        if (!section) return;
        const sync = () => {
            section.hidden = !toggle.checked;
            section.querySelectorAll("input,select,textarea,button").forEach(control => {
                control.disabled = !toggle.checked;
            });
        };
        toggle.addEventListener("change", sync);
        sync();
    });

    if (page.dataset.doctorForm === "prescription") addMedicine(false);

    function addPreviewLine(label, value) {
        if (!value || !previewContent) return;
        const section = document.createElement("div");
        section.className = "doctor-form-preview-group";
        const heading = document.createElement("strong");
        heading.textContent = label;
        const paragraph = document.createElement("p");
        paragraph.textContent = value;
        section.append(heading, paragraph);
        previewContent.appendChild(section);
    }

    function value(name) {
        return (form.elements.namedItem(name)?.value || "").trim();
    }

    function examinationPreview() {
        addPreviewLine("Triệu chứng chính", value("chiefComplaint"));
        addPreviewLine("Tiền sử", value("medicalHistory"));
        addPreviewLine("Thị lực không kính", "OD: " + (value("odUncorrected") || "—") + " · OS: " + (value("osUncorrected") || "—"));
        addPreviewLine("Thị lực có kính", "OD: " + (value("odCorrected") || "—") + " · OS: " + (value("osCorrected") || "—"));
        addPreviewLine("Nhãn áp (mmHg)", "OD: " + (value("odIop") || "—") + " · OS: " + (value("osIop") || "—"));
        addPreviewLine("Bán phần trước", value("anteriorFindings"));
        addPreviewLine("Bán phần sau", value("posteriorFindings"));
        addPreviewLine("Chẩn đoán lâm sàng", value("clinicalDiagnosis"));
        addPreviewLine("Kết quả khám", value("examinationResult"));
        addPreviewLine("Kết luận và hướng xử trí", value("conclusion"));
        addPreviewLine("Ngày tái khám", value("followUpDate"));
    }

    function prescriptionPreview() {
        if (form.elements.namedItem("includeMedication").checked) {
            document.querySelectorAll("[data-medicine-list] .doctor-form-medicine").forEach((row, index) => {
                const get = key => (row.querySelector("[data-name='" + key + "']")?.value || "").trim();
                const summary = [
                    get("medicineName") || "Chưa nhập tên",
                    get("strength"),
                    get("dosage"),
                    get("frequency"),
                    get("duration"),
                    get("quantity") ? get("quantity") + " " + get("unit") : "",
                    get("instructions")
                ].filter(Boolean).join(" · ");
                addPreviewLine("Thuốc " + (index + 1), summary);
            });
        }
        if (form.elements.namedItem("includeGlasses").checked) {
            const eye = prefix => ["SPH " + (value(prefix + "Sph") || "—"), "CYL " + (value(prefix + "Cyl") || "—"),
                "AXIS " + (value(prefix + "Axis") || "—"), "ADD " + (value(prefix + "Add") || "—")].join(" · ");
            addPreviewLine("Kính mắt phải (OD)", eye("od"));
            addPreviewLine("Kính mắt trái (OS)", eye("os"));
            addPreviewLine("PD / Loại kính", [value("pd") ? value("pd") + " mm" : "", form.elements.namedItem("lensType").selectedOptions[0]?.textContent].filter(Boolean).join(" · "));
            addPreviewLine("Ghi chú về kính", value("glassesNotes"));
        }
        addPreviewLine("Lời dặn của bác sĩ", value("doctorNotes"));
        addPreviewLine("Ngày tái khám", value("followUpDate"));
    }

    function closePreview() {
        if (!modal || modal.hidden) return;
        modal.hidden = true;
        document.body.style.overflow = "";
        returnFocus?.focus();
    }

    document.querySelector("[data-preview-button]")?.addEventListener("click", event => {
        if (!modal || !previewContent) return;
        returnFocus = event.currentTarget;
        previewContent.replaceChildren();
        if (page.dataset.doctorForm === "examination") examinationPreview();
        else prescriptionPreview();
        if (!previewContent.childElementCount) addPreviewLine("Nội dung", "Chưa có dữ liệu để xem trước.");
        modal.hidden = false;
        document.body.style.overflow = "hidden";
        modal.querySelector("[data-close-preview]:not(.doctor-form-modal-backdrop)")?.focus();
    });

    modal?.querySelectorAll("[data-close-preview]").forEach(button => button.addEventListener("click", closePreview));
    document.addEventListener("keydown", event => {
        if (event.key === "Escape") closePreview();
    });
})();
