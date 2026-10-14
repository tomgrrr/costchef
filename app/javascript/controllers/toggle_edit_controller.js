import { Controller } from "@hotwired/stimulus"

// Shows or hides rows by id. Used by any element with
// data-action="click->toggle-edit#toggle" and
// data-toggle-edit-target-param="<id>" or "<id>,<id>" (e.g. swap a display
// row and its edit row). Rows start with the `hidden` attribute as needed.
export default class extends Controller {
  toggle(event) {
    event.preventDefault()

    let revealed = null
    String(event.params.target).split(",").forEach(id => {
      const row = document.getElementById(id.trim())
      if (!row) return
      row.hidden = !row.hidden
      if (!row.hidden && row.querySelector("input:not([type=hidden]), select, textarea")) revealed = row
    })
    // Keep keyboard users in place: the clicked button may just have been hidden.
    if (revealed) revealed.querySelector("input:not([type=hidden]), select, textarea").focus()
  }
}
