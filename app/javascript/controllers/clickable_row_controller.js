import { Controller } from "@hotwired/stimulus"
import { visit } from "@hotwired/turbo"

export default class extends Controller {
  click(event) {
    if (event.target.closest(".row-actions, a, button, form")) return

    const row = event.target.closest("tr[data-href]")
    if (row) visit(row.dataset.href)
  }
}
