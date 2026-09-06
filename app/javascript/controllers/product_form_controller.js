import { Controller } from "@hotwired/stimulus"

// Shared controller for the product calculation forms
// (trolley, stillage, stillage_pallet, stillage_warehouse).
//
// It replaces the old inline `onsubmit` / `onclick` handlers and the
// per-page `showHide` / `validate_*` / `hide_dsp` global functions.
//
// Markup contract:
//   <form data-controller="product-form"
//         data-action="submit->product-form#validate">
//     <div data-action="click->product-form#toggle">
//       <img data-product-form-target="icon" data-open-src="/assets/minus.png">
//     </div>
//     <div data-product-form-target="panel">
//       <input data-product-form-target="field"
//              data-label="Высота" data-min="500" data-max="3500">
//     </div>
//   </form>
//
// Conditional limits (see stillage_warehouse depth): a field may declare
//   data-max-source="group3" data-max-map='{"metall":1215,"dsp":1500}'
// and the effective limit is chosen from the current value of the named input.
export default class extends Controller {
  static targets = ["panel", "icon", "field", "dspOption", "dspRow"]

  connect() {
    if (this.hasIconTarget) this.closedIconSrc = this.iconTarget.src
    this.buildSteppers()
  }

  disconnect() {
    // a finger still holding a stepper when the page is torn down must not
    // leave its auto-repeat interval running
    ;(this._holdStops || []).forEach((stop) => stop())
    this._holdStops = []
  }

  // --- numeric steppers: −/＋ around every field -------------------------
  // Lets the visitor nudge a dimension up/down instead of only typing. Each
  // change fires a bubbling `input`, so the live 3D (rack-viewer) redraws and
  // the same validation limits (min/max, conditional maps) are respected.
  buildSteppers() {
    if (!this.hasFieldTarget) return
    this.fieldTargets.forEach((field) => {
      if (field.closest(".pdp-stepper")) return
      const wrap = document.createElement("div")
      wrap.className = "pdp-stepper"
      field.parentNode.insertBefore(wrap, field)
      const minus = this.stepBtn("−", "minus")
      const plus = this.stepBtn("+", "plus")
      wrap.appendChild(minus)
      wrap.appendChild(field)
      wrap.appendChild(plus)
      this.bindHold(minus, () => this.step(field, -1))
      this.bindHold(plus, () => this.step(field, +1))
    })
  }

  stepBtn(label, kind) {
    const b = document.createElement("button")
    b.type = "button" // never submit the form
    b.className = `pdp-stepper__btn pdp-stepper__btn--${kind}`
    b.tabIndex = -1
    b.setAttribute("aria-hidden", "true")
    b.textContent = label
    return b
  }

  // press-and-hold repeats after a short delay
  bindHold(btn, fn) {
    let delay, rep
    const stop = () => { clearTimeout(delay); clearInterval(rep) }
    ;(this._holdStops = this._holdStops || []).push(stop)
    btn.addEventListener("pointerdown", (e) => {
      e.preventDefault()
      fn()
      delay = setTimeout(() => { rep = setInterval(fn, 80) }, 380)
    })
    for (const ev of ["pointerup", "pointerleave", "pointercancel"]) btn.addEventListener(ev, stop)
  }

  stepSize(field) {
    if (field.dataset.step) return Number(field.dataset.step)
    const byName = { num_of_shelves: 1, shelf_load: 10, hight: 50, widthS: 50, depth: 50 }
    if (field.name in byName) return byName[field.name]
    const max = Number(field.dataset.max)
    return Number.isFinite(max) && max <= 20 ? 1 : 10
  }

  // The rack-viewer on the same page declares the dimensions it draws when the
  // form is empty (data-rack-viewer-defaults-value = {"h","w","d","n"}).
  viewerDefault(field) {
    const el = document.querySelector("[data-rack-viewer-defaults-value]")
    if (!el) return null
    try {
      const d = JSON.parse(el.dataset.rackViewerDefaultsValue || "{}")
      const key = { hight: "h", widthS: "w", depth: "d", num_of_shelves: "n" }[field.name]
      const v = key ? Number(d[key]) : NaN
      return Number.isFinite(v) ? v : null
    } catch (_) {
      return null
    }
  }

  step(field, dir) {
    const size = this.stepSize(field)
    const min = this.resolveLimit(field, "min")
    const max = this.resolveLimit(field, "max")
    const cur = parseInt(String(field.value).replace(/[^\d]/g, ""), 10)
    let next
    if (Number.isFinite(cur)) {
      next = cur + dir * size
    } else {
      // empty field: the live 3D is currently drawing the viewer's default
      // rack, so step from THAT value (not from the minimum) to avoid a jump
      const def = this.viewerDefault(field)
      next = def !== null ? def + dir * size : (min !== null ? min : Math.max(0, dir * size))
    }
    if (min !== null) next = Math.max(min, next)
    if (max !== null) next = Math.min(max, next)
    if (String(next) === String(field.value).trim()) return
    field.value = String(next)
    field.dispatchEvent(new Event("input", { bubbles: true }))
    field.dispatchEvent(new Event("change", { bubbles: true }))
  }

  // --- client-side validation on submit ----------------------------------
  validate(event) {
    for (const field of this.fieldTargets) {
      const label = field.dataset.label || field.name || "поле"
      const raw = field.value.trim()

      if (raw === "") {
        return this.reject(event, `Пожалуйста заполните поле '${label}'.`, field)
      }

      const value = Number(raw)
      if (Number.isNaN(value)) {
        return this.reject(event, `Поле '${label}' должно быть числом.`, field)
      }

      const max = this.resolveLimit(field, "max")
      if (max !== null && value > max) {
        return this.reject(event, `Значение поля '${label}' не должно быть больше ${max}.`, field)
      }

      const min = this.resolveLimit(field, "min")
      if (min !== null && value < min) {
        return this.reject(event, `Значение поля '${label}' не должно быть меньше ${min}.`, field)
      }
    }
  }

  reject(event, message, field) {
    // Block both a plain submit and a Rails UJS / Turbo remote submit:
    // stopImmediatePropagation prevents the event from reaching the
    // document-level handlers that would otherwise fire the request.
    event.preventDefault()
    event.stopImmediatePropagation()
    window.alert(message)
    if (field) field.focus()
  }

  // --- expand / collapse the on-line calculation panel -------------------
  toggle() {
    if (!this.hasPanelTarget) return

    const willShow = getComputedStyle(this.panelTarget).display === "none"
    this.panelTarget.style.display = willShow ? "block" : "none"

    if (this.hasIconTarget) {
      const openSrc = this.iconTarget.dataset.openSrc
      this.iconTarget.src = willShow && openSrc ? openSrc : this.closedIconSrc
    }
  }

  // --- warehouse: disable painted-shelf options when the shelf is ДСП ----
  toggleDsp() {
    const source = this.element.elements["group3"]
    const isDsp = source && source.value === "dsp"

    this.dspOptionTargets.forEach((option, index) => {
      option.disabled = isDsp
      if (isDsp && index === 0) option.checked = true // force "оцинкованная"
    })

    // dimming is done with a class so the styling stays in the stylesheet
    // (the dark redesign theme can't use a hard-coded rgb(0,0,0))
    this.dspRowTargets.forEach((row) => {
      row.classList.toggle("is-off", isDsp)
    })
  }

  // --- helpers -----------------------------------------------------------
  // Reads `data-<kind>` (min/max) from a field, honouring an optional
  // conditional map keyed by another input's current value.
  resolveLimit(field, kind) {
    const mapJson = field.dataset[`${kind}Map`]
    const sourceName = field.dataset[`${kind}Source`]

    if (mapJson && sourceName) {
      const source = this.element.elements[sourceName]
      const key = source ? source.value : null
      try {
        const map = JSON.parse(mapJson)
        if (key !== null && key in map) return Number(map[key])
      } catch (_) {
        // malformed map – fall back to the plain limit below
      }
    }

    const direct = field.dataset[kind]
    return direct !== undefined && direct !== "" ? Number(direct) : null
  }
}

