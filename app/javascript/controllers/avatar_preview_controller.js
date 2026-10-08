import { Controller } from '@hotwired/stimulus';
import { DirectUpload } from '@rails/activestorage';

// Muestra la foto elegida, la achica en el teléfono a maxSize px por lado y la sube en ese momento, directo a
// R2 (DirectUploadsController), mientras se llena el resto del formulario: al guardar solo viaja la referencia
// firmada, y el servidor no recibe cientos de fotos la mañana en que se cargan todas. Si la subida directa
// falla (sin conexión, CORS mal puesto en el bucket), la foto achicada se manda con el formulario como antes.
export default class extends Controller {
  static targets = ['input', 'image', 'placeholder', 'status'];
  static values = { maxSize: { type: Number, default: 1600 }, directUploadUrl: String };

  connect() {
    this.form = this.inputTarget.form;
    this.fieldName = this.inputTarget.name;
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

    // Otra foto elegida antes de que termine la anterior: la anterior ya no cuenta.
    const attempt = (this.attempt = {});
    this.#useFileInput();

    const pending = this.#prepare(file, attempt).finally(() => {
      if (this.pending === pending) this.pending = null;
    });
    this.pending = pending;
  }

  async #prepare(file, attempt) {
    const smaller = await this.#downscale(file);
    if (attempt !== this.attempt) return;
    const chosen = smaller || file;

    if (this.directUploadUrlValue) {
      try {
        const signedId = await this.#upload(chosen, attempt);
        if (attempt !== this.attempt) return;
        this.#useSignedId(signedId);
        this.#status('Foto lista');
        return;
      } catch {
        if (attempt !== this.attempt) return;
        this.#status('');
      }
    }

    if (smaller && this.inputTarget.files[0] === file) this.#replace(smaller);
  }

  #upload(file, attempt) {
    this.#status('Subiendo foto…');
    const delegate = {
      directUploadWillStoreFileWithXHR: (xhr) => {
        xhr.upload.addEventListener('progress', ({ loaded, total }) => {
          if (attempt === this.attempt && total) this.#status(`Subiendo foto… ${Math.round((loaded / total) * 100)} %`);
        });
      }
    };

    return new Promise((resolve, reject) => {
      new DirectUpload(file, this.directUploadUrlValue, delegate).create((error, blob) => {
        error ? reject(error) : resolve(blob.signed_id);
      });
    });
  }

  // La foto ya está en el bucket: el formulario manda su referencia y el campo de archivo no manda nada.
  #useSignedId(signedId) {
    this.hidden ||= Object.assign(document.createElement('input'), { type: 'hidden' });
    this.hidden.name = this.fieldName;
    this.hidden.value = signedId;
    this.inputTarget.after(this.hidden);
    this.inputTarget.removeAttribute('name');
  }

  #useFileInput() {
    this.hidden?.remove();
    this.inputTarget.name = this.fieldName;
  }

  // Si mandan el formulario mientras la foto se achica o se sube, espera y lo manda después.
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

  #status(text) {
    if (!this.hasStatusTarget) return;
    this.statusTarget.textContent = text;
    this.statusTarget.classList.toggle('hidden', !text);
  }

  #revoke() {
    if (this.objectUrl) URL.revokeObjectURL(this.objectUrl);
    this.objectUrl = null;
  }
}
