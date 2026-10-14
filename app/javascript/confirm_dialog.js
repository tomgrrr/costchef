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

// The open confirmation: { dialog, resolve, opener }. One at a time.
let pending = null

// Settles the open confirmation, only from the dialog that shows it.
function finish(dialog, accepted) {
  if (!pending || pending.dialog !== dialog) return
  const { resolve, opener } = pending
  pending = null
  resolve(accepted)
  // After the dialog has closed: the page is inert until then.
  setTimeout(() => { if (opener?.isConnected) opener.focus() })
}

// A page change while the dialog is open counts as "Annuler".
function cancelPending() {
  if (!pending) return
  const { dialog } = pending
  finish(dialog, false)
  if (dialog.open) dialog.close("")
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

// Every answer is settled synchronously, before the dialog closes, so a late
// "close" event can never answer a later confirmation.
function bind(dialog) {
  if (dialog.dataset.confirmBound) return
  dialog.querySelector("form").addEventListener("submit", (event) => {
    finish(dialog, event.submitter?.value === "accept")
  })
  dialog.addEventListener("cancel", () => finish(dialog, false)) // Escape
  dialog.addEventListener("click", (event) => {
    if (event.target !== dialog) return // a click on the backdrop lands on the <dialog> itself
    finish(dialog, false)
    dialog.close("")
  })
  // Any other way of closing; ignored if the dialog was reopened meanwhile.
  dialog.addEventListener("close", () => { if (!dialog.open) finish(dialog, false) })
  dialog.dataset.confirmBound = "on"
}

// Opens the dialog; false when it cannot (no dialog, no API, already open, error).
function show(dialog, title, detail, form) {
  if (typeof dialog?.showModal !== "function" || dialog.open) return false
  bind(dialog)
  const danger = fill(dialog, title, detail, form)
  try {
    dialog.returnValue = ""
    dialog.showModal()
  } catch {
    return false
  }
  dialog.querySelector(danger ? "[data-confirm-cancel]" : "[data-confirm-accept]").focus()
  return true
}

function confirmWithDialog(message, form) {
  // The page is inert while the dialog is open: a second request can only come
  // from a script, and must not share the first answer.
  if (pending) return Promise.resolve(false)

  const dialog = document.getElementById("confirm-dialog")
  const detail = form?.dataset.confirmDetail || ""
  const opener = document.activeElement
  if (!show(dialog, message, detail, form)) {
    return Promise.resolve(window.confirm([message, detail].join(" ").trim()))
  }
  return new Promise((resolve) => { pending = { dialog, resolve, opener } })
}

document.addEventListener("turbo:before-render", cancelPending)
document.addEventListener("turbo:before-cache", cancelPending)

Turbo.config.forms.confirm = confirmWithDialog
