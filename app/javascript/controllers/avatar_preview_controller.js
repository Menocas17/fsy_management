import { Controller } from '@hotwired/stimulus';

// Muestra la foto elegida y, antes de subirla, la achica en el teléfono a maxSize px por lado: una foto de
// 12 MP procesada en el servidor pasa de los 512 MB del plan gratis de Render. Si el navegador no puede
// achicarla, se sube la original (el servidor la procesa igual, más despacio).
export default class extends Controller {
  static targets = ['input', 'image', 'placeholder'];
  static values = { maxSize: { type: Number, default: 1600 } };

  connect() {
    this.form = this.inputTarget.form;
    this.holdSubmit = this.#holdSubmit.bind(this);
    this.form?.addEventListener('submit', this.holdSubmit);
  }

  disconnect() {
    this.form?.removeEventListener('submit', this.holdSubmit);
    this.#revoke();
  }

  preview() {
    const [file] = this.inputTarget.files;
    if (!file || !file.type.startsWith('image/')) return;

    this.#revoke();
    this.objectUrl = URL.createObjectURL(file);
    this.imageTarget.src = this.objectUrl;
    this.imageTarget.classList.remove('hidden');
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add('hidden');

    this.pending = this.#downscale(file).then((smaller) => {
      if (smaller && this.inputTarget.files[0] === file) this.#replace(smaller);
    }).finally(() => { this.pending = null; });
  }

  // Si mandan el formulario mientras la foto se achica (es menos de un segundo), espera y lo manda después.
  async #holdSubmit(event) {
    if (!this.pending) return;

    event.preventDefault();
    event.stopImmediatePropagation();
    const submitter = event.submitter;
    await this.pending;
    this.form.requestSubmit(submitter);
  }

  async #downscale(file) {
    try {
      const bitmap = await createImageBitmap(file, { imageOrientation: 'from-image' });
      const scale = Math.min(1, this.maxSizeValue / Math.max(bitmap.width, bitmap.height));
      const width = Math.round(bitmap.width * scale);
      const height = Math.round(bitmap.height * scale);

      const canvas = document.createElement('canvas');
      canvas.width = width;
      canvas.height = height;
      const context = canvas.getContext('2d');
      context.fillStyle = '#fff'; // un PNG transparente pasado a JPEG quedaría con fondo negro
      context.fillRect(0, 0, width, height);
      context.drawImage(bitmap, 0, 0, width, height);
      bitmap.close();

      const blob = await new Promise((resolve) => canvas.toBlob(resolve, 'image/jpeg', 0.85));
      if (!blob || (scale === 1 && blob.size >= file.size)) return null;

      const name = file.name.replace(/\.[^.]+$/, '') + '.jpg';
      return new File([blob], name, { type: 'image/jpeg', lastModified: Date.now() });
    } catch {
      return null;
    }
  }

  #replace(file) {
    const transfer = new DataTransfer();
    transfer.items.add(file);
    this.inputTarget.files = transfer.files;
  }

  #revoke() {
    if (this.objectUrl) URL.revokeObjectURL(this.objectUrl);
    this.objectUrl = null;
  }
}
