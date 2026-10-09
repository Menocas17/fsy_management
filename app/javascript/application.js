// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from '@hotwired/turbo-rails';
import 'controllers';

// Un diálogo abierto al salir de una página (la hoja «Más» al tocar uno de sus enlaces, el QR…) queda abierto
// en la copia que Turbo guarda de ella. Al volver, Turbo pinta esa copia mientras llega la página nueva, y
// ahí el <dialog open> ya no es modal: se veía un instante arriba de todo. Se cierran en la copia antes de
// pintarla. En un refresco por morph (los tableros en vivo) no: ahí el diálogo abierto es el de quien mira.
document.addEventListener('turbo:before-render', (event) => {
  if (event.detail.renderMethod === 'morph') return;

  event.detail.newBody.querySelectorAll('dialog[open]').forEach((dialog) => dialog.removeAttribute('open'));
});

// Chrome avisa que la app se puede instalar (beforeinstallprompt) una sola vez por carga, a veces antes de que
// conecte el controlador de la hoja de instalar (install_controller.js): se guarda aquí y se le avisa. Sin el
// preventDefault, Chrome pondría además su propia barrita abajo.
window.addEventListener('beforeinstallprompt', (event) => {
  event.preventDefault();
  window.fsyInstallPrompt = event;
  document.dispatchEvent(new CustomEvent('fsy:installable'));
});
window.addEventListener('appinstalled', () => {
  window.fsyInstallPrompt = null;
});

// La barra de progreso de Turbo sale si la página tarda más de esto (por defecto 500 ms, y con la señal del
// evento se sentía que el toque no había hecho nada). Lo que llega antes no la muestra.
Turbo.config.drive.progressBarDelay = 150;

// Al tocar una opción del menú (barra de abajo, menú lateral, hoja «Más»), se marca enseguida, antes de que
// llegue la página: la opción lleva data-nav-pending y su menú data-nav-switching (los estilos, en
// application.css). La página nueva trae su menú limpio; si la visita no sale (sin señal), se desmarca.
const NAV_LINK = '[data-bottom-nav-item], [data-nav-link], [data-more-link]';

const clearPendingNav = () => {
  document.querySelectorAll('[data-nav-pending]').forEach((link) => delete link.dataset.navPending);
  document.querySelectorAll('[data-nav-switching]').forEach((menu) => delete menu.dataset.navSwitching);
};

document.addEventListener('turbo:click', (event) => {
  const link = event.target.closest?.(NAV_LINK);
  if (!link || link.getAttribute('aria-current') === 'page') return;

  clearPendingNav();
  link.dataset.navPending = '';
  const menu = link.closest('nav');
  if (menu) menu.dataset.navSwitching = '';
});
document.addEventListener('turbo:fetch-request-error', clearPendingNav);
document.addEventListener('turbo:load', clearPendingNav);
// La copia que Turbo guarda de la página que se deja no lleva la marca: al volver atrás se vería tocada.
document.addEventListener('turbo:before-cache', clearPendingNav);
