import { Controller } from '@hotwired/stimulus';

// La vista previa del selector de icono y color (inventarios, categorías de gasto): al elegir, la baldosa de arriba
// cambia y dice en palabras lo que se eligió.
export default class extends Controller {
  static targets = ['tile', 'icon', 'summary'];
  static values = { iconLabel: String, colorLabel: String, colorClass: String };

  pickIcon(event) {
    const svg = event.target.closest('label')?.querySelector('svg');
    if (svg) {
      const copy = svg.cloneNode(true);
      copy.setAttribute('class', 'w-5 h-5');
      this.iconTarget.replaceChildren(copy);
    }
    this.iconLabelValue = event.target.dataset.label;
    this.paintSummary();
  }

  pickColor(event) {
    this.tileTarget.classList.remove(this.colorClassValue);
    this.colorClassValue = event.target.dataset.colorClass;
    this.tileTarget.classList.add(this.colorClassValue);
    this.colorLabelValue = event.target.dataset.label;
    this.paintSummary();
  }

  paintSummary() {
    this.summaryTarget.textContent = `${this.iconLabelValue} · ${this.colorLabelValue}`;
  }
}
