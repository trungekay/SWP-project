(() => {
    "use strict";

    const page = document.querySelector("[data-doctor-form]");
    if (!page) return;

    if (page.dataset.doctorForm === "examination") {
        const form = page.querySelector("#examination-form");
        const acuityInputs = [...form.querySelectorAll("[data-visual-acuity]")];
        const iopInputs = [...form.querySelectorAll('[name="odIop"], [name="osIop"]')];
        const showInputError = (input, message) => {
            let feedback = input.parentElement.querySelector(".doctor-form-input-error");
            if (!feedback) {
                feedback = document.createElement("small");
                feedback.className = "doctor-form-input-error";
                feedback.id = input.name + "-error";
                input.parentElement.appendChild(feedback);
            }
            feedback.textContent = message;
            input.setAttribute("aria-invalid", String(Boolean(message)));
            if (message) input.setAttribute("aria-describedby", feedback.id);
            else input.removeAttribute("aria-describedby");
        };
        const validateAcuity = input => {
            const normalized = input.value.trim().replace(',', '.');
            const valid = normalized === "" || (/^[0-9]+(?:\.[0-9]+)?$/.test(normalized)
                && Number(normalized) <= 10
                && (Number(normalized) < 1 || Number.isInteger(Number(normalized))));
            const message = valid ? "" : "Nh\u1eadp s\u1ed1 nguy\u00ean t\u1eeb 1 \u0111\u1ebfn 10; ch\u1ec9 gi\u00e1 tr\u1ecb d\u01b0\u1edbi 1 \u0111\u01b0\u1ee3c c\u00f3 ph\u1ea7n th\u1eadp ph\u00e2n.";
            showInputError(input, message);
            if (/^[0-9]+(?:\.[0-9]+)?$/.test(normalized)) input.value = normalized;
            return valid;
        };
        const validateIop = input => {
            const raw = input.value.trim();
            const valid = !input.validity.badInput && (raw === "" || (/^[0-9]+(?:\.[0-9])?$/.test(raw)
                && Number(raw) >= 5 && Number(raw) <= 70));
            showInputError(input, valid ? "" : "Nh\u00e3n \u00e1p ph\u1ea3i t\u1eeb 5 \u0111\u1ebfn 70 mmHg, b\u01b0\u1edbc 0.1 (t\u1ed1i \u0111a 1 ch\u1eef s\u1ed1 th\u1eadp ph\u00e2n).");
            return valid;
        };
        acuityInputs.forEach(input => {
            input.addEventListener("blur", () => validateAcuity(input));
            input.addEventListener("input", () => {
                if (input.getAttribute("aria-invalid") === "true") validateAcuity(input);
            });
        });
        iopInputs.forEach(input => {
            input.addEventListener("blur", () => validateIop(input));
            input.addEventListener("input", () => validateIop(input));
        });
        form.addEventListener("invalid", event => {
            if (iopInputs.includes(event.target)) {
                validateIop(event.target);
                event.preventDefault();
                event.target.focus();
            }
        }, true);
        form.addEventListener("submit", event => {
            let firstInvalid = null;
            acuityInputs.forEach(input => {
                if (!validateAcuity(input) && !firstInvalid) firstInvalid = input;
            });
            iopInputs.forEach(input => {
                if (!validateIop(input) && !firstInvalid) firstInvalid = input;
            });
            if (firstInvalid) {
                event.preventDefault();
                firstInvalid.focus();
            }
        });
    }

    function syncDoseRow(row) {
        const selected = row.querySelector("[data-dose-toggle]");
        const dose = row.querySelector("[data-dose-input]");
        const medicationToggle = document.querySelector('[data-section-toggle="medication"]');
        if (!selected || !dose) return;
        const active = (!medicationToggle || medicationToggle.checked) && selected.checked;
        row.classList.toggle("is-selected", selected.checked);
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
                empty.textContent = "Kh\u00f4ng c\u00f3 trong danh m\u1ee5c. B\u1ea1n v\u1eabn c\u00f3 th\u1ec3 nh\u1eadp t\u00ean thu\u1ed1c n\u00e0y.";
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
        const syncSurgery = open => {
            surgeryPanel.hidden = !open;
            surgeryToggle.setAttribute("aria-expanded", String(open));
            surgeryToggle.classList.toggle("is-active", open);
        };
        syncSurgery(page.dataset.surgeryInitial === "true");
        surgeryToggle.addEventListener("click", () => syncSurgery(surgeryPanel.hidden));
    }
    if (page.dataset.readonly === "true") {
        page.querySelectorAll("#examination-form input, #examination-form textarea, #examination-form select, #examination-form button")
            .forEach(control => { control.disabled = true; });
    }
})();
