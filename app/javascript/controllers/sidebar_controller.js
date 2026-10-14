import { Controller } from "@hotwired/stimulus"

// Opens and closes the navigation on narrow screens (below 900px the
// sidebar collapses into a top bar with a menu button).
export default class extends Controller {
  static targets = ["toggle"]

  toggle() {
    const open = !this.element.hasAttribute("data-open")
    this.element.toggleAttribute("data-open", open)
    this.toggleTarget.setAttribute("aria-expanded", String(open))
    this.toggleTarget.setAttribute("aria-label", open ? "Fermer le menu" : "Ouvrir le menu")
  }
}
