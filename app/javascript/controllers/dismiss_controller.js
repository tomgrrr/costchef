import { Controller } from "@hotwired/stimulus"

// Removes the element it is attached to (flash messages).
export default class extends Controller {
  close() {
    this.element.remove()
  }
}
