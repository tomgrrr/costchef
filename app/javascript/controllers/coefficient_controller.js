import { Controller } from "@hotwired/stimulus"

// Settings page: live preview of what a coefficient means before saving.
// Margin on materials = 1 − 1 / coefficient; example price = cost × coefficient.
export default class extends Controller {
  static targets = ["input", "margin", "example"]
  static values = { cost: Number }

  connect() {
    this.update()
  }

  step(event) {
    const next = Math.round((this.value + Number(event.params.delta)) * 100) / 100
    this.inputTarget.value = Math.max(0.1, next).toFixed(2)
    this.update()
  }

  update() {
    const coefficient = this.value
    if (coefficient < 0.1) {
      this.exampleTarget.textContent = "—"
      this.marginTarget.textContent = "—"
      return
    }
    const money = new Intl.NumberFormat("fr-FR", { style: "currency", currency: "EUR" })
    this.exampleTarget.textContent = money.format(this.costValue * coefficient)
    this.marginTarget.textContent = coefficient > 1
      ? `${Math.round((1 - 1 / coefficient) * 100)}\u00A0%`
      : "aucune"
  }

  get value() {
    const parsed = parseFloat(String(this.inputTarget.value).replace(",", "."))
    return Number.isFinite(parsed) ? parsed : 0
  }
}
