import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typeSelect", "productWrapper", "recipeWrapper", "productSelect", "recipeSelect"]

  connect() {
    this.toggle()
  }

  toggle() {
    if (this.typeSelectTarget.value === "Recipe") {
      this.productWrapperTarget.classList.add("d-none")
      this.recipeWrapperTarget.classList.remove("d-none")
      this.productSelectTarget.disabled = true
      this.productSelectTarget.value = ""
      this.recipeSelectTarget.disabled = false
    } else {
      this.productWrapperTarget.classList.remove("d-none")
      this.recipeWrapperTarget.classList.add("d-none")
      this.productSelectTarget.disabled = false
      this.recipeSelectTarget.disabled = true
      this.recipeSelectTarget.value = ""
    }
  }
}
