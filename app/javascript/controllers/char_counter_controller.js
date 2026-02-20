import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count"]
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    this.countTarget.textContent = this.element.querySelector("textarea").value.length
  }
}
