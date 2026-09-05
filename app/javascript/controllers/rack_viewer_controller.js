import { Controller } from "@hotwired/stimulus"
import { loadThree } from "../lib/three_loader"
import { makeRackScene } from "../lib/rack_scene"

// Live 3D of the rack the visitor is configuring.
//
// It reads the calculator's own form fields, builds a parametric rack from the
// millimetre dimensions and re-draws it the moment any field changes, so the
// product is "drawn immediately" and turns slowly on a turntable. Mouse drag
// spins it; touch is left to page scrolling.
//
// Configure via data attributes on the controller element (all optional):
//   data-rack-viewer-form-value       id of the form to read (default contact_form)
//   data-rack-viewer-type-value       arxiv | warehouse | pallet   (proportions/props)
//   data-rack-viewer-height-value     input name for height   (default hight)
//   data-rack-viewer-width-value      input name for width    (default widthS)
//   data-rack-viewer-depth-value      input name for depth    (default depth; "" = fixed)
//   data-rack-viewer-shelves-value    input name for shelves  (default num_of_shelves)
//   data-rack-viewer-shelftype-value  radio group name -> metall|dsp
//   data-rack-viewer-finish-value     radio group name -> galvanised|painted
//   data-rack-viewer-defaults-value   JSON {h,w,d,n} used when the form is empty

const clamp = (v, a, b) => Math.min(b, Math.max(a, v))
const lerp = (a, b, t) => a + (b - a) * t

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    form: { type: String, default: "contact_form" },
    type: { type: String, default: "arxiv" },
    height: { type: String, default: "hight" },
    width: { type: String, default: "widthS" },
    depth: { type: String, default: "depth" },
    shelves: { type: String, default: "num_of_shelves" },
    shelftype: { type: String, default: "" },
    finish: { type: String, default: "" },
    defaults: { type: Object, default: {} },
  }

  connect() {
    this.reduceMotion = matchMedia("(prefers-reduced-motion: reduce)").matches
    this.yaw = 0.6
    this.yawTarget = 0.6
    this.visible = true
    this.form = document.getElementById(this.formValue)

    this.io = new IntersectionObserver(([e]) => { this.visible = e.isIntersecting }, { threshold: 0 })
    this.io.observe(this.element)

    loadThree()
      .then((THREE) => this.init(THREE))
      .catch(() => this.element.classList.add("pdp-stage--fallback"))
  }

  disconnect() {
    if (this.io) this.io.disconnect()
    if (this.ro) this.ro.disconnect()
    if (this.raf) cancelAnimationFrame(this.raf)
    if (this.form && this.onInput) {
      this.form.removeEventListener("input", this.onInput)
      this.form.removeEventListener("change", this.onInput)
    }
    if (this.renderer) { this.renderer.dispose(); this.renderer.forceContextLoss?.() }
  }

  init(THREE) {
    this.THREE = THREE
    const canvas = this.canvasTarget
    const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true })
    renderer.setClearColor(0x000000, 0)
    renderer.setPixelRatio(Math.min(devicePixelRatio, 2))
    renderer.shadowMap.enabled = true
    renderer.shadowMap.type = THREE.PCFSoftShadowMap
    this.renderer = renderer

    const scene = new THREE.Scene()
    this.scene = scene
    const { envMap, materials } = makeRackScene(THREE, renderer)
    scene.environment = envMap
    this.materials = materials

    this.camera = new THREE.PerspectiveCamera(35, 1, 0.05, 100)

    const key = new THREE.DirectionalLight(0xffffff, 2.4)
    key.position.set(4, 7, 5)
    key.castShadow = true
    key.shadow.mapSize.set(1024, 1024)
    key.shadow.camera.near = 0.5; key.shadow.camera.far = 40
    key.shadow.camera.left = -5; key.shadow.camera.right = 5
    key.shadow.camera.top = 6; key.shadow.camera.bottom = -6
    key.shadow.bias = -0.0004
    scene.add(key)
    const fill = new THREE.DirectionalLight(0xbcd0ff, 0.7)
    fill.position.set(-5, 3, -3)
    scene.add(fill)
    scene.add(new THREE.HemisphereLight(0xaebacc, 0x20242c, 0.8))

    this.turntable = new THREE.Group()
    scene.add(this.turntable)

    this.ground = new THREE.Mesh(
      new THREE.PlaneGeometry(40, 40),
      new THREE.ShadowMaterial({ opacity: 0.24 })
    )
    this.ground.rotation.x = -Math.PI / 2
    this.ground.receiveShadow = true
    scene.add(this.ground)

    // mouse drag to spin
    canvas.addEventListener("pointerdown", (e) => {
      if (e.pointerType && e.pointerType !== "mouse") return
      this.drag = true; this.lastX = e.clientX; canvas.setPointerCapture(e.pointerId)
    })
    canvas.addEventListener("pointermove", (e) => {
      if (!this.drag) return
      this.yawTarget += (e.clientX - this.lastX) * 0.007; this.lastX = e.clientX
    })
    const up = () => { this.drag = false }
    canvas.addEventListener("pointerup", up)
    canvas.addEventListener("pointercancel", up)

    // rebuild on form changes
    if (this.form) {
      this.onInput = () => this.scheduleRebuild()
      this.form.addEventListener("input", this.onInput)
      this.form.addEventListener("change", this.onInput)
    }

    this.ro = new ResizeObserver(() => this.resize())
    this.ro.observe(canvas)

    this.rebuild()
    this.resize()
    this.last = performance.now()
    this.loop()
  }

  // ---- read the form --------------------------------------------------
  fieldNum(name, fallback) {
    if (!this.form || !name) return fallback
    const el = this.form.elements[name]
    if (!el) return fallback
    const v = parseInt(String(el.value).replace(/[^\d]/g, ""), 10)
    return Number.isFinite(v) && v > 0 ? v : fallback
  }
  radioVal(name) {
    if (!this.form || !name) return ""
    const el = this.form.elements[name]
    return el ? String(el.value || "") : ""
  }

  config() {
    const d = this.defaultsValue || {}
    const H = clamp(this.fieldNum(this.heightValue, d.h || 2000), 300, 6500)
    const W = clamp(this.fieldNum(this.widthValue, d.w || 1000), 300, 3600)
    const D = this.depthValue
      ? clamp(this.fieldNum(this.depthValue, d.d || 500), 150, 1600)
      : (d.d || 800)
    const N = clamp(this.fieldNum(this.shelvesValue, d.n || 5), 2, 15)
    const shelf = this.radioVal(this.shelftypeValue).toLowerCase()
    const fin = this.radioVal(this.finishValue).toLowerCase()
    const dsp = shelf.includes("dsp")
    // when the calculator has no finish control (e.g. pallet racks) fall back to
    // the default declared on the element
    const painted = fin ? /okr|paint|farb/.test(fin) : !!d.painted
    return { H, W, D, N, dsp, painted }
  }

  // ---- build ----------------------------------------------------------
  scheduleRebuild() {
    clearTimeout(this._t)
    this._t = setTimeout(() => this.rebuild(), 90)
  }

  rebuild() {
    const THREE = this.THREE
    const c = this.config()
    const same = this.lastKey === JSON.stringify(c)
    if (same) return
    this.lastKey = JSON.stringify(c)

    if (this.rack) {
      this.turntable.remove(this.rack)
      this.rack.traverse((m) => {
        if (m.geometry) m.geometry.dispose()
        if (m.isSprite && m.material) { m.material.map?.dispose(); m.material.dispose() }
      })
    }
    if (!this.dimMat) this.dimMat = new THREE.MeshBasicMaterial({ color: 0xff7a2a })

    const frameMat = c.painted ? this.materials.painted : this.materials.galvanized
    const deckMat = c.dsp ? this.materials.wood : (c.painted ? this.materials.painted : this.materials.steelDeck)

    // units: metres
    const W = c.W / 1000, D = c.D / 1000, H = c.H / 1000
    const type = this.typeValue
    const pallet = type === "pallet"
    const warehouse = type === "warehouse"
    const post = pallet ? 0.1 : warehouse ? 0.07 : 0.05
    const g = new THREE.Group()

    const addBox = (w, h, d, x, y, z, mat, rot) => {
      const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), mat)
      m.position.set(x, y, z)
      if (rot) { m.rotation.x = rot.x || 0; m.rotation.y = rot.y || 0; m.rotation.z = rot.z || 0 }
      m.castShadow = true; m.receiveShadow = true
      g.add(m)
      return m
    }

    const px = W / 2 - post / 2
    const pz = D / 2 - post / 2
    const top = H / 2 - 0.08
    const bottom = -H / 2 + (pallet ? 0.22 : 0.14)
    const levelY = (i) => (c.N === 1 ? top : lerp(bottom, top, i / (c.N - 1)))

    // corner posts + feet
    for (const sx of [-1, 1]) for (const sz of [-1, 1]) {
      addBox(post, H, post, sx * px, 0, sz * pz, frameMat)
      addBox(post * 2.2, 0.05, post * 2.4, sx * px, -H / 2 + 0.025, sz * pz, frameMat)
    }

    if (pallet) {
      // ── real pallet rack: two braced upright frames + horizontal load beams
      // side frame bracing (zig-zag in the depth plane) — NOT a back cross
      for (const sx of [-1, 1]) {
        const rungs = Math.max(3, Math.round(H / 0.9))
        let prev = null
        for (let r = 0; r <= rungs; r++) {
          const y = -H / 2 + (H * r) / rungs
          addBox(post * 0.55, 0.03, D - post, sx * px, y, 0, frameMat) // horizontal rung
          if (prev) {
            const dy = y - prev
            const len = Math.hypot(D - post, dy)
            const b = addBox(post * 0.5, 0.028, len, sx * px, (y + prev) / 2, 0, frameMat,
              { x: (r % 2 ? 1 : -1) * Math.atan2(D - post, dy) })
            b.scale.set(1, 1, 1)
          }
          prev = y
        }
      }
      // load beams front & back at each level (pallets rest on these, no deck)
      const beamH = 0.11
      for (let i = 0; i < c.N; i++) {
        const y = levelY(i)
        for (const sz of [-1, 1]) addBox(W - post, beamH, 0.06, 0, y - beamH / 2, sz * pz, frameMat)
        // a couple of euro pallets sitting on the beams
        const palW = Math.min(1.2, (W - post) / 2 - 0.1)
        for (const side of [-1, 1]) {
          const g2y = y + 0.02
          addBox(palW, 0.06, D - 0.16, side * (W / 4), g2y + 0.06, 0, this.materials.wood) // pallet top
          for (const bx of [-1, 0, 1]) addBox(0.09, 0.06, D - 0.16, side * (W / 4) + bx * palW * 0.42, g2y, 0, this.materials.wood) // blocks
        }
      }
    } else {
      // ── archive (light) / warehouse (medium) shelving: flat decks + edge beams
      const deckT = warehouse ? 0.04 : 0.03
      const beamH = warehouse ? 0.08 : 0.05
      for (let i = 0; i < c.N; i++) {
        const y = levelY(i)
        for (const sz of [-1, 1]) addBox(W - post, beamH, 0.04, 0, y - beamH / 2, sz * pz, frameMat)
        addBox(W - post * 1.4, deckT, D - post * 1.4, 0, y - deckT / 2, 0, deckMat)
        // small back stop lip on archive shelving
        if (!warehouse) addBox(W - post, 0.05, 0.014, 0, y + 0.02, -pz, deckMat)
      }
    }

    // ── dimension annotations (H × W × D in mm), rotate with the rack ──────
    const dim = (w, h, d, x, y, z, rot) => {
      const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), this.dimMat)
      m.position.set(x, y, z); if (rot) m.rotation.z = rot
      g.add(m)
    }
    const zf = D / 2 + 0.02
    const ox = 0.16, oy = 0.16
    // height (left, vertical)
    dim(0.01, H, 0.01, -W / 2 - ox, 0, zf)
    dim(0.07, 0.012, 0.01, -W / 2 - ox, H / 2, zf)
    dim(0.07, 0.012, 0.01, -W / 2 - ox, -H / 2, zf)
    g.add(this.placeLabel(`${c.H} мм`, -W / 2 - ox - 0.02, 0, zf, "right"))
    // width (bottom, horizontal)
    dim(W, 0.01, 0.01, 0, -H / 2 - oy, zf)
    dim(0.012, 0.07, 0.01, -W / 2, -H / 2 - oy, zf)
    dim(0.012, 0.07, 0.01, W / 2, -H / 2 - oy, zf)
    g.add(this.placeLabel(`${c.W} мм`, 0, -H / 2 - oy - 0.02, zf, "center"))
    // depth (right, along Z)
    dim(0.01, 0.01, D, W / 2 + ox, -H / 2, 0)
    dim(0.01, 0.07, 0.012, W / 2 + ox, -H / 2, D / 2)
    dim(0.01, 0.07, 0.012, W / 2 + ox, -H / 2, -D / 2)
    g.add(this.placeLabel(`${Math.round(c.D)} мм`, W / 2 + ox + 0.02, -H / 2, 0, "left"))

    this.rack = g
    this.turntable.add(g)
    this.rackH = H; this.rackW = W; this.rackD = D
    this.ground.position.y = -H / 2 + 0.001
    this.frameCamera()
  }

  // billboard text label (mm dimension) as a camera-facing sprite
  placeLabel(text, x, y, z, align) {
    const THREE = this.THREE
    const fs = 46, pad = 18
    const c = document.createElement("canvas")
    let ctx = c.getContext("2d")
    ctx.font = `700 ${fs}px 'JetBrains Mono', monospace`
    const w = Math.ceil(ctx.measureText(text).width) + pad * 2
    const h = fs + pad * 1.4
    c.width = w; c.height = h
    ctx = c.getContext("2d")
    ctx.font = `700 ${fs}px 'JetBrains Mono', monospace`
    const r = 12
    ctx.fillStyle = "rgba(10,10,12,0.82)"
    ctx.beginPath()
    ctx.moveTo(r, 0); ctx.arcTo(w, 0, w, h, r); ctx.arcTo(w, h, 0, h, r)
    ctx.arcTo(0, h, 0, 0, r); ctx.arcTo(0, 0, w, 0, r); ctx.closePath(); ctx.fill()
    ctx.lineWidth = 3; ctx.strokeStyle = "rgba(255,106,26,0.9)"; ctx.stroke()
    ctx.fillStyle = "#ffb079"; ctx.textAlign = "center"; ctx.textBaseline = "middle"
    ctx.fillText(text, w / 2, h / 2 + 2)

    const tex = new THREE.CanvasTexture(c)
    tex.colorSpace = THREE.SRGBColorSpace
    const mat = new THREE.SpriteMaterial({ map: tex, transparent: true, depthTest: false, depthWrite: false })
    const sp = new THREE.Sprite(mat)
    const unit = 0.17
    const worldW = unit * (w / h)
    sp.scale.set(worldW, unit, 1)
    // nudge so the label sits just outside the tick, not centred on it
    const dx = align === "right" ? -worldW / 2 : align === "left" ? worldW / 2 : 0
    sp.position.set(x + dx, y, z)
    sp.renderOrder = 999
    return sp
  }

  frameCamera() {
    const H = this.rackH, W = this.rackW, D = this.rackD
    const reach = Math.max(H + 0.5, W * 1.15 + 0.6, D + 0.4)
    const dist = reach * 1.75 + 0.7
    this.camDist = dist
    this.camera.position.set(dist * 0.64, H * 0.12, dist * 0.9)
    this.camera.lookAt(0, -H * 0.04, 0)
    this.camera.updateProjectionMatrix()
  }

  resize() {
    if (!this.renderer) return
    const r = this.canvasTarget.getBoundingClientRect()
    if (r.width < 2 || r.height < 2) return
    this.renderer.setSize(r.width, r.height, false)
    this.camera.aspect = r.width / r.height
    this.camera.updateProjectionMatrix()
  }

  loop() {
    this.raf = requestAnimationFrame(() => this.loop())
    const now = performance.now()
    const dt = Math.min(0.05, (now - this.last) / 1000)
    this.last = now
    if (!this.visible || document.hidden) return
    if (!this.reduceMotion && !this.drag) this.yawTarget += dt * 0.35
    this.yaw = lerp(this.yaw, this.yawTarget, 1 - Math.pow(0.001, dt))
    this.turntable.rotation.y = this.yaw
    this.renderer.render(this.scene, this.camera)
  }
}
