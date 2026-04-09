import { Controller } from "@hotwired/stimulus"

// Attach to a <form> element.
// Any child element with data-action="change->auto-submit#submit" will trigger
// form submission on change — CSP-safe alternative to inline onchange handlers.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
