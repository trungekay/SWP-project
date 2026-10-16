document.addEventListener('DOMContentLoaded', () => {
  const toast = document.getElementById('medicineSuccessToast');
  if (toast) {
    window.setTimeout(() => {
      toast.remove();
      const url = new URL(window.location.href);
      ['created', 'updated', 'deleted'].forEach((key) => url.searchParams.delete(key));
      window.history.replaceState(null, '', url);
    }, 3000);
  }

  const search = document.getElementById('medicineSearch');
  if (search) {
    search.value = '';
    const rows = [...document.querySelectorAll('#medicineView .catalog-table tbody tr')];
    const empty = document.getElementById('medicineEmpty');
    const filter = () => {
      const term = search.value.trim().toLocaleLowerCase('vi');
      let count = 0;
      rows.forEach((row) => {
        row.hidden = !row.textContent.toLocaleLowerCase('vi').includes(term);
        if (!row.hidden) count++;
      });
      empty.hidden = count > 0;
    };
    search.addEventListener('input', filter);
    filter();

    const dialog = document.getElementById('medicineDeleteDialog');
    let pendingForm = null;
    document.querySelectorAll('.medicine-delete-form').forEach((form) => {
      form.querySelector('.catalog-delete').addEventListener('click', () => {
        pendingForm = form;
        document.getElementById('medicineDeleteName').textContent = `“${form.dataset.name}”`;
        dialog.showModal();
      });
    });
    document.getElementById('medicineDeleteCancel').addEventListener('click', () => dialog.close());
    document.getElementById('medicineDeleteConfirm').addEventListener('click', () => {
      if (!pendingForm) return;
      const form = pendingForm;
      pendingForm = null;
      form.submit();
    });
    dialog.addEventListener('close', () => { pendingForm = null; });
    dialog.addEventListener('click', (event) => {
      if (event.target === dialog) dialog.close();
    });
  }

  const input = document.getElementById('medicineImageFile');
  const fileName = document.getElementById('medicineFileName');
  const previewWrap = document.getElementById('medicineSelectedImage');
  const preview = previewWrap?.querySelector('img');
  if (!input || !fileName || !previewWrap || !preview) return;

  let previewUrl;
  input.addEventListener('change', () => {
    if (previewUrl) URL.revokeObjectURL(previewUrl);
    previewUrl = undefined;
    const file = input.files?.[0];
    fileName.textContent = file ? file.name : 'Chưa chọn ảnh mới';
    fileName.classList.toggle('has-file', Boolean(file));
    previewWrap.hidden = !file;
    if (file) {
      previewUrl = URL.createObjectURL(file);
      preview.src = previewUrl;
    } else {
      preview.removeAttribute('src');
    }
  });
  window.addEventListener('pagehide', () => {
    if (previewUrl) URL.revokeObjectURL(previewUrl);
  });
});
