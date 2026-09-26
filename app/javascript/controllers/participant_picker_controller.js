import { Controller } from '@hotwired/stimulus';

const MAX_RESULTS = 8;
const normalize = (text) =>
  text
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase();

// Search box over the staff list: picking somebody moves them into the chosen box, where each
// one carries its own hidden field and a button to take them out again.
export default class extends Controller {
  static targets = ['query', 'option', 'results', 'selected', 'empty', 'template', 'status'];

  connect() {
    this.syncEmptyState();
  }

  filter() {
    const term = normalize(this.queryTarget.value.trim());
    let shown = 0;

    this.optionTargets.forEach((option) => {
      const matches =
        term.length > 0 &&
        !this.isSelected(option.dataset.id) &&
        normalize(option.dataset.search).includes(term) &&
        shown < MAX_RESULTS;

      option.hidden = !matches;
      if (matches) shown += 1;
    });

    this.resultsTarget.hidden = shown === 0;
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = term.length > 0 && shown === 0 ? 'Nadie coincide con esa búsqueda.' : '';
    }
  }

  // Enter picks the first match instead of submitting the form.
  keydown(event) {
    if (event.key !== 'Enter') return;

    event.preventDefault();
    const first = this.optionTargets.find((option) => !option.hidden);
    first?.querySelector('button')?.click();
  }

  add(event) {
    const { id, name, role } = event.currentTarget.dataset;
    if (this.isSelected(id)) return;

    const chip = this.templateTarget.content.firstElementChild.cloneNode(true);
    chip.dataset.id = id;
    chip.querySelector('[data-name]').textContent = name;
    chip.querySelector('[data-role]').textContent = role;
    chip.querySelector('input').value = id;
    this.selectedTarget.appendChild(chip);

    this.queryTarget.value = '';
    this.filter();
    this.syncEmptyState();
    this.queryTarget.focus();
  }

  remove(event) {
    event.currentTarget.closest('[data-picked]').remove();
    this.syncEmptyState();
    this.filter();
  }

  isSelected(id) {
    return this.selectedTarget.querySelector(`[data-picked][data-id="${id}"]`) !== null;
  }

  syncEmptyState() {
    if (!this.hasEmptyTarget) return;

    this.emptyTarget.hidden = this.selectedTarget.querySelectorAll('[data-picked]').length > 0;
  }
}
