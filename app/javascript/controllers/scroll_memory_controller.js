import { Controller } from '@hotwired/stimulus';

// Turbo solo recuerda el scroll de la ventana, pero aquí el que se desplaza es <main>. Sin esto,
// volver de una ficha a la lista la deja arriba de todo y hay que buscar otra vez el lugar.
// Se recupera al volver con el navegador (visita «restore») y con el botón «Volver» de la barra
// superior (enlaces con data-scroll-restore), que es por donde vuelve casi todo el mundo.
let restoreNext = false;
document.addEventListener('turbo:visit', (event) => {
  if (event.detail?.action === 'restore') restoreNext = true;
});
document.addEventListener('click', (event) => {
  if (event.target.closest?.('a[data-scroll-restore]')) restoreNext = true;
});
// Hasta turbo:load, no antes: en una visita normal Turbo pinta primero la copia en caché y luego la
// página fresca, y las dos tienen que llegar al mismo lugar.
document.addEventListener('turbo:load', () => {
  queueMicrotask(() => (restoreNext = false));
});

export default class extends Controller {
  connect() {
    this.key = `fsy:scroll:${location.pathname}${location.search}`;

    this.boundSave = this.save.bind(this);
    this.element.addEventListener('scroll', this.boundSave, { passive: true });

    if (restoreNext) {
      const saved = Number(this.read());
      if (saved) this.restore(saved);
    }
  }

  disconnect() {
    this.element.removeEventListener('scroll', this.boundSave);
    this.stopFollowing();
  }

  // En el teléfono las listas cargan por tandas (frames lazy): si el lugar guardado queda más abajo
  // de lo que ya hay, se baja hasta el final, eso trae la tanda siguiente, y se sigue hasta llegar.
  restore(target) {
    this.target = target;
    requestAnimationFrame(() => this.follow());

    this.boundFollow = () => this.follow();
    this.element.addEventListener('turbo:frame-load', this.boundFollow);
    this.followTimer = setTimeout(() => this.stopFollowing(), 5000);
    // Si la persona empieza a desplazarse, manda ella.
    this.boundStop = () => this.stopFollowing();
    this.element.addEventListener('touchstart', this.boundStop, { passive: true, once: true });
    this.element.addEventListener('wheel', this.boundStop, { passive: true, once: true });
  }

  follow() {
    if (this.target == null) return;
    this.element.scrollTop = this.target;
    if (Math.abs(this.element.scrollTop - this.target) < 2) this.stopFollowing();
  }

  stopFollowing() {
    this.target = null;
    clearTimeout(this.followTimer);
    if (this.boundFollow) this.element.removeEventListener('turbo:frame-load', this.boundFollow);
    if (this.boundStop) {
      this.element.removeEventListener('touchstart', this.boundStop);
      this.element.removeEventListener('wheel', this.boundStop);
    }
  }

  save() {
    // Mientras se recupera el lugar, los saltos intermedios no pisan el valor guardado.
    if (this.target != null || this.frame) return;
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
