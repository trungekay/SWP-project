(() => {
  const input = document.getElementById('catalogImageFile');
  const fileName = document.getElementById('catalogFileName');
  const previewWrap = document.getElementById('catalogSelectedImage');
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
})();
