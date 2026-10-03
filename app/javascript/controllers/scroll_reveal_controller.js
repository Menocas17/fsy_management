import { Controller } from '@hotwired/stimulus';

// La barra de desplazamiento del menú solo se ve mientras se desplaza (estilos en .scroll-reveal): al
// moverse se marca data-scrolling y, un momento después de detenerse, se quita y la barra se desvanece.
const HIDE_AFTER_MS = 900;

export default class extends Controller {
  connect() {
    this.onScroll = this.scrolled.bind(this);
    this.element.addEventListener('scroll', this.onScroll, { passive: true });
  }

  disconnect() {
    this.element.removeEventListener('scroll', this.onScroll);
    clearTimeout(this.timer);
  }

  scrolled() {
    this.element.dataset.scrolling = '';
    clearTimeout(this.timer);
    this.timer = setTimeout(() => delete this.element.dataset.scrolling, HIDE_AFTER_MS);
  }
}
