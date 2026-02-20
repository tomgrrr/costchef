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
      const select = this.wrapperTarget.querySelector("select")
      if (select) select.value = ""
    }
  }
}
