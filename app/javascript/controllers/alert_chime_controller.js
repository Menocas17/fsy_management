import { Controller } from "@hotwired/stimulus"

// Turbo guarda una copia de cada página para mostrarla al instante al volver. Esa copia lleva el
// contador congelado, así que hay que saber si lo que se está dibujando es fresco o de la caché:
// si no, al regresar al panel la campanita "revive" alertas que ya se leyeron y vuelve a sonar.
let restoring = false

document.addEventListener("turbo:visit", (event) => {
  restoring = event.detail?.action === "restore"
})
document.addEventListener("turbo:load", () => {
  queueMicrotask(() => { restoring = false })
})

// Suena y vibra cuando entra una alerta con la app abierta. Con la app cerrada avisa el sistema.
export default class extends Controller {
  static targets = ["badge"]
  static values = { unread: Number, countUrl: String }

  connect() {
    // La vista previa de la caché se reemplaza sola por la respuesta real: no hay nada que hacer.
    if (document.documentElement.hasAttribute("data-turbo-preview")) return

    // Al volver atrás, el HTML es viejo: se le pregunta al servidor en vez de creerle, y nunca suena.
    if (restoring) return this.refresh()

    const previous = this.remembered
    this.remember(this.unreadValue)
    if (previous !== null && this.unreadValue > previous) this.announce()
  }

  async refresh() {
    if (!this.hasCountUrlValue) return

    try {
      const response = await fetch(this.countUrlValue, { headers: { Accept: "application/json" } })
      if (!response.ok) return

      const { unread } = await response.json()
      this.paint(unread)
      this.remember(unread)
    } catch (error) {
      // Sin red: se queda lo que hay, y la próxima navegación lo corrige.
    }
  }

  paint(unread) {
    const grew = unread > this.unreadValue
    this.unreadValue = unread
    this.badgeTargets.forEach((badge) => {
      badge.textContent = unread
      badge.hidden = unread < 1
      // Una alerta nueva es rara e importante: el número salta un poco para que se note sin mirar la campanita.
      if (grew && !badge.hidden && !this.reducedMotion) {
        badge.animate([ { transform: "scale(.6)" }, { transform: "scale(1)" } ],
                      { duration: 220, easing: "cubic-bezier(0.34, 1.4, 0.64, 1)" })
      }
    })
  }

  get reducedMotion() {
    return document.documentElement.classList.contains("reduce-motion") ||
      window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  announce() {
    if (!this.enabled) return

    navigator.vibrate?.([ 90, 60, 90 ])
    this.beep()
  }

  // Dos notas cortas, generadas al vuelo: ningún archivo que cargar.
  beep() {
    const Context = window.AudioContext || window.webkitAudioContext
    if (!Context) return

    try {
      window.fsyAudioContext ||= new Context()
      const audio = window.fsyAudioContext
      if (audio.state === "suspended") audio.resume().catch(() => {})

      for (const [ frequency, offset ] of [ [ 880, 0 ], [ 1175, 0.12 ] ]) {
        const oscillator = audio.createOscillator()
        const gain = audio.createGain()
        const start = audio.currentTime + offset

        oscillator.type = "sine"
        oscillator.frequency.value = frequency
        gain.gain.setValueAtTime(0.0001, start)
        gain.gain.linearRampToValueAtTime(0.16, start + 0.02)
        gain.gain.exponentialRampToValueAtTime(0.0001, start + 0.18)

        oscillator.connect(gain).connect(audio.destination)
        oscillator.start(start)
        oscillator.stop(start + 0.2)
      }
    } catch (error) {
      // Sin permiso de audio todavía: el número de la campanita ya cambió, que es lo importante.
    }
  }

  // El mismo interruptor que gobierna las notificaciones del sistema, en Configuración.
  get enabled() {
    try {
      return localStorage.getItem("fsy:push-sound") !== "false"
    } catch (error) {
      return true
    }
  }

  get remembered() {
    try {
      const value = sessionStorage.getItem("fsy:unread")
      return value === null ? null : Number(value)
    } catch (error) {
      return null
    }
  }

  remember(count) {
    try {
      sessionStorage.setItem("fsy:unread", count)
    } catch (error) {
      // Navegación privada: sin memoria, no suena; tampoco molesta.
    }
  }
}
