(() => {
    "use strict";
    const element = document.getElementById("invoiceMedicalRecord");
    if (!element) return;

    const modal = bootstrap.Modal.getOrCreateInstance(element);
    const body = element.querySelector(".modal-body");
    const title = element.querySelector(".modal-title");
    const titleLabel = title.textContent.trim();
    const endpoint = new URL(element.dataset.url, location.origin);
    let currentAppointment;
    let revision = 0;
    let timer;

    const showMessage = (message, kind) => {
        const alert = document.createElement("div");
        alert.className = "alert alert-" + kind;
        alert.textContent = message;
        body.prepend(alert);
    };

    async function render(form = null, paid = false) {
        clearTimeout(timer);
        const currentRevision = ++revision;
        const url = new URL(endpoint);
        url.searchParams.set("appointmentId", currentAppointment);
        try {
            const response = await fetch(url, form ? { method: "POST", body: form } : {});
            if (response.redirected || !response.ok) throw new Error();
            const html = await response.text();
            if (currentRevision !== revision) return;
            body.innerHTML = html;
            if (paid) showMessage(element.dataset.paid, "success");
            const poll = body.querySelector("[data-procedure-poll]");
            if (poll) {
                const qr = poll.querySelector("[data-procedure-qr]");
                if (qr?.dataset.payload && typeof QRCode !== "undefined") {
                    new QRCode(qr, { text: qr.dataset.payload, width: 210, height: 210 });
                }
                timer = setTimeout(() => checkPayment(poll, currentRevision), 3500);
            }
        } catch {
            if (currentRevision !== revision) return;
            body.replaceChildren();
            showMessage(element.dataset.loadError, "danger");
        }
    }

    async function checkPayment(poll, currentRevision) {
        const data = new URLSearchParams({
            appointmentId: currentAppointment,
            csrfToken: poll.dataset.csrf,
            orderCode: poll.dataset.order,
            action: "checkProcedureQr"
        });
        try {
            const response = await fetch(endpoint, { method: "POST", headers: { Accept: "application/json" }, body: data });
            if (currentRevision !== revision) return;
            const result = await response.json();
            if (currentRevision !== revision) return;
            if (result.status === "Paid" || result.status === "Cancelled") {
                await render(null, result.status === "Paid");
                if (currentRevision + 1 === revision && result.status === "Cancelled") {
                    showMessage(element.dataset.qrCancelled, "warning");
                }
                return;
            }
            if (response.status === 401 || response.status === 403) {
                showMessage(element.dataset.sessionExpired, "warning");
                return;
            }
        } catch {
            // A transient network error leaves the same payment open for the next check.
        }
        if (currentRevision === revision) timer = setTimeout(() => checkPayment(poll, currentRevision), 3500);
    }

    function open(appointmentId) {
        currentAppointment = appointmentId;
        title.textContent = titleLabel + " #APT-" + appointmentId;
        body.textContent = element.dataset.loading;
        modal.show();
        render();
    }

    document.querySelectorAll("[data-invoice-record]").forEach(button => {
        button.addEventListener("click", () => open(button.dataset.invoiceRecord));
    });
    element.addEventListener("hidden.bs.modal", () => {
        revision++;
        clearTimeout(timer);
        body.replaceChildren();
    });
    body.addEventListener("change", event => {
        if (event.target.name !== "action") return;
        const confirmation = event.target.form.querySelector("[data-cash-confirmation]");
        if (!confirmation) return;
        const cash = event.target.value === "procedureCash";
        confirmation.hidden = !cash;
        confirmation.querySelector("input").required = cash;
    });
    body.addEventListener("submit", event => {
        if (!event.target.matches("[data-procedure-form]")) return;
        event.preventDefault();
        const form = new URLSearchParams(new FormData(event.target));
        event.submitter.disabled = true;
        render(form);
    });

    const requested = new URLSearchParams(location.search).get("openRecord");
    if (requested && [...document.querySelectorAll("[data-invoice-record]")]
        .some(button => button.dataset.invoiceRecord === requested)) open(requested);
})();
