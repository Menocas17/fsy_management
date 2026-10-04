import { Controller } from '@hotwired/stimulus';

// El organigrama del teléfono (una lista con sangría, sin lienzo): cada compañía auxiliar abre y cierra
// sus compañías, y «Mostrar compañías» las abre todas, igual que en el lienzo de escritorio (org_chart).
export default class extends Controller {
  static targets = ['branch', 'toggleAllButton', 'toggleAllLabel'];

  toggleBranch(event) {
    const branch = this.branchTargets.find((element) => element.id === event.currentTarget.dataset.branch);
    if (branch) this.setBranch(branch, branch.hidden);
    this.syncToggleAll();
  }

  toggleAll() {
    const expand = this.branchTargets.some((branch) => branch.hidden);
    this.branchTargets.forEach((branch) => this.setBranch(branch, expand));
    this.syncToggleAll();
  }

  setBranch(branch, expanded) {
    branch.hidden = !expanded;
    const button = this.element.querySelector(`[data-branch="${branch.id}"]`);
    if (!button) return;

    button.setAttribute('aria-expanded', String(expanded));
    button.querySelector('svg')?.classList.toggle('rotate-180', expanded);
  }

  // El botón general dice lo que hará: si queda alguna cerrada, mostrar; si están todas abiertas, ocultar.
  syncToggleAll() {
    const allOpen = this.branchTargets.every((branch) => !branch.hidden);
    if (this.hasToggleAllLabelTarget) {
      this.toggleAllLabelTarget.textContent = allOpen ? 'Ocultar compañías' : 'Mostrar compañías';
    }
    if (this.hasToggleAllButtonTarget) this.toggleAllButtonTarget.setAttribute('aria-pressed', String(allOpen));
  }
}
