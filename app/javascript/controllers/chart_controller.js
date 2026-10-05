import { Controller } from '@hotwired/stimulus';

// Renders a column, stacked column or donut chart with ApexCharts from server-provided data.
// Columns and donuts take a flat series of numbers; stacked charts take [{ name, data }, …].
// Colors arrive as hex (ApexCharts can't parse OKLCH); axis and tooltip colors follow the dark-mode class on <html>.
// Rellenos sólidos siempre: el color es el dato (ChartsHelper), un degradado solo lo ensucia.

// ApexCharts pesa ~300 KB comprimido: se pide la primera vez que una página trae gráficas, no en cada carga.
let apexCharts;
const loadApexCharts = () =>
  (apexCharts ||= import('apexcharts')
    .then((module) => module.default)
    .catch((error) => {
      apexCharts = null;
      throw error;
    }));

// Al volver atrás Turbo pinta la página desde su caché: las gráficas aparecen quietas en vez de crecer otra vez.
let restoring = false;
document.addEventListener('turbo:visit', (event) => {
  restoring = event.detail?.action === 'restore';
});
document.addEventListener('turbo:load', () => {
  queueMicrotask(() => (restoring = false));
});

export default class extends Controller {
  static targets = ['canvas'];
  static values = {
    kind: { type: String, default: 'columns' },
    name: { type: String, default: 'Total' },
    labels: Array,
    series: Array,
    colors: Array,
    height: { type: Number, default: 220 },
    radius: { type: Number, default: 5 },
    columnWidth: { type: String, default: '45%' },
    // Valor encima de cada barra, y número grande en el centro del donut.
    showValues: Boolean,
    total: String,
  };

  async connect() {
    // A Turbo cache snapshot may still contain the previous render.
    this.canvasTarget.replaceChildren();
    // Se lee antes de esperar la librería: turbo:load ya habrá apagado la bandera cuando llegue.
    this.restored = restoring;
    const ApexCharts = await loadApexCharts();
    // Crece cuando se ve, no al cargar: bajo el borde del panel la animación pasaba sin que nadie la viera.
    if (!this.restored) await this.untilVisible();
    // Turbo pudo haber salido de la página mientras llegaba.
    if (!this.element.isConnected || this.chart) return;

    this.chart = new ApexCharts(this.canvasTarget, this.options());
    this.chart.render();

    this.themeObserver = new MutationObserver(() =>
      this.chart.updateOptions(this.themeOptions(), false, false),
    );
    this.themeObserver.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class'],
    });
  }

  // Se resuelve cuando un tercio de la gráfica entra a la pantalla (en el acto si ya está a la vista).
  untilVisible() {
    if (!('IntersectionObserver' in window)) return Promise.resolve();

    return new Promise((resolve) => {
      this.visibilityObserver = new IntersectionObserver(
        (entries) => {
          if (!entries.some((entry) => entry.isIntersecting)) return;
          this.visibilityObserver.disconnect();
          resolve();
        },
        { threshold: 0.3 },
      );
      this.visibilityObserver.observe(this.element);
    });
  }

  disconnect() {
    this.visibilityObserver?.disconnect();
    this.themeObserver?.disconnect();
    this.chart?.destroy();
    this.chart = null;
  }

  get dark() {
    return document.documentElement.classList.contains('dark');
  }

  get reduceMotion() {
    return (
      document.documentElement.classList.contains('reduce-motion') ||
      window.matchMedia('(prefers-reduced-motion: reduce)').matches
    );
  }

  get mutedText() {
    return this.dark ? '#94a3b8' : '#6f757e';
  }

  get surface() {
    return this.dark ? '#1e293b' : '#fcfcfd';
  }

  get headingColor() {
    return this.dark ? '#f1f5f9' : '#1d2b4a';
  }

  // Las mismas líneas que las tarjetas (line-soft), para leer la magnitud sin que la cuadrícula compita.
  get gridColor() {
    return this.dark ? '#314158' : '#e6e9ef';
  }

  options() {
    const base = {
      chart: {
        type: this.kindValue === 'donut' ? 'donut' : 'bar',
        stacked: this.kindValue === 'stacked',
        height: this.heightValue,
        fontFamily: 'Onest, sans-serif',
        parentHeightOffset: 0,
        toolbar: { show: false },
        animations: {
          enabled: !this.reduceMotion && !this.restored,
          speed: 380,
          animateGradually: { enabled: false },
          dynamicAnimation: { speed: 250 },
        },
      },
      colors: this.colorsValue,
      dataLabels: { enabled: false },
      legend: { show: false },
      tooltip: { theme: this.dark ? 'dark' : 'light' },
    };

    if (this.kindValue === 'donut') return { ...base, ...this.donutOptions() };
    if (this.kindValue === 'stacked') return { ...base, ...this.stackedOptions() };
    return { ...base, ...this.columnOptions() };
  }

  stackedOptions() {
    return {
      ...this.columnOptions(),
      series: this.seriesValue,
      plotOptions: {
        bar: {
          columnWidth: this.columnWidthValue,
          borderRadius: this.radiusValue,
          borderRadiusApplication: 'end',
          borderRadiusWhenStacked: 'last',
        },
      },
      fill: { type: 'solid', opacity: 1 },
      legend: this.legendOptions(),
      tooltip: { theme: this.dark ? 'dark' : 'light', shared: true, intersect: false },
    };
  }

  legendOptions() {
    return {
      show: true,
      position: 'top',
      horizontalAlign: 'left',
      fontSize: '12px',
      fontWeight: 600,
      labels: { colors: this.mutedText },
    };
  }

  columnOptions() {
    return {
      series: [{ name: this.nameValue, data: this.seriesValue }],
      xaxis: {
        categories: this.labelsValue,
        axisBorder: { show: false },
        axisTicks: { show: false },
        labels: { style: this.axisLabelStyle() },
      },
      yaxis: { show: false },
      grid: this.gridOptions(),
      dataLabels: this.showValuesValue
        ? {
            enabled: true,
            offsetY: -22,
            style: { fontSize: '11px', fontWeight: 700, colors: [this.mutedText] },
          }
        : { enabled: false },
      plotOptions: {
        bar: {
          distributed: true,
          columnWidth: this.columnWidthValue,
          borderRadius: this.radiusValue,
          borderRadiusApplication: 'end',
        },
      },
      fill: { type: 'solid', opacity: 1 },
    };
  }

  // Con los valores escritos sobre cada barra la cuadrícula sobra; sin ellos, unas líneas tenues dan la escala.
  gridOptions() {
    const padding = { left: 0, right: 0, top: this.showValuesValue ? 10 : -10 };
    if (this.showValuesValue) return { show: false, padding };

    return {
      show: true,
      borderColor: this.gridColor,
      strokeDashArray: 0,
      xaxis: { lines: { show: false } },
      yaxis: { lines: { show: true } },
      padding,
    };
  }

  donutOptions() {
    return {
      series: this.seriesValue,
      labels: this.labelsValue,
      stroke: { width: 3, colors: [this.surface] },
      fill: { type: 'solid', opacity: 1 },
      plotOptions: {
        pie: {
          expandOnClick: false,
          donut: { size: '70%', labels: this.donutCenter() },
        },
      },
    };
  }

  // El total va en el hueco del donut: se lee como una sola pieza en vez de un aro suelto.
  donutCenter() {
    if (!this.totalValue) return { show: false };

    const style = { fontSize: '28px', fontWeight: 800, color: this.headingColor };
    return {
      show: true,
      name: { show: false },
      value: { show: true, offsetY: 7, ...style },
      total: { show: true, showAlways: true, label: '', formatter: () => this.totalValue, ...style },
    };
  }

  axisLabelStyle() {
    return { colors: this.mutedText, fontSize: '11.5px', fontWeight: 600 };
  }

  themeOptions() {
    const theme = { tooltip: { theme: this.dark ? 'dark' : 'light' } };
    if (this.kindValue === 'donut') {
      theme.stroke = { width: 3, colors: [this.surface] };
      theme.plotOptions = { pie: { donut: { labels: this.donutCenter() } } };
    } else {
      theme.xaxis = { labels: { style: this.axisLabelStyle() } };
      theme.grid = this.gridOptions();
      if (this.showValuesValue) {
        theme.dataLabels = { style: { fontSize: '11px', fontWeight: 700, colors: [this.mutedText] } };
      }
    }
    if (this.kindValue === 'stacked') theme.legend = this.legendOptions();
    return theme;
  }
}
