import { Controller } from "@hotwired/stimulus"

// Product form: shows the piece-weight field for "piece" products and the
// dehydration fields for "kg" products. Works with the base-unit radios
// (data-action="change->unit-select#toggle"). Hidden fields are cleared so
// they are not submitted with stale values.
export default class extends Controller {
  static targets = ["weightField", "dehydratedField", "coefficientField"]

  connect() {
    this.toggle()
  }

  get unit() {
    const checked = this.element.querySelector("input[name='product[base_unit]']:checked")
    return checked ? checked.value : "kg"
  }

  toggle() {
    const unit = this.unit
    this.show(this.weightFieldTarget, unit === "piece")

    if (this.hasDehydratedFieldTarget) {
      this.show(this.dehydratedFieldTarget, unit === "kg")
      if (unit !== "kg") {
        const checkbox = this.dehydratedFieldTarget.querySelector("input[type='checkbox']")
        if (checkbox) checkbox.checked = false
      }
      this.toggleDehydrated()
    }
  }

  toggleDehydrated() {
    if (!this.hasCoefficientFieldTarget) return
    const checkbox = this.dehydratedFieldTarget.querySelector("input[type='checkbox']")
    this.show(this.coefficientFieldTarget, Boolean(checkbox && checkbox.checked))
  }

  show(element, visible) {
    element.hidden = !visible
    if (!visible) {
      element.querySelectorAll("input[type='number']").forEach(input => { input.value = "" })
    }
  }
}
