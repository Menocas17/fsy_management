import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['menu', 'backdrop'];

  connect() {
    this.boundHandleResize = this.handleResize.bind(this);
    window.addEventListener('resize', this.boundHandleResize);
  }
  disconnect() {
    window.removeEventListener('resize', this.boundHandleResize);
  }

  toggle(event) {
    event.stopPropagation();
    this.menuTarget.classList.toggle('-translate-x-full');
    this.menuTarget.classList.toggle('translate-x-0');

    this.backdropTarget.classList.toggle('hidden');
  }

  close() {
    this.menuTarget.classList.add('-translate-x-full');
    this.menuTarget.classList.remove('translate-x-0');
    this.backdropTarget.classList.add('hidden');
  }

  handleResize() {
    if (
      window.innerWidth >= 768 &&
      !this.backdropTarget.classList.contains('hidden')
    ) {
      this.close();
    }
  }
}
