import { Controller } from "@hotwired/stimulus"

// Campos que solo tienen sentido para ciertos roles (data-roles="logistica director_logistica"): se muestran
// al elegir uno de esos roles y, escondidos, van deshabilitados para que no viajen en el formulario.
export default class extends Controller {
  static targets = [ "role", "field" ]

  toggle() {
    const role = this.roleTarget.value

    this.fieldTargets.forEach((field) => {
      const shown = field.dataset.roles.split(" ").includes(role)
      field.hidden = !shown
      field.querySelectorAll("input, select, textarea").forEach((input) => { input.disabled = !shown })
    })
  }
}
