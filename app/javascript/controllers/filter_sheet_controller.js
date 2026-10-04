import { Controller } from '@hotwired/stimulus';

// Filtros en el teléfono: junto a la búsqueda, un botón «Filtros» con cuántos hay puestos; al tocarlo, los
// filtros suben en una hoja desde abajo. Desde lg la hoja es la fila de siempre y nada de esto se ve.
// Los filtros se siguen aplicando solos (auto_submit) con la hoja abierta: la lista de atrás ya está al día.

// Cada filtro elegido actualiza la lista con una visita que guarda copia de la página, y esa copia lleva la
// hoja abierta (cerrarla en turbo:before-cache la cerraría a cada toque). Antes de pintar cualquier página
// (la copia que Turbo muestra al tocar «Limpiar todo», o al volver) se le quita: llega cerrada, sin verse
// abrir y cerrar.
document.addEventListener('turbo:before-render', (event) => {
  event.detail.newBody.querySelectorAll('[data-filter-sheet-target][data-open]').forEach((element) => element.removeAttribute('data-open'));
  event.detail.newBody.querySelectorAll('[data-filter-sheet-target="trigger"]').forEach((trigger) => trigger.setAttribute('aria-expanded', 'false'));
});

export default class extends Controller {
  static targets = ['sheet', 'scrim', 'trigger', 'count'];

  open() {
    this.toggle(true);
  }

  close() {
    this.toggle(false);
  }

  toggle(open) {
    [this.sheetTarget, this.scrimTarget].forEach((element) => element.toggleAttribute('data-open', open));
    this.triggerTarget.setAttribute('aria-expanded', String(open));
  }

  // El número del botón: los campos de la hoja que tienen algo elegido o escrito.
  recount() {
    const active = [...this.sheetTarget.querySelectorAll('select, input')].filter((field) => field.value.trim() !== '').length;
    this.countTarget.textContent = active;
    this.countTarget.hidden = active === 0;
  }
}
