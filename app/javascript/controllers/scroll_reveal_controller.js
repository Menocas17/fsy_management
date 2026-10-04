import { Controller } from '@hotwired/stimulus';

// La barra de desplazamiento del menú solo se ve mientras se desplaza (estilos en .scroll-reveal): al
// moverse se marca data-scrolling y, un momento después de detenerse, se quita y la barra se desvanece.
const HIDE_AFTER_MS = 900;

// Cada visita de Turbo cambia el <body> entero y el menú nuevo llegaría arriba de todo, lejos de la
// opción que se acaba de tocar. Su lugar se guarda aquí (dura entre visitas, no entre recargas) por clave.
const positions = {};

export default class extends Controller {
  static values = { key: String };

  connect() {
    this.onScroll = this.scrolled.bind(this);
    this.element.addEventListener('scroll', this.onScroll, { passive: true });
    if (this.hasKeyValue) this.restore();
  }

  disconnect() {
    this.element.removeEventListener('scroll', this.onScroll);
    clearTimeout(this.timer);
  }

  scrolled() {
    if (this.hasKeyValue) positions[this.keyValue] = this.element.scrollTop;
    // El salto de restore() no lo hizo la persona: la barra no aparece por él.
    if (this.silent) {
      this.silent = false;
      return;
    }
    this.element.dataset.scrolling = '';
    clearTimeout(this.timer);
    this.timer = setTimeout(() => delete this.element.dataset.scrolling, HIDE_AFTER_MS);
  }

  // Vuelve al lugar de antes; si no hay (recién se abrió la app), al menos deja a la vista la opción activa.
  restore() {
    const saved = positions[this.keyValue];
    if (saved != null) return this.jumpTo(saved);

    const active = this.element.querySelector('[aria-current="page"]');
    if (!active) return;
    const box = this.element.getBoundingClientRect();
    const item = active.getBoundingClientRect();
    if (item.top < box.top || item.bottom > box.bottom) {
      this.jumpTo(this.element.scrollTop + item.top - box.top - (box.height - item.height) / 2);
    }
  }

  jumpTo(top) {
    const before = this.element.scrollTop;
    this.element.scrollTop = top;
    // Solo si de verdad se movió habrá un evento scroll que callar.
    this.silent = this.element.scrollTop !== before;
  }
}
