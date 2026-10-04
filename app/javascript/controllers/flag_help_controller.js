import { Controller } from "@hotwired/stimulus"

// Qué da cada bandera de logística. En escritorio lo explica una nota al pasar el ratón (CSS, en
// logistics_areas/_flag_help_chip); en pantallas táctiles no hay ratón, así que tocar la pastilla abre su diálogo.
export default class extends Controller {
  static targets = [ "dialog" ]

  open({ params: { flag } }) {
    if (window.matchMedia("(hover: hover)").matches) return

    this.dialogTargets.find((dialog) => dialog.dataset.flag === flag)?.showModal()
  }

  close(event) {
    event.currentTarget.closest("dialog")?.close()
  }

  clickOutside(event) {
    if (event.target === event.currentTarget) event.currentTarget.close()
  }
}
