import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "wrapper"]

  connect() {
    this.toggle()
  }

  toggle() {
    if (this.checkboxTarget.checked) {
      this.wrapperTarget.style.display = ""
    } else {
      this.wrapperTarget.style.display = "none"
      const input = this.wrapperTarget.querySelector("input")
      if (input) input.value = ""
    }
  }
}
