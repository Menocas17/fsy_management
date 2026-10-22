import { Controller } from '@hotwired/stimulus';

// El lector de manuales (manuals/read): dibuja el PDF con PDF.js, que solo se baja al abrir un manual. Las
// páginas van una tras otra; solo se dibujan las que están cerca de la vista y se sueltan las que se alejan,
// para no llenar la memoria del teléfono con un manual largo. Recuerda en el dispositivo la página donde iba la
// persona (la lee la lista de manuales, manual_progress_controller.js).
let loadingPdfjs;
const loadPdfjs = () => (loadingPdfjs ||= import('pdfjs-dist'));

const ZOOMS = [0.5, 0.75, 1, 1.25, 1.5, 2, 3];
const THUMB_WIDTH = 120;

export default class extends Controller {
  static targets = [
    'viewport', 'pages', 'thumbs', 'current', 'total', 'input', 'zoom', 'progress', 'status', 'error',
    'prev', 'next', 'outline', 'outlineButton', 'outlinePanel', 'outlineList',
  ];
  static values = { url: String, worker: String, storageKey: String };

  async connect() {
    this.zoomIndex = ZOOMS.indexOf(1);
    this.currentPage = 1;
    this.shells = [];
    this.renders = new Map();
    try {
      const pdfjs = await loadPdfjs();
      pdfjs.GlobalWorkerOptions.workerSrc = this.workerValue;
      // Sin eval: el CSP de la app solo deja correr sus propios scripts.
      this.task = pdfjs.getDocument({ url: this.urlValue, isEvalSupported: false });
      this.pdf = await this.task.promise;
      if (!this.element.isConnected) return;
      const first = await this.pdf.getPage(1);
      this.baseSize = first.getViewport({ scale: 1 });
    } catch (error) {
      if (this.element.isConnected) this.fail(error);
      return;
    }
    this.statusTarget.hidden = true;
    this.totalTarget.textContent = this.pdf.numPages;
    this.buildPages();
    this.buildThumbs();
    this.loadOutline();
    this.onScroll = () => this.scheduleTrack();
    this.viewportTarget.addEventListener('scroll', this.onScroll, { passive: true });
    this.onResize = () => { clearTimeout(this.resizeTimer); this.resizeTimer = setTimeout(() => this.relayout(), 200); };
    window.addEventListener('resize', this.onResize);
    this.closeOutline = (event) => {
      if (!this.outlineTarget.contains(event.target)) this.hideOutline();
    };
    document.addEventListener('click', this.closeOutline);
    this.goTo(this.savedPage(), 'instant');
    this.updateIndicators();
  }

  disconnect() {
    this.observer?.disconnect();
    this.thumbObserver?.disconnect();
    this.viewportTarget.removeEventListener('scroll', this.onScroll);
    window.removeEventListener('resize', this.onResize);
    document.removeEventListener('click', this.closeOutline);
    clearTimeout(this.resizeTimer);
    this.renders.forEach((task) => task.cancel());
    this.task?.destroy();
  }

  // Ajusta la página al ancho del visor (sin pasar de su tamaño real), y el zoom multiplica eso.
  get scale() {
    const available = this.viewportTarget.clientWidth - (window.innerWidth < 768 ? 24 : 48);
    const fit = Math.min(available / this.baseSize.width, 1.5);
    return fit * ZOOMS[this.zoomIndex];
  }

  buildPages() {
    this.pagesTarget.replaceChildren();
    this.shells = [];
    for (let number = 1; number <= this.pdf.numPages; number++) {
      const shell = document.createElement('div');
      shell.className = 'relative shrink-0 bg-white rounded-inner shadow-md overflow-hidden';
      shell.dataset.page = number;
      shell.setAttribute('aria-label', `Página ${number}`);
      this.pagesTarget.appendChild(shell);
      this.shells.push(shell);
    }
    this.sizeShells();
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        const number = Number(entry.target.dataset.page);
        if (entry.isIntersecting) this.renderPage(number);
        else this.releasePage(number);
      });
    }, { root: this.viewportTarget, rootMargin: '150% 0px' });
    this.shells.forEach((shell) => this.observer.observe(shell));
  }

  sizeShells() {
    const width = this.baseSize.width * this.scale;
    const height = this.baseSize.height * this.scale;
    this.shells.forEach((shell) => {
      shell.style.width = `${Math.floor(width)}px`;
      shell.style.height = `${Math.floor(height)}px`;
    });
  }

  async renderPage(number) {
    const shell = this.shells[number - 1];
    const scale = this.scale;
    if (!shell || shell.dataset.scale === String(scale)) return;
    this.renders.get(number)?.cancel();
    try {
      const page = await this.pdf.getPage(number);
      const viewport = page.getViewport({ scale });
      const ratio = Math.min(window.devicePixelRatio || 1, 2);
      const canvas = document.createElement('canvas');
      canvas.width = Math.floor(viewport.width * ratio);
      canvas.height = Math.floor(viewport.height * ratio);
      canvas.className = 'block';
      canvas.style.width = `${Math.floor(viewport.width)}px`;
      canvas.style.height = `${Math.floor(viewport.height)}px`;
      const task = page.render({
        canvasContext: canvas.getContext('2d'), viewport,
        transform: ratio === 1 ? null : [ratio, 0, 0, ratio, 0, 0],
      });
      this.renders.set(number, task);
      await task.promise;
      this.renders.delete(number);
      // Una página puede medir distinto que la primera: el marco toma su tamaño real.
      shell.style.width = canvas.style.width;
      shell.style.height = canvas.style.height;
      shell.replaceChildren(canvas);
      shell.dataset.scale = String(scale);
    } catch (error) {
      if (error?.name !== 'RenderingCancelledException') console.warn('No se pudo dibujar la página', number, error);
    }
  }

  releasePage(number) {
    const shell = this.shells[number - 1];
    if (!shell?.dataset.scale) return;
    this.renders.get(number)?.cancel();
    shell.replaceChildren();
    delete shell.dataset.scale;
  }

  // Las miniaturas (solo en la computadora, donde se ve la columna): se dibujan al asomarse.
  buildThumbs() {
    if (!this.hasThumbsTarget || this.thumbsTarget.offsetParent === null) return;
    const height = Math.round(THUMB_WIDTH * (this.baseSize.height / this.baseSize.width));
    for (let number = 1; number <= this.pdf.numPages; number++) {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'flex flex-col items-center gap-1.5 cursor-pointer group';
      button.dataset.thumb = number;
      button.setAttribute('aria-label', `Ir a la página ${number}`);
      button.addEventListener('click', () => this.goTo(number));
      const frame = document.createElement('span');
      frame.className = 'block bg-white rounded-avatar-sm shadow-sm ring-2 ring-transparent group-data-[current]:ring-sun overflow-hidden';
      frame.style.width = `${THUMB_WIDTH}px`;
      frame.style.height = `${height}px`;
      const label = document.createElement('span');
      label.className = 'text-meta font-semibold text-ink-500 tabular-nums group-data-[current]:text-ink-900 group-data-[current]:font-bold';
      label.textContent = number;
      button.append(frame, label);
      this.thumbsTarget.appendChild(button);
    }
    this.thumbObserver = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        this.thumbObserver.unobserve(entry.target);
        this.renderThumb(entry.target);
      });
    }, { root: this.thumbsTarget.parentElement, rootMargin: '100% 0px' });
    this.thumbsTarget.querySelectorAll('[data-thumb]').forEach((button) => this.thumbObserver.observe(button));
  }

  async renderThumb(button) {
    try {
      const page = await this.pdf.getPage(Number(button.dataset.thumb));
      const viewport = page.getViewport({ scale: (THUMB_WIDTH * 2) / page.getViewport({ scale: 1 }).width });
      const canvas = document.createElement('canvas');
      canvas.width = Math.floor(viewport.width);
      canvas.height = Math.floor(viewport.height);
      canvas.className = 'block w-full h-full';
      await page.render({ canvasContext: canvas.getContext('2d'), viewport }).promise;
      button.firstChild.replaceChildren(canvas);
    } catch (error) {
      console.warn('No se pudo dibujar la miniatura', error);
    }
  }

  // El índice que trae el PDF (sus marcadores), si trae: el primer nivel y el segundo.
  async loadOutline() {
    let outline;
    try { outline = await this.pdf.getOutline(); } catch { return; }
    if (!outline?.length || !this.element.isConnected) return;
    const add = (item, depth) => {
      const li = document.createElement('li');
      const button = document.createElement('button');
      button.type = 'button';
      button.className = `w-full text-left px-2.5 py-2 rounded-inner hover:bg-muted text-body cursor-pointer ${depth ? 'pl-6 text-ink-700' : 'font-semibold text-ink-900'}`;
      button.textContent = item.title;
      button.addEventListener('click', () => this.openDestination(item.dest));
      li.appendChild(button);
      this.outlineListTarget.appendChild(li);
      if (depth === 0) (item.items || []).forEach((child) => add(child, 1));
    };
    outline.forEach((item) => add(item, 0));
    this.outlineTarget.hidden = false;
  }

  async openDestination(dest) {
    try {
      const explicit = typeof dest === 'string' ? await this.pdf.getDestination(dest) : dest;
      if (!explicit) return;
      const index = typeof explicit[0] === 'number' ? explicit[0] : await this.pdf.getPageIndex(explicit[0]);
      this.hideOutline();
      this.goTo(index + 1);
    } catch (error) {
      console.warn('No se pudo abrir esa parte del índice', error);
    }
  }

  toggleOutline(event) {
    event.stopPropagation();
    const open = this.outlinePanelTarget.hidden;
    this.outlinePanelTarget.hidden = !open;
    this.outlineButtonTarget.setAttribute('aria-expanded', String(open));
  }

  hideOutline() {
    if (!this.hasOutlinePanelTarget) return;
    this.outlinePanelTarget.hidden = true;
    this.outlineButtonTarget.setAttribute('aria-expanded', 'false');
  }

  previous() { this.goTo(this.currentPage - 1); }
  next() { this.goTo(this.currentPage + 1); }

  jump(event) {
    const number = parseInt(event.target.value, 10);
    if (Number.isFinite(number)) this.goTo(number);
    else event.target.value = this.currentPage;
  }

  zoomIn() { this.setZoom(this.zoomIndex + 1); }
  zoomOut() { this.setZoom(this.zoomIndex - 1); }

  setZoom(index) {
    if (!this.pdf || index < 0 || index >= ZOOMS.length) return;
    this.zoomIndex = index;
    this.relayout();
  }

  // Cambió el zoom o el ancho: nuevos tamaños, se redibuja lo que se ve y se vuelve a la misma página.
  relayout() {
    if (!this.pdf) return;
    const page = this.currentPage;
    this.shells.forEach((shell, index) => this.releasePage(index + 1));
    this.sizeShells();
    this.goTo(page, 'instant');
    this.shells.forEach((shell, index) => {
      const top = shell.offsetTop - this.viewportTarget.scrollTop;
      if (top < this.viewportTarget.clientHeight * 2.5 && top + shell.offsetHeight > -this.viewportTarget.clientHeight * 1.5) this.renderPage(index + 1);
    });
    this.updateIndicators();
  }

  goTo(number, behavior = 'smooth') {
    if (!this.pdf) return;
    const page = Math.min(Math.max(number, 1), this.pdf.numPages);
    const shell = this.shells[page - 1];
    this.viewportTarget.scrollTo({ top: shell.offsetTop - 12, behavior });
    this.currentPage = page;
    this.updateIndicators();
  }

  scheduleTrack() {
    if (this.tracking) return;
    this.tracking = true;
    requestAnimationFrame(() => {
      this.tracking = false;
      this.trackCurrent();
    });
  }

  // La página actual es la que cruza el primer tercio del visor.
  trackCurrent() {
    const line = this.viewportTarget.scrollTop + this.viewportTarget.clientHeight / 3;
    const shell = this.shells.find((candidate) => candidate.offsetTop + candidate.offsetHeight > line) || this.shells.at(-1);
    const page = Number(shell.dataset.page);
    if (page === this.currentPage) return;
    this.currentPage = page;
    this.updateIndicators();
  }

  updateIndicators() {
    if (!this.pdf) return;
    const total = this.pdf.numPages;
    this.currentTarget.textContent = this.currentPage;
    this.inputTargets.forEach((input) => { if (document.activeElement !== input) input.value = this.currentPage; });
    this.zoomTargets.forEach((label) => { label.textContent = `${Math.round(ZOOMS[this.zoomIndex] * 100)} %`; });
    this.progressTarget.style.width = `${(this.currentPage / total) * 100}%`;
    this.prevTargets.forEach((button) => { button.disabled = this.currentPage <= 1; });
    this.nextTargets.forEach((button) => { button.disabled = this.currentPage >= total; });
    if (this.hasThumbsTarget) {
      this.thumbsTarget.querySelectorAll('[data-current]').forEach((thumb) => delete thumb.dataset.current);
      const thumb = this.thumbsTarget.querySelector(`[data-thumb="${this.currentPage}"]`);
      if (thumb) {
        thumb.dataset.current = '';
        thumb.scrollIntoView({ block: 'nearest' });
      }
    }
    this.savePage(total);
  }

  savedPage() {
    try {
      return JSON.parse(localStorage.getItem(this.storageKeyValue))?.page || 1;
    } catch {
      return 1;
    }
  }

  savePage(total) {
    try {
      localStorage.setItem(this.storageKeyValue, JSON.stringify({ page: this.currentPage, total }));
    } catch {
      // Sin almacenamiento (modo privado): el lector funciona igual, solo no recuerda la página.
    }
  }

  fail(error) {
    console.warn('No se pudo abrir el manual', error);
    this.statusTarget.hidden = true;
    this.errorTarget.hidden = false;
  }
}
