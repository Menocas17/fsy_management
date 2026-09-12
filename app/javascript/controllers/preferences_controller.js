import { Controller } from '@hotwired/stimulus';

const KEYS = {
  theme: 'fsy:theme',
  reduceMotion: 'fsy:reduce-motion',
  textSize: 'fsy:text-size',
};

export default class extends Controller {
  static targets = ['themeToggle', 'motionToggle', 'textSizeToggle'];

  connect() {
    this.themeToggleTarget.checked = this.read(KEYS.theme) === 'dark';
    this.motionToggleTarget.checked = this.read(KEYS.reduceMotion) === 'true';
    this.textSizeToggleTarget.checked = this.read(KEYS.textSize) === 'large';
  }

  toggleTheme(event) {
    this.applyAndPersist('dark', event.target.checked, KEYS.theme, 'dark', 'light');
  }

  toggleMotion(event) {
    this.applyAndPersist('reduce-motion', event.target.checked, KEYS.reduceMotion, 'true', 'false');
  }

  toggleTextSize(event) {
    this.applyAndPersist('text-lg-mode', event.target.checked, KEYS.textSize, 'large', 'normal');
  }

  applyAndPersist(className, enabled, key, onValue, offValue) {
    document.documentElement.classList.toggle(className, enabled);
    this.write(key, enabled ? onValue : offValue);
  }

  read(key) {
    try {
      return localStorage.getItem(key);
    } catch (e) {
      return null;
    }
  }

  write(key, value) {
    try {
      localStorage.setItem(key, value);
    } catch (e) {
      // ignore — preference just won't persist this session
    }
  }
}
