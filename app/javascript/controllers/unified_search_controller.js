import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "searchInput",
    "resultsList",
    "componentId",
    "componentType",
    "selectedDisplay",
    "submitBtn"
  ]

  static values = {
    products: Array,
    subrecipes: Array,
    maxRecent: { type: Number, default: 10 }
  }

  connect() {
    this.allItems = [
      ...this.productsValue.map(p => ({ ...p, kind: "Product", label: "Produit" })),
      ...this.subrecipesValue.map(r => ({ ...r, kind: "Recipe", label: "Sous-recette" }))
    ]

    this.recentItems = [...this.allItems].sort((a, b) => b.id - a.id)

    this.renderResults(this.recentItems.slice(0, this.maxRecentValue))
    this.searchInputTarget.focus()
  }

  search() {
    const query = this.searchInputTarget.value.trim().toLowerCase()

    if (query === "") {
      this.renderResults(this.recentItems.slice(0, this.maxRecentValue))
      return
    }

    const filtered = this.allItems.filter(item =>
      item.name.toLowerCase().includes(query)
    )

    this.renderResults(filtered)
  }

  select(event) {
    const el = event.currentTarget
    const id = el.dataset.id
    const name = el.dataset.name
    const kind = el.dataset.kind

    this.componentIdTarget.value = id
    this.componentTypeTarget.value = kind
    this.selectedDisplayTarget.textContent = name

    this.resultsListTarget.querySelectorAll(".search-result-item").forEach(item => {
      item.classList.remove("selected")
    })
    el.classList.add("selected")

    this.submitBtnTarget.removeAttribute("disabled")
  }

  clear() {
    this.searchInputTarget.value = ""
    this.componentIdTarget.value = ""
    this.componentTypeTarget.value = ""
    this.selectedDisplayTarget.textContent = "Aucune sélection"
    this.submitBtnTarget.setAttribute("disabled", "disabled")
    this.renderResults(this.recentItems.slice(0, this.maxRecentValue))
    this.searchInputTarget.focus()
  }

  renderResults(items) {
    const list = this.resultsListTarget

    if (items.length === 0) {
      list.style.display = "block"
      list.innerHTML = `
        <div class="search-result-item" style="justify-content: center; color: var(--sl-400); cursor: default;">
          Aucun résultat
        </div>`
      return
    }

    list.style.display = "block"
    list.innerHTML = items.map(item => `
      <div class="search-result-item"
           data-action="click->unified-search#select"
           data-id="${item.id}"
           data-name="${this.escapeHtml(item.name)}"
           data-kind="${item.kind}">
        <span>${this.escapeHtml(item.name)}</span>
        <span class="${item.kind === 'Product' ? 'badge-produit' : 'badge-sous-recette'}">
          ${item.label}
        </span>
      </div>`
    ).join("")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
