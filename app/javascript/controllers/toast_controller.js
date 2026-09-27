import { Controller } from '@hotwired/stimulus';

// Los avisos se cierran solos; los errores (timeout 0) esperan a que alguien los lea y los cierre.
// El tiempo se detiene mientras el puntero está encima.
export default class extends Controller {
  static values = { timeout: { type: Number, default: 4000 } };

  connect() {
    this.resume();
  }

  disconnect() {
    clearTimeout(this.timer);
  }

  pause() {
    clearTimeout(this.timer);
  }

  resume() {
    if (this.timeoutValue > 0) {
      this.timer = setTimeout(() => this.close(), this.timeoutValue);
    }
  }

  close() {
    clearTimeout(this.timer);
    this.element.classList.add('toast-leaving');

    const remove = () => this.element.remove();
    this.element.addEventListener('transitionend', remove, { once: true });
    // Con movimiento reducido no hay transición que termine.
    setTimeout(remove, 250);
  }
}
