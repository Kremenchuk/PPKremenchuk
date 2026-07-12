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
    this.initAnchorScroll()
    this.closeNavOnClick()
  }

  disconnect() {
    if (this._onScroll) window.removeEventListener("scroll", this._onScroll)
    if (this._revealObserver) this._revealObserver.disconnect()
    if (this._onAnchorClick) this.element.removeEventListener("click", this._onAnchorClick)
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

  // ---- in-page anchor scrolling -------------------------------------
  // Header/footer links point at "<root>#section" so they also work from
  // sub-pages. When the target section exists on the *current* page we handle
  // the click ourselves: this avoids a full page reload (which would jump to
  // the anchor before lazy images/reveal settle and land mid-section) and
  // performs a reliable smooth scroll that respects `scroll-margin-top`.
  initAnchorScroll() {
    this._onAnchorClick = (event) => {
      const link = event.target.closest('a[href*="#"]')
      if (!link) return
      const url = new URL(link.href, window.location.href)
      if (url.pathname !== window.location.pathname && url.hash === "") return
      const id = url.hash.slice(1)
      if (!id) return
      const target = document.getElementById(id)
      if (!target) return // not on this page — let the browser navigate

      event.preventDefault()
      target.scrollIntoView({
        behavior: this.reduceMotion ? "auto" : "smooth",
        block: "start"
      })
      history.replaceState(null, "", `#${id}`)
    }
    this.element.addEventListener("click", this._onAnchorClick)

    // Handle a hash present on initial load (arriving from another page):
    // wait a tick so images/fonts lay out, then align the section correctly.
    if (window.location.hash.length > 1) {
      const el = document.getElementById(window.location.hash.slice(1))
      if (el) {
        window.requestAnimationFrame(() =>
          setTimeout(() => el.scrollIntoView({ behavior: "auto", block: "start" }), 60)
        )
      }
    }
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



  // ---- contact form → sends email server-side (SendEmail mailer) ----
  sendMail(event) {
    event.preventDefault()
    const form = event.target
    const data = new FormData(form)

    const submitBtn = form.querySelector('[type="submit"]')
    if (submitBtn) submitBtn.disabled = true

    const token =
      document.querySelector('meta[name="csrf-token"]')?.content || ""

    fetch(form.action, {
      method: "POST",
      headers: {
        "X-CSRF-Token": token,
        "Accept": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      },
      body: data
    })
      .then((res) => {
        if (!res.ok) throw new Error("request failed")
        return res.json()
      })
      .then(() => {
        form.reset()
        if (this.hasNoteTarget) {
          this.noteTarget.classList.remove("form__note--error")
          this.noteTarget.hidden = false
        }
      })
      .catch(() => {
        if (this.hasNoteTarget) {
          this.noteTarget.textContent = this.noteTarget.dataset.errorText ||
            "Не вдалося надіслати заявку. Спробуйте пізніше або зателефонуйте нам."
          this.noteTarget.classList.add("form__note--error")
          this.noteTarget.hidden = false
        }
      })
      .finally(() => {
        if (submitBtn) submitBtn.disabled = false
      })
  }
}

