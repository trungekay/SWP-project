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
  const categoryFilter = document.getElementById('medicineCategoryFilter');
  const categoryTrigger = document.getElementById('medicineCategoryTrigger');
  const categoryMenu = document.getElementById('medicineCategoryMenu');
  if (search) {
    search.value = '';
    const rows = [...document.querySelectorAll('#medicineView .catalog-table tbody tr')];
    const empty = document.getElementById('medicineEmpty');
    const visibleCount = document.getElementById('medicineVisibleCount');
    const categoryLabel = document.getElementById('medicineCategoryLabel');
    const categoryOptions = [...(categoryMenu?.querySelectorAll('.catalog-filter-option') ?? [])];
    let selectedCategory = '';

    const filter = () => {
      const term = search.value.trim().toLocaleLowerCase('vi');
      const matchingRows = new Set(rows.filter((row) =>
        row.textContent.toLocaleLowerCase('vi').includes(term)));
      categoryOptions.forEach((option) => {
        const count = [...matchingRows].filter((row) =>
          option.dataset.category === '' || row.dataset.category === option.dataset.category).length;
        option.querySelector('.catalog-filter-option-count').textContent = count;
      });
      let count = 0;
      rows.forEach((row) => {
        row.hidden = !matchingRows.has(row) ||
          (selectedCategory !== '' && row.dataset.category !== selectedCategory);
        if (!row.hidden) count++;
      });
      empty.hidden = count > 0;
      if (visibleCount) visibleCount.textContent = count;
    };

    const closeMenu = () => {
      if (!categoryMenu) return;
      categoryMenu.hidden = true;
      categoryTrigger.setAttribute('aria-expanded', 'false');
    };

    categoryTrigger?.addEventListener('click', () => {
      if (categoryMenu.hidden) {
        categoryMenu.hidden = false;
        categoryTrigger.setAttribute('aria-expanded', 'true');
        categoryOptions.find((option) => option.dataset.category === selectedCategory)?.focus();
      } else {
        closeMenu();
      }
    });
    categoryMenu?.addEventListener('click', (event) => {
      const option = event.target.closest('.catalog-filter-option');
      if (!option) return;
      selectedCategory = option.dataset.category;
      const label = option.querySelector('.catalog-filter-option-name').textContent.trim();
      categoryLabel.textContent = label;
      categoryTrigger.setAttribute('aria-label', `Lọc theo phân loại: ${label}`);
      categoryFilter.classList.toggle('is-active', selectedCategory !== '');
      categoryOptions.forEach((item) => {
        const selected = item === option;
        item.classList.toggle('is-selected', selected);
        item.setAttribute('aria-pressed', String(selected));
      });
      closeMenu();
      categoryTrigger.focus();
      filter();
    });
    document.addEventListener('click', (event) => {
      if (categoryFilter && !categoryFilter.contains(event.target)) closeMenu();
    });
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && categoryMenu && !categoryMenu.hidden) {
        closeMenu();
        categoryTrigger.focus();
      }
    });
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
