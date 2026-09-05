// Loads three.js (UMD global build) from a CDN exactly once and resolves with
// the global THREE. Kept out of the webpack bundle on purpose: three is ~600 KB
// and only a couple of pages (the hero and the product calculators) need it, so
// we pull it lazily instead of inflating application.js for every visitor.

const THREE_VERSION = "0.160.0"
const THREE_URL = `https://cdn.jsdelivr.net/npm/three@${THREE_VERSION}/build/three.min.js`

let promise = null

export function loadThree() {
  if (window.THREE) return Promise.resolve(window.THREE)
  if (promise) return promise

  promise = new Promise((resolve, reject) => {
    const existing = document.querySelector(`script[data-three="${THREE_VERSION}"]`)
    if (existing) {
      existing.addEventListener("load", () => resolve(window.THREE))
      existing.addEventListener("error", reject)
      return
    }
    const s = document.createElement("script")
    s.src = THREE_URL
    s.async = true
    s.dataset.three = THREE_VERSION
    s.addEventListener("load", () => resolve(window.THREE))
    s.addEventListener("error", () => reject(new Error("failed to load three.js")))
    document.head.appendChild(s)
  })
  return promise
}
