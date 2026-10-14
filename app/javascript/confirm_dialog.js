// Branded confirmation for every data-turbo-confirm: replaces the browser's
// native confirm() with the <dialog id="confirm-dialog"> rendered by the layout
// (shared/_confirm_dialog.html.erb).
//
// On the form: data-turbo-confirm="Supprimer cet achat ?" is the title, an
// optional data-confirm-detail="…" the explanation. The button takes the
// title's opening verb ("Supprimer"), or data-confirm-label="…".
// DELETE forms get the red button and the focus starts on "Annuler".
import { Turbo } from "@hotwired/turbo-rails"

const INFINITIVE = /^[A-ZÀ-Ý][a-zà-ÿ]+(er|ir|re)$/

// The confirmation waiting for an answer: one at a time.
let pending = null

function finish(accepted) {
  if (!pending) return
  const { resolve, opener } = pending
  pending = null
  resolve(accepted)
  if (opener?.isConnected) opener.focus()
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

function fill(dialog, title, detail, form) {
  const danger = isDelete(form)
  const body = dialog.querySelector("[data-confirm-body]")
  const accept = dialog.querySelector("[data-confirm-accept]")
  dialog.querySelector("[data-confirm-title]").textContent = title
  body.textContent = detail
  body.hidden = detail === ""
  accept.className = danger ? "btn btn--danger" : "btn btn--primary"
  accept.textContent = acceptLabel(title, form, danger)
  return danger
}

// Listeners live on the dialog element, once: each page render brings a new one.
function bind(dialog) {
  if (dialog.dataset.confirmBound) return
  dialog.addEventListener("close", () => finish(dialog.returnValue === "accept"))
  // A click on the backdrop lands on the <dialog> itself.
  dialog.addEventListener("click", (event) => { if (event.target === dialog) dialog.close("") })
  dialog.dataset.confirmBound = "on"
}

function confirmWithDialog(message, form) {
  const dialog = document.getElementById("confirm-dialog")
  const detail = form?.dataset.confirmDetail || ""
  if (typeof dialog?.showModal !== "function") {
    return Promise.resolve(window.confirm([message, detail].join(" ").trim()))
  }
  // The page is inert while the dialog is open: a second request can only come
  // from a script, and must not ride on the first answer.
  if (dialog.open || pending) return Promise.resolve(false)

  bind(dialog)
  const danger = fill(dialog, message, detail, form)
  return new Promise((resolve) => {
    pending = { resolve, opener: document.activeElement }
    dialog.returnValue = ""
    dialog.showModal()
    dialog.querySelector(danger ? "[data-confirm-cancel]" : "[data-confirm-accept]").focus()
  })
}

// A page change while the dialog is open counts as "Annuler", and the dialog
// must not be cached open.
document.addEventListener("turbo:before-render", () => finish(false))
document.addEventListener("turbo:before-cache", () => {
  document.getElementById("confirm-dialog")?.close("")
  finish(false)
})

Turbo.config.forms.confirm = confirmWithDialog
