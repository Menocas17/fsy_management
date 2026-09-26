import { Controller } from '@hotwired/stimulus';

// Keeps the dashboard countdown ticking. The server renders the first values, so the page is
// already correct without JavaScript.
export default class extends Controller {
  static targets = ['days', 'hours', 'minutes', 'seconds'];
  static values = { startsAt: String };

  connect() {
    this.tick();
    this.timer = setInterval(() => this.tick(), 1000);
  }

  disconnect() {
    clearInterval(this.timer);
  }

  tick() {
    const remaining = Math.max(0, Math.floor((new Date(this.startsAtValue) - Date.now()) / 1000));

    this.write('days', Math.floor(remaining / 86400));
    this.write('hours', Math.floor((remaining % 86400) / 3600));
    this.write('minutes', Math.floor((remaining % 3600) / 60));
    this.write('seconds', remaining % 60);

    if (remaining === 0) clearInterval(this.timer);
  }

  write(name, value) {
    const target = this[`${name}Target`];
    if (target) target.textContent = name === 'days' ? String(value) : String(value).padStart(2, '0');
  }
}
