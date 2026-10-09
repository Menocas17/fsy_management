import { Controller } from "@hotwired/stimulus"

// Llega por el stream "alerts" cuando entra una alerta (shared/_alerts_signal). Le avisa a la campanita
// (alert_chime_controller#check) para que pregunte su número, después de una espera al azar de hasta unos
// segundos: con todos los teléfonos abiertos a la vez, las preguntas llegan repartidas y no de golpe.
const SPREAD_MS = 8000

export default class extends Controller {
  static values = { id: Number }

  connect() {
    // Una copia de la caché de Turbo trae el aviso viejo: no es una alerta nueva.
    if (document.documentElement.hasAttribute("data-turbo-preview")) return

    this.timer = setTimeout(() => {
      window.dispatchEvent(new CustomEvent("alerts:changed", { detail: { id: this.idValue } }))
    }, Math.random() * SPREAD_MS)
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
