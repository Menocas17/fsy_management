import { Controller } from '@hotwired/stimulus';

// En la lista de manuales: «Ibas en la página 12» y «Seguir leyendo» si la persona ya empezó a leerlo en este
// dispositivo (lo guarda el lector, pdf_reader_controller.js); si no, se queda en «Leer».
export default class extends Controller {
  static targets = ['chip', 'action'];
  static values = { key: String };

  connect() {
    let saved;
    try { saved = JSON.parse(localStorage.getItem(this.keyValue)); } catch { saved = null; }
    if (!saved?.page || saved.page <= 1) return;

    this.chipTarget.textContent = `Ibas en la página ${saved.page}`;
    this.chipTarget.hidden = false;
    this.actionTarget.textContent = 'Seguir leyendo';
  }
}
