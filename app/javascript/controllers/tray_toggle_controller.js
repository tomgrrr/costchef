import { Controller } from "@hotwired/stimulus"

// Recipe form: shows the tray-size select only when "Vendue en barquette"
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
      const select = this.wrapperTarget.querySelector("select")
      if (select) select.value = ""
    }
  }
}
