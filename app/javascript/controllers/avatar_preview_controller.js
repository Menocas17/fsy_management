import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input', 'image', 'placeholder'];

  disconnect() {
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
  }

  #revoke() {
    if (this.objectUrl) URL.revokeObjectURL(this.objectUrl);
    this.objectUrl = null;
  }
}
