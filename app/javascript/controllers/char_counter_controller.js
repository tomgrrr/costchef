import { Controller } from "@hotwired/stimulus"

// Live character count for a textarea. Attach to a wrapper that contains
// the textarea (data-char-counter-target="input") and the count element.
export default class extends Controller {
  static targets = ["input", "count"]
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    this.countTarget.textContent = this.inputTarget.value.length.toLocaleString("fr-FR")
  }
}
