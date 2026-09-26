import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ['menu', 'chevron'];

  toggle(event) {
    event.stopPropagation();
    this.menuTarget.classList.toggle('hidden');
    this.chevronTargets.forEach((chevron) => chevron.classList.toggle('rotate-180'));
  }

  hide(event) {
    if (this.menuTarget.classList.contains('hidden')) return;
    if (this.element.contains(event.target)) return;

    this.close();
  }

  close() {
    this.menuTarget.classList.add('hidden');
    this.chevronTargets.forEach((chevron) => chevron.classList.remove('rotate-180'));
  }
}
