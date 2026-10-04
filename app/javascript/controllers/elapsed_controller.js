import { Controller } from '@hotwired/stimulus';

// Cuánto lleva un joven en enfermería («12 min», «2 h 15»). El servidor pinta el primer valor
// (InfirmaryHelper#infirmary_elapsed, con la misma forma) y aquí se repite cada minuto.
export default class extends Controller {
  static values = { since: String };

  connect() {
    this.tick();
    this.timer = setInterval(() => this.tick(), 30000);
  }

  disconnect() {
    clearInterval(this.timer);
  }

  tick() {
    const minutes = Math.max(0, Math.floor((Date.now() - new Date(this.sinceValue)) / 60000));
    this.element.textContent =
      minutes < 60 ? `${minutes} min` : `${Math.floor(minutes / 60)} h ${String(minutes % 60).padStart(2, '0')}`;
  }
}
