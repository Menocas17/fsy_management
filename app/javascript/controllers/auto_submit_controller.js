import { Controller } from '@hotwired/stimulus';

// Filtros que se aplican solos. Lo que se escribe espera a que la persona haga una pausa (antes se
// enviaba una búsqueda por cada letra) y reemplaza la entrada del historial en vez de apilar una por
// letra; elegir en un select se aplica al instante y sí queda en el historial.
export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } };

  disconnect() {
    clearTimeout(this.timer);
  }

  typed() {
    clearTimeout(this.timer);
    this.timer = setTimeout(() => this.send('replace'), this.delayValue);
  }

  changed() {
    clearTimeout(this.timer);
    this.send('advance');
  }

  send(action) {
    this.element.dataset.turboAction = action;
    this.element.requestSubmit();
  }
}
