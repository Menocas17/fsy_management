import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="dialog"
export default class extends Controller {
  static targets = ['modal'];

  open() {
    this.modalTarget.showModal();
  }

  close() {
    this.modalTarget.close();
  }

  clickOutside(event) {
    if (event.target === this.modalTarget) {
      this.close();
    }
  }
}
