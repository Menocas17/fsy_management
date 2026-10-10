import { Controller } from '@hotwired/stimulus';

// Instalar la app en el teléfono (shared/_install_sheet). Al entrar desde el navegador del teléfono sube una
// hoja, una vez por visita: en Android con el botón de instalar de verdad (el permiso que Chrome da con
// beforeinstallprompt, guardado en application.js), en iPhone con los pasos en láminas, y dentro de Facebook,
// Instagram o Messenger pidiendo abrirla en el navegador. Abierta ya como app (standalone), nunca sale.
// «Ahora no» (o cerrarla) la calla un día; «Ya la tengo instalada», un mes. Configuración la abre a mano.
//
// El tutorial espera a que esta hoja se cierre: mientras puede salir, <html data-install-prompt> lo avisa y al
// terminar se dispara install:settled.
const SNOOZE_KEY = 'fsy:install-snooze';
const SHOWN_KEY = 'fsy:install-shown';
const DAY = 24 * 60 * 60 * 1000;
const ANDROID_WAIT = 2500; // ms que se espera el permiso de Chrome antes de rendirse

// La hoja no viaja con cada página (InstallSheetsController): se pide la primera vez que va a abrirse y su HTML
// queda aquí para las visitas siguientes.
let sheetHtml = null;

const storage = (store, action, key, value) => {
  try {
    return action === 'get' ? store.getItem(key) : store.setItem(key, value);
  } catch (e) {
    return null; // sin almacenamiento (navegación privada) la hoja simplemente no recuerda
  }
};

export default class extends Controller {
  static targets = ['sheet', 'track', 'dot', 'next', 'secondary', 'external', 'copyLabel'];
  static values = { url: String };

  connect() {
    this.onOpenRequest = (event) => {
      if (!event.target.closest('[data-install-open]')) return;
      event.preventDefault();
      this.open(this.platform || 'android');
    };
    this.onInstallable = () => this.waiting && this.open('android');
    document.addEventListener('click', this.onOpenRequest);
    document.addEventListener('fsy:installable', this.onInstallable);

    this.platform = this.detect();
    if (this.shouldAutoOpen) this.autoOpen();
  }

  disconnect() {
    document.removeEventListener('click', this.onOpenRequest);
    document.removeEventListener('fsy:installable', this.onInstallable);
    clearTimeout(this.timer);
    clearTimeout(this.glideTimer);
    // Al cambiar de página no se avisa al tutorial (el de la página que se va): el de la nueva vuelve a mirar.
    delete document.documentElement.dataset.installPrompt;
  }

  // ---------- Cuándo sale ----------

  get standalone() {
    return window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true;
  }

  get shouldAutoOpen() {
    if (!this.platform || this.standalone) return false;
    if (storage(sessionStorage, 'get', SHOWN_KEY)) return false;

    const snoozedUntil = Number(storage(localStorage, 'get', SNOOZE_KEY) || 0);
    return Date.now() > snoozedUntil;
  }

  autoOpen() {
    document.documentElement.dataset.installPrompt = 'pending';
    if (this.platform !== 'android') return this.open(this.platform);

    // Chrome da el permiso solo si la app no está instalada. Si no llega, o ya está o este navegador no
    // instala (Firefox sí se explica: tiene menú pero no permiso).
    if (window.fsyInstallPrompt) return this.open('android');
    if (/Firefox/i.test(navigator.userAgent)) return this.open('android-manual');

    this.registerWorker();
    this.waiting = true;
    this.timer = setTimeout(() => {
      this.waiting = false;
      this.settle();
    }, ANDROID_WAIT);
  }

  // Qué teléfono es: ios, android, inapp, o nada (computadora: no sale).
  detect() {
    const ua = navigator.userAgent;
    const ios = /iPhone|iPad|iPod/.test(ua) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
    const android = /Android/.test(ua);
    if (!ios && !android) return null;

    this.os = ios ? 'ios' : 'android';
    if (/FBAN|FBAV|FB_IAB|FBIOS|Instagram|Messenger|Line\/|MicroMessenger|TikTok|musical_ly|Snapchat|LinkedInApp/.test(ua)) return 'inapp';
    if (!ios) return 'android';

    // Safari 26 escondió Compartir en el menú ⋯ (su versión va en Version/, la del sistema quedó fija en 18).
    // Chrome, Firefox y Edge del iPhone tienen Compartir junto a la dirección o en su menú.
    const safari = !/CriOS|FxiOS|EdgiOS|OPiOS/.test(ua);
    const version = Number((ua.match(/Version\/(\d+)/) || [])[1] || 0);
    this.variant = !safari ? 'other' : version >= 26 ? 'safari26' : 'safari';
    return 'ios';
  }

  // Chrome pide un service worker para considerar la app instalable; el de las notificaciones sirve.
  registerWorker() {
    navigator.serviceWorker?.register('/service-worker', { scope: '/' }).catch(() => {});
  }

  // ---------- La hoja ----------

  async open(platform) {
    clearTimeout(this.timer);
    this.waiting = false;
    // Sin la hoja (sin señal) no hay nada que mostrar: el tutorial no se queda esperándola.
    if (!(await this.loadSheet())) return this.settle();

    let panel = platform;
    if (panel === 'android' && !window.fsyInstallPrompt) panel = 'android-manual';

    storage(sessionStorage, 'set', SHOWN_KEY, '1');
    this.sheetTarget.querySelectorAll('[data-install-panel]').forEach((section) => {
      section.hidden = section.dataset.installPanel !== panel;
    });
    this.sheetTarget.querySelectorAll('[data-only]').forEach((element) => {
      const only = element.dataset.only.split(' ');
      element.hidden = !only.includes(this.variant) && !only.includes(this.os);
    });
    if (panel === 'ios') this.goTo(0, { instant: true });
    if (panel === 'inapp') this.externalTarget.href = this.externalUrl;

    document.documentElement.dataset.installPrompt = 'open';
    if (!this.sheetTarget.open) this.sheetTarget.showModal();
  }

  async loadSheet() {
    if (this.hasSheetTarget) return true;

    try {
      sheetHtml ||= fetch(this.urlValue, { headers: { Accept: 'text/html' } }).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.text();
      });
      const html = await sheetHtml;
      // Dos pedidos a la vez (sale sola y además se tocó el botón): la pone uno solo.
      if (!this.hasSheetTarget) this.element.insertAdjacentHTML('beforeend', html);
    } catch (e) {
      sheetHtml = null;
      return false;
    }
    return this.hasSheetTarget;
  }

  async install() {
    const prompt = window.fsyInstallPrompt;
    if (!prompt) return this.open('android-manual');

    window.fsyInstallPrompt = null; // cada permiso se usa una sola vez
    prompt.prompt();
    const { outcome } = await prompt.userChoice;
    if (outcome !== 'accepted') return this.later();

    this.skipTutorialHere();
    this.open('installed');
  }

  // Cerrar sin instalar: vuelve a salir mañana.
  later() {
    storage(localStorage, 'set', SNOOZE_KEY, String(Date.now() + DAY));
    this.close();
  }

  // Ya instalada (o vio los pasos hasta el final): no se insiste en un mes. Si la agregó, el tutorial se ve
  // en la app instalada, no aquí en el navegador.
  installed() {
    storage(localStorage, 'set', SNOOZE_KEY, String(Date.now() + 30 * DAY));
    this.skipTutorialHere();
    this.close();
  }

  done() {
    this.installed();
  }

  close() {
    if (this.sheetTarget.open) this.sheetTarget.close();
    this.settle();
  }

  // Esc o el botón atrás de Android: como «Ahora no».
  cancel(event) {
    event.preventDefault();
    this.later();
  }

  clickOutside(event) {
    if (event.target === event.currentTarget) this.later();
  }

  settle() {
    if (!document.documentElement.dataset.installPrompt) return;

    delete document.documentElement.dataset.installPrompt;
    document.dispatchEvent(new CustomEvent('install:settled'));
  }

  skipTutorialHere() {
    storage(sessionStorage, 'set', 'fsy:tour:dismissed', '1');
  }

  // ---------- Láminas del iPhone ----------

  next() {
    if (this.index >= this.slides.length - 1) return this.installed();
    this.goTo(this.index + 1);
  }

  // Mientras la lámina se desliza sola, el scroll no cambia el paso (un segundo toque seguido saltaba atrás);
  // si el dedo la interrumpe, a los 600 ms vuelve a mandar el scroll.
  goTo(index, { instant = false } = {}) {
    this.index = index;
    this.gliding = !instant;
    clearTimeout(this.glideTimer);
    this.glideTimer = setTimeout(() => (this.gliding = false), 600);
    this.trackTarget.scrollTo({ left: index * this.trackTarget.clientWidth, behavior: instant ? 'instant' : 'smooth' });
    this.paint();
  }

  // Al deslizar con el dedo, los puntos y el botón siguen a la lámina que quedó.
  track() {
    if (this.gliding) return;

    const index = Math.round(this.trackTarget.scrollLeft / Math.max(1, this.trackTarget.clientWidth));
    if (index === this.index) return;
    this.index = index;
    this.paint();
  }

  paint() {
    const last = this.slides.length - 1;
    this.dotTargets.forEach((dot, i) => dot.toggleAttribute('data-active', i === this.index));
    this.nextTarget.textContent = this.index === 0 ? 'Ver cómo' : this.index === last ? 'Listo, ya la agregué' : 'Siguiente';
    this.secondaryTarget.hidden = this.index !== 0;
  }

  get slides() {
    return this.trackTarget.querySelectorAll('[data-install-slide]');
  }

  // ---------- Fuera de Facebook o Instagram ----------

  // Safari se abre con su esquema propio (iOS 17+); en Android, una intención directa a Chrome.
  get externalUrl() {
    const here = location.href;
    if (this.os === 'ios') return here.replace(/^https?:\/\//, 'x-safari-https://');

    const url = new URL(here);
    return `intent://${url.host}${url.pathname}${url.search}#Intent;scheme=https;package=com.android.chrome;S.browser_fallback_url=${encodeURIComponent(here)};end`;
  }

  async copy() {
    try {
      await navigator.clipboard.writeText(location.href);
      this.copyLabelTarget.textContent = 'Enlace copiado';
    } catch (e) {
      this.copyLabelTarget.textContent = location.href;
    }
  }
}
