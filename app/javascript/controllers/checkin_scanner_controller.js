import { Controller } from "@hotwired/stimulus"
import jsQR from "jsqr"

const SCAN_INTERVAL_MS = 120
const SCAN_MAX_SIDE = 640

// Registro de llegadas del día del evento: la cámara no se cierra entre persona y persona.
// Trabaja sin señal a propósito — el padrón queda en el dispositivo y los escaneos se encolan
// hasta que vuelva el internet, porque el día que llegan 445 jóvenes el wifi es lo primero que falla.
// El padrón y la cola se guardan por modo: la llegada al FSY y cada capacitación no se mezclan.
// Un gafete que se queda frente a la cámara no vuelve a contar; vuelve a leerse cuando lleva este
// tiempo fuera de cuadro (antes, a los 4 s el mismo gafete pasaba de «registrado» a «ya estaba»).
const SAME_CODE_MS = 1500
// Cuánto queda la tarjeta del resultado sobre la cámara.
const CARD_MS = 5000

// Safari de iOS no vibra: el tono es la confirmación que no obliga a mirar la pantalla.
const TONES = {
  ok: [ [ 1320, 0, 0.07, "sine" ] ],
  already: [ [ 660, 0, 0.06, "sine" ], [ 660, 0.11, 0.06, "sine" ] ],
  unknown: [ [ 220, 0, 0.22, "square" ] ]
}

export default class extends Controller {
  static targets = ["video", "canvas", "start", "status", "card", "last", "corner", "arrived", "pending", "manual"]
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

    // La cámara no sobrevive a salir de la página: Turbo guardaba la pantalla con el botón oculto y el
    // video sin señal, y al volver con el gesto quedaba en negro. Se apaga al salir o al esconder la app,
    // se deja la pantalla como nueva, y se vuelve a encender sola si ya había permiso.
    this.onBeforeCache = () => { this.stop(); this.resetCamera() }
    this.onVisibility = () => document.hidden ? this.stop() : this.resume()
    this.onPageShow = (event) => { if (event.persisted) this.resume() }
    this.onFirstTouch = () => this.unlockAudio()
    document.addEventListener("turbo:before-cache", this.onBeforeCache)
    document.addEventListener("visibilitychange", this.onVisibility)
    window.addEventListener("pageshow", this.onPageShow)
    this.element.addEventListener("pointerdown", this.onFirstTouch, { once: true })

    this.resume()
  }

  disconnect() {
    this.stop()
    clearTimeout(this.hideTimer)
    document.removeEventListener("turbo:before-cache", this.onBeforeCache)
    document.removeEventListener("visibilitychange", this.onVisibility)
    window.removeEventListener("pageshow", this.onPageShow)
    this.element.removeEventListener("pointerdown", this.onFirstTouch)
    window.removeEventListener("online", this.onOnline)
    clearInterval(this.timer)
  }

  // Cámara ----------------------------------------------------------------
  async start() {
    if (this.starting || this.scanning) return
    this.starting = true
    this.startTarget.hidden = true
    this.unlockAudio()
    this.say("Abriendo la cámara…")
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" }, audio: false })
      this.videoTarget.srcObject = this.stream
      this.videoTarget.setAttribute("playsinline", true)
      await this.videoTarget.play()
    } catch (error) {
      this.stop()
      this.startTarget.hidden = false
      return this.say("No se pudo abrir la cámara. Puedes registrar con el código a mano.", true)
    } finally {
      this.starting = false
    }

    this.say("Apunta al código del gafete")
    this.scanning = true
    this.tick()
  }

  stop() {
    this.scanning = false
    if (this.frame) cancelAnimationFrame(this.frame)
    this.stream?.getTracks().forEach((track) => track.stop())
    this.stream = null
  }

  // Pantalla como recién abierta: botón visible, sin video ni tarjeta encima.
  resetCamera() {
    this.videoTarget.srcObject = null
    this.startTarget.hidden = false
    clearTimeout(this.hideTimer)
    this.cardTarget.hidden = true
    this.say("Activa la cámara para empezar")
  }

  // Si el navegador ya dio permiso a la cámara, se enciende sola; si no, queda el botón para pedirlo.
  async resume() {
    if (this.scanning || this.starting) return
    this.resetCamera()

    try {
      const permission = await navigator.permissions?.query({ name: "camera" })
      if (permission?.state === "granted") await this.start()
    } catch (error) {
      // Navegadores sin Permissions API para la cámara: se queda el botón.
    }
  }

  tick() {
    if (!this.scanning) return

    const video = this.videoTarget
    const now = performance.now()
    // Unas ocho lecturas por segundo a 640px sobran para un QR, y no calientan el teléfono en horas de
    // registro como leer cada cuadro a resolución completa.
    if (video.readyState === video.HAVE_ENOUGH_DATA && now - (this.lastRead || 0) >= SCAN_INTERVAL_MS) {
      this.lastRead = now
      const canvas = this.canvasTarget
      const ratio = Math.min(1, SCAN_MAX_SIDE / Math.max(video.videoWidth, video.videoHeight))
      canvas.width = Math.round(video.videoWidth * ratio)
      canvas.height = Math.round(video.videoHeight * ratio)
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
    this.unlockAudio()
    if (code) this.handle(code, { force: true })
    this.manualTarget.value = ""
  }

  handle(payload, { force = false } = {}) {
    const id = payload.trim().split("/").pop().split("?")[0]
    const now = Date.now()

    // La cámara lee el mismo código treinta veces por segundo: solo cuenta la primera, y cada
    // lectura repetida alarga la espera mientras el gafete siga en cuadro.
    if (!force && id === this.lastCode && now - this.lastAt < SAME_CODE_MS) {
      this.lastAt = now
      return
    }
    this.lastCode = id
    this.lastAt = now

    const person = this.roster[id]
    if (!person) return this.show({ tone: "unknown", title: "Código no reconocido", detail: "No aparece en el padrón de este registro." }, [ 200 ])
    if (person.arrived) return this.show({ tone: "already", title: person.name, detail: this.summary(person), url: person.url }, [ 60, 50, 60 ])

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
      detail: this.summary(person),
      url: person.url
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
      this.say(this.scanning ? "Apunta al código del gafete" : "Padrón actualizado")
    } catch (error) {
      this.say("Sin conexión: se trabaja con el padrón guardado y se sincroniza después.")
    }
  }

  // Pantalla --------------------------------------------------------------
  show(result, vibration) {
    const tones = {
      ok: { label: "Registrado", bar: "border-l-cat-green dark:border-l-cat-green", text: "text-cat-green-ink", corner: "border-cat-green", dot: "bg-cat-green" },
      already: { label: "Ya estaba registrado", bar: "border-l-cat-amber dark:border-l-cat-amber", text: "text-cat-amber-ink", corner: "border-cat-amber", dot: "bg-cat-amber" },
      unknown: { label: "No reconocido", bar: "border-l-cat-rose dark:border-l-cat-rose", text: "text-cat-rose-ink", corner: "border-cat-rose", dot: "bg-cat-rose" }
    }
    const tone = tones[result.tone]

    // Franja compacta de alto fijo (tres líneas cortadas) en la zona de abajo del visor; el enlace a la ficha
    // va en la nota de «Último» debajo de la cámara, para no navegar por un toque sin querer.
    this.cardTarget.className = `absolute inset-x-3 bottom-3 z-10 h-[76px] flex flex-col justify-center rounded-tile border border-line border-l-4 ${tone.bar} bg-surface/95 px-3.5 shadow-lg dark:border-slate-700 transition-opacity duration-200`
    this.cardTarget.innerHTML = `
      <p class="text-[11px] font-bold uppercase tracking-[.06em] leading-tight ${tone.text}">${tone.label}</p>
      <p class="text-[15px] font-extrabold leading-snug text-ink-900 truncate">${this.escape(result.title)}</p>
      ${result.detail ? `<p class="text-[12px] font-semibold leading-tight text-ink-700 dark:text-slate-300 truncate">${this.escape(result.detail)}</p>` : ""}
    `
    this.cardTarget.hidden = false
    this.cardTarget.classList.remove("opacity-0")
    this.scheduleHide()
    this.paintLast(result, tone)
    this.pulse(tone.corner)
    navigator.vibrate?.(vibration)
    this.chime(result.tone)
  }

  summary(person) {
    return [ person.company, person.stake, person.gender ].filter(Boolean).join(" · ")
  }

  // La tarjeta sobre la cámara se va sola a los 5 segundos para no tapar al siguiente; tocarla la quita ya.
  scheduleHide() {
    clearTimeout(this.hideTimer)
    this.hideTimer = setTimeout(() => this.hideCard(), CARD_MS)
  }

  dismissCard(event) {
    if (event.target.closest("a")) return
    this.hideCard()
  }

  hideCard() {
    clearTimeout(this.hideTimer)
    this.cardTarget.classList.add("opacity-0")
    setTimeout(() => {
      if (this.cardTarget.classList.contains("opacity-0")) this.cardTarget.hidden = true
    }, 200)
  }

  // Debajo de la cámara queda anotado el último escaneo, por si hace falta saber quién pasó.
  paintLast(result, tone) {
    if (!this.hasLastTarget) return

    const time = new Date().toLocaleTimeString("es", { hour: "2-digit", minute: "2-digit" })
    this.lastTarget.innerHTML = `
      <span class="w-2.5 h-2.5 shrink-0 rounded-full ${tone.dot}" aria-hidden="true"></span>
      <span class="min-w-0 flex-1">
        <span class="block text-[11px] font-bold text-ink-500">Último · ${time} · <span class="${tone.text}">${tone.label}</span></span>
        <span class="block text-[13.5px] font-bold text-ink-900 truncate">${this.escape(result.title)}</span>
        ${result.detail ? `<span class="block text-[11.5px] font-semibold text-ink-500 truncate">${this.escape(result.detail)}</span>` : ""}
      </span>
      ${result.url ? `<a href="${this.escape(result.url)}" class="shrink-0 inline-flex items-center min-h-11 md:min-h-0 text-[12.5px] font-bold text-primary-700 dark:text-primary-300 underline underline-offset-2">Ver perfil</a>` : ""}
    `
    this.lastTarget.hidden = false
  }

  // Dos escaneos «ok» seguidos se ven iguales: el pulso y las esquinas de color marcan que hubo uno nuevo.
  pulse(cornerClass) {
    clearTimeout(this.cornerTimer)
    this.cornerTargets.forEach((corner) => {
      corner.classList.remove("border-white/90", "border-cat-green", "border-cat-amber", "border-cat-rose")
      corner.classList.add(cornerClass)
    })
    this.cornerTimer = setTimeout(() => {
      this.cornerTargets.forEach((corner) => {
        corner.classList.remove(cornerClass)
        corner.classList.add("border-white/90")
      })
    }, 700)

    if (this.reducedMotion) return
    this.cardTarget.animate(
      [ { transform: "scale(.98)", opacity: 0.7 }, { transform: "none", opacity: 1 } ],
      { duration: 180, easing: "cubic-bezier(0.23, 1, 0.32, 1)" }
    )
  }

  // El audio solo se puede abrir dentro de un gesto: se hace al tocar «Activar la cámara» o «Registrar».
  unlockAudio() {
    const Context = window.AudioContext || window.webkitAudioContext
    if (!Context) return

    try {
      window.fsyAudioContext ||= new Context()
      if (window.fsyAudioContext.state === "suspended") window.fsyAudioContext.resume().catch(() => {})
    } catch (error) {
      // Sin audio: quedan la vibración y la pantalla.
    }
  }

  chime(tone) {
    const audio = window.fsyAudioContext
    if (!audio || audio.state !== "running") return

    for (const [ frequency, offset, length, type ] of TONES[tone]) {
      const oscillator = audio.createOscillator()
      const gain = audio.createGain()
      const start = audio.currentTime + offset

      oscillator.type = type
      oscillator.frequency.value = frequency
      gain.gain.setValueAtTime(0.0001, start)
      gain.gain.linearRampToValueAtTime(type === "square" ? 0.08 : 0.16, start + 0.01)
      gain.gain.exponentialRampToValueAtTime(0.0001, start + length)

      oscillator.connect(gain).connect(audio.destination)
      oscillator.start(start)
      oscillator.stop(start + length + 0.02)
    }
  }

  get reducedMotion() {
    return document.documentElement.classList.contains("reduce-motion") ||
      window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  say(message, isError = false) {
    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle("text-cat-rose-ink", isError)
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
