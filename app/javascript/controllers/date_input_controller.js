import { Controller } from '@hotwired/stimulus';

// El campo de fecha día/mes/año (UiHelper#date_input): pone las barras mientras se escribe, revisa que la fecha
// exista y esté en su rango, y el botón abre el calendario del teléfono, cuya elección vuelve como dd/mm/aaaa.
export default class extends Controller {
  static targets = ['text', 'picker'];
  static values = { min: String, max: String };

  // 14032010 → 14/03/2010, sin pelear con quien borra o escribe las barras.
  typed(event) {
    if (event.inputType?.startsWith('delete')) return this.textTarget.setCustomValidity('');

    const digits = this.textTarget.value.replace(/\D/g, '').slice(0, 8);
    const parts = [digits.slice(0, 2), digits.slice(2, 4), digits.slice(4)].filter(Boolean);
    this.textTarget.value = parts.join('/') + (digits.length === 2 || digits.length === 4 ? '/' : '');
    this.textTarget.setCustomValidity('');
  }

  check() {
    const value = this.textTarget.value.trim();
    if (!value) return this.textTarget.setCustomValidity('');

    const date = parse(value);
    let message = '';
    if (!date) message = 'Escribe la fecha como día/mes/año, por ejemplo 14/03/2010.';
    else if (this.minValue && iso(date) < this.minValue) message = `La fecha no puede ser antes del ${show(this.minValue)}.`;
    else if (this.maxValue && iso(date) > this.maxValue) message = `La fecha no puede ser después del ${show(this.maxValue)}.`;
    if (date) this.textTarget.value = show(iso(date));
    this.textTarget.setCustomValidity(message);
    if (message) this.textTarget.reportValidity();
  }

  openPicker() {
    const date = parse(this.textTarget.value);
    if (date) this.pickerTarget.value = iso(date);
    try {
      this.pickerTarget.showPicker();
    } catch (_) {
      this.pickerTarget.focus();
      this.pickerTarget.click();
    }
  }

  picked() {
    if (!this.pickerTarget.value) return;
    this.textTarget.value = show(this.pickerTarget.value);
    this.textTarget.setCustomValidity('');
    this.textTarget.dispatchEvent(new Event('change', { bubbles: true }));
  }
}

// «14/03/2010» → Date (o null si no existe: 31/02 no pasa).
function parse(value) {
  const match = value.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (!match) return null;
  const [day, month, year] = match.slice(1).map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  return date.getUTCDate() === day && date.getUTCMonth() === month - 1 ? date : null;
}

const iso = (date) => date.toISOString().slice(0, 10);

const show = (isoDate) => {
  const [year, month, day] = isoDate.split('-');
  return `${day}/${month}/${year}`;
};
