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

