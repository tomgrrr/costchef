import { Controller } from "@hotwired/stimulus"

// Supplier picker for purchase forms: filters the user's active suppliers,
// writes the chosen id into the hidden field. Results are a popover that
// opens on focus or typing and closes on Escape, outside click or selection.
export default class extends Controller {
  static targets = ["input", "hidden", "results"]
  static values = { suppliers: Array, selected: { type: Number, default: 0 } }

  connect() {
    this.selectedName = this.inputTarget.value
    this.renderResults(this.suppliersValue)
    this.outsideClick = (event) => {
      if (!this.element.contains(event.target)) this.close()
    }
    document.addEventListener("click", this.outsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClick)
  }

  close() {
    this.resultsTarget.hidden = true
  }

  search() {
    const query = this.inputTarget.value.trim().toLowerCase()
    this.resultsTarget.hidden = false
    // Typed text no longer matches the chosen supplier: forget it.
    if (this.hiddenTarget.value && this.inputTarget.value !== this.selectedName) {
      this.hiddenTarget.value = ""
      this.selectedValue = 0
    }

    if (query === "") {
      this.renderResults(this.suppliersValue)
      return
    }

    const filtered = this.suppliersValue.filter(s =>
      s.name.toLowerCase().includes(query)
    )
    this.renderResults(filtered)
  }

  focus() {
    this.search()
  }

  select(event) {
    const el = event.currentTarget

    this.hiddenTarget.value = el.dataset.id
    this.inputTarget.value = el.dataset.name
    this.selectedName = el.dataset.name
    this.selectedValue = parseInt(el.dataset.id)
    this.close()
  }

  renderResults(items) {
    const list = this.resultsTarget

    if (items.length === 0) {
      list.innerHTML = `<div class="search-result-item search-result-item--empty">Aucun fournisseur</div>`
      return
    }

    list.innerHTML = items.map(s => `
      <div class="search-result-item ${s.id === this.selectedValue ? "selected" : ""}"
           role="option"
           data-action="click->supplier-search#select"
           data-id="${s.id}"
           data-name="${this.escapeHtml(s.name)}">
        <span>${this.escapeHtml(s.name)}</span>
      </div>`
    ).join("")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
