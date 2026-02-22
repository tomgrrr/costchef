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
    const li = event.currentTarget
    const id = li.dataset.id
    const name = li.dataset.name
    const kind = li.dataset.kind

    this.componentIdTarget.value = id
    this.componentTypeTarget.value = kind
    this.selectedDisplayTarget.textContent = name

    this.resultsListTarget.querySelectorAll("li").forEach(el => {
      el.classList.remove("active")
    })
    li.classList.add("active")

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
    if (items.length === 0) {
      this.resultsListTarget.innerHTML = `
        <li class="list-group-item text-muted small py-2 text-center">
          Aucun résultat
        </li>`
      return
    }

    this.resultsListTarget.innerHTML = items.map(item => `
      <li class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
          style="cursor: pointer;"
          data-action="click->unified-search#select"
          data-id="${item.id}"
          data-name="${this.escapeHtml(item.name)}"
          data-kind="${item.kind}">
        <span>${this.escapeHtml(item.name)}</span>
        <span class="badge ${item.kind === 'Product' ? 'bg-success' : 'bg-info'} ms-2">
          ${item.label}
        </span>
      </li>`
    ).join("")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
