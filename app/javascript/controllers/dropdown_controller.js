import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ['menu', 'chevron'];

  // Turbo guarda la página tal cual al salir: sin esto, volver atrás la muestra con el menú abierto.
  connect() {
    this.boundClose = this.close.bind(this);
    document.addEventListener('turbo:before-cache', this.boundClose);
  }

  disconnect() {
    document.removeEventListener('turbo:before-cache', this.boundClose);
  }

  toggle(event) {
    event.stopPropagation();
    this.menuTarget.classList.toggle('hidden');
    this.chevronTargets.forEach((chevron) => chevron.classList.toggle('rotate-180'));
  }

  hide(event) {
    if (this.menuTarget.classList.contains('hidden')) return;
    if (this.element.contains(event.target)) return;

    this.close();
  }

  close() {
    this.menuTarget.classList.add('hidden');
    this.chevronTargets.forEach((chevron) => chevron.classList.remove('rotate-180'));
  }
}
