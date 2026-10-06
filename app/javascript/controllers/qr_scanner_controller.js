import { Controller } from "@hotwired/stimulus"
import { QrReader, openCamera, closeCamera } from "lib/qr_frame"

// jsQR (~50 KB) solo sirve con la cámara: se pide al abrir esta pantalla y no en cada carga de la app.
// Mientras llega, tick() se salta los cuadros; si falló (sin señal), encender la cámara lo vuelve a pedir.
let jsQR
let loadingJsQR
const loadJsQR = () =>
  (loadingJsQR ||= import("jsqr")
    .then((module) => (jsQR = module.default))
    .catch(() => (loadingJsQR = null)))


// Lee un QR con la cámara del teléfono y salta a donde lleva: la caja del inventario o, desde el panel,
// el gafete de una persona. jsQR va incluido en vendor/javascript porque Safari no trae lector propio.
export default class extends Controller {
  static targets = ["video", "canvas", "status", "start"]
  static values = {
    url: String,
    aim: { type: String, default: "Apunta al código de la caja" },
    found: { type: String, default: "Artículo" }
  }

  connect() {
    loadJsQR()
    // La cámara se apaga al esconder la app o salir de la página; se vuelve a encender con el botón.
    this.onVisibility = () => { if (document.hidden) this.pause() }
    this.onLeave = () => this.pause()
    document.addEventListener("visibilitychange", this.onVisibility)
    document.addEventListener("turbo:before-cache", this.onLeave)
    window.addEventListener("pagehide", this.onLeave)
  }

  disconnect() {
    this.stop()
    this.reader?.close()
    this.reader = null
    document.removeEventListener("visibilitychange", this.onVisibility)
    document.removeEventListener("turbo:before-cache", this.onLeave)
    window.removeEventListener("pagehide", this.onLeave)
  }

  async start() {
    loadJsQR()
    // Cada encendido es un turno: stop() lo cierra, y lo que llegue tarde de un turno cerrado se suelta.
    const run = (this.run = (this.run || 0) + 1)
    const stillWanted = () => run === this.run && this.element.isConnected
    this.startTarget.hidden = true
    this.status("Pidiendo permiso a la cámara…")

    try {
      const reader = this.reader || await QrReader.create(() => jsQR)
      if (!stillWanted()) {
        if (reader !== this.reader) reader.close()
        return
      }
      this.reader = reader
      this.stream = await openCamera(this.videoTarget, stillWanted)
      if (!this.stream) return
    } catch (error) {
      this.startTarget.hidden = false
      this.status("No se pudo abrir la cámara. Escribe el código a mano.", true)
      return
    }

    this.status(this.aimValue)
    this.scanning = true
    this.tick()
  }

  stop() {
    this.run = (this.run || 0) + 1
    this.scanning = false
    if (this.frame) cancelAnimationFrame(this.frame)
    this.stream = closeCamera(this.stream, this.videoTarget)
  }

  // Apagada mientras no se ve: al volver, el botón para encenderla otra vez.
  pause() {
    const on = this.scanning || this.startTarget.hidden // encendida o encendiéndose
    this.stop()
    if (!on) return

    this.startTarget.hidden = false
    this.status("Toca para volver a encender la cámara")
  }

  tick() {
    if (!this.scanning) return

    // Una lectura a la vez, fuera del hilo de la pantalla (lib/qr_frame): apenas termina una, empieza la otra.
    if (this.reader?.ready(this.videoTarget)) {
      this.reader.read(this.videoTarget, this.canvasTarget).then((payload) => {
        if (payload && this.scanning) this.found(payload)
      })
    }

    this.frame = requestAnimationFrame(() => this.tick())
  }

  // El QR lleva el código del artículo; si alguien pega una URL completa, tomamos el último tramo.
  found(payload) {
    const code = payload.trim().split("/").pop().split("?")[0]
    this.stop()
    this.status(`${this.foundValue} ${code}`)
    navigator.vibrate?.(40)
    const url = this.urlValue.replace("CODE", encodeURIComponent(code))
    window.Turbo ? Turbo.visit(url) : (window.location.href = url)
  }

  status(message, isError = false) {
    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle("text-cat-rose-ink", isError)
  }
}
