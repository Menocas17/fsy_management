import { Controller } from "@hotwired/stimulus"
import jsQR from "jsqr"

// Registro de llegadas del día del evento: la cámara no se cierra entre persona y persona.
// Trabaja sin señal a propósito — el padrón queda en el dispositivo y los escaneos se encolan
// hasta que vuelva el internet, porque el día que llegan 445 jóvenes el wifi es lo primero que falla.
// El padrón y la cola se guardan por modo: la llegada al FSY y cada capacitación no se mezclan.
const SAME_CODE_MS = 4000

export default class extends Controller {
  static targets = ["video", "canvas", "start", "status", "card", "arrived", "pending", "manual"]
  static values = { rosterUrl: String, syncUrl: String, mode: String, total: Number, arrived: Number }

  connect() {
    this.rosterKey = `fsy:checkin-roster:${this.modeValue}`
    this.queueKey = `fsy:checkin-queue:${this.modeValue}`
    this.roster = this.readStore(this.rosterKey) || {}
    this.queue = this.readStore(this.queueKey) || []
    this.paintPending()
    this.refreshRoster()
    this.flush()

    this.onOnline = () => { this.refreshRoster(); this.flush() }
    window.addEventListener("online", this.onOnline)
    this.timer = setInterval(() => this.flush(), 20000)
  }

  disconnect() {
    this.stop()
    window.removeEventListener("online", this.onOnline)
    clearInterval(this.timer)
  }

  // Cámara ----------------------------------------------------------------
  async start() {
    this.startTarget.hidden = true
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" }, audio: false })
    } catch (error) {
      this.startTarget.hidden = false
      return this.say("No se pudo abrir la cámara. Podés registrar con el código a mano.", true)
    }

    this.videoTarget.srcObject = this.stream
    this.videoTarget.setAttribute("playsinline", true)
    await this.videoTarget.play()
    this.say("Apuntá al código del gafete")
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
      if (found?.data) this.handle(found.data)
    }

    this.frame = requestAnimationFrame(() => this.tick())
  }

  // Registro --------------------------------------------------------------
  typed(event) {
    event.preventDefault()
    const code = this.manualTarget.value.trim()
    if (code) this.handle(code, { force: true })
    this.manualTarget.value = ""
  }

  handle(payload, { force = false } = {}) {
    const id = payload.trim().split("/").pop().split("?")[0]
    const now = Date.now()

    // La cámara lee el mismo código treinta veces por segundo: solo cuenta la primera.
    if (!force && id === this.lastCode && now - this.lastAt < SAME_CODE_MS) return
    this.lastCode = id
    this.lastAt = now

    const person = this.roster[id]
    if (!person) return this.show({ tone: "unknown", title: "Código no reconocido", detail: "No aparece en el padrón de este registro." }, [ 200 ])
    if (person.arrived) return this.show({ tone: "already", title: person.name, detail: `Ya estaba registrado · ${person.company || "sin compañía"}` }, [ 60, 50, 60 ])

    person.arrived = true
    this.writeStore(this.rosterKey, this.roster)
    this.arrivedValue += 1
    this.arrivedTarget.textContent = this.arrivedValue

    this.enqueue({
      client_token: `${id}-${now}`,
      participant_id: id,
      recorded_at: new Date().toISOString(),
      source: force ? "manual" : "qr"
    })

    this.show({
      tone: "ok",
      title: person.name,
      detail: [ person.company, person.room && `Cuarto ${person.room}` ].filter(Boolean).join(" · "),
      care: person.care
    }, [ 90 ])
  }

  // Cola ------------------------------------------------------------------
  enqueue(scan) {
    this.queue.push(scan)
    this.writeStore(this.queueKey, this.queue)
    this.paintPending()
    this.flush()
  }

  async flush() {
    if (this.sending || this.queue.length === 0 || !navigator.onLine) return

    this.sending = true
    const sending = this.queue.slice(0, 50)

    try {
      const response = await fetch(this.syncUrlValue, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": this.csrfToken },
        body: JSON.stringify({ checkins: sending })
      })
      if (!response.ok) throw new Error(response.status)

      const body = await response.json()
      const sent = new Set(sending.map((scan) => scan.client_token))
      this.queue = this.queue.filter((scan) => !sent.has(scan.client_token))
      this.writeStore(this.queueKey, this.queue)

      if (typeof body.arrived === "number") {
        this.arrivedValue = body.arrived
        this.arrivedTarget.textContent = body.arrived
      }
    } catch (error) {
      // Sin señal o servidor caído: la cola se queda y se reintenta sola.
    } finally {
      this.sending = false
      this.paintPending()
    }
  }

  paintPending() {
    const count = this.queue.length
    this.pendingTarget.hidden = count === 0
    this.pendingTarget.textContent = count === 1 ? "1 sin sincronizar" : `${count} sin sincronizar`
  }

  async refreshRoster() {
    if (!navigator.onLine) return

    try {
      const response = await fetch(this.rosterUrlValue, { headers: { Accept: "application/json" } })
      if (!response.ok) return

      const body = await response.json()
      const roster = {}
      for (const person of body.people) roster[person.id] = person
      // Lo que se escaneó sin señal sigue contando como llegado hasta que el servidor lo confirme.
      for (const scan of this.queue) if (roster[scan.participant_id]) roster[scan.participant_id].arrived = true

      this.roster = roster
      this.writeStore(this.rosterKey, roster)
      this.say(this.scanning ? "Apuntá al código del gafete" : "Padrón actualizado")
    } catch (error) {
      this.say("Sin conexión: se trabaja con el padrón guardado y se sincroniza después.")
    }
  }

  // Pantalla --------------------------------------------------------------
  show(result, vibration) {
    const tones = {
      ok: "border-cat-green/40 bg-cat-green/10 text-cat-green",
      already: "border-cat-amber/40 bg-cat-amber/10 text-amber-700",
      unknown: "border-cat-rose/40 bg-cat-rose/10 text-cat-rose"
    }

    this.cardTarget.className = `rounded-[16px] border px-4 py-3.5 ${tones[result.tone]}`
    this.cardTarget.innerHTML = `
      <p class="text-[15px] font-extrabold">${this.escape(result.title)}</p>
      ${result.detail ? `<p class="mt-0.5 text-[12.5px] font-semibold opacity-90">${this.escape(result.detail)}</p>` : ""}
      ${result.care ? `<p class="mt-1.5 text-[12px] font-bold">⚠ ${this.escape(result.care)}</p>` : ""}
    `
    this.cardTarget.hidden = false
    navigator.vibrate?.(vibration)
  }

  say(message, isError = false) {
    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle("text-cat-rose", isError)
  }

  escape(text) {
    const node = document.createElement("span")
    node.textContent = text
    return node.innerHTML
  }

  get csrfToken() {
    return document.querySelector("meta[name=csrf-token]")?.content
  }

  readStore(key) {
    try {
      return JSON.parse(localStorage.getItem(key))
    } catch (error) {
      return null
    }
  }

  writeStore(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value))
    } catch (error) {
      // Sin espacio o en navegación privada: se sigue trabajando en memoria.
    }
  }
}
