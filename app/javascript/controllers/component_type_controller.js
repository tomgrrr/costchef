import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "typeSelect",
    "searchWrapper",
    "searchInput",
    "resultsList",
    "componentId",
    "selectedDisplay",
    "submitBtn"
  ]

  static values = {
    products: Array,
    subrecipes: Array
  }

  connect() {
    this.currentDataset = []
    this.toggleType()
  }

  toggleType() {
    const type = this.typeSelectTarget.value

    if (!type) {
      this.searchWrapperTarget.classList.add("d-none")
      this.reset()
      return
    }

    if (type === "Product") {
      this.currentDataset = this.productsValue
    } else {
      this.currentDataset = this.subrecipesValue
    }

    this.searchWrapperTarget.classList.remove("d-none")
    this.reset()
    this.searchInputTarget.focus()
    this.renderResults(this.currentDataset)
  }

  search() {
    const query = this.searchInputTarget.value.toLowerCase().trim()

    if (query === "") {
      this.renderResults(this.currentDataset)
      return
    }

    const filtered = this.currentDataset.filter(item =>
      item.name.toLowerCase().includes(query)
    )
    this.renderResults(filtered)
  }

  select(event) {
    const id = event.currentTarget.dataset.id
    const name = event.currentTarget.dataset.name

    this.componentIdTarget.value = id
    this.selectedDisplayTarget.textContent = name

    this.resultsListTarget.querySelectorAll("li").forEach(li => {
      li.classList.remove("active")
    })
    event.currentTarget.classList.add("active")

    this.submitBtnTarget.removeAttribute("disabled")
  }

  reset() {
    this.searchInputTarget.value = ""
    this.resultsListTarget.innerHTML = ""
    this.componentIdTarget.value = ""
    this.selectedDisplayTarget.textContent = "Aucune sélection"
    this.submitBtnTarget.setAttribute("disabled", "disabled")
  }

  renderResults(items) {
    this.resultsListTarget.innerHTML = items.map(item =>
      `<li class="list-group-item list-group-item-action"
           style="cursor: pointer;"
           data-action="click->component-type#select"
           data-id="${item.id}"
           data-name="${this.escapeHtml(item.name)}">${this.escapeHtml(item.name)}</li>`
    ).join("")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
