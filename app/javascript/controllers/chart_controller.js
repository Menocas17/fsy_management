import { Controller } from '@hotwired/stimulus';
import ApexCharts from 'apexcharts';

// Renders a column or donut chart with ApexCharts from server-provided data.
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

  options() {
    const base = {
      chart: {
        type: this.kindValue === 'donut' ? 'donut' : 'bar',
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

    return this.kindValue === 'donut'
      ? { ...base, ...this.donutOptions() }
      : { ...base, ...this.columnOptions() };
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
      grid: { show: false, padding: { left: 0, right: 0, top: -10 } },
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
      plotOptions: {
        pie: { expandOnClick: false, donut: { size: '72%', labels: { show: false } } },
      },
    };
  }

  axisLabelStyle() {
    return { colors: this.mutedText, fontSize: '11.5px', fontWeight: 600 };
  }

  themeOptions() {
    const theme = { tooltip: { theme: this.dark ? 'dark' : 'light' } };
    if (this.kindValue === 'donut') {
      theme.stroke = { width: 3, colors: [this.surface] };
    } else {
      theme.xaxis = { labels: { style: this.axisLabelStyle() } };
    }
    return theme;
  }
}
