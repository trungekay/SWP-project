document.addEventListener('DOMContentLoaded', () => {
  const $ = (selector) => document.querySelector(selector);
  const $$ = (selector) => [...document.querySelectorAll(selector)];
  const serviceCards = $$('.catalog-service');
  const supplyRows = $$('.catalog-table tbody tr');
  const serviceDialog = $('#serviceDialog');
  const supplyDialog = $('#supplyDialog');
  const money = (amount) => `${new Intl.NumberFormat('vi-VN').format(Number(amount))} VNĐ`;
  let selectedService = null;
  let selectedSupply = null;

  function setTab(tab) {
    $('#servicesView').hidden = tab !== 'services';
    $('#suppliesView').hidden = tab !== 'supplies';
    $$('.catalog-tab').forEach((button) => {
      const active = button.dataset.tab === tab;
      button.classList.toggle('is-active', active);
      button.setAttribute('aria-selected', String(active));
    });
  }
  $$('.catalog-tab').forEach((button) => button.addEventListener('click', () => setTab(button.dataset.tab)));

  function filterServices() {
    const term = $('#serviceSearch').value.trim().toLocaleLowerCase('vi');
    const specialty = $('#specialtySelect').value;
    const status = $('#statusSelect').value;
    let shown = 0;
    serviceCards.forEach((card) => {
      const matches = (specialty === 'all' || card.dataset.specialty === specialty)
        && (status === 'all' || card.dataset.status === status)
        && card.textContent.toLocaleLowerCase('vi').includes(term);
      card.hidden = !matches;
      if (matches) shown++;
    });
    $('#serviceEmpty').hidden = shown > 0;
  }
  ['serviceSearch', 'specialtySelect', 'statusSelect'].forEach((id) => {
    $('#' + id).addEventListener(id === 'serviceSearch' ? 'input' : 'change', filterServices);
  });
  $$('.specialty-link').forEach((button) => button.addEventListener('click', () => {
    $$('.specialty-link').forEach((item) => item.classList.toggle('is-active', item === button));
    $('#specialtySelect').value = button.dataset.specialty;
    setTab('services');
    filterServices();
  }));
  $('#specialtySelect').addEventListener('change', () => {
    $$('.specialty-link').forEach((button) => button.classList.toggle('is-active', button.dataset.specialty === $('#specialtySelect').value));
  });

  $('#supplySearch').addEventListener('input', () => {
    const term = $('#supplySearch').value.trim().toLocaleLowerCase('vi');
    let shown = 0;
    supplyRows.forEach((row) => {
      row.hidden = !row.textContent.toLocaleLowerCase('vi').includes(term);
      if (!row.hidden) shown++;
    });
    $('#supplyEmpty').hidden = shown > 0;
  });

  function openService(card, detailsOnly = false) {
    selectedService = card;
    $('#editServiceName').value = card.querySelector('.catalog-service-name').textContent.trim();
    $('#editServicePrice').value = card.dataset.price;
    $('#editServiceSummary').value = card.querySelector('.catalog-summary').textContent.trim();
    $('#editServiceDescription').value = card.querySelector('.catalog-description').textContent.trim();
    serviceDialog.querySelector('.catalog-dialog-head h2').textContent = detailsOnly ? 'Chi tiết dịch vụ' : 'Cập nhật thông tin dịch vụ';
    serviceDialog.querySelector('.catalog-preview-note').hidden = detailsOnly;
    serviceDialog.querySelector('.catalog-dialog-actions .catalog-primary').hidden = detailsOnly;
    serviceDialog.querySelectorAll('input, textarea').forEach((input) => { input.readOnly = detailsOnly; });
    serviceDialog.showModal();
  }
  serviceCards.forEach((card) => {
    card.querySelector('.catalog-edit').addEventListener('click', () => openService(card));
    card.querySelector('.catalog-detail').addEventListener('click', () => openService(card, true));
  });
  $('#updateService').addEventListener('click', () => openService(serviceCards.find((card) => !card.hidden) || serviceCards[0]));
  $('#serviceForm').addEventListener('submit', (event) => {
    event.preventDefault();
    if (!selectedService) return;
    selectedService.querySelector('.catalog-service-name').textContent = $('#editServiceName').value.trim();
    selectedService.querySelector('.catalog-summary').textContent = $('#editServiceSummary').value.trim();
    selectedService.querySelector('.catalog-description').textContent = $('#editServiceDescription').value.trim();
    selectedService.dataset.price = $('#editServicePrice').value;
    const priceLabel = selectedService.querySelector('.catalog-price span');
    priceLabel.textContent = `${priceLabel.textContent.trim().startsWith('Từ') ? 'Từ ' : ''}${money($('#editServicePrice').value)}`;
    serviceDialog.close();
    filterServices();
  });

  function openSupply(row) {
    selectedSupply = row;
    $('#editSupplyName').value = row.querySelector('td strong').textContent.trim();
    $('#editSupplyQuantity').value = row.dataset.quantity;
    $('#editSupplyPrice').value = row.dataset.price;
    supplyDialog.showModal();
  }
  supplyRows.forEach((row) => row.querySelector('.catalog-supply-edit').addEventListener('click', () => openSupply(row)));
  $('#updateSupply').addEventListener('click', () => openSupply(supplyRows.find((row) => !row.hidden) || supplyRows[0]));
  $('#supplyForm').addEventListener('submit', (event) => {
    event.preventDefault();
    if (!selectedSupply) return;
    selectedSupply.querySelector('td strong').textContent = $('#editSupplyName').value.trim();
    const unit = selectedSupply.cells[2].textContent.trim().split(' ').slice(1).join(' ');
    selectedSupply.cells[2].textContent = `${$('#editSupplyQuantity').value} ${unit}`;
    selectedSupply.cells[3].textContent = money($('#editSupplyPrice').value);
    selectedSupply.dataset.quantity = $('#editSupplyQuantity').value;
    selectedSupply.dataset.price = $('#editSupplyPrice').value;
    const stock = selectedSupply.querySelector('.catalog-stock');
    const low = Number($('#editSupplyQuantity').value) < 10;
    stock.classList.toggle('is-low', low);
    stock.textContent = low ? 'Sắp hết hàng' : 'Còn hàng';
    supplyDialog.close();
  });
  [serviceDialog, supplyDialog].forEach((dialog) => {
    dialog.querySelector('.catalog-close').addEventListener('click', () => dialog.close());
    dialog.querySelector('.catalog-cancel').addEventListener('click', () => dialog.close());
    dialog.addEventListener('click', (event) => { if (event.target === dialog) dialog.close(); });
  });
});
