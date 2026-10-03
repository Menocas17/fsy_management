import { Controller } from '@hotwired/stimulus';

// Jalar para recargar. El gesto del navegador solo funciona cuando se desplaza la página entera, y aquí
// el body no se mueve nunca (solo <main>, ver layouts/application), así que el gesto se hace a mano:
// con <main> arriba de todo, arrastrar hacia abajo baja el indicador y, pasado el umbral, al soltar
// se recarga la página con Turbo. También sirve en la app instalada del iPhone, que no trae el gesto.
const THRESHOLD = 72; // px que hay que bajar el indicador para que al soltar recargue
const MAX = 110;
const START_SLOP = 8; // movimiento mínimo antes de decidir si es un jalón o un scroll

export default class extends Controller {
  static targets = ['scroller', 'indicator', 'icon'];

  connect() {
    this.onStart = this.start.bind(this);
    this.onMove = this.move.bind(this);
    this.onEnd = this.end.bind(this);
    this.scrollerTarget.addEventListener('touchstart', this.onStart, { passive: true });
    // No pasivo: mientras se jala hay que impedir el rebote nativo de <main>.
    this.scrollerTarget.addEventListener('touchmove', this.onMove, { passive: false });
    this.scrollerTarget.addEventListener('touchend', this.onEnd);
    this.scrollerTarget.addEventListener('touchcancel', this.onEnd);
  }

  disconnect() {
    this.scrollerTarget.removeEventListener('touchstart', this.onStart);
    this.scrollerTarget.removeEventListener('touchmove', this.onMove);
    this.scrollerTarget.removeEventListener('touchend', this.onEnd);
    this.scrollerTarget.removeEventListener('touchcancel', this.onEnd);
  }

  start(event) {
    this.tracking = false;
    if (this.refreshing || event.touches.length !== 1) return;
    if (this.scrollerTarget.scrollTop > 0) return;
    // Ni con un diálogo abierto ni desde algo que se arrastra por su cuenta (carruseles, el escáner…).
    if (document.querySelector('dialog[open]') || event.target.closest('[data-no-pull-refresh]')) return;

    this.tracking = true;
    this.pulling = false;
    this.startX = event.touches[0].clientX;
    this.startY = event.touches[0].clientY;
  }

  move(event) {
    if (!this.tracking) return;
    const dx = event.touches[0].clientX - this.startX;
    const dy = event.touches[0].clientY - this.startY;

    if (!this.pulling) {
      if (Math.abs(dy) < START_SLOP && Math.abs(dx) < START_SLOP) return;
      // Hacia arriba o de lado es un scroll o un deslizamiento normal: no es asunto nuestro.
      if (dy <= 0 || Math.abs(dx) > dy || this.scrollerTarget.scrollTop > 0) {
        this.tracking = false;
        return;
      }
      this.pulling = true;
      this.indicatorTarget.style.transition = 'none';
    }

    event.preventDefault();
    // Resistencia: cuanto más se jala, menos avanza, como el gesto del sistema.
    const distance = Math.min(MAX, (dy - START_SLOP) * 0.5);
    const armed = distance >= THRESHOLD;
    if (armed && !this.armed) navigator.vibrate?.(8);
    this.armed = armed;
    this.render(distance);
  }

  end() {
    if (!this.pulling) return;
    this.tracking = this.pulling = false;
    this.indicatorTarget.style.transition = '';

    if (this.armed) {
      this.refreshing = true;
      this.indicatorTarget.dataset.state = 'refreshing';
      this.render(THRESHOLD * 0.8);
      // replace: recargar no agrega una entrada más al historial. Turbo reemplaza el body (y con él este
      // indicador) al terminar.
      window.Turbo.visit(window.location.href, { action: 'replace' });
    } else {
      this.reset();
    }
    this.armed = false;
  }

  render(distance) {
    const progress = Math.min(1, distance / THRESHOLD);
    if (!this.refreshing) this.indicatorTarget.dataset.state = progress >= 1 ? 'armed' : 'pulling';
    this.indicatorTarget.style.opacity = String(Math.min(1, progress * 1.4));
    this.indicatorTarget.style.transform = `translate(-50%, ${distance - 48}px)`;
    if (!this.refreshing) this.iconTarget.style.transform = `rotate(${progress * 270}deg)`;
  }

  reset() {
    this.indicatorTarget.dataset.state = 'idle';
    this.indicatorTarget.style.opacity = '0';
    this.indicatorTarget.style.transform = 'translate(-50%, -48px)';
  }
}
