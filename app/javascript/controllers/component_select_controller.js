import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typeField"]

  updateType() {
    const selected = this.element.selectedOptions[0]
    if (selected && selected.dataset.type) {
      this.typeFieldTarget.value = selected.dataset.type
    }
  }
}
