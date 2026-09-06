import { Controller } from "@hotwired/stimulus"

// Client-side gallery lightbox.
// Thumbnails are progressive-enhancement links (they still open the server
// viewer without JS). When JS is on we intercept the click and show a modal:
//   • navigate within the same category with prev/next
//   • keyboard: ← / → / Esc, focus trapped inside the dialog
//   • touch swipe on mobile, backdrop click to close, body scroll locked
export default class extends Controller {
  static targets = ["item", "lightbox", "image", "caption", "counter"]

  connect() {
    this._onKey = this.onKey.bind(this)
    this.list = []
    this.index = 0
  }

  disconnect() {
    this.unlock()
    document.removeEventListener("keydown", this._onKey)
  }

  // ---- open ----------------------------------------------------------
  open(event) {
    event.preventDefault()
    const el = event.currentTarget
    const category = el.dataset.category

    // Build the ordered list of items in the clicked category.
    this.list = this.itemTargets
      .filter((i) => i.dataset.category === category)
      .map((i) => ({ full: i.dataset.full, caption: i.dataset.caption || "" }))
    this.index = this.itemTargets
      .filter((i) => i.dataset.category === category)
      .indexOf(el)
    if (this.index < 0) this.index = 0

    this.render()
    this.lightboxTarget.classList.add("is-open")
    this.lightboxTarget.setAttribute("aria-hidden", "false")
    this.lock()
    document.addEventListener("keydown", this._onKey)
    this.lightboxTarget.focus()
  }

  close() {
    this.lightboxTarget.classList.remove("is-open")
    this.lightboxTarget.setAttribute("aria-hidden", "true")
    this.unlock()
    document.removeEventListener("keydown", this._onKey)
  }

  next() { this.step(1) }
  prev() { this.step(-1) }

  step(dir) {
    if (this.list.length === 0) return
    this.index = (this.index + dir + this.list.length) % this.list.length
    this.render()
  }

  // ---- rendering -----------------------------------------------------
  render() {
    const item = this.list[this.index]
    if (!item) return
    if (this.hasImageTarget) {
      this.imageTarget.src = item.full
      this.imageTarget.alt = item.caption
    }
    if (this.hasCaptionTarget) {
      this.captionTarget.textContent = item.caption
      this.captionTarget.hidden = !item.caption
    }
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.index + 1} / ${this.list.length}`
    }
    // hide nav when there is only one image
    const single = this.list.length < 2
    this.lightboxTarget
      .querySelectorAll(".g-lightbox__nav")
      .forEach((b) => (b.style.display = single ? "none" : ""))
  }

  // ---- keyboard ------------------------------------------------------
  onKey(e) {
    switch (e.key) {
      case "Escape": this.close(); break
      case "ArrowRight": this.next(); break
      case "ArrowLeft": this.prev(); break
      case "Tab": e.preventDefault(); break // simple focus trap
    }
  }

  // ---- backdrop click ------------------------------------------------
  backdrop(event) {
    if (event.target === this.lightboxTarget) this.close()
  }

  // ---- touch swipe ---------------------------------------------------
  touchStart(event) { this._x = event.changedTouches[0].clientX }
  touchEnd(event) {
    if (this._x == null) return
    const dx = event.changedTouches[0].clientX - this._x
    if (Math.abs(dx) > 45) (dx < 0 ? this.next() : this.prev())
    this._x = null
  }

  // ---- scroll lock ---------------------------------------------------
  lock() { document.body.style.overflow = "hidden" }
  unlock() { document.body.style.overflow = "" }
}

