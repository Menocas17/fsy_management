import { Controller } from '@hotwired/stimulus';

// Uno o varios diálogos en la misma pantalla: el botón dice cuál abre con data-dialog-name.
// Sin nombre se abre el primero, que es como venía funcionando.
export default class extends Controller {
  static targets = ['modal'];

  open(event) {
    this.modalFor(event.currentTarget.dataset.dialogName).showModal();
  }

  close(event) {
    (event.currentTarget.closest('dialog') || this.modalTarget).close();
  }

  clickOutside(event) {
    if (event.target === event.currentTarget) event.currentTarget.close();
  }

  modalFor(name) {
    if (!name) return this.modalTarget;

    return this.modalTargets.find((modal) => modal.dataset.dialogName === name) || this.modalTarget;
  }
}
