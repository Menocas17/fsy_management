import { Controller } from "@hotwired/stimulus"

// Un solo cuadro de ajuste para toda la pantalla: los botones + y − de la tabla, el de la ficha
// y el escáner lo abren con los datos del artículo que tocaron.
export default class extends Controller {
  static targets = ["modal", "form", "title", "subtitle", "sign", "quantity", "preview", "plus", "minus", "source"]
  static values = { autoOpen: Boolean }

  connect() {
    if (this.autoOpenValue) {
      const button = this.element.querySelector("[data-adjust-item]")
      if (button) this.open({ currentTarget: button })
    }
  }

  open(event) {
    const button = event.currentTarget
    this.stock = Number(button.dataset.adjustStock || 0)
    this.unit = button.dataset.adjustUnit || "u"
    this.formTarget.action = button.dataset.adjustUrl
    this.titleTarget.textContent = button.dataset.adjustItem
    this.subtitleTarget.textContent = `${button.dataset.adjustInventory} · ${button.dataset.adjustCode} · existencia ${this.stock} ${this.unit}`
    this.sourceTarget.value = button.dataset.adjustSource || "manual"
    this.quantityTarget.value = 1
    this.setSign(button.dataset.adjustSign === "-1" ? -1 : 1)
    this.modalTarget.showModal()
    this.quantityTarget.focus()
    this.quantityTarget.select()
  }

  close() {
    this.modalTarget.close()
  }

  clickOutside(event) {
    if (event.target === this.modalTarget) this.close()
  }

  add() {
    this.setSign(1)
  }

  subtract() {
    this.setSign(-1)
  }

  step(event) {
    const next = Number(this.quantityTarget.value || 0) + Number(event.currentTarget.dataset.step)
    this.quantityTarget.value = Math.max(1, next)
    this.preview()
  }

  preview() {
    const quantity = Math.max(0, Number(this.quantityTarget.value || 0))
    const total = this.stock + this.sign * quantity
    const invalid = total < 0
    this.previewTarget.textContent = invalid
      ? `Solo hay ${this.stock} ${this.unit}`
      : `${total} ${this.unit}`
    this.previewTarget.classList.toggle("text-cat-rose", invalid)
    this.formTarget.querySelector("[type=submit]").disabled = invalid || quantity === 0
  }

  setSign(sign) {
    this.sign = sign
    this.signTarget.value = sign
    const adding = sign === 1
    this.plusTarget.setAttribute("aria-pressed", String(adding))
    this.minusTarget.setAttribute("aria-pressed", String(!adding))
    this.plusTarget.classList.toggle("bg-cat-green", adding)
    this.plusTarget.classList.toggle("text-white", adding)
    this.minusTarget.classList.toggle("bg-cat-rose", !adding)
    this.minusTarget.classList.toggle("text-white", !adding)
    this.preview()
  }
}
