import { Controller } from "@hotwired/stimulus"
import { CAMERA, QrReader } from "lib/qr_frame"

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
  }

  disconnect() {
    this.stop()
    this.reader?.close()
    this.reader = null
  }

  async start() {
    loadJsQR()
    this.startTarget.hidden = true
    this.status("Pidiendo permiso a la cámara…")

    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: CAMERA, audio: false
      })
    } catch (error) {
      this.startTarget.hidden = false
      this.status("No se pudo abrir la cámara. Escribe el código a mano.", true)
      return
    }

    this.videoTarget.srcObject = this.stream
    this.videoTarget.setAttribute("playsinline", true)
    await this.videoTarget.play()
    this.reader ||= await QrReader.create(() => jsQR)
    this.status(this.aimValue)
    this.scanning = true
    this.tick()
  }

  stop() {
    this.scanning = false
    if (this.frame) cancelAnimationFrame(this.frame)
    this.stream?.getTracks().forEach((track) => track.stop())
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
