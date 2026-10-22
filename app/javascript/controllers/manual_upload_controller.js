import { Controller } from '@hotwired/stimulus';
import { DirectUpload } from '@rails/activestorage';

// Subir el PDF de un manual (manuals/show): al elegirlo sube directo a R2 (DirectUploadsController) con su
// barra y su porcentaje, y el formulario manda solo la referencia firmada. Si la subida directa falla (sin
// regla CORS en el bucket, sin conexión), el PDF viaja con el formulario y se avisa que puede tardar.
export default class extends Controller {
  static targets = ['input', 'picker', 'status', 'bar', 'fill', 'message'];
  static values = { directUploadUrl: String, maxBytes: Number };

  pick() {
    const [file] = this.inputTarget.files;
    if (!file) return;
    if (file.type !== 'application/pdf') return this.#error('Ese archivo no es un PDF.');
    if (file.size > this.maxBytesValue) return this.#error(`Pesa más de ${Math.round(this.maxBytesValue / 1048576)} MB.`);

    this.#busy();
    this.#upload(file)
      .then((signedId) => {
        this.#show('Guardando…', 100);
        const hidden = Object.assign(document.createElement('input'), { type: 'hidden', name: this.inputTarget.name, value: signedId });
        this.inputTarget.removeAttribute('name');
        this.element.appendChild(hidden);
        this.element.requestSubmit();
      })
      .catch(() => {
        // Sin subida directa el archivo va con el formulario: no hay porcentaje, pero sí aviso.
        this.#show('Subiendo… puede tardar un par de minutos, no cierres la página.', null);
        this.element.requestSubmit();
      });
  }

  #upload(file) {
    const delegate = {
      directUploadWillStoreFileWithXHR: (xhr) => {
        xhr.upload.addEventListener('progress', ({ loaded, total }) => {
          if (total) this.#show('Subiendo…', Math.round((loaded / total) * 100));
        });
      },
    };
    return new Promise((resolve, reject) => {
      new DirectUpload(file, this.directUploadUrlValue, delegate).create((error, blob) => {
        error ? reject(error) : resolve(blob.signed_id);
      });
    });
  }

  #busy() {
    this.pickerTarget.classList.add('pointer-events-none', 'opacity-60');
    this.statusTarget.hidden = false;
    this.#show('Subiendo… 0 %', 0);
  }

  // percent null: sin porcentaje, la barra se queda en movimiento.
  #show(text, percent) {
    this.messageTarget.textContent = percent === null || text.includes('%') || percent === 100 ? text : `${text} ${percent} %`;
    this.barTarget.dataset.indeterminate = percent === null ? 'true' : 'false';
    this.fillTarget.style.width = percent === null ? '40%' : `${percent}%`;
  }

  #error(text) {
    this.inputTarget.value = '';
    this.statusTarget.hidden = false;
    this.barTarget.hidden = true;
    this.messageTarget.textContent = text;
    this.messageTarget.classList.add('text-cat-rose-ink');
  }
}
