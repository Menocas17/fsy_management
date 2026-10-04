import { Controller } from "@hotwired/stimulus"

// La lista de la asistencia nocturna: el motivo aparece al marcar «Ausente», y el campo para escribirlo al
// elegir «Otro». «Todos presentes» marca a quien siga sin marcar (no cambia a quien ya se marcó ausente).
export default class extends Controller {
  static targets = ["row"]

  connect() {
    this.rowTargets.forEach((row) => this.syncRow(row))
  }

  sync(event) {
    this.syncRow(event.target.closest("[data-night-attendance-target~=row]"))
  }

  markAllPresent() {
    this.rowTargets.forEach((row) => {
      if (row.querySelector("[data-night-status]:checked")) return

      row.querySelector("[data-night-status=presente]").checked = true
      this.syncRow(row)
    })
  }

  syncRow(row) {
    const absent = row.querySelector("[data-night-status=ausente]").checked
    const other = row.querySelector("[data-night-reason=otro]").checked
    const detail = row.querySelector("[data-night-detail]")

    row.querySelector("[data-night-reason-box]").hidden = !absent
    detail.hidden = !(absent && other)
    if (absent && other && document.activeElement?.dataset?.nightReason === "otro") detail.focus()
  }
}
