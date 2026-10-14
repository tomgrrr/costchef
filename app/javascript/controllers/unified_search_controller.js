import { Controller } from "@hotwired/stimulus"

// Ingredient picker on the recipe page: searches products and sub-recipes,
// fills the hidden component_id / component_type fields and enables "Ajouter".
// The results list is a popover under the search field: it opens on click or
// typing, closes on Escape, outside click or selection.
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
    this.outsideClick = (event) => {
      if (!this.element.contains(event.target)) this.close()
    }
    document.addEventListener("click", this.outsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClick)
  }

  open() {
    this.resultsListTarget.hidden = false
  }

  close() {
    this.resultsListTarget.hidden = true
  }

  search() {
    const query = this.searchInputTarget.value.trim().toLowerCase()
    this.open()
    this.dropStaleSelection()

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
    this.searchInputTarget.value = name

    this.resultsListTarget.querySelectorAll(".search-result-item").forEach(item => {
      item.classList.remove("selected")
    })
    el.classList.add("selected")

    this.submitBtnTarget.removeAttribute("disabled")
    this.close()
  }

  // Typing after a selection means the user wants something else: forget
  // the previous choice so "Ajouter" can't submit it.
  dropStaleSelection() {
    if (!this.componentIdTarget.value) return
    if (this.searchInputTarget.value === this.selectedDisplayTarget.textContent) return

    this.componentIdTarget.value = ""
    this.componentTypeTarget.value = ""
    this.selectedDisplayTarget.textContent = "Aucune sélection"
    this.submitBtnTarget.setAttribute("disabled", "disabled")
  }

  clear() {
    this.searchInputTarget.value = ""
    this.componentIdTarget.value = ""
    this.componentTypeTarget.value = ""
    this.selectedDisplayTarget.textContent = "Aucune sélection"
    this.submitBtnTarget.setAttribute("disabled", "disabled")
    this.renderResults(this.recentItems.slice(0, this.maxRecentValue))
    this.searchInputTarget.focus()
    this.open()
  }

  renderResults(items) {
    const list = this.resultsListTarget

    if (items.length === 0) {
      list.innerHTML = `<div class="search-result-item search-result-item--empty">Aucun résultat</div>`
      return
    }

    list.innerHTML = items.map(item => `
      <div class="search-result-item"
           role="option"
           data-action="click->unified-search#select"
           data-id="${item.id}"
           data-name="${this.escapeHtml(item.name)}"
           data-kind="${item.kind}">
        <span>${this.escapeHtml(item.name)}</span>
        <span class="chip ${item.kind === "Product" ? "" : "chip--brand"}">${item.label}</span>
      </div>`
    ).join("")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
