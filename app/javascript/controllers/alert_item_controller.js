import { Controller } from "@hotwired/stimulus"

// Una alerta en la campanita o en Notificaciones. Con el dedo se desliza a la izquierda y deja ver
// «Eliminar» detrás (como en el correo del teléfono); deslizada hasta el fondo se borra sola. Al borrarse,
// por el botón o por la X de escritorio, se va hacia la izquierda y la lista se cierra sobre el hueco.
const REVEAL = 96 // ancho del botón «Eliminar»
const SLOP = 8 // px antes de decidir si el gesto es horizontal o de scroll

export default class extends Controller {
  static targets = ["panel", "actions"]

  connect() {
    this.offset = 0
    this.onDown = this.down.bind(this)
    this.onMove = this.move.bind(this)
    this.onUp = this.up.bind(this)
    this.onClick = this.swallowClick.bind(this)
    this.onOtherOpened = (event) => { if (event.detail !== this) this.close() }

    this.panelTarget.addEventListener("pointerdown", this.onDown)
    this.panelTarget.addEventListener("click", this.onClick, true)
    window.addEventListener("alert-item:opened", this.onOtherOpened)
  }

  disconnect() {
    this.panelTarget.removeEventListener("pointerdown", this.onDown)
    this.panelTarget.removeEventListener("click", this.onClick, true)
    window.removeEventListener("alert-item:opened", this.onOtherOpened)
    this.stopTracking()
  }

  down(event) {
    // Solo el dedo: con ratón se usa la X, y arrastrar seleccionaría texto.
    if (event.pointerType !== "touch" || this.leaving) return

    this.start = { x: event.clientX, y: event.clientY, offset: this.offset }
    this.axis = null
    this.moved = false
    this.panelTarget.addEventListener("pointermove", this.onMove)
    this.panelTarget.addEventListener("pointerup", this.onUp)
    this.panelTarget.addEventListener("pointercancel", this.onUp)
  }

  move(event) {
    const dx = event.clientX - this.start.x
    const dy = event.clientY - this.start.y

    if (!this.axis) {
      if (Math.abs(dx) < SLOP && Math.abs(dy) < SLOP) return
      // touch-pan-y deja el scroll vertical al navegador: si el gesto es vertical, no es nuestro.
      this.axis = Math.abs(dx) > Math.abs(dy) ? "x" : "y"
      if (this.axis === "y") return this.stopTracking()

      this.panelTarget.setPointerCapture(event.pointerId)
      this.actionsTarget.hidden = false
      this.panelTarget.style.transition = "none"
    }

    this.moved = true
    const width = this.element.offsetWidth
    let next = Math.min(0, this.start.offset + dx)
    // Pasado el botón cuesta más (resistencia), así el borrado por deslizamiento completo es intencional.
    if (next < -REVEAL) next = -REVEAL + (next + REVEAL) * 0.6
    this.translate(Math.max(next, -width))
  }

  up() {
    this.stopTracking()
    if (this.axis !== "x") return

    this.panelTarget.style.transition = ""
    const width = this.element.offsetWidth
    if (this.offset < -width * 0.55) return this.submit()
    this.offset < -REVEAL / 2 ? this.open() : this.close()
  }

  stopTracking() {
    this.panelTarget.removeEventListener("pointermove", this.onMove)
    this.panelTarget.removeEventListener("pointerup", this.onUp)
    this.panelTarget.removeEventListener("pointercancel", this.onUp)
  }

  // Tras deslizar, el dedo se levanta sobre el enlace estirado: ese clic no debe abrir la alerta. Y si
  // está abierta, tocarla la cierra en vez de navegar.
  swallowClick(event) {
    if (this.moved || this.offset !== 0) {
      event.preventDefault()
      event.stopPropagation()
      this.moved = false
      if (this.offset !== 0) this.close()
    }
  }

  open() {
    this.animateTo(-REVEAL)
    window.dispatchEvent(new CustomEvent("alert-item:opened", { detail: this }))
  }

  close() {
    if (this.offset === 0) return
    this.animateTo(0)
    this.panelTarget.addEventListener("transitionend", () => {
      if (this.offset === 0) this.actionsTarget.hidden = true
    }, { once: true })
  }

  submit() {
    this.actionsTarget.querySelector("form")?.requestSubmit()
  }

  // Al mandar el borrado (cualquiera de los dos botones) la tarjeta se va; la respuesta la quita del DOM.
  leave() {
    this.leaving = true
    if (this.reducedMotion) return (this.element.style.opacity = "0.4")

    this.actionsTarget.hidden = true
    this.panelTarget.style.transition = "transform 200ms cubic-bezier(0.32, 0.72, 0, 1)"
    this.translate(-this.element.offsetWidth)
    this.element.style.height = `${this.element.offsetHeight}px`
    this.element.animate([ { height: `${this.element.offsetHeight}px` }, { height: "0px" } ],
                         { duration: 220, delay: 120, easing: "ease-out", fill: "forwards" })
  }

  // Si el servidor no pudo, la alerta vuelve a su lugar.
  settle(event) {
    if (event.detail.success) return

    this.leaving = false
    this.element.getAnimations().forEach((animation) => animation.cancel())
    this.element.style.height = ""
    this.element.style.opacity = ""
    this.animateTo(0)
  }

  animateTo(offset) {
    this.panelTarget.style.transition = this.reducedMotion ? "none" : "transform 220ms cubic-bezier(0.32, 0.72, 0, 1)"
    this.translate(offset)
  }

  translate(offset) {
    this.offset = offset
    this.panelTarget.style.transform = offset ? `translateX(${offset}px)` : ""
  }

  get reducedMotion() {
    return document.documentElement.classList.contains("reduce-motion") ||
      window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
