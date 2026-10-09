import { Controller } from '@hotwired/stimulus';

// Una hoja que sube desde abajo (la de «Más», la de los filtros) se cierra también arrastrándola hacia abajo,
// como en las apps del teléfono. Sigue al dedo; al soltar se cierra si bajó un tercio de su alto o si se lanzó
// rápido, y si no vuelve a su lugar. Quien la usa decide qué es cerrar: escucha sheet-drag:dismiss.
// Con eventos táctiles (no pointer): solo así se puede frenar el scroll del navegador una vez que el gesto es
// nuestro. Si el dedo empieza sobre una lista que todavía puede subir, el gesto es de esa lista.
const SLOP = 6; // px antes de decidir si el gesto es para arrastrar la hoja
const CLOSE_FRACTION = 1 / 3;
const CLOSE_VELOCITY = 0.5; // px por ms: un lanzamiento corto también la cierra
const EASE = 'cubic-bezier(0.32, 0.72, 0, 1)';

export default class extends Controller {
  // Para una hoja que solo es hoja en el teléfono (los filtros, que en escritorio son una fila): la consulta
  // de pantalla en la que se arrastra. Vacía, siempre.
  static values = { media: String };

  connect() {
    this.onStart = this.start.bind(this);
    this.onMove = this.move.bind(this);
    this.onEnd = this.end.bind(this);
    this.element.addEventListener('touchstart', this.onStart, { passive: true });
    this.element.addEventListener('touchmove', this.onMove, { passive: false });
    this.element.addEventListener('touchend', this.onEnd);
    this.element.addEventListener('touchcancel', this.onEnd);
  }

  disconnect() {
    this.element.removeEventListener('touchstart', this.onStart);
    this.element.removeEventListener('touchmove', this.onMove);
    this.element.removeEventListener('touchend', this.onEnd);
    this.element.removeEventListener('touchcancel', this.onEnd);
    this.reset();
  }

  start(event) {
    if (event.touches.length !== 1 || this.closing) return;
    if (this.mediaValue && !window.matchMedia(this.mediaValue).matches) return;

    const touch = event.touches[0];
    this.origin = { x: touch.clientX, y: touch.clientY };
    this.scroller = this.scrollerFor(event.target);
    this.decided = false;
    this.dragging = false;
  }

  move(event) {
    if (!this.origin) return;

    const touch = event.touches[0];
    if (!this.decided) {
      const dx = touch.clientX - this.origin.x;
      const dy = touch.clientY - this.origin.y;
      if (Math.abs(dx) < SLOP && Math.abs(dy) < SLOP) return;

      this.decided = true;
      this.dragging = dy > 0 && dy > Math.abs(dx) && (!this.scroller || this.scroller.scrollTop <= 0);
      if (!this.dragging) return (this.origin = null);

      // Desde aquí, sin salto: la hoja arranca donde está el dedo ahora.
      this.origin.y = touch.clientY;
      this.samples = [];
      this.element.style.transition = 'none';
    }

    event.preventDefault();
    this.offset = Math.max(0, touch.clientY - this.origin.y);
    this.samples.push({ y: touch.clientY, time: event.timeStamp });
    if (this.samples.length > 5) this.samples.shift();
    this.element.style.transform = this.offset ? `translateY(${this.offset}px)` : '';
  }

  end() {
    const dragging = this.dragging;
    this.origin = null;
    this.dragging = false;
    if (!dragging) return;

    const height = this.element.offsetHeight;
    if (this.offset > height * CLOSE_FRACTION || (this.offset > 24 && this.velocity() > CLOSE_VELOCITY)) {
      this.dismiss(height);
    } else {
      this.element.style.transition = this.reducedMotion ? 'none' : `transform 280ms ${EASE}`;
      this.element.style.transform = '';
      this.afterTransition(() => this.reset());
    }
  }

  // Termina de bajar y entonces se cierra de verdad, sin transiciones: la hoja ya está fuera de la pantalla.
  dismiss(height) {
    this.closing = true;
    this.element.style.transition = this.reducedMotion ? 'none' : `transform 200ms ${EASE}`;
    this.element.style.transform = `translateY(${height}px)`;
    this.afterTransition(() => {
      this.element.style.transition = 'none';
      this.dispatch('dismiss');
      this.element.style.transform = '';
      this.element.offsetHeight; // aplica el estado cerrado antes de devolverle sus transiciones
      requestAnimationFrame(() => this.reset());
    });
  }

  afterTransition(callback) {
    if (this.reducedMotion) return callback();

    let done = false;
    const finish = () => {
      if (done) return;
      done = true;
      callback();
    };
    this.element.addEventListener('transitionend', finish, { once: true });
    setTimeout(finish, 320);
  }

  reset() {
    this.element.style.transition = '';
    this.element.style.transform = '';
    this.closing = false;
    this.offset = 0;
  }

  // Lo último que se movió el dedo, en px por ms (positivo hacia abajo).
  velocity() {
    const samples = this.samples || [];
    if (samples.length < 2) return 0;

    const first = samples[0];
    const last = samples[samples.length - 1];
    return (last.y - first.y) / Math.max(1, last.time - first.time);
  }

  // La lista con scroll propio dentro de la hoja que está bajo el dedo, si hay.
  scrollerFor(target) {
    for (let node = target; node && node !== this.element; node = node.parentElement) {
      const overflow = getComputedStyle(node).overflowY;
      if ((overflow === 'auto' || overflow === 'scroll') && node.scrollHeight > node.clientHeight) return node;
    }
    return null;
  }

  get reducedMotion() {
    return document.documentElement.classList.contains('reduce-motion') ||
      window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  }
}
