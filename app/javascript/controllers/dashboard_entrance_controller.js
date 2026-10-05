import { Controller } from '@hotwired/stimulus';

// La entrada del panel, «Amanecer» (estilos en application.css): el hero se materializa con la luz del sol
// detrás, la cuenta regresiva entra rodando y las tres cifras suben y cuentan desde cero. Una vez por sesión:
// el panel se abre muchas veces al día y nadie tiene que esperarla dos veces. ?lento=N la repite siempre,
// N veces más lenta, para revisarla. Con movimiento reducido no corre: todo está en su lugar desde el inicio.
const SEEN = 'fsy:entrance-seen';
// Lo que dura la entrada completa a velocidad normal (la última cifra termina de contar).
const TOTAL_MS = 1350;
const COUNT_MS = 700;
const COUNT_AT_MS = [460, 520, 580];

export default class extends Controller {
  static targets = ['count'];

  connect() {
    const html = document.documentElement;
    const slow = parseFloat(new URLSearchParams(window.location.search).get('lento'));
    const pending = html.classList.contains('entrance-pending');
    let seen = false;
    try {
      seen = sessionStorage.getItem(SEEN) === '1';
    } catch {
      // Sin sessionStorage (navegación privada estricta) se ve como primera visita.
    }

    html.classList.remove('entrance-pending');
    // Una visita de Turbo no vuelve a correr el script del <head>: aquí se decide igual que allá.
    if (this.reduceMotion || !(pending || slow > 0 || !seen)) return;

    this.slow = slow > 0 ? slow : 1;
    html.style.setProperty('--entrance-slow', this.slow);
    html.classList.add('entrance-play');
    try {
      sessionStorage.setItem(SEEN, '1');
    } catch {
      // Igual que arriba: sin dónde guardarlo, solo se repetirá la próxima vez.
    }

    this.countUp();
    this.timer = setTimeout(() => this.finish(), TOTAL_MS * this.slow + 100);
  }

  disconnect() {
    clearTimeout(this.timer);
    cancelAnimationFrame(this.frame);
    this.finish();
  }

  // Al terminar se quitan las animaciones: lo que queda es el estado de reposo, idéntico al último cuadro.
  finish() {
    const html = document.documentElement;
    html.classList.remove('entrance-play');
    html.style.removeProperty('--entrance-slow');
    this.countTargets.forEach((target) => (target.textContent = target.dataset.entranceValue ?? target.textContent));
  }

  // Cada cifra cuenta desde cero con una curva que frena al final; son tabulares, así que no tiemblan.
  countUp() {
    const counters = this.countTargets
      .map((target, index) => {
        const value = parseInt(target.textContent.replace(/\D/g, ''), 10);
        if (Number.isNaN(value)) return null;
        target.dataset.entranceValue = target.textContent;
        target.textContent = '0';
        return { target, value, at: (COUNT_AT_MS[index] ?? COUNT_AT_MS.at(-1)) * this.slow };
      })
      .filter(Boolean);
    if (counters.length === 0) return;

    const duration = COUNT_MS * this.slow;
    const start = performance.now();
    const step = (now) => {
      let running = false;
      counters.forEach(({ target, value, at }) => {
        const progress = Math.min(1, Math.max(0, (now - start - at) / duration));
        const eased = progress === 1 ? 1 : 1 - 2 ** (-10 * progress);
        target.textContent = String(Math.round(value * eased));
        if (progress < 1) running = true;
      });
      if (running) this.frame = requestAnimationFrame(step);
    };
    this.frame = requestAnimationFrame(step);
  }

  get reduceMotion() {
    return (
      document.documentElement.classList.contains('reduce-motion') ||
      window.matchMedia('(prefers-reduced-motion: reduce)').matches
    );
  }
}
