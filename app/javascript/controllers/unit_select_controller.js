import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["unitSelect", "weightField"]

  connect() {
    this.toggle()
  }

  toggle() {
    if (this.unitSelectTarget.value === "piece") {
      this.weightFieldTarget.classList.remove("d-none")
    } else {
      this.weightFieldTarget.classList.add("d-none")
      const input = this.weightFieldTarget.querySelector("input")
      if (input) input.value = ""
    }
  }
}
