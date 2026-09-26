import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['image'];

  connect() {
    if (this.imageTarget.complete && this.imageTarget.naturalWidth > 0) {
      this.#show();
    }
  }

  loaded() {
    this.#show();
  }

  #show() {
    this.imageTarget.classList.remove('opacity-0');
  }
}
