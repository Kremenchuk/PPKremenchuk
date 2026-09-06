import { Controller } from "@hotwired/stimulus"

// Scroll-driven photo morph hero.
//
// A pinned viewport where scrolling continuously cross-fades one full-screen
// photograph into the next (with a slow Ken-Burns scale) while the headline and
// copy morph in step. No 3D, no image files beyond the photos themselves — the
// whole thing is CSS opacity/transform driven from the scroll position, so it
// stays light and buttery.
//
// Markup contract (welcome/index.html.haml):
//   section.photostage[data-controller="photostage"]
//     .photostage__sticky
//       .photostage__layer[data-photostage-target="layer"] (× N, stacked)
//       .photostage__cap[data-photostage-target="cap"]     (× N, stacked)
//       .photostage__dot[data-photostage-target="dot"]     (× N)
//       .photostage__rail > i[data-photostage-target="progress"]

const clamp = (v, a, b) => Math.min(b, Math.max(a, v))
const lerp = (a, b, t) => a + (b - a) * t
const smooth = (t) => t * t * (3 - 2 * t)
const smoothstep = (a, b, x) => smooth(clamp((x - a) / (b - a), 0, 1))

export default class extends Controller {
  static targets = ["layer", "cap", "dot", "progress"]

  connect() {
    this.n = this.layerTargets.length
    this.reduce = matchMedia("(prefers-reduced-motion: reduce)").matches
    this.progress = 0
    this.target = 0
    this.visible = true

    this.onScroll = () => this.measure()
    window.addEventListener("scroll", this.onScroll, { passive: true })
    window.addEventListener("resize", this.onScroll)

    this.io = new IntersectionObserver(([e]) => { this.visible = e.isIntersecting }, { threshold: 0 })
    this.io.observe(this.element)

    // prime first frame so nothing flashes before the loop settles
    this.layerTargets.forEach((l, k) => { l.style.opacity = k === 0 ? 1 : 0 })
    this.capTargets.forEach((c, k) => { c.style.opacity = k === 0 ? 1 : 0 })

    this.measure()
    this.progress = this.target
    this.last = performance.now()
    this.loop()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
    window.removeEventListener("resize", this.onScroll)
    if (this.io) this.io.disconnect()
    if (this.raf) cancelAnimationFrame(this.raf)
  }

  measure() {
    const r = this.element.getBoundingClientRect()
    const total = this.element.offsetHeight - window.innerHeight
    const scrolled = clamp(-r.top, 0, total)
    this.target = total > 0 ? scrolled / total : 0
  }

  loop() {
    this.raf = requestAnimationFrame(() => this.loop())
    const now = performance.now()
    const dt = Math.min(0.05, (now - this.last) / 1000)
    this.last = now
    if (!this.visible || document.hidden) return

    this.progress = this.reduce ? this.target : lerp(this.progress, this.target, 1 - Math.pow(0.0016, dt))

    // Timeline: each scene owns an equal band; the first ~55% of a band HOLDS
    // that scene, the last ~45% TRANSITIONS to the next. Middle scenes get a
    // real dwell, so the headline settles instead of only peaking for a frame.
    const n = this.n
    const HOLD = 0.55
    const x = clamp(this.progress, 0, 0.99999) * n // 0 .. n
    const k = clamp(Math.floor(x), 0, n - 1)        // current scene
    const local = x - k                              // 0 .. 1 within the band
    const t = k < n - 1 ? clamp((local - HOLD) / (1 - HOLD), 0, 1) : 0 // transition amount

    // photos: continuous cross-fade + slow zoom
    for (let i = 0; i < n; i++) {
      let o = 0
      if (i === k) o = 1 - t
      else if (i === k + 1) o = t
      const layer = this.layerTargets[i]
      layer.style.opacity = o.toFixed(3)
      layer.style.transform = `scale(${lerp(1.16, 1.0, smooth(o)).toFixed(4)})`
    }

    // text: leaves before the next arrives (dead-zone), so two giant headlines
    // never double-expose — reads as a morph, not an overlap
    const outO = 1 - smoothstep(0, 0.5, t)
    const inO = smoothstep(0.5, 1, t)
    for (let i = 0; i < n; i++) {
      const cap = this.capTargets[i]
      if (!cap) continue
      let o = 0, rise = 0
      if (i === k) { o = outO; rise = lerp(0, -20, 1 - outO) }
      else if (i === k + 1) { o = inO; rise = lerp(30, 0, inO) }
      cap.style.opacity = o.toFixed(3)
      cap.style.transform = `translate3d(0, ${rise.toFixed(1)}px, 0)`
      cap.style.pointerEvents = o > 0.6 ? "auto" : "none"
    }

    const active = t > 0.5 ? k + 1 : k
    if (this.hasDotTarget) this.dotTargets.forEach((d, i) => d.classList.toggle("is-active", i === active))
    if (this.hasProgressTarget) this.progressTarget.style.transform = `scaleY(${clamp(this.progress, 0, 1).toFixed(3)})`
  }
}
