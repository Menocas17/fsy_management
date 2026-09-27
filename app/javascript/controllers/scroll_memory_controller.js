import { Controller } from '@hotwired/stimulus';

// Turbo solo recuerda el scroll de la ventana, pero aquí el que se desplaza es <main>. Sin esto,
// volver de una ficha a la lista la deja arriba de todo y hay que buscar otra vez el lugar.
let restoring = false;
document.addEventListener('turbo:visit', (event) => {
  restoring = event.detail?.action === 'restore';
});

export default class extends Controller {
  connect() {
    this.key = `fsy:scroll:${location.pathname}${location.search}`;

    if (restoring) {
      restoring = false;
      const saved = Number(this.read());
      if (saved) requestAnimationFrame(() => (this.element.scrollTop = saved));
    }

    this.boundSave = this.save.bind(this);
    this.element.addEventListener('scroll', this.boundSave, { passive: true });
  }

  disconnect() {
    this.element.removeEventListener('scroll', this.boundSave);
  }

  save() {
    if (this.frame) return;
    this.frame = requestAnimationFrame(() => {
      this.frame = null;
      try {
        sessionStorage.setItem(this.key, String(this.element.scrollTop));
      } catch (e) {
        // sessionStorage no disponible (navegación privada): se pierde el lugar, nada más.
      }
    });
  }

  read() {
    try {
      return sessionStorage.getItem(this.key);
    } catch (e) {
      return null;
    }
  }
}
