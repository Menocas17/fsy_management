import { Controller } from "@hotwired/stimulus"

const REASONS = { enfermeria: "Enfermería" }

// Pasar lista: un toque en la fila marca presente (otro lo quita); «Falta» abre la hoja del motivo. Lo marcado
// va en los campos ocultos de cada fila; aquí se lleva la cuenta y se habilita «Confirmar» al completar.
export default class extends Controller {
  static targets = ["row", "count", "fill", "hint", "confirm", "sheet", "sheetName", "detail", "save"]

  toggle(event) {
    const row = event.currentTarget.closest("[data-night-attendance-target~=row]")
    this.set(row, row.dataset.state === "presente" ? {} : { status: "presente" })
  }

  openSheet(event) {
    this.current = event.currentTarget.closest("[data-night-attendance-target~=row]")
    this.reason = this.field(this.current, "reason").value || null
    this.detailTarget.value = this.field(this.current, "detail").value
    this.sheetNameTarget.textContent = this.current.dataset.name
    this.syncSheet()
    this.sheetTarget.showModal()
  }

  chooseReason(event) {
    this.reason = event.currentTarget.dataset.reason
    this.syncSheet()
    if (this.reason === "otro") this.detailTarget.focus()
  }

  syncSheet() {
    this.sheetTarget.querySelectorAll("[data-reason]").forEach((button) => {
      button.setAttribute("aria-pressed", button.dataset.reason === this.reason)
    })
    this.detailTarget.hidden = this.reason !== "otro"
    this.saveTarget.disabled = !(this.reason === "enfermeria" || (this.reason === "otro" && this.detailTarget.value.trim()))
  }

  markAbsent() {
    const detail = this.reason === "otro" ? this.detailTarget.value.trim() : ""
    this.set(this.current, { status: "ausente", reason: this.reason, detail })
    this.closeSheet()
  }

  closeSheet() {
    this.sheetTarget.close()
  }

  clickOutside(event) {
    if (event.target === this.sheetTarget) this.closeSheet()
  }

  set(row, { status = "", reason = "", detail = "" }) {
    this.field(row, "status").value = status
    this.field(row, "reason").value = reason || ""
    this.field(row, "detail").value = detail
    if (status) row.dataset.state = status
    else delete row.dataset.state

    const label = row.querySelector("[data-night-label]")
    label.textContent = status === "presente" ? "Presente"
      : status === "ausente" ? `Ausente · ${REASONS[reason] || detail}` : "Toca para marcar presente"
    this.refresh()
  }

  refresh() {
    const total = this.rowTargets.length
    const marked = this.rowTargets.filter((row) => row.dataset.state).length
    this.countTarget.textContent = `${marked} de ${total}`
    this.fillTarget.style.width = `${total ? (marked * 100) / total : 0}%`
    this.confirmTarget.disabled = marked < total
    this.hintTarget.textContent = marked < total ? `Faltan ${total - marked} por marcar` : "Lista completa"
  }

  field(row, name) {
    return row.querySelector(`[data-field=${name}]`)
  }
}
