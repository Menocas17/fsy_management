import { Controller } from "@hotwired/stimulus"

// Registra el dispositivo para recibir notificaciones aunque la app esté cerrada.
// El permiso solo se puede pedir a partir de un clic, así que todo cuelga del botón de Configuración.
export default class extends Controller {
  static targets = ["button", "status", "sound", "test"]
  static values = { publicKey: String, url: String, testUrl: String }

  connect() {
    if (this.hasSoundTarget) this.soundTarget.checked = this.soundEnabled
    this.refresh()
  }

  get supported() {
    return "serviceWorker" in navigator && "PushManager" in window && "Notification" in window
  }

  async refresh() {
    if (!this.supported) {
      return this.paint("no-soportado", "Este navegador no admite notificaciones. En iPhone hay que agregar la app a la pantalla de inicio primero.")
    }
    if (Notification.permission === "denied") {
      return this.paint("bloqueado", "Las notificaciones están bloqueadas para este sitio; hay que permitirlas desde los ajustes del navegador.")
    }

    const subscription = await this.healed(await this.currentSubscription())
    this.paint(subscription ? "activo" : "inactivo",
      subscription ? "Este dispositivo recibirá las alertas." : "Este dispositivo todavía no recibe alertas.")
  }

  // Que el teléfono diga «activo» no basta: la suscripción puede estar hecha con otra llave del servidor (se
  // cambiaron las credenciales) o faltar en la base. Con la llave vieja se rehace sin volver a pedir permiso,
  // y en cualquier caso se le vuelve a mandar al servidor, que la guarda una sola vez.
  async healed(subscription) {
    if (!subscription || Notification.permission !== "granted") return subscription

    if (!this.sameKey(subscription.options?.applicationServerKey)) {
      await subscription.unsubscribe()
      subscription = await this.subscribe()
    }
    return (await this.save(subscription)) ? subscription : null
  }

  sameKey(buffer) {
    if (!buffer) return true
    const current = this.decodeKey(this.publicKeyValue)
    const given = new Uint8Array(buffer)
    return given.length === current.length && given.every((byte, index) => byte === current[index])
  }

  async toggle() {
    if (!this.supported) return

    const subscription = await this.currentSubscription()
    if (subscription) return this.disable(subscription)

    await this.enable()
  }

  async enable() {
    this.paint("pidiendo", "Esperando tu permiso…")
    const permission = await Notification.requestPermission()
    if (permission !== "granted") return this.refresh()

    const subscription = await this.subscribe()
    if (!(await this.save(subscription))) {
      await subscription.unsubscribe()
      return this.paint("error", "No se pudo guardar la suscripción. Intenta de nuevo.")
    }

    this.paint("activo", "Listo: este dispositivo recibirá las alertas.")
    this.preview()
  }

  async subscribe() {
    const registration = await this.registration()
    return registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: this.decodeKey(this.publicKeyValue)
    })
  }

  async save(subscription) {
    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrfToken },
        body: JSON.stringify({ subscription: subscription.toJSON() })
      })
      return response.ok
    } catch (error) {
      return false
    }
  }

  // «Enviar una prueba»: el aviso sale del servidor, como una alerta de verdad, y aquí se cuenta qué contestó.
  // Si llega con la app abierta pero no cerrada, lo que falta es del teléfono (ahorro de batería).
  async sendTest() {
    const subscription = await this.currentSubscription()
    if (!subscription) return this.refresh()

    this.paint("probando", "Enviando una prueba desde el servidor…")
    try {
      const response = await fetch(this.testUrlValue, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrfToken },
        body: JSON.stringify({ endpoint: subscription.endpoint })
      })
      const result = await response.json().catch(() => ({}))
      if (response.ok) {
        return this.paint("activo", "Prueba enviada. Si no aparece en unos segundos, revisa el ahorro de batería del teléfono para esta app.")
      }
      this.paint("error", `El servidor no pudo enviarla: ${result.error || response.status}`)
    } catch (error) {
      this.paint("error", "Sin conexión: no se pudo pedir la prueba.")
    }
  }

  async disable(subscription) {
    await fetch(`${this.urlValue}?endpoint=${encodeURIComponent(subscription.endpoint)}`, {
      method: "DELETE",
      headers: { "X-CSRF-Token": this.csrfToken }
    })
    await subscription.unsubscribe()
    this.paint("inactivo", "Este dispositivo dejó de recibir alertas.")
  }

  // Un aviso de prueba, que además deja el permiso "estrenado" en iOS.
  preview() {
    if (Notification.permission !== "granted") return

    this.registration().then((registration) =>
      registration.showNotification("Notificaciones activadas", {
        body: "Así vas a ver las alertas del FSY en este dispositivo.",
        icon: "/icon-192.png",
        badge: "/icon.png",
        vibrate: this.soundEnabled ? [90, 60, 90] : undefined,
        silent: !this.soundEnabled
      })
    )
  }

  // El interruptor de sonido vive en el dispositivo: cada quien decide en el suyo.
  saveSound() {
    try {
      localStorage.setItem("fsy:push-sound", this.hasSoundTarget && this.soundTarget.checked ? "true" : "false")
    } catch (error) {
      // Navegación privada: se queda con el valor por defecto.
    }
    this.preview()
  }

  get soundEnabled() {
    try {
      return localStorage.getItem("fsy:push-sound") !== "false"
    } catch (error) {
      return true
    }
  }

  get csrfToken() {
    return document.querySelector("meta[name=csrf-token]")?.content
  }

  async currentSubscription() {
    const registration = await this.registration()
    return registration.pushManager.getSubscription()
  }

  registration() {
    this.registrationPromise ||= navigator.serviceWorker.register("/service-worker", { scope: "/" })
    return this.registrationPromise
  }

  paint(state, message) {
    this.element.dataset.pushState = state
    if (this.hasStatusTarget) this.statusTarget.textContent = message
    if (!this.hasButtonTarget) return

    const active = state === "activo"
    this.buttonTarget.textContent = active ? "Desactivar en este dispositivo" : "Activar en este dispositivo"
    this.buttonTarget.disabled = ["no-soportado", "bloqueado", "pidiendo", "probando"].includes(state)
    if (this.hasTestTarget) {
      this.testTarget.hidden = !["activo", "probando", "error"].includes(state)
      this.testTarget.disabled = state === "probando"
    }
  }

  // La llave VAPID viaja en base64 url-safe y el navegador la pide como bytes.
  decodeKey(key) {
    const padding = "=".repeat((4 - (key.length % 4)) % 4)
    const base64 = (key + padding).replace(/-/g, "+").replace(/_/g, "/")
    const raw = window.atob(base64)
    return Uint8Array.from([...raw].map((char) => char.charCodeAt(0)))
  }
}
