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

  // Un número que cambia sube en su ventana (.countdown-tick en application.css); el que no cambia, quieto.
  write(name, value) {
    const target = this[`${name}Target`];
    if (!target) return;

    const text = name === 'days' ? String(value) : String(value).padStart(2, '0');
    if (target.textContent === text) return;
    target.textContent = text;
    target.classList.remove('countdown-tick');
    void target.offsetWidth;
    target.classList.add('countdown-tick');
  }
}
