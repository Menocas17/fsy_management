import { Controller } from '@hotwired/stimulus';

const MIN_SCALE = 0.1;
const MAX_SCALE = 2;
const ZOOM_STEP = 1.25;
const DRAG_THRESHOLD = 4;
const PAN_STEP = 60;

// Pan & zoom canvas for the organigrama.
// Drag (mouse or touch) to move, pinch or Ctrl/⌘ + wheel to zoom, plain wheel/trackpad to pan,
// and the toolbar or keyboard (arrows, + / −, 0 to fit) for everything else.
export default class extends Controller {
  static targets = ['viewport', 'canvas', 'zoomLabel', 'fullscreenButton', 'branch', 'toggleAllButton', 'toggleAllLabel'];

  connect() {
    this.scale = 1;
    this.x = 0;
    this.y = 0;
    this.pointers = new Map();
    this.dragged = false;
    this.fitted = false;
    this.interacted = false;

    if (this.hasFullscreenButtonTarget && !document.fullscreenEnabled) {
      this.fullscreenButtonTarget.hidden = true;
    }

    this.handleFullscreenChange = () => requestAnimationFrame(() => this.fit());
    document.addEventListener('fullscreenchange', this.handleFullscreenChange);

    // The canvas is hidden on phones; fit it the first time it gets a real size.
    this.resizeObserver = new ResizeObserver(() => {
      if (!this.fitted) this.fit();
    });
    this.resizeObserver.observe(this.viewportTarget);

    // Web fonts change node sizes, so refit once they load unless the user already moved around.
    document.fonts?.ready.then(() => {
      if (!this.interacted) this.fit();
    });
  }

  disconnect() {
    document.removeEventListener('fullscreenchange', this.handleFullscreenChange);
    this.resizeObserver?.disconnect();
  }

  // Toolbar ---------------------------------------------------------------

  zoomIn() {
    this.zoomAtCenter(ZOOM_STEP);
  }

  zoomOut() {
    this.zoomAtCenter(1 / ZOOM_STEP);
  }

  fit() {
    const viewport = this.viewportTarget;
    const width = this.canvasTarget.offsetWidth;
    const height = this.canvasTarget.offsetHeight;
    if (!width || !height || !viewport.clientWidth || !viewport.clientHeight) return;

    this.scale = this.clamp(Math.min(viewport.clientWidth / width, viewport.clientHeight / height, 1));
    this.x = (viewport.clientWidth - width * this.scale) / 2;
    this.y = Math.max((viewport.clientHeight - height * this.scale) / 2, 0);
    this.fitted = true;
    this.apply();
  }

  // Collapsible branches -------------------------------------------------

  toggleBranch(event) {
    const branch = this.branchTargets.find((element) => element.id === event.currentTarget.dataset.branch);
    if (branch) this.setBranch(branch, branch.hidden);
  }

  toggleAll() {
    const expand = this.branchTargets.some((branch) => branch.hidden);
    this.branchTargets.forEach((branch) => this.setBranch(branch, expand));

    if (this.hasToggleAllLabelTarget) {
      this.toggleAllLabelTarget.textContent = expand ? 'Ocultar compañías' : 'Mostrar compañías';
    }
    this.toggleAllButtonTarget?.setAttribute('aria-pressed', String(expand));
    requestAnimationFrame(() => this.fit());
  }

  setBranch(branch, expanded) {
    branch.hidden = !expanded;
    const button = this.element.querySelector(`[data-branch="${branch.id}"]`);
    if (!button) return;

    button.setAttribute('aria-expanded', String(expanded));
    button.querySelector('svg')?.classList.toggle('rotate-180', expanded);
  }

  toggleFullscreen() {
    if (document.fullscreenElement) {
      document.exitFullscreen();
    } else {
      this.element.requestFullscreen?.();
    }
  }

  // Pointer panning and pinch zoom ----------------------------------------

  pointerDown(event) {
    if (event.button !== 0 || event.target.closest('[data-org-chart-controls]')) return;

    this.pointers.set(event.pointerId, { x: event.clientX, y: event.clientY });
    if (this.pointers.size === 1) {
      this.dragged = false;
      this.start = { x: event.clientX, y: event.clientY };
    }
    this.pinchDistance = this.pointers.size === 2 ? this.distance() : null;
  }

  pointerMove(event) {
    const previous = this.pointers.get(event.pointerId);
    if (!previous) return;

    const current = { x: event.clientX, y: event.clientY };
    this.pointers.set(event.pointerId, current);

    if (this.pointers.size === 2) {
      const distance = this.distance();
      if (this.pinchDistance) {
        const [a, b] = [...this.pointers.values()];
        const rect = this.viewportTarget.getBoundingClientRect();
        this.zoomAt(distance / this.pinchDistance, (a.x + b.x) / 2 - rect.left, (a.y + b.y) / 2 - rect.top);
      }
      this.pinchDistance = distance;
      this.dragged = true;
      return;
    }

    if (!this.dragged) {
      if (Math.hypot(current.x - this.start.x, current.y - this.start.y) < DRAG_THRESHOLD) return;
      // Capture only once it's a real drag, so a plain click still reaches the node's link.
      this.dragged = true;
      this.viewportTarget.setPointerCapture(event.pointerId);
      this.viewportTarget.dataset.dragging = '';
    }

    this.panBy(current.x - previous.x, current.y - previous.y);
  }

  pointerUp(event) {
    this.pointers.delete(event.pointerId);
    if (this.pointers.size < 2) this.pinchDistance = null;
    if (this.pointers.size === 0) delete this.viewportTarget.dataset.dragging;
  }

  // A drag that ends over a node shouldn't also follow its link.
  suppressClick(event) {
    if (!this.dragged) return;
    event.preventDefault();
    event.stopPropagation();
    this.dragged = false;
  }

  wheel(event) {
    event.preventDefault();
    const unit = event.deltaMode === 1 ? 16 : 1;

    if (event.ctrlKey || event.metaKey) {
      const rect = this.viewportTarget.getBoundingClientRect();
      this.zoomAt(Math.exp(-event.deltaY * unit * 0.01), event.clientX - rect.left, event.clientY - rect.top);
    } else {
      this.panBy(-event.deltaX * unit, -event.deltaY * unit);
    }
  }

  keydown(event) {
    if (event.ctrlKey || event.metaKey || event.altKey || event.target.closest('[data-org-chart-controls]')) return;

    const actions = {
      ArrowLeft: () => this.panBy(PAN_STEP, 0),
      ArrowRight: () => this.panBy(-PAN_STEP, 0),
      ArrowUp: () => this.panBy(0, PAN_STEP),
      ArrowDown: () => this.panBy(0, -PAN_STEP),
      '+': () => this.zoomIn(),
      '=': () => this.zoomIn(),
      '-': () => this.zoomOut(),
      0: () => this.fit(),
    };
    const action = actions[event.key];
    if (!action) return;

    event.preventDefault();
    action();
  }

  // Helpers ---------------------------------------------------------------

  panBy(dx, dy) {
    this.x += dx;
    this.y += dy;
    this.interacted = true;
    this.apply();
  }

  zoomAtCenter(factor) {
    this.zoomAt(factor, this.viewportTarget.clientWidth / 2, this.viewportTarget.clientHeight / 2);
  }

  zoomAt(factor, originX, originY) {
    const scale = this.clamp(this.scale * factor);
    const ratio = scale / this.scale;
    this.x = originX - (originX - this.x) * ratio;
    this.y = originY - (originY - this.y) * ratio;
    this.scale = scale;
    this.interacted = true;
    this.apply();
  }

  clamp(scale) {
    return Math.min(MAX_SCALE, Math.max(MIN_SCALE, scale));
  }

  distance() {
    const [a, b] = [...this.pointers.values()];
    return Math.hypot(a.x - b.x, a.y - b.y);
  }

  apply() {
    this.canvasTarget.style.transform = `translate(${this.x}px, ${this.y}px) scale(${this.scale})`;
    if (this.hasZoomLabelTarget) this.zoomLabelTarget.textContent = `${Math.round(this.scale * 100)}%`;
  }
}
