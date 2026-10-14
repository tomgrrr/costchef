import { Controller } from "@hotwired/stimulus"

// Opens a native <dialog> by id: data-action="dialog#open" data-dialog-id-param="…".
// Inside the dialog, data-action="dialog#close" closes it.
export default class extends Controller {
  open(event) {
    const dialog = document.getElementById(event.params.id)
    if (!dialog) return
    if (!dialog.dataset.backdropClose) {
      // A click on the backdrop lands on the <dialog> itself: close it.
      dialog.addEventListener("click", (click) => { if (click.target === dialog) dialog.close() })
      dialog.dataset.backdropClose = "on"
    }
    dialog.showModal()
  }

  close(event) {
    const dialog = event.target.closest("dialog")
    if (dialog) dialog.close()
  }
}
