import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "edit"]

  toggle() {
    this.displayTargets.forEach(el => el.classList.add("d-none"))
    this.editTargets.forEach(el => el.classList.remove("d-none"))
  }

  cancel() {
    this.displayTargets.forEach(el => el.classList.remove("d-none"))
    this.editTargets.forEach(el => el.classList.add("d-none"))
  }
}
