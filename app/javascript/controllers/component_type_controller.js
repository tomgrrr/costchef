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
      this.productSelectTarget.value = ""
    } else {
      this.productWrapperTarget.classList.remove("d-none")
      this.recipeWrapperTarget.classList.add("d-none")
      this.recipeSelectTarget.value = ""
    }
  }
}
