import { Controller } from "@hotwired/stimulus"

// Recipe form: shows the unit weight field only when "Vendue à l'unité"
// is checked, and clears it when unchecked.
export default class extends Controller {
  static targets = ["checkbox", "wrapper"]

  connect() {
    this.toggle()
  }

  toggle() {
    const on = this.checkboxTarget.checked
    this.wrapperTarget.hidden = !on
    if (!on) {
      const input = this.wrapperTarget.querySelector("input")
      if (input) input.value = ""
    }
  }
}
