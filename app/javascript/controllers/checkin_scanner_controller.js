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
  static targets = ["video", "canvas", "start", "status", "card", "last", "corner", "arrived", "pending", "manual",
                    "voidDialog", "voidName", "voidDetail"]
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
    const id = this.resolveId(payload.trim().split("/").pop().split("?")[0])
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
    if (person.arrived) return this.show({ tone: "already", title: person.name, detail: this.summary(person), gender: person.gender, url: person.url }, [ 60, 50, 60 ])

    person.arrived = true
    this.writeStore(this.rosterKey, this.roster)
    this.setArrived(this.arrivedValue + 1)

    const token = `${id}-${now}`
    this.enqueue({
      client_token: token,
      participant_id: id,
      recorded_at: new Date().toISOString(),
      source: force ? "manual" : "qr"
    })

    this.show({
      tone: "ok",
      title: person.name,
      detail: this.summary(person),
      gender: person.gender,
      url: person.url,
      // Solo lo que registró este escaneo se puede anular (no un «ya estaba»: esa llegada es de antes).
      void: { token, participantId: id, name: person.name }
    }, [ 90 ])
  }

  // Anular --------------------------------------------------------------------
  // Llegó alguien con el gafete de otra persona, o se escaneó el que no era. Se anula el último escaneo
  // (desde «Último», debajo de la cámara) o uno de la lista de recientes; el motivo sale de una lista.
  askVoid(event) {
    const data = event.currentTarget.dataset
    this.voiding = { token: data.token, recordId: data.recordId, participantId: data.participantId,
                     name: data.name, row: event.currentTarget.closest("[data-recent-record]") }
    this.voidNameTarget.textContent = data.name
    this.voidDialogTarget.querySelector("form").reset()
    this.voidDialogTarget.showModal()
  }

  closeVoid() {
    this.voidDialogTarget.close()
    this.voiding = null
  }

  closeVoidOutside(event) {
    if (event.target === this.voidDialogTarget) this.closeVoid()
  }

  confirmVoid(event) {
    event.preventDefault()
    const voiding = this.voiding
    if (!voiding) return
    const form = new FormData(event.target)

    this.enqueue({
      kind: "void",
      client_token: `void-${voiding.participantId}-${Date.now()}`,
      target_token: voiding.token,
      record_id: voiding.recordId,
      participant_id: voiding.participantId,
      reason: form.get("void_reason"),
      detail: form.get("void_detail")
    })

    const person = this.roster[voiding.participantId]
    if (person?.arrived) {
      person.arrived = false
      this.writeStore(this.rosterKey, this.roster)
      this.setArrived(Math.max(0, this.arrivedValue - 1))
    }
    voiding.row?.remove()
    // El dueño verdadero del gafete puede pasar enseguida: no se ignora como «el mismo código de recién».
    this.lastCode = null
    this.hideCard()
    this.paintVoided(voiding.name)
    this.say(`Se anuló el registro de ${voiding.name}.`)
    this.closeVoid()
  }

  paintVoided(name) {
    if (!this.hasLastTarget) return

    const time = new Date().toLocaleTimeString("es", { hour: "2-digit", minute: "2-digit" })
    this.lastTarget.innerHTML = `
      <span class="w-2.5 h-2.5 shrink-0 rounded-full bg-cat-rose" aria-hidden="true"></span>
      <span class="min-w-0 flex-1">
        <span class="block text-meta font-bold text-ink-500">Último · ${time} · <span class="text-cat-rose-ink">Anulado</span></span>
        <span class="block text-body font-bold text-ink-900 truncate line-through decoration-ink-300">${this.escape(name)}</span>
        <span class="block text-label font-semibold text-ink-500 truncate">Vuelve a quedar como que no ha llegado</span>
      </span>
    `
    this.lastTarget.hidden = false
  }

  setArrived(count) {
    this.arrivedValue = count
    this.arrivedTarget.textContent = count
  }

  // El QR trae el id; a mano se escribe el código corto del gafete (P-0421, p421 o solo 421).
  resolveId(value) {
    if (this.roster[value]) return value

    const match = value.match(/^p?[\s-]*(\d{1,6})$/i)
    if (!match) return value

    // Igual que Participant.normalize_code: «0421», «421» y «p-421» son P-0421.
    const code = `P-${String(parseInt(match[1], 10)).padStart(4, "0")}`
    const person = Object.values(this.roster).find((candidate) => candidate.code === code)
    return person ? person.id : value
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

      if (typeof body.arrived === "number") this.setArrived(body.arrived)
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
      // Lo que se escaneó (o se anuló) sin señal sigue valiendo hasta que el servidor lo confirme, en orden.
      for (const scan of this.queue) {
        if (roster[scan.participant_id]) roster[scan.participant_id].arrived = scan.kind !== "void"
      }

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
      ok: { label: "Registrado", bar: "border-l-cat-green", text: "text-cat-green-ink", corner: "border-cat-green", dot: "bg-cat-green" },
      already: { label: "Ya estaba registrado", bar: "border-l-cat-amber", text: "text-cat-amber-ink", corner: "border-cat-amber", dot: "bg-cat-amber" },
      unknown: { label: "No reconocido", bar: "border-l-cat-rose", text: "text-cat-rose-ink", corner: "border-cat-rose", dot: "bg-cat-rose" }
    }
    const tone = tones[result.tone]

    // Franja compacta de alto fijo (tres líneas cortadas) en la zona de abajo del visor; el enlace a la ficha
    // va en la nota de «Último» debajo de la cámara, para no navegar por un toque sin querer.
    this.cardTarget.className = `absolute inset-x-3 bottom-3 z-10 h-[76px] flex flex-col justify-center rounded-tile border border-line border-l-4 ${tone.bar} bg-surface/95 px-3.5 shadow-lg transition-opacity duration-200`
    this.cardTarget.innerHTML = `
      <p class="text-meta font-bold uppercase tracking-[.07em] leading-tight ${tone.text}">${tone.label}</p>
      <p class="flex items-center gap-2 min-w-0"><span class="text-title font-extrabold leading-snug text-ink-900 truncate">${this.escape(result.title)}</span>${this.genderChip(result.gender)}</p>
      ${result.detail ? `<p class="text-label font-semibold leading-tight text-ink-700 truncate">${this.escape(result.detail)}</p>` : ""}
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
    return [ person.company, person.stake ].filter(Boolean).join(" · ")
  }

  // El género va aparte y con color: es lo primero que delata a alguien con el gafete de otra persona.
  genderChip(gender) {
    if (!gender) return ""
    const woman = gender === "Mujer"
    const color = woman ? "bg-cat-rose/15 text-cat-rose-ink" : "bg-primary-100 text-primary-700 dark:bg-primary-700/30 dark:text-primary-100"
    return `<span class="shrink-0 inline-flex items-center h-6 px-2.5 rounded-full text-label font-bold ${color}" data-gender-chip>${woman ? "♀ Mujer" : "♂ Hombre"}</span>`
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
        <span class="block text-meta font-bold text-ink-500">Último · ${time} · <span class="${tone.text}">${tone.label}</span></span>
        <span class="flex items-center gap-2 min-w-0"><span class="text-body font-bold text-ink-900 truncate">${this.escape(result.title)}</span>${this.genderChip(result.gender)}</span>
        ${result.detail ? `<span class="block text-label font-semibold text-ink-500 truncate">${this.escape(result.detail)}</span>` : ""}
      </span>
      ${result.url ? `<a href="${this.escape(result.url)}" class="shrink-0 inline-flex items-center min-h-11 md:min-h-0 text-label font-bold text-primary-700 dark:text-primary-300 underline underline-offset-2">Ver perfil</a>` : ""}
      ${result.void ? `<button type="button" data-action="checkin-scanner#askVoid" data-token="${this.escape(result.void.token)}"
          data-participant-id="${this.escape(result.void.participantId)}" data-name="${this.escape(result.void.name)}" data-void-last
          class="shrink-0 inline-flex items-center min-h-11 md:min-h-0 text-label font-bold text-cat-rose-ink underline underline-offset-2 cursor-pointer">Anular</button>` : ""}
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

  // También las comillas: los nombres van dentro de atributos (data-name del botón «Anular»).
  escape(text) {
    const node = document.createElement("span")
    node.textContent = text
    return node.innerHTML.replace(/"/g, "&quot;")
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
