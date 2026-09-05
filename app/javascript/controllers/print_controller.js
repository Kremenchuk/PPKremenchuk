import { Controller } from "@hotwired/stimulus"

// Prints the calculation result block.
//
// Markup contract:
//   <button data-controller="print"
//           data-action="click->print#run"
//           data-print-name-value="Стелаж 2000 x 1000 x 400">🖨</button>
//
// The document title is swapped for the product name while the print dialog
// is open, so the page header / suggested PDF file name carries the name of
// the calculated product instead of the generic site title. Everything that
// must not appear on paper is hidden by print.scss (#no_print etc.).
export default class extends Controller {
  static values = { name: String }

  run(event) {
    if (event) event.preventDefault()

    const originalTitle = document.title
    if (this.nameValue) document.title = this.nameValue

    const restore = () => {
      document.title = originalTitle
      window.removeEventListener("afterprint", restore)
    }
    window.addEventListener("afterprint", restore)

    window.print()

    // Browsers without a reliable `afterprint` (older WebKit) fall back to a timer.
    setTimeout(restore, 2000)
  }
}
