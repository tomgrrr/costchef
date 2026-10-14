// Branded confirmation for every data-turbo-confirm: replaces the browser's
// native confirm() with the <dialog id="confirm-dialog"> rendered by the layout
// (shared/_confirm_dialog.html.erb).
//
// "Supprimer cet achat ? Il ne comptera plus." → title "Supprimer cet achat ?",
// the rest as text, and a "Supprimer" button (the message's opening verb).
// DELETE forms get the red button and the focus starts on "Annuler".
// A form can name its button with data-confirm-label="…".
import { Turbo } from "@hotwired/turbo-rails"

const INFINITIVE = /^[A-ZÀ-Ý][a-zà-ÿ]+(er|ir|re)$/

function splitMessage(message) {
  const end = message.indexOf("?")
  if (end === -1) return [message, ""]
  return [message.slice(0, end + 1), message.slice(end + 1).trim()]
}

function isDelete(form) {
  const method = form?.querySelector("input[name='_method']")?.value || form?.getAttribute("method") || ""
  return method.toLowerCase() === "delete"
}

function acceptLabel(title, form, danger) {
  if (form?.dataset.confirmLabel) return form.dataset.confirmLabel
  const verb = title.split(/\s/)[0]
  if (INFINITIVE.test(verb)) return verb
  return danger ? "Supprimer" : "Confirmer"
}

function fill(dialog, message, form) {
  const [title, text] = splitMessage(message)
  const danger = isDelete(form)
  const body = dialog.querySelector("[data-confirm-body]")
  const accept = dialog.querySelector("[data-confirm-accept]")
  dialog.querySelector("[data-confirm-title]").textContent = title
  body.textContent = text
  body.hidden = text === ""
  accept.className = danger ? "btn btn--danger" : "btn btn--primary"
  accept.textContent = acceptLabel(title, form, danger)
  return danger
}

function closeOnBackdrop(dialog) {
  if (dialog.dataset.backdropClose) return
  // A click on the backdrop lands on the <dialog> itself.
  dialog.addEventListener("click", (event) => { if (event.target === dialog) dialog.close("") })
  dialog.dataset.backdropClose = "on"
}

function confirmWithDialog(message, form) {
  const dialog = document.getElementById("confirm-dialog")
  if (!dialog) return Promise.resolve(window.confirm(message))

  const danger = fill(dialog, message, form)
  const opener = document.activeElement
  closeOnBackdrop(dialog)
  return new Promise((resolve) => {
    dialog.addEventListener("close", () => {
      resolve(dialog.returnValue === "accept")
      opener?.focus?.()
    }, { once: true })
    dialog.returnValue = ""
    dialog.showModal()
    dialog.querySelector(danger ? "[data-confirm-cancel]" : "[data-confirm-accept]").focus()
  })
}

Turbo.config.forms.confirm = confirmWithDialog
