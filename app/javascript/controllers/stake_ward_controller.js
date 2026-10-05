import { Controller } from "@hotwired/stimulus"

// Estaca y barrio en la ficha: cada estaca ofrece solo sus barrios. «Otra» (una estaca que no participa,
// escrita a mano) es solo para el staff: con ella se esconde el barrio de la lista y aparecen los dos campos
// de texto. Lo escondido va deshabilitado para que no viaje en el formulario.
export default class extends Controller {
  static targets = [ "role", "stake", "ward", "wardField", "other", "otherOption" ]
  static values = { wards: Object, other: String }

  connect() {
    this.refresh()
  }

  refresh() {
    const role = this.hasRoleTarget ? this.roleTarget.value : ""
    const staff = role !== "" && role !== "joven"

    if (this.hasOtherOptionTarget) {
      this.otherOptionTarget.hidden = !staff
      this.otherOptionTarget.disabled = !staff
      if (!staff && this.stakeTarget.value === this.otherValue) this.stakeTarget.value = ""
    }

    const other = this.stakeTarget.value === this.otherValue
    this.show(this.wardFieldTarget, !other)
    this.otherTargets.forEach((field) => this.show(field, other))
    if (!other) this.fillWards()
  }

  fillWards() {
    const wards = this.wardsValue[this.stakeTarget.value] || []
    const current = this.wardTarget.value
    const prompt = this.wardTarget.options[0]
    this.wardTarget.replaceChildren(prompt, ...wards.map(([ label, key ]) => new Option(label, key, false, key === current)))
    this.wardTarget.disabled = wards.length === 0
  }

  show(field, shown) {
    field.hidden = !shown
    field.querySelectorAll("input, select").forEach((input) => { input.disabled = !shown })
  }
}
