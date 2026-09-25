import { Controller } from '@hotwired/stimulus';
import ApexCharts from 'apexcharts';

// Renders a column, stacked column or donut chart with ApexCharts from server-provided data.
// Columns and donuts take a flat series of numbers; stacked charts take [{ name, data }, …].
// Colors arrive as hex (ApexCharts can't parse OKLCH); axis and tooltip colors follow the dark-mode class on <html>.
export default class extends Controller {
  static targets = ['canvas'];
  static values = {
    kind: { type: String, default: 'columns' },
    name: { type: String, default: 'Total' },
    labels: Array,
    series: Array,
    colors: Array,
    height: { type: Number, default: 220 },
    radius: { type: Number, default: 10 },
    columnWidth: { type: String, default: '45%' },
    gradient: Boolean,
    // Valor encima de cada barra, y número grande en el centro del donut.
    showValues: Boolean,
    total: String,
  };

  connect() {
    // A Turbo cache snapshot may still contain the previous render.
    this.canvasTarget.replaceChildren();
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

  disconnect() {
    this.themeObserver?.disconnect();
    this.chart?.destroy();
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

  options() {
    const base = {
      chart: {
        type: this.kindValue === 'donut' ? 'donut' : 'bar',
        stacked: this.kindValue === 'stacked',
        height: this.heightValue,
        fontFamily: 'Onest, sans-serif',
        parentHeightOffset: 0,
        toolbar: { show: false },
        animations: { enabled: !this.reduceMotion, speed: 800 },
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
      grid: { show: false, padding: { left: 0, right: 0, top: this.showValuesValue ? 10 : -10 } },
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
      fill: this.gradientValue
        ? {
            type: 'gradient',
            gradient: {
              type: 'vertical',
              shadeIntensity: 0,
              opacityFrom: 1,
              opacityTo: 0.55,
              stops: [0, 100],
            },
          }
        : { type: 'solid', opacity: 1 },
    };
  }

  donutOptions() {
    return {
      series: this.seriesValue,
      labels: this.labelsValue,
      stroke: { width: 3, colors: [this.surface] },
      fill: this.gradientValue ? { type: 'gradient' } : { type: 'solid', opacity: 1 },
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
      if (this.showValuesValue) {
        theme.dataLabels = { style: { fontSize: '11px', fontWeight: 700, colors: [this.mutedText] } };
      }
    }
    if (this.kindValue === 'stacked') theme.legend = this.legendOptions();
    return theme;
  }
}
