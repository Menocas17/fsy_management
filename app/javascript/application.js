// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails';
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
