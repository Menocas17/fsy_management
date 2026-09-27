import { Controller } from '@hotwired/stimulus';

const DEFAULT_DETAIL = 'Esta acción no se puede deshacer.';
const DEFAULT_BUTTON = 'Sí, eliminar';

// La respuesta sale siempre del evento close del <dialog>, que dispara igual con los botones, con Esc
// o tocando fuera. Antes Esc dejaba la promesa colgada y la siguiente confirmación aprobaba también
// la anterior.
export default class extends Controller {
  static targets = ['modal', 'message', 'detail', 'confirmButton'];

  connect() {
    Turbo.setConfirmMethod(this.showConfirm.bind(this));
  }

  showConfirm(message, element, submitter) {
    const data = { ...element?.dataset, ...submitter?.dataset };
    const detail = data.turboConfirmDetail ?? DEFAULT_DETAIL;

    this.messageTarget.textContent = message;
    this.detailTarget.textContent = detail;
    this.detailTarget.hidden = detail === '';
    this.confirmButtonTarget.textContent = data.turboConfirmButton || DEFAULT_BUTTON;

    this.resolve?.(false);
    this.modalTarget.returnValue = '';
    this.modalTarget.showModal();

    return new Promise((resolve) => (this.resolve = resolve));
  }

  settle() {
    this.resolve?.(this.modalTarget.returnValue === 'confirm');
    this.resolve = null;
  }

  // El <dialog> ocupa toda la pantalla detrás del cuadro: un clic en él es un clic en el fondo.
  clickOutside(event) {
    if (event.target === this.modalTarget) this.modalTarget.close();
  }
}
