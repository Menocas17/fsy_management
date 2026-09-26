import { Controller } from "@hotwired/stimulus"
import jsQR from "jsqr"

// Lee el QR pegado en la caja con la cámara del teléfono y salta a la ficha del artículo.
// jsQR va incluido en vendor/javascript porque Safari no trae lector propio.
export default class extends Controller {
  static targets = ["video", "canvas", "status", "start"]
  static values = { url: String }

  disconnect() {
    this.stop()
  }

  async start() {
    this.startTarget.hidden = true
    this.status("Pedí permiso a la cámara…")

    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment" }, audio: false
      })
    } catch (error) {
      this.startTarget.hidden = false
      this.status("No se pudo abrir la cámara. Escribí el código a mano.", true)
      return
    }

    this.videoTarget.srcObject = this.stream
    this.videoTarget.setAttribute("playsinline", true)
    await this.videoTarget.play()
    this.status("Apuntá al código de la caja")
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

    const video = this.videoTarget
    if (video.readyState === video.HAVE_ENOUGH_DATA) {
      const canvas = this.canvasTarget
      canvas.width = video.videoWidth
      canvas.height = video.videoHeight
      const context = canvas.getContext("2d", { willReadFrequently: true })
      context.drawImage(video, 0, 0, canvas.width, canvas.height)

      const image = context.getImageData(0, 0, canvas.width, canvas.height)
      const found = jsQR(image.data, image.width, image.height, { inversionAttempts: "dontInvert" })
      if (found?.data) return this.found(found.data)
    }

    this.frame = requestAnimationFrame(() => this.tick())
  }

  // El QR lleva el código del artículo; si alguien pega una URL completa, tomamos el último tramo.
  found(payload) {
    const code = payload.trim().split("/").pop().split("?")[0]
    this.stop()
    this.status(`Artículo ${code}`)
    window.location.href = this.urlValue.replace("CODE", encodeURIComponent(code))
  }

  status(message, isError = false) {
    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle("text-cat-rose", isError)
  }
}
