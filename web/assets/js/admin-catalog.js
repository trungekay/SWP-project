document.addEventListener('DOMContentLoaded', () => {
  const tabs = [...document.querySelectorAll('.catalog-tab')];
  const servicesView = document.getElementById('servicesView');
  const suppliesView = document.getElementById('suppliesView');
  const cards = [...document.querySelectorAll('.catalog-service')];
  const rows = [...document.querySelectorAll('#suppliesView .catalog-table tbody tr')];
  const successToast = document.getElementById('catalogSuccessToast');
  if (successToast) {
    window.setTimeout(() => {
      successToast.remove();
      const url = new URL(window.location.href);
      url.searchParams.delete('created');
      url.searchParams.delete('updated');
      url.searchParams.delete('deleted');
      window.history.replaceState(null, '', url);
    }, 3000);
  }
  const deleteDialog = document.getElementById('catalogDeleteDialog');
  let pendingDeleteForm = null;

  document.querySelectorAll('.catalog-delete-form').forEach((form) => {
    form.querySelector('.catalog-delete').addEventListener('click', () => {
      pendingDeleteForm = form;
      document.getElementById('catalogDeleteKind').textContent = form.dataset.kind;
      document.getElementById('catalogDeleteName').textContent = `\u201c${form.dataset.name}\u201d`;
      deleteDialog.showModal();
    });
  });
  document.getElementById('catalogDeleteCancel').addEventListener('click', () => deleteDialog.close());
  document.getElementById('catalogDeleteConfirm').addEventListener('click', () => {
    if (!pendingDeleteForm) return;
    const form = pendingDeleteForm;
    pendingDeleteForm = null;
    form.submit();
  });
  deleteDialog.addEventListener('close', () => { pendingDeleteForm = null; });
  deleteDialog.addEventListener('click', (event) => {
    if (event.target === deleteDialog) deleteDialog.close();
  });

  function setTab(tab, updateUrl = true) {
    tab = tab === 'supplies' ? 'supplies' : 'services';
    servicesView.hidden = tab !== 'services';
    suppliesView.hidden = tab !== 'supplies';
    tabs.forEach((button) => {
      const active = button.dataset.tab === tab;
      button.classList.toggle('is-active', active);
      button.setAttribute('aria-selected', String(active));
      button.tabIndex = active ? 0 : -1;
    });
    document.querySelectorAll('[data-catalog-subnav]').forEach((link) => {
      const active = link.dataset.catalogSubnav === tab;
      link.classList.toggle('active-sub', active);
      if (active) link.setAttribute('aria-current', 'page');
      else link.removeAttribute('aria-current');
    });
    if (updateUrl) {
      const url = new URL(window.location.href);
      url.searchParams.set('tab', tab);
      window.history.replaceState(null, '', url);
    }
  }
  tabs.forEach((button) => button.addEventListener('click', () => setTab(button.dataset.tab)));
  document.querySelectorAll('[data-catalog-subnav]').forEach((link) => {
    link.addEventListener('click', (event) => {
      event.preventDefault();
      setTab(link.dataset.catalogSubnav);
    });
  });
  window.addEventListener('popstate', () => {
    setTab(new URL(window.location.href).searchParams.get('tab'), false);
  });
  setTab(new URL(window.location.href).searchParams.get('tab'), false);
  tabs.forEach((button, index) => button.addEventListener('keydown', (event) => {
    if (event.key !== 'ArrowLeft' && event.key !== 'ArrowRight') return;
    event.preventDefault();
    const next = tabs[(index + (event.key === 'ArrowRight' ? 1 : tabs.length - 1)) % tabs.length];
    setTab(next.dataset.tab);
    next.focus();
  }));

  function filterServices() {
    const term = document.getElementById('serviceSearch').value.trim().toLocaleLowerCase('vi');
    const specialty = document.getElementById('specialtySelect').value;
    let count = 0;
    cards.forEach((card) => {
      const visible = (specialty === 'all' || card.dataset.specialty === specialty)
        && card.textContent.toLocaleLowerCase('vi').includes(term);
      card.hidden = !visible;
      if (visible) count++;
    });
    document.getElementById('serviceEmpty').hidden = count > 0;
  }
  document.getElementById('serviceSearch').addEventListener('input', filterServices);
  document.getElementById('specialtySelect').addEventListener('change', filterServices);
  filterServices();

  document.getElementById('supplySearch').addEventListener('input', (event) => {
    const term = event.target.value.trim().toLocaleLowerCase('vi');
    let count = 0;
    rows.forEach((row) => {
      row.hidden = !row.textContent.toLocaleLowerCase('vi').includes(term);
      if (!row.hidden) count++;
    });
    document.getElementById('supplyEmpty').hidden = count > 0;
  });
  document.getElementById('supplyEmpty').hidden = rows.length > 0;
});
