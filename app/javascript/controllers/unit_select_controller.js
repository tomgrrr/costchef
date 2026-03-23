import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["unitSelect", "weightField", "dehydratedField", "coefficientField"]

  connect() {
    this.toggle()
  }

  toggle() {
    const value = this.unitSelectTarget.value

    // Poids unitaire (piece uniquement)
    if (value === "piece") {
      this.weightFieldTarget.classList.remove("d-none")
    } else {
      this.weightFieldTarget.classList.add("d-none")
      const input = this.weightFieldTarget.querySelector("input")
      if (input) input.value = ""
    }

    // Déshydraté (kg uniquement)
    if (this.hasDehydratedFieldTarget) {
      if (value === "kg") {
        this.dehydratedFieldTarget.classList.remove("d-none")
      } else {
        this.dehydratedFieldTarget.classList.add("d-none")
        const checkbox = this.dehydratedFieldTarget.querySelector("input[type='checkbox']")
        if (checkbox) { checkbox.checked = false }
        this.hideCoefficient()
      }
    }
  }

  toggleDehydrated() {
    const checkbox = this.dehydratedFieldTarget.querySelector("input[type='checkbox']")
    if (checkbox && checkbox.checked) {
      this.coefficientFieldTarget.classList.remove("d-none")
    } else {
      this.hideCoefficient()
    }
  }

  hideCoefficient() {
    if (this.hasCoefficientFieldTarget) {
      this.coefficientFieldTarget.classList.add("d-none")
      const input = this.coefficientFieldTarget.querySelector("input[type='number']")
      if (input) input.value = ""
    }
  }
}
