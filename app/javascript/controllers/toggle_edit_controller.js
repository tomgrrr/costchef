import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    event.preventDefault()

    const targetId = event.params.target
    const targetRow = document.getElementById(targetId)

    if (targetRow) {
      targetRow.classList.toggle("d-none")
    }
  }
}
