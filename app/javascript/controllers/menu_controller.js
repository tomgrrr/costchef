import { Controller } from "@hotwired/stimulus"

// <details class="menu"> dropdown. The panel is positioned with `position:
// fixed` when it opens so it never gets clipped by a scrolling table, opens
// upwards when there is no room below, and closes on outside click, Escape,
// scroll, resize and before Turbo caches the page.
export default class extends Controller {
  connect() {
    this.panel = this.element.querySelector(".menu__panel")
    this.onToggle = () => (this.element.open ? this.place() : this.reset())
    this.onClick = (event) => { if (!this.element.contains(event.target)) this.close() }
    this.onKey = (event) => { if (event.key === "Escape") this.close() }
    this.onMove = () => this.close()

    this.element.addEventListener("toggle", this.onToggle)
    document.addEventListener("click", this.onClick)
    document.addEventListener("keydown", this.onKey)
    document.addEventListener("turbo:before-cache", this.onMove)
    window.addEventListener("resize", this.onMove)
    window.addEventListener("scroll", this.onMove, true)
  }

  disconnect() {
    this.element.removeEventListener("toggle", this.onToggle)
    document.removeEventListener("click", this.onClick)
    document.removeEventListener("keydown", this.onKey)
    document.removeEventListener("turbo:before-cache", this.onMove)
    window.removeEventListener("resize", this.onMove)
    window.removeEventListener("scroll", this.onMove, true)
  }

  close() {
    this.element.removeAttribute("open")
  }

  place() {
    if (!this.panel) return
    const anchor = this.element.querySelector("summary").getBoundingClientRect()
    const gap = 6
    this.panel.style.position = "fixed"
    this.panel.style.right = `${Math.max(window.innerWidth - anchor.right, 8)}px`
    this.panel.style.left = "auto"
    const below = anchor.bottom + gap
    const fits = below + this.panel.offsetHeight < window.innerHeight
    this.panel.style.top = fits ? `${below}px` : `${Math.max(anchor.top - gap - this.panel.offsetHeight, 8)}px`
  }

  reset() {
    if (!this.panel) return
    this.panel.style.position = ""
    this.panel.style.top = ""
    this.panel.style.right = ""
    this.panel.style.left = ""
  }
}
