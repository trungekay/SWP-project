(() => {
    "use strict";

    const page = document.querySelector("[data-doctor-form]");
    if (!page) return;

    function syncDoseRow(row) {
        const selected = row.querySelector("[data-dose-toggle]");
        const dose = row.querySelector("[data-dose-input]");
        const medicationToggle = document.querySelector('[data-section-toggle="medication"]');
        if (!selected || !dose) return;
        const active = (!medicationToggle || medicationToggle.checked) && selected.checked;
        dose.disabled = !active;
        dose.required = active;
    }

    function renumberMedicines() {
        const rows = [...document.querySelectorAll("[data-medicine-list] .doctor-form-medicine")];
        const medicationToggle = document.querySelector('[data-section-toggle="medication"]');
        rows.forEach((row, index) => {
            row.querySelector("[data-medicine-number]").textContent = String(index + 1);
            row.querySelectorAll("[data-name]").forEach(input => {
                input.name = "medicines[" + index + "]." + input.dataset.name;
            });
            const medicineName = row.querySelector("[data-name='medicineName']");
            const medicineLabel = row.querySelector(".doctor-form-medicine-name label");
            const suggestions = row.querySelector("[data-medicine-suggestions]");
            if (medicineName && medicineLabel && suggestions) {
                medicineName.id = "medicine-name-" + index;
                medicineLabel.htmlFor = medicineName.id;
                suggestions.id = "medicine-suggestions-" + index;
                medicineName.setAttribute("aria-controls", suggestions.id);
            }
            row.querySelector("[data-remove-medicine]").disabled =
                rows.length === 1 || (medicationToggle && !medicationToggle.checked);
            row.querySelectorAll("[data-dose-row]").forEach(syncDoseRow);
        });
        const addButton = document.querySelector("[data-add-medicine]");
        if (addButton) addButton.disabled = rows.length >= 20 || (medicationToggle && !medicationToggle.checked);
    }

    function addMedicine(focusNewRow = true) {
        const template = document.querySelector("#medicine-row-template");
        const list = document.querySelector("[data-medicine-list]");
        if (!template || !list || list.children.length >= 20) return;
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
    document.querySelector("[data-medicine-list]")?.addEventListener("change", event => {
        if (event.target.matches("[data-dose-toggle]")) syncDoseRow(event.target.closest("[data-dose-row]"));
    });

    document.querySelectorAll("[data-section-toggle]").forEach(toggle => {
        const section = document.getElementById(toggle.dataset.sectionToggle + "-section");
        if (!section) return;
        const sync = () => {
            section.hidden = !toggle.checked;
            section.querySelectorAll("input,select,textarea,button").forEach(control => {
                control.disabled = !toggle.checked;
            });
            if (toggle.dataset.sectionToggle === "medication") renumberMedicines();
        };
        toggle.addEventListener("change", sync);
        sync();
    });

    if (page.dataset.doctorForm === "prescription") {
        const list = document.querySelector("[data-medicine-list]");
        const catalog = [...document.querySelectorAll("#doctor-medicine-catalog option")]
            .map(option => option.value).filter(Boolean);
        const normalize = value => value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLocaleLowerCase("vi");
        const closeSuggestions = combo => {
            const input = combo.querySelector("[data-name='medicineName']");
            const suggestions = combo.querySelector("[data-medicine-suggestions]");
            suggestions.hidden = true;
            input.setAttribute("aria-expanded", "false");
            input.removeAttribute("aria-activedescendant");
        };
        const setActiveSuggestion = (combo, index) => {
            const input = combo.querySelector("[data-name='medicineName']");
            const options = [...combo.querySelectorAll("[data-medicine-option]")];
            options.forEach((option, optionIndex) => {
                const active = optionIndex === index;
                option.classList.toggle("is-active", active);
                option.setAttribute("aria-selected", String(active));
                if (active) option.scrollIntoView({ block: "nearest" });
            });
            if (options[index]) input.setAttribute("aria-activedescendant", options[index].id);
            else input.removeAttribute("aria-activedescendant");
        };
        const renderSuggestions = combo => {
            list.querySelectorAll("[data-medicine-combobox]").forEach(other => {
                if (other !== combo) closeSuggestions(other);
            });
            const input = combo.querySelector("[data-name='medicineName']");
            const suggestions = combo.querySelector("[data-medicine-suggestions]");
            const query = normalize(input.value.trim());
            const matches = catalog.filter(name => normalize(name).includes(query))
                .sort((a, b) => Number(normalize(b).startsWith(query)) - Number(normalize(a).startsWith(query)))
                .slice(0, 8);
            suggestions.replaceChildren();
            if (matches.length === 0) {
                const empty = document.createElement("div");
                empty.className = "doctor-form-suggestion-empty";
                empty.textContent = "Không có trong danh mục. Bạn vẫn có thể nhập tên thuốc này.";
                suggestions.appendChild(empty);
            } else {
                matches.forEach((name, index) => {
                    const option = document.createElement("button");
                    option.type = "button";
                    option.className = "doctor-form-suggestion";
                    option.id = suggestions.id + "-" + index;
                    option.setAttribute("role", "option");
                    option.setAttribute("aria-selected", "false");
                    option.dataset.medicineOption = name;
                    const icon = document.createElement("i");
                    icon.className = "bi bi-capsule";
                    icon.setAttribute("aria-hidden", "true");
                    const label = document.createElement("span");
                    label.textContent = name;
                    option.append(icon, label);
                    suggestions.appendChild(option);
                });
            }
            suggestions.hidden = false;
            input.setAttribute("aria-expanded", "true");
            input.removeAttribute("aria-activedescendant");
        };
        const selectSuggestion = option => {
            const combo = option.closest("[data-medicine-combobox]");
            const input = combo.querySelector("[data-name='medicineName']");
            input.value = option.dataset.medicineOption;
            input.dispatchEvent(new Event("change", { bubbles: true }));
            input.focus();
            closeSuggestions(combo);
        };
        list?.addEventListener("focusin", event => {
            if (event.target.matches("[data-name='medicineName']")) {
                renderSuggestions(event.target.closest("[data-medicine-combobox]"));
            }
        });
        list?.addEventListener("input", event => {
            if (event.target.matches("[data-name='medicineName']")) {
                renderSuggestions(event.target.closest("[data-medicine-combobox]"));
            }
        });
        list?.addEventListener("keydown", event => {
            if (!event.target.matches("[data-name='medicineName']")) return;
            const combo = event.target.closest("[data-medicine-combobox]");
            const suggestions = combo.querySelector("[data-medicine-suggestions]");
            if (event.key === "Escape") { closeSuggestions(combo); return; }
            if (event.key !== "ArrowDown" && event.key !== "ArrowUp" && event.key !== "Enter") return;
            if (suggestions.hidden && event.key !== "Enter") renderSuggestions(combo);
            const options = [...suggestions.querySelectorAll("[data-medicine-option]")];
            if (options.length === 0 || suggestions.hidden) return;
            const active = options.findIndex(option => option.classList.contains("is-active"));
            if (event.key === "Enter") {
                if (active >= 0) { event.preventDefault(); selectSuggestion(options[active]); }
            } else {
                event.preventDefault();
                setActiveSuggestion(combo, event.key === "ArrowDown"
                    ? (active + 1) % options.length
                    : (active - 1 + options.length) % options.length);
            }
        });
        list?.addEventListener("click", event => {
            const option = event.target.closest("[data-medicine-option]");
            if (option) selectSuggestion(option);
        });
        document.addEventListener("pointerdown", event => {
            if (!event.target.closest("[data-medicine-combobox]")) {
                list?.querySelectorAll("[data-medicine-combobox]").forEach(closeSuggestions);
            }
        });
        if (list && list.children.length === 0) addMedicine(false);
        else renumberMedicines();
    }

    const surgeryToggle = page.querySelector("[data-surgery-toggle]");
    const surgeryPanel = page.querySelector("[data-surgery-panel]");
    if (surgeryToggle && surgeryPanel) {
        const canRefer = page.dataset.surgeryCanRefer === "true";
        const controls = [...surgeryPanel.querySelectorAll("[data-surgery-required]")];
        const submit = page.querySelector("[data-exam-submit]");
        const submitLabel = submit?.querySelector("[data-exam-submit-label]");
        const submitIcon = submit?.querySelector("[data-exam-submit-icon]");
        const syncSurgery = open => {
            surgeryPanel.hidden = !open;
            surgeryToggle.setAttribute("aria-expanded", String(open));
            surgeryToggle.classList.toggle("is-active", open);
            controls.forEach(control => {
                control.disabled = !open || !canRefer;
                control.required = open && canRefer;
            });
            if (submit && submitLabel && submitIcon) {
                const refer = open && canRefer;
                submit.value = refer ? "refer" : "save";
                submitLabel.textContent = refer ? submit.dataset.labelRefer : submit.dataset.labelSave;
                submitIcon.className = refer ? "bi bi-send" : "bi bi-cloud-arrow-up";
            }
        };
        syncSurgery(page.dataset.surgeryInitial === "true");
        surgeryToggle.addEventListener("click", () => syncSurgery(surgeryPanel.hidden));
    }
    if (page.dataset.readonly === "true") {
        page.querySelectorAll("#examination-form input, #examination-form textarea, #examination-form select, #examination-form button")
            .forEach(control => { control.disabled = true; });
    }
})();
