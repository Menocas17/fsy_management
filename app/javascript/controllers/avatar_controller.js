import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image"]

  loaded() {
    this.imageTarget.classList.remove("opacity-0")
  }
}
