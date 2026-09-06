import { Controller } from "@hotwired/stimulus"

// Prints the current calculation.
//
// Browsers take the default file name of the "Save as PDF" dialog from
// document.title, which is the site-wide title here. This controller swaps
// the title for the name of the product being printed and restores it once
// the print dialog is done, so the saved file is called e.g.
// "Стелаж архівний 2000 x 500 x 400 5п. Оцинкований.pdf".
//
// Markup contract:
//   <button data-controller="print"
//           data-action="click->print#run"
//           data-print-name-value="Стелаж архівний 2000 x 500 x 400 5п.">
export default class extends Controller {
  static values = { name: String }

  run(event) {
    if (event) event.preventDefault()

    const wanted = this.hasNameValue ? this.nameValue.trim() : ""
    if (!wanted) return window.print()

    const original = document.title
    const restore = () => {
      document.title = original
      window.removeEventListener("afterprint", restore)
    }

    document.title = wanted
    window.addEventListener("afterprint", restore)
    // afterprint is not reliable in every browser — restore anyway
    setTimeout(restore, 10000)

    window.print()
  }
}
