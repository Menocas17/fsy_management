import { Controller } from '@hotwired/stimulus';

// El menú lateral del teléfono. Cerrado queda inert (fuera de pantalla no se puede tabular ni leer);
// abierto, bloquea el scroll de fondo, se cierra con Esc y devuelve el foco al botón que lo abrió.
export default class extends Controller {
  static targets = ['menu', 'backdrop', 'trigger', 'closeButton'];

  connect() {
    this.menuTarget.inert = true;
    this.boundHandleResize = this.handleResize.bind(this);
    window.addEventListener('resize', this.boundHandleResize);
    // Turbo guarda la página tal cual al salir: sin esto, volver atrás la muestra con el menú abierto.
    this.boundClose = () => this.close({ restoreFocus: false });
    document.addEventListener('turbo:before-cache', this.boundClose);
  }

  disconnect() {
    window.removeEventListener('resize', this.boundHandleResize);
    document.removeEventListener('turbo:before-cache', this.boundClose);
    this.scrollArea?.style.removeProperty('overflow');
  }

  toggle(event) {
    event.stopPropagation();
    this.isOpen ? this.close() : this.open();
  }

  open() {
    this.isOpen = true;
    this.menuTarget.inert = false;
    this.menuTarget.classList.replace('-translate-x-full', 'translate-x-0');
    this.backdropTarget.classList.remove('opacity-0', 'pointer-events-none');
    this.triggerTargets.forEach((trigger) => trigger.setAttribute('aria-expanded', 'true'));
    this.scrollArea?.style.setProperty('overflow', 'hidden');
    if (this.hasCloseButtonTarget) this.closeButtonTarget.focus({ preventScroll: true });
  }

  close({ restoreFocus = true } = {}) {
    const wasOpen = this.isOpen;
    this.isOpen = false;
    this.menuTarget.inert = true;
    this.menuTarget.classList.replace('translate-x-0', '-translate-x-full');
    this.backdropTarget.classList.add('opacity-0', 'pointer-events-none');
    this.triggerTargets.forEach((trigger) => trigger.setAttribute('aria-expanded', 'false'));
    this.scrollArea?.style.removeProperty('overflow');
    if (wasOpen && restoreFocus && this.hasTriggerTarget) this.triggerTarget.focus({ preventScroll: true });
  }

  closeOnEscape(event) {
    if (this.isOpen) this.close();
  }

  handleResize() {
    if (window.innerWidth >= 768 && this.isOpen) this.close({ restoreFocus: false });
  }

  get scrollArea() {
    return document.querySelector('main');
  }
}
