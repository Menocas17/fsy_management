import { Controller } from '@hotwired/stimulus';

const normalize = (text) =>
  text
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase();

// La nota de la ficha clínica (infirmary_charts/_note_form): «Medicamento» muestra el selector del inventario de
// enfermería. Buscar filtra la lista; tocar un medicamento lo agrega como fila con su cantidad (hasta lo que
// queda), y la X lo quita. Lo descuenta el servidor al guardar.
export default class extends Controller {
  static targets = ['medicines', 'query', 'option', 'noMatch', 'chosen', 'template', 'body'];

  // Al volver con un error, los medicamentos ya elegidos no se repiten en la lista.
  connect() {
    if (this.hasQueryTarget) this.filter();
  }

  mode(event) {
    const medication = event.target.value === 'true';
    this.medicinesTarget.hidden = !medication;
    this.bodyTarget.placeholder = medication
      ? this.bodyTarget.dataset.placeholderMedication
      : this.bodyTarget.dataset.placeholderNote;
    if (medication && this.hasQueryTarget) this.queryTarget.focus();
  }

  filter() {
    const term = normalize(this.queryTarget.value.trim());
    let shown = 0;
    this.optionTargets.forEach((option) => {
      const visible = !this.isChosen(option.dataset.id) && normalize(option.dataset.search).includes(term);
      option.hidden = !visible;
      if (visible) shown += 1;
    });
    this.noMatchTarget.hidden = shown > 0;
  }

  // Enter en el buscador agrega el primero que se ve, en vez de enviar la nota.
  pickFirst(event) {
    if (event.key !== 'Enter') return;

    event.preventDefault();
    this.optionTargets.find((option) => !option.hidden)?.querySelector('button:not([disabled])')?.click();
  }

  add(event) {
    const { id, name, unit, stock } = event.currentTarget.dataset;
    if (this.isChosen(id)) return;

    const row = this.templateTarget.content.firstElementChild.cloneNode(true);
    row.dataset.id = id;
    row.querySelector('[data-field=item]').value = id;
    row.querySelector('[data-field=name]').textContent = name;
    row.querySelector('[data-field=stock]').textContent = `Quedan ${stock} ${unit}`;
    row.querySelector('[data-field=unit]').textContent = unit;
    const quantity = row.querySelector('[data-field=quantity]');
    quantity.max = stock;
    quantity.setAttribute('aria-label', `Cantidad de ${name}`);
    this.chosenTarget.appendChild(row);

    this.queryTarget.value = '';
    this.filter();
    quantity.focus();
    quantity.select();
  }

  remove(event) {
    event.currentTarget.closest('[data-dose-row]').remove();
    this.filter();
  }

  isChosen(id) {
    return this.chosenTarget.querySelector(`[data-dose-row][data-id="${id}"]`) !== null;
  }
}
