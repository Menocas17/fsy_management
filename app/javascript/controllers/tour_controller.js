import { Controller } from '@hotwired/stimulus';

// El tutorial (Tutorial en el servidor): un recorrido por las páginas de verdad que oscurece la pantalla e
// ilumina una parte a la vez, con una tarjeta que explica qué es o pide hacer algo. Solo en el teléfono.
//
// Sigue entre páginas: el paso en curso vive en sessionStorage, y en cada página este controlador (que está
// en el layout) lo retoma; si la página no es la del paso, va a ella. Lo iluminado es lo único que se puede
// tocar. En los pasos de práctica el gesto es real pero el envío se frena aquí, y por si acaso el formulario
// lleva tutorial_practice=1, que el servidor descarta (PracticeMode).
const KEY = 'fsy:tour';
const PHONE = '(max-width: 47.99rem)';
const EASE = 'cubic-bezier(0.32, 0.72, 0, 1)';

// Los textos vienen del servidor, y el saludo lleva el nombre de la ficha: se escapan antes de pintarlos.
const escapeHTML = (text) => String(text ?? '').replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);

const HINTS = {
  tap: 'Toca la parte iluminada',
  play: 'Pruébalo y sigue',
  practice: 'Práctica: no se guarda',
  real: 'Desliza a la izquierda',
  locked: 'Durante el tutorial no se mueve',
};

export default class extends Controller {
  static values = { url: String, autostart: Boolean, home: String };

  connect() {
    this.onClick = this.click.bind(this);
    this.onSubmit = this.submit.bind(this);
    this.onSubmitEnd = this.submitEnd.bind(this);
    this.onKey = this.key.bind(this);
    this.onReposition = () => requestAnimationFrame(() => this.place());
    window.addEventListener('click', this.onClick, true);
    window.addEventListener('submit', this.onSubmit, true);
    document.addEventListener('turbo:submit-end', this.onSubmitEnd);
    document.addEventListener('keydown', this.onKey);
    window.addEventListener('resize', this.onReposition);
    document.querySelector('main')?.addEventListener('scroll', this.onReposition, { passive: true });

    this.state = this.read();
    const params = new URLSearchParams(location.search);
    if (params.get('tutorial') === 'ver') {
      params.delete('tutorial');
      history.replaceState(history.state, '', location.pathname + (params.size ? `?${params}` : ''));
      this.start();
    } else if (this.state) {
      this.show();
    } else if (this.autostartValue && this.onPhone && location.pathname === this.homeValue && !this.dismissed) {
      this.start();
    }
  }

  disconnect() {
    window.removeEventListener('click', this.onClick, true);
    window.removeEventListener('submit', this.onSubmit, true);
    document.removeEventListener('turbo:submit-end', this.onSubmitEnd);
    document.removeEventListener('keydown', this.onKey);
    window.removeEventListener('resize', this.onReposition);
    document.querySelector('main')?.removeEventListener('scroll', this.onReposition);
    clearTimeout(this.timer);
    cancelAnimationFrame(this.frame);
    this.overlay?.remove();
  }

  // ---------- Recorrido ----------

  async start() {
    if (!this.onPhone || !document.querySelector('[data-bottom-nav]')) return;

    const response = await fetch(this.urlValue, { method: 'POST', headers: this.headers });
    if (!response.ok) return;

    const { steps } = await response.json();
    this.state = { steps, index: 0, result: false };
    this.write();
    this.show();
  }

  show() {
    const step = this.step;
    if (!step) return this.finish();

    // Si la página no es la del paso, se va a ella; si ya se intentó y no se llegó (una redirección), el paso
    // se muestra igual, sin iluminar nada, para no quedar dando vueltas.
    if (!this.onPageOf(step) && this.state.visited !== this.state.index) {
      this.state.visited = this.state.index;
      this.write();
      return window.Turbo.visit(step.path);
    }
    this.render();
  }

  go(index) {
    this.state.index = Math.max(0, Math.min(this.state.steps.length - 1, index));
    this.state.result = false;
    delete this.state.visited;
    this.write();
    this.show();
  }

  next() {
    this.go(this.state.index + 1);
  }

  // Terminar o saltar: queda como visto en la cuenta y se borra su alerta de práctica.
  finish() {
    fetch(this.urlValue, { method: 'PATCH', headers: this.headers, keepalive: true });
    this.state = null;
    try {
      sessionStorage.removeItem(KEY);
      sessionStorage.setItem(`${KEY}:dismissed`, '1');
    } catch (e) {
      // sin sessionStorage el tutorial simplemente no recuerda nada
    }
    this.overlay?.remove();
    this.overlay = null;
  }

  // ---------- Lo que pasa en la página ----------

  // Tocar lo iluminado. Un enlace lleva a la página del paso siguiente (con su ?practica=1 si hace falta);
  // un botón (Más, la cuenta) o una actividad hacen lo suyo y el tutorial sigue un momento después.
  // Fuera de lo iluminado no se toca nada (la capa de abajo ya lo tapa; esto cubre la tarjeta y la hoja).
  click(event) {
    if (!this.state || !this.overlay) return;
    if (this.overlay.contains(event.target)) return;

    const step = this.step;
    const target = this.target;
    if (!target || !target.contains(event.target)) return;

    if (['practice', 'locked'].includes(step.action) && !this.state.result) {
      const submitter = event.target.closest('button[type="submit"], input[type="submit"]');
      if (submitter) {
        event.preventDefault();
        event.stopImmediatePropagation();
        return this.practiced(submitter.form);
      }
      return;
    }
    if (step.action !== 'tap') return;

    const link = event.target.closest('a[href]');
    const following = this.state.steps[this.state.index + 1];
    if (link && following) {
      event.preventDefault();
      event.stopImmediatePropagation();
      this.state.index += 1;
      this.state.result = false;
      delete this.state.visited;
      this.write();
      if (this.onPageOf(following)) return this.show();
      this.state.visited = this.state.index;
      this.write();
      return window.Turbo.visit(following.path);
    }
    clearTimeout(this.timer);
    this.timer = setTimeout(() => this.next(), 420);
  }

  // El envío de un formulario de práctica (deslizar hasta el fondo lo manda sin tocar el botón): se frena.
  submit(event) {
    if (!this.state || !['practice', 'locked'].includes(this.step?.action)) return;

    const target = this.target;
    if (!target || !(target.contains(event.target) || event.target.contains(target))) return;

    event.preventDefault();
    event.stopImmediatePropagation();
    this.practiced(event.target);
  }

  practiced(form) {
    if (this.step.action === 'locked') return this.flash('Lo cambias cuando termines el tutorial.');

    // La tarjeta deslizada vuelve a su lugar (alert_item_controller).
    const swiped = form?.closest('[data-controller~="alert-item"]');
    if (swiped) window.Stimulus?.getControllerForElementAndIdentifier(swiped, 'alert-item')?.close();
    this.state.result = true;
    this.write();
    this.render();
  }

  // Borrar su alerta de bienvenida sí va de verdad: cuando el servidor responde, se muestra qué pasó.
  submitEnd(event) {
    if (!this.state || this.step?.action !== 'real' || !event.detail.success) return;

    this.state.result = true;
    this.write();
    clearTimeout(this.timer);
    this.timer = setTimeout(() => this.render(), 450);
  }

  key(event) {
    if (!this.state || !this.overlay) return;
    if (event.key === 'Escape') this.finish();
  }

  // ---------- Dibujo ----------

  render() {
    this.overlay?.remove();
    const step = this.step;
    const target = this.target;
    const result = this.state.result && step.result;

    // Con una hoja abierta (la de «Más»), el tutorial va dentro de ella: lo de afuera queda inerte.
    const host = document.querySelector('dialog[open]:modal') || document.body;
    this.overlay = document.createElement('div');
    this.overlay.className = 'tour';
    this.overlay.dataset.turboTemporary = '';
    this.overlay.innerHTML = `
      <div class="tour-blocker" data-tour-blocker></div>
      <div class="tour-spot" data-tour-spot></div>
      <section class="tour-coach fixed inset-x-3 z-[1002] rounded-panel bg-surface text-ink-900 shadow-lg p-4 outline-none" tabindex="-1" role="dialog" aria-modal="true" aria-labelledby="tour-title">
        ${this.coachHTML(step, result)}
      </section>`;
    host.append(this.overlay);
    this.coach = this.overlay.querySelector('section');
    this.coach.addEventListener('click', (event) => this.coachAction(event));

    if (target && !result) this.markPractice(target);
    if (target) target.scrollIntoView({ block: 'center', behavior: this.reducedMotion ? 'auto' : 'smooth' });
    this.follow();
    (this.coach.querySelector('[data-tour-go]') || this.coach).focus({ preventScroll: true });
  }

  coachHTML(step, result) {
    const steps = this.state.steps;
    const last = this.state.index === steps.length - 1;
    const title = escapeHTML(result ? step.result_title : step.title);
    const text = escapeHTML(result ? step.result : step.text);
    const practice = step.action === 'practice';
    const tag = practice ? '<span class="ml-1.5 px-2 py-0.5 rounded-full bg-cat-amber/15 text-cat-amber-ink">Práctica</span>'
      : step.action === 'real' && result ? '<span class="ml-1.5 px-2 py-0.5 rounded-full bg-cat-green/15 text-cat-green-ink">De verdad</span>' : '';
    const waits = !result && ['tap', 'practice', 'real'].includes(step.action);
    const hint = !result && HINTS[step.action] ? `<p class="mt-2.5 inline-flex px-2.5 py-1 rounded-full bg-primary-50 dark:bg-muted text-label font-bold text-primary-700 dark:text-primary-100">${HINTS[step.action]}</p>` : '';
    const progress = Math.round((this.state.index / (steps.length - 1)) * 100);
    return `
      <p class="text-meta font-extrabold tracking-[.08em] uppercase text-sun-ink">${this.state.index === 0 ? 'Tutorial · 5 min' : last ? 'Terminado' : `Paso ${this.state.index} de ${steps.length - 2}`}${tag}</p>
      <h2 id="tour-title" class="mt-1.5 text-title font-extrabold text-ink-900 text-balance">${title}</h2>
      <p class="mt-1 text-body text-ink-700">${text}</p>
      ${result ? `<p class="mt-3 flex items-start gap-2 rounded-tile border-2 border-dashed ${step.action === 'real' ? 'border-cat-green/60 bg-cat-green/15' : 'border-cat-amber/60 bg-cat-amber/15'} px-3 py-2 text-label font-semibold text-ink-700">${step.action === 'real' ? 'Borrada de verdad: era solo tuya.' : 'No se guardó nada: así se ve en la semana.'}</p>` : ''}
      ${hint}
      <p class="mt-2 text-label font-semibold text-cat-rose-ink" data-tour-flash hidden></p>
      <div class="mt-3.5 flex items-center justify-between gap-2">
        <span class="flex-1 max-w-28 h-1 rounded-full bg-sunken overflow-hidden" aria-hidden="true"><span class="block h-full rounded-full bg-primary-600" style="width:${progress}%"></span></span>
        <span class="flex gap-1.5">
          ${this.state.index > 0 && !last ? '<button type="button" data-tour-act="back" class="h-9 px-3 rounded-control text-label font-bold text-ink-500 hover:bg-muted cursor-pointer">Atrás</button>' : ''}
          ${last ? '' : '<button type="button" data-tour-act="skip" class="h-9 px-3 rounded-control text-label font-bold text-ink-500 hover:bg-muted cursor-pointer">Saltar</button>'}
          ${last ? '<button type="button" data-tour-act="close" data-tour-go class="h-9 px-4 rounded-control bg-primary-700 text-white text-label font-bold cursor-pointer">Cerrar</button>'
            : waits ? '' : `<button type="button" data-tour-act="next" data-tour-go class="h-9 px-4 rounded-control bg-primary-700 text-white text-label font-bold cursor-pointer">${this.state.index === 0 ? 'Empezar' : 'Siguiente'}</button>`}
        </span>
      </div>`;
  }

  coachAction(event) {
    const action = event.target.closest('[data-tour-act]')?.dataset.tourAct;
    if (action === 'next') this.next();
    if (action === 'back') this.go(this.state.index - 1);
    if (action === 'skip' || action === 'close') this.finish();
  }

  // Lo iluminado puede seguir moviéndose un momento (el desplazamiento suave, la hoja «Más» que sube): el
  // foco lo acompaña cuadro a cuadro durante el primer segundo.
  follow() {
    cancelAnimationFrame(this.frame);
    const until = performance.now() + 1000;
    const tick = () => {
      this.place();
      if (performance.now() < until) this.frame = requestAnimationFrame(tick);
    };
    tick();
  }

  // Ilumina lo del paso: el foco con su sombra alrededor, la capa que tapa el resto (con un hueco justo ahí
  // cuando hay que tocarlo o usarlo) y la tarjeta del lado con más espacio.
  place() {
    if (!this.overlay?.isConnected) return;

    const step = this.step;
    const target = this.state.result && step.action === 'real' ? null : this.target;
    const spot = this.overlay.querySelector('[data-tour-spot]');
    const blocker = this.overlay.querySelector('[data-tour-blocker]');
    const height = window.innerHeight;

    if (!target) {
      spot.hidden = true;
      blocker.classList.add('tour-blocker-dim');
      blocker.style.clipPath = '';
      Object.assign(this.coach.style, { top: '50%', transform: 'translateY(-50%)' });
      return;
    }

    const box = target.getBoundingClientRect();
    const pad = 6;
    const area = { top: box.top - pad, left: Math.max(4, box.left - pad), width: Math.min(window.innerWidth - 8, box.width + pad * 2), height: box.height + pad * 2 };
    spot.hidden = false;
    blocker.classList.remove('tour-blocker-dim');
    Object.assign(spot.style, { top: `${area.top}px`, left: `${area.left}px`, width: `${area.width}px`, height: `${area.height}px`,
                                borderRadius: step.target.includes("'center'") ? '999px' : '16px' });
    const open = !this.state.result && step.action !== 'info';
    const { top, left, width, height: h } = area;
    blocker.style.clipPath = open
      ? `polygon(0 0, 100% 0, 100% 100%, 0 100%, 0 ${top}px, ${left}px ${top}px, ${left}px ${top + h}px, ${left + width}px ${top + h}px, ${left + width}px ${top}px, 0 ${top}px)`
      : '';

    const coachHeight = this.coach.offsetHeight;
    const below = top + h + 12;
    const above = top - 12 - coachHeight;
    const coachTop = below + coachHeight <= height - 12 ? below : above >= 12 ? above : Math.max(12, height - coachHeight - 12);
    Object.assign(this.coach.style, { top: `${coachTop}px`, transform: '', transition: this.reducedMotion ? '' : `top 300ms ${EASE}` });
  }

  // Segundo candado: lo que se envíe desde lo iluminado en un paso de práctica va marcado para que el
  // servidor lo descarte, aunque el envío se escape de aquí.
  markPractice(target) {
    if (this.step.action !== 'practice') return;

    const forms = new Set([ ...target.querySelectorAll('form'), target.closest('form'), target.form ].filter(Boolean));
    if (target.matches('form')) forms.add(target);
    forms.forEach((form) => {
      if (form.querySelector('input[name="tutorial_practice"]')) return;
      const input = document.createElement('input');
      Object.assign(input, { type: 'hidden', name: 'tutorial_practice', value: '1' });
      form.append(input);
    });
  }

  flash(text) {
    const note = this.coach?.querySelector('[data-tour-flash]');
    if (!note) return;
    note.textContent = text;
    note.hidden = false;
    this.place();
  }

  // ---------- Ayudas ----------

  get step() {
    return this.state?.steps[this.state.index];
  }

  get target() {
    const selector = this.step?.target;
    if (!selector) return null;
    return [ ...document.querySelectorAll(selector) ].find((element) => element.getClientRects().length > 0) || null;
  }

  onPageOf(step) {
    const url = new URL(step.path, location.origin);
    if (url.pathname !== location.pathname) return false;

    const here = new URLSearchParams(location.search);
    return [ ...url.searchParams ].every(([ key, value ]) => here.get(key) === value);
  }

  get onPhone() {
    return window.matchMedia(PHONE).matches;
  }

  get dismissed() {
    try {
      return sessionStorage.getItem(`${KEY}:dismissed`) === '1';
    } catch (e) {
      return false;
    }
  }

  get headers() {
    return { 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content, Accept: 'application/json' };
  }

  get reducedMotion() {
    return document.documentElement.classList.contains('reduce-motion') ||
      window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  }

  read() {
    try {
      return JSON.parse(sessionStorage.getItem(KEY));
    } catch (e) {
      return null;
    }
  }

  write() {
    try {
      sessionStorage.setItem(KEY, JSON.stringify(this.state));
    } catch (e) {
      // sin sessionStorage el recorrido sigue en esta página, pero no entre páginas
    }
  }
}
