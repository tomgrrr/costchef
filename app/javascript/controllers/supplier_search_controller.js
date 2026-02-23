import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hidden", "results", "display"]
  static values = { suppliers: Array, selected: { type: Number, default: 0 } }

  connect() {
    this.renderResults(this.suppliersValue)
    document.addEventListener("click", this.outsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClick)
  }

  outsideClick = (event) => {
    if (!this.element.contains(event.target)) {
      this.resultsTarget.style.display = "none"
    }
  }

  search() {
    const query = this.inputTarget.value.trim().toLowerCase()
    this.resultsTarget.style.display = "block"

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
    this.resultsTarget.style.display = "block"
    this.search()
  }

  select(event) {
    const el = event.currentTarget
    const id = el.dataset.id
    const name = el.dataset.name

    this.hiddenTarget.value = id
    this.inputTarget.value = name
    this.selectedValue = parseInt(id)
    this.resultsTarget.style.display = "none"
  }

  renderResults(items) {
    const list = this.resultsTarget

    if (items.length === 0) {
      list.innerHTML = `
        <div class="search-result-item" style="justify-content: center; color: var(--sl-400); cursor: default;">
          Aucun fournisseur
        </div>`
      return
    }

    list.innerHTML = items.map(s => `
      <div class="search-result-item ${s.id === this.selectedValue ? 'selected' : ''}"
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
