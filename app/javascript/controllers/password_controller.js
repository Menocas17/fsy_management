import { Controller } from "@hotwired/stimulus"

// Los mismos requisitos que valida User#password_complexity, para verlos mientras se escribe.
const RULES = {
  length: (value) => value.length >= 8,
  uppercase: (value) => /[A-Z]/.test(value),
  digit: (value) => /\d/.test(value),
  special: (value) => /[^A-Za-z0-9\s]/.test(value)
}

export default class extends Controller {
  static targets = ["field", "button", "showIcon", "hideIcon", "rule"]

  toggle() {
    const showing = this.fieldTarget.type === "text"
    this.fieldTarget.type = showing ? "password" : "text"
    this.showIconTarget.classList.toggle("hidden", !showing)
    this.hideIconTarget.classList.toggle("hidden", showing)
    this.buttonTarget.setAttribute("aria-label", showing ? "Mostrar la contraseña" : "Ocultar la contraseña")
  }

  check() {
    const value = this.fieldTarget.value

    this.ruleTargets.forEach((rule) => {
      const met = RULES[rule.dataset.rule](value)
      rule.classList.toggle("text-cat-green", met)
      rule.classList.toggle("text-ink-500", !met)
      rule.querySelector("[data-rule-icon='pending']").classList.toggle("hidden", met)
      rule.querySelector("[data-rule-icon='met']").classList.toggle("hidden", !met)
    })
  }
}
