import { Controller } from "@hotwired/stimulus"

// Handles all homepage / chrome interactions from the redesign:
// mobile nav, sticky-header shadow, reveal-on-scroll, animated counters,
// hero parallax and the contact form (opens the user's mail client).
export default class extends Controller {
  static targets = ["nav", "burger", "heroImg", "note"]

  connect() {
    this.reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches

    this.initHeaderShadow()
    this.initReveal()
    this.closeNavOnClick()
  }

  disconnect() {
    if (this._onScroll) window.removeEventListener("scroll", this._onScroll)
    if (this._revealObserver) this._revealObserver.disconnect()
  }

  // ---- mobile nav ----------------------------------------------------
  toggleNav() {
    if (!this.hasNavTarget || !this.hasBurgerTarget) return
    const open = this.navTarget.classList.toggle("open")
    this.burgerTarget.setAttribute("aria-expanded", open ? "true" : "false")
    document.body.style.overflow = open ? "hidden" : ""
  }

  closeNavOnClick() {
    if (!this.hasNavTarget) return
    this.navTarget.querySelectorAll("a").forEach((a) => {
      a.addEventListener("click", () => {
        this.navTarget.classList.remove("open")
        if (this.hasBurgerTarget) this.burgerTarget.setAttribute("aria-expanded", "false")
        document.body.style.overflow = ""
      })
    })
  }

  // ---- sticky-header shadow -----------------------------------------
  initHeaderShadow() {
    const header = this.element.querySelector(".header")
    if (!header) return
    this._onScroll = () => header.classList.toggle("scrolled", window.scrollY > 24)
    this._onScroll()
    window.addEventListener("scroll", this._onScroll, { passive: true })
  }

  // ---- reveal on scroll ---------------------------------------------
  initReveal() {
    const reveals = this.element.querySelectorAll(".reveal")
    if (!("IntersectionObserver" in window)) {
      reveals.forEach((el) => el.classList.add("in"))
      return
    }
    this._revealObserver = new IntersectionObserver((entries) => {
      entries.forEach((e) => {
        if (e.isIntersecting) {
          e.target.classList.add("in")
          this._revealObserver.unobserve(e.target)
        }
      })
    }, { threshold: 0.14, rootMargin: "0px 0px -8% 0px" })
    reveals.forEach((el) => this._revealObserver.observe(el))
  }



  // ---- contact form → mail client -----------------------------------
  sendMail(event) {
    event.preventDefault()
    const form = event.target
    const data = new FormData(form)
    const name = (data.get("name") || "").toString().trim()
    const phone = (data.get("phone") || "").toString().trim()
    const msg = (data.get("msg") || "").toString().trim()

    const subject = `Заявка з сайту STM Industry${name ? ` — ${name}` : ""}`
    const body = [
      name ? `Ім'я: ${name}` : null,
      phone ? `Телефон: ${phone}` : null,
      msg ? `\n${msg}` : null
    ].filter(Boolean).join("\n")

    window.location.href =
      `mailto:stm_industry@ukr.net?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`

    if (this.hasNoteTarget) this.noteTarget.hidden = false
  }
}

