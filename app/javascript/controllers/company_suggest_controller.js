import { Controller } from "@hotwired/stimulus"

// Las compañías sugeridas en el formulario de un joven sin compañía: con lo que va escrito (fecha de nacimiento,
// género, barrio) el marco pide las sugerencias (CompanySuggestionsController) y «Elegir» llena la compañía.
// Si el rol no es joven o ya tiene compañía, el marco se esconde.
export default class extends Controller {
  static targets = [ "frame", "company" ]
  static values = { url: String }

  connect() {
    this.refresh()
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  refresh() {
    if (!this.hasFrameTarget) return

    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.load(), 300)
  }

  load() {
    const value = (name) => this.element.elements[`participant[${name}]`]?.value || ""
    const shown = (value("rol") || "joven") === "joven" && !value("company_id")
    this.frameTarget.hidden = !shown
    if (!shown) return

    const params = new URLSearchParams({ fecha: value("birth_date"), genero: value("gender"), barrio: value("ward") })
    if (this.frameTarget.dataset.participantId) params.set("participant_id", this.frameTarget.dataset.participantId)
    const src = `${this.urlValue}?${params}`
    if (this.frameTarget.getAttribute("src") !== src) this.frameTarget.setAttribute("src", src)
  }

  choose({ params: { id } }) {
    this.companyTarget.value = id
    this.companyTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
