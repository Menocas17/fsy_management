import { Controller } from '@hotwired/stimulus';

// Crear cuenta: con «Usar otro correo» aparecen los dos campos; con el de la ficha se esconden y se
// deshabilitan, para que el navegador no exija llenarlos ni se envíen.
export default class extends Controller {
  static targets = ['fields'];

  toggle(event) {
    const other = event.target.value === 'otro';
    this.fieldsTarget.classList.toggle('hidden', !other);
    this.fieldsTarget.querySelectorAll('input').forEach((input) => (input.disabled = !other));
    if (other) this.fieldsTarget.querySelector('input')?.focus();
  }
}
