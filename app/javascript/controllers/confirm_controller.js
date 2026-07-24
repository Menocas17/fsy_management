import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['modal', 'message', 'confirmButton', 'cancelButton'];

  connect() {
    Turbo.setConfirmMethod(this.showConfirm.bind(this));
  }

  async showConfirm(message, element) {
    this.messageTarget.textContent = message;

    this.modalTarget.showModal();

    return new Promise((resolve) => {
      this.confirmButtonTarget.addEventListener(
        'click',
        () => {
          this.modalTarget.close();
          resolve(true);
        },
        { once: true },
      );

      this.cancelButtonTarget.addEventListener(
        'click',
        () => {
          this.modalTarget.close();
          resolve(false);
        },
        { once: true },
      );
    });
  }
}
