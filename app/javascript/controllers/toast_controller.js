import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { timeout: { type: Number, default: 4000 } };

  connect() {
    this.timer = setTimeout(() => {
      this.close();
    }, this.timeoutValue);
  }

  close() {
    clearTimeout(this.timer);

    this.element.classList.add('opacity-0', 'translate-x-full');

    setTimeout(() => {
      this.element.remove();
    }, 300);
  }
}
