(() => {
    "use strict";

    const page = document.querySelector("[data-doctor-form]");
    if (!page) return;

    if (page.dataset.doctorForm === "examination") {
        const form = page.querySelector("#examination-form");
        const acuityInputs = [...form.querySelectorAll("[data-visual-acuity]")];
        const iopInputs = [...form.querySelectorAll('[name="odIop"], [name="osIop"]')];
        // Hiển thị lỗi cạnh ô nhập và cập nhật thuộc tính hỗ trợ trình đọc màn hình.
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
        // Kiểm tra thang thị lực; chỉ giá trị dưới 1 được có phần thập phân.
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
        // Kiểm tra nhãn áp trong khoảng 5–70 mmHg với tối đa một chữ số thập phân.
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

    // Chỉ yêu cầu liều dùng khi buổi uống và phần đơn thuốc đều được chọn.
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

    // Đồng bộ số thứ tự, tên trường gửi lên server và giới hạn số dòng thuốc.
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

    // Thêm một dòng thuốc từ mẫu và chuyển focus tới tên thuốc khi cần.
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
        // Bật hoặc tắt toàn bộ ô nhập theo lựa chọn kê thuốc/kính.
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
        const form = page.querySelector("#prescription-form");
        const glassesInputs = [...form.querySelectorAll("[data-glasses-number]")];
        const validateGlassesNumber = input => {
            const raw = input.value.trim();
            const min = Number(input.dataset.min);
            const max = Number(input.dataset.max);
            const step = Number(input.dataset.step);
            const number = Number(raw);
            const numericFormat = step === 1 ? /^[0-9]+$/ : /^[+-]?[0-9]+(?:\.[0-9]+)?$/;
            const valid = raw === "" || (numericFormat.test(raw)
                && number >= min && number <= max
                && Math.abs(number / step - Math.round(number / step)) < 1e-9);
            const label = input.getAttribute("aria-label") || "PD";
            const message = valid ? "" : label + " phải từ " + min + " đến " + max
                + (step === 1 ? " (số nguyên)." : " và theo bước " + step + ".");
            let feedback = input.parentElement.querySelector(".doctor-form-input-error");
            if (!feedback) {
                feedback = document.createElement("small");
                feedback.className = "doctor-form-input-error";
                feedback.id = input.name + "-error";
                input.parentElement.appendChild(feedback);
            }
            feedback.textContent = message;
            input.setAttribute("aria-invalid", String(!valid));
            if (valid) input.removeAttribute("aria-describedby");
            else input.setAttribute("aria-describedby", feedback.id);
            return valid;
        };
        glassesInputs.forEach(input => {
            input.addEventListener("input", () => {
                const start = input.selectionStart;
                const end = input.selectionEnd;
                input.value = input.value.replace(/,/g, ".");
                input.setSelectionRange(start, end);
                validateGlassesNumber(input);
            });
            input.addEventListener("blur", () => validateGlassesNumber(input));
        });
        form.addEventListener("submit", event => {
            let firstInvalid = null;
            glassesInputs.forEach(input => {
                if (!input.disabled && !validateGlassesNumber(input) && !firstInvalid) firstInvalid = input;
            });
            if (firstInvalid) {
                event.preventDefault();
                firstInvalid.focus();
            }
        });
        const list = document.querySelector("[data-medicine-list]");
        const catalog = [...document.querySelectorAll("#doctor-medicine-catalog option")]
            .map(option => option.value).filter(Boolean);
        // Chuẩn hóa tiếng Việt để tìm tên thuốc không phụ thuộc dấu và chữ hoa.
        const normalize = value => value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLocaleLowerCase("vi");
        // Đóng danh sách gợi ý và xóa trạng thái lựa chọn cho trình đọc màn hình.
        const closeSuggestions = combo => {
            const input = combo.querySelector("[data-name='medicineName']");
            const suggestions = combo.querySelector("[data-medicine-suggestions]");
            suggestions.hidden = true;
            input.setAttribute("aria-expanded", "false");
            input.removeAttribute("aria-activedescendant");
        };
        // Đánh dấu gợi ý đang chọn khi điều hướng bằng bàn phím.
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
        // Lọc tối đa tám thuốc phù hợp và hiển thị danh sách gợi ý.
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
        // Đưa thuốc được chọn vào ô nhập và đóng danh sách gợi ý.
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
        // Đồng bộ trạng thái hiển thị của phần chỉ định phẫu thuật.
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
