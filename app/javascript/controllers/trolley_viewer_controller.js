import { Controller } from "@hotwired/stimulus"
import { loadThree } from "../lib/three_loader"
import { makeRackScene } from "../lib/rack_scene"

// Live 3D of the trolley model the visitor is configuring — the trolley
// counterpart of rack_viewer for the rack calculators.
//
// It sits inside each model card's collapsible calculator panel, reads the
// card's own form (lengthT / widthS / hight_ruch in mm) and redraws the
// trolley the moment a field changes. Mouse drag spins it; touch scrolls the
// page (canvas keeps touch-action: pan-y).
//
// There are 15 cards and every panel starts collapsed, so the WebGL context
// is created lazily when the stage actually becomes visible and released
// (with a fresh canvas) when it hides — the page never holds more than the
// open cards' contexts.
//
//   data-trolley-viewer-model-value   TP-01 … PT-04 → build recipe below

const clamp = (v, a, b) => Math.min(b, Math.max(a, v))
const lerp = (a, b, t) => a + (b - a) * t

// Per-model recipe, lifted from TrolleyController#show:
//   TP  priceTP(kol_shelf, deck, _, kol_ruchek)  → shelves (incl. bottom), deck, handles
//   KS  priceKS(set_long, set_shot, …)           → mesh panels on the long / short sides
//   PT  pricePT(nw, deck, _, setka)              → deck, mesh back behind the handle
const MODELS = {
  "TP-01": { kind: "tp", shelves: 2, deck: "dsp", handles: 1 },
  "TP-02": { kind: "tp", shelves: 3, deck: "dsp", handles: 1 },
  "TP-03": { kind: "tp", shelves: 4, deck: "dsp", handles: 1 },
  "TP-04": { kind: "tp", shelves: 2, deck: "dsp", handles: 2 },
  "TP-05": { kind: "tp", shelves: 3, deck: "dsp", handles: 2 },
  "TP-06": { kind: "tp", shelves: 3, deck: "met", handles: 1 },
  "TP-07": { kind: "tp", shelves: 2, deck: "met", handles: 1 },
  "KS-01": { kind: "ks", meshLong: 2, meshShort: 2, deck: "met" },
  "KS-02": { kind: "ks", meshLong: 0, meshShort: 2, deck: "met" },
  "KS-03": { kind: "ks", meshLong: 1, meshShort: 2, deck: "met" },
  "KS-04": { kind: "ks", meshLong: 2, meshShort: 2, deck: "met", doors: true },
  "PT-01": { kind: "pt", deck: "met", meshBack: true },
  "PT-02": { kind: "pt", deck: "met", meshBack: false },
  "PT-03": { kind: "pt", deck: "dsp", meshBack: false },
  "PT-04": { kind: "pt", deck: "dsp", meshBack: true },
}

export default class extends Controller {
  static targets = ["canvas"]
  static values = { model: { type: String, default: "TP-01" } }

  connect() {
    this.reduceMotion = matchMedia("(prefers-reduced-motion: reduce)").matches
    this.yaw = 0.7
    this.yawTarget = 0.7
    this.visible = false
    this.form = this.element.closest("form")

    // lazy WebGL: build when the (collapsed-by-default) stage is shown, drop
    // the context when it is hidden again
    this.io = new IntersectionObserver(([e]) => {
      this.visible = e.isIntersecting
      if (e.isIntersecting) this.ensureInit()
      else this.teardown()
    }, { threshold: 0 })
    this.io.observe(this.element)

    if (this.form) {
      this.onInput = () => this.scheduleRebuild()
      this.form.addEventListener("input", this.onInput)
      this.form.addEventListener("change", this.onInput)
    }
  }

  disconnect() {
    if (this.io) this.io.disconnect()
    if (this.form && this.onInput) {
      this.form.removeEventListener("input", this.onInput)
      this.form.removeEventListener("change", this.onInput)
    }
    clearTimeout(this._t)
    this.teardown()
  }

  ensureInit() {
    if (this.renderer || this.initing) return
    this.initing = true
    loadThree()
      .then((THREE) => { this.initing = false; if (this.visible && !this.renderer) this.init(THREE) })
      .catch(() => { this.initing = false; this.element.classList.add("pdp-stage--fallback") })
  }

  teardown() {
    if (this.raf) { cancelAnimationFrame(this.raf); this.raf = null }
    if (this.ro) { this.ro.disconnect(); this.ro = null }
    if (!this.renderer) return
    this.renderer.dispose()
    this.renderer.forceContextLoss?.()
    this.renderer = null
    this.scene = null
    this.trolley = null
    this.lastKey = null
    // a lost context stays attached to its canvas — swap in a fresh one so the
    // next init gets a working context
    const old = this.canvasTarget
    old.replaceWith(old.cloneNode(false))
  }

  // ---- setup ----------------------------------------------------------
  init(THREE) {
    this.THREE = THREE
    const canvas = this.canvasTarget
    const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true })
    renderer.setClearColor(0x000000, 0) // transparent: the .pdp-stage CSS paints the theme background
    renderer.setPixelRatio(Math.min(devicePixelRatio, 2))
    renderer.shadowMap.enabled = true
    renderer.shadowMap.type = THREE.PCFSoftShadowMap
    this.renderer = renderer

    const scene = new THREE.Scene()
    this.scene = scene
    const { envMap, materials } = makeRackScene(THREE, renderer)
    scene.environment = envMap
    this.materials = materials
    this.rubber = new THREE.MeshStandardMaterial({ color: 0x232327, roughness: 0.92, metalness: 0.05 })
    this.hub = new THREE.MeshStandardMaterial({ color: 0x9aa1aa, roughness: 0.4, metalness: 0.7, envMap })

    this.camera = new THREE.PerspectiveCamera(35, 1, 0.05, 100)

    const key = new THREE.DirectionalLight(0xffffff, 2.4)
    key.position.set(4, 6, 5)
    key.castShadow = true
    key.shadow.mapSize.set(1024, 1024)
    key.shadow.camera.near = 0.5; key.shadow.camera.far = 30
    key.shadow.camera.left = -4; key.shadow.camera.right = 4
    key.shadow.camera.top = 4; key.shadow.camera.bottom = -4
    key.shadow.bias = -0.0004
    scene.add(key)
    const fill = new THREE.DirectionalLight(0xbcd0ff, 0.7)
    fill.position.set(-5, 3, -3)
    scene.add(fill)
    scene.add(new THREE.HemisphereLight(0xaebacc, 0x20242c, 0.8))

    this.turntable = new THREE.Group()
    scene.add(this.turntable)

    const ground = new THREE.Mesh(new THREE.PlaneGeometry(30, 30), new THREE.ShadowMaterial({ opacity: 0.24 }))
    ground.rotation.x = -Math.PI / 2
    ground.position.y = 0.001
    ground.receiveShadow = true
    scene.add(ground)

    // mouse drag to spin; touch is left to page scrolling
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

    this.ro = new ResizeObserver(() => this.resize())
    this.ro.observe(canvas)

    this.rebuild()
    this.resize()
    this.last = performance.now()
    this.loop()
  }

  // ---- read the form --------------------------------------------------
  fieldNum(name, fallback) {
    if (!this.form) return fallback
    const el = this.form.elements[name]
    if (!el) return fallback
    const v = parseInt(String(el.value).replace(/[^\d]/g, ""), 10)
    return Number.isFinite(v) && v > 0 ? v : fallback
  }

  config() {
    const spec = MODELS[this.modelValue] || MODELS["TP-01"]
    const L = clamp(this.fieldNum("lengthT", 1000), 300, 2500) / 1000   // platform length
    const W = clamp(this.fieldNum("widthS", 600), 300, 1600) / 1000     // platform width
    const H = clamp(this.fieldNum("hight_ruch", 900), 400, 1600) / 1000 // handle height from the floor
    return { ...spec, L, W, H, Lmm: Math.round(L * 1000), Wmm: Math.round(W * 1000), Hmm: Math.round(H * 1000) }
  }

  // ---- build ----------------------------------------------------------
  scheduleRebuild() {
    clearTimeout(this._t)
    this._t = setTimeout(() => this.rebuild(), 90)
  }

  rebuild() {
    if (!this.renderer) return
    const THREE = this.THREE
    const c = this.config()
    const key = JSON.stringify(c)
    if (this.lastKey === key) return
    this.lastKey = key

    if (this.trolley) {
      this.turntable.remove(this.trolley)
      this.trolley.traverse((m) => {
        if (m.geometry) m.geometry.dispose()
        if (m.isSprite && m.material) { m.material.map?.dispose(); m.material.dispose() }
      })
    }
    this.trolley = this.buildTrolley(THREE, c)
    this.turntable.add(this.trolley)
    this.frameCamera(c)
  }

  // Length runs along X, width along Z, the floor is y = 0. The handle end is +X.
  buildTrolley(THREE, c) {
    const g = new THREE.Group()
    const M = this.materials
    const frame = M.bluePaint                      // RAL5005 powder coat, like the real ones
    const deckMat = c.deck === "dsp" ? M.wood : M.steelDeck
    const { L, W, H } = c
    const tube = 0.025                             // 25×25 square tube
    const angle = 0.02                             // 20×20 angle for shelf rims
    const hr = 0.0125                              // Ø25 handle tube
    const wheelR = 0.075, wheelT = 0.04
    const platY = wheelR * 2 + 0.03                // top of the platform frame

    const box = (w, h, d, x, y, z, mat, rot) => {
      const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), mat)
      m.position.set(x, y, z)
      if (rot) { m.rotation.x = rot.x || 0; m.rotation.y = rot.y || 0; m.rotation.z = rot.z || 0 }
      m.castShadow = true; m.receiveShadow = true
      g.add(m)
      return m
    }
    const rod = (r, len, x, y, z, axis) => {           // cylinder along axis 'x' | 'y' | 'z'
      const m = new THREE.Mesh(new THREE.CylinderGeometry(r, r, len, 14), frame)
      m.position.set(x, y, z)
      if (axis === "x") m.rotation.z = Math.PI / 2
      if (axis === "z") m.rotation.x = Math.PI / 2
      m.castShadow = true
      g.add(m)
      return m
    }
    // welded-mesh panel (Сітка 50×50): a grid of thin bars in a vertical plane.
    // alongX → panel plane is X–Y at z = cz; otherwise Z–Y at x = cx.
    const meshPanel = (cx, cy, cz, spanU, spanH, alongX) => {
      const bar = 0.006, pitch = 0.05
      const nU = Math.max(2, Math.round(spanU / pitch)), nH = Math.max(2, Math.round(spanH / pitch))
      for (let i = 0; i <= nU; i++) {
        const u = -spanU / 2 + (spanU * i) / nU
        alongX ? box(bar, spanH, bar, cx + u, cy, cz, frame) : box(bar, spanH, bar, cx, cy, cz + u, frame)
      }
      for (let j = 0; j <= nH; j++) {
        const v = -spanH / 2 + (spanH * j) / nH
        alongX ? box(spanU, bar, bar, cx, cy + v, cz, frame) : box(bar, bar, spanU, cx, cy + v, cz, frame)
      }
    }
    // a shelf = angle rim + deck panel at height y
    const shelf = (y) => {
      for (const sz of [-1, 1]) box(L - tube, angle, angle, 0, y - angle / 2, sz * (W / 2 - tube / 2 - angle / 2), frame)
      for (const sx of [-1, 1]) box(angle, angle, W - tube, sx * (L / 2 - tube / 2 - angle / 2), y - angle / 2, 0, frame)
      box(L - tube * 2, 0.016, W - tube * 2, 0, y + 0.006, 0, deckMat)
    }
    // U-shaped push handle at end sx (+1 / −1), from y0 up to the grip at H
    const handle = (sx, y0) => {
      const hx = sx * (L / 2 - 0.03)
      for (const sz of [-1, 1]) rod(hr, H - y0, hx, (H + y0) / 2, sz * (W / 2 - 0.05), "y")
      rod(hr, W - 0.1 + hr * 2, hx, H, 0, "z")
    }

    // ── castors: 4 swivel wheels under the platform corners ─────────────
    for (const sx of [-1, 1]) for (const sz of [-1, 1]) {
      const wx = sx * (L / 2 - 0.12), wz = sz * (W / 2 - 0.07)
      const wheel = new THREE.Mesh(new THREE.CylinderGeometry(wheelR, wheelR, wheelT, 24), this.rubber)
      wheel.rotation.x = Math.PI / 2
      wheel.position.set(wx, wheelR, wz)
      wheel.castShadow = true
      g.add(wheel)
      const hub = new THREE.Mesh(new THREE.CylinderGeometry(wheelR * 0.42, wheelR * 0.42, wheelT + 0.006, 16), this.hub)
      hub.rotation.x = Math.PI / 2
      hub.position.copy(wheel.position)
      g.add(hub)
      box(0.045, platY - wheelR - 0.02, 0.03, wx, (platY + wheelR) / 2, wz, frame) // fork/bracket
      box(0.07, 0.01, 0.07, wx, platY - 0.02, wz, frame)                            // mounting plate
    }

    // ── platform frame (square tube rectangle) + bottom deck ────────────
    for (const sz of [-1, 1]) box(L, tube, tube, 0, platY - tube / 2, sz * (W / 2 - tube / 2), frame)
    for (const sx of [-1, 1]) box(tube, tube, W - tube * 2, sx * (L / 2 - tube / 2), platY - tube / 2, 0, frame)
    shelf(platY + tube / 2)

    if (c.kind === "tp") {
      // shelf trolley: corner posts carry N decks (the bottom one is the platform)
      const topY = H - 0.14
      const N = Math.max(2, c.shelves)
      for (const sx of [-1, 1]) for (const sz of [-1, 1])
        box(tube, topY - platY, tube, sx * (L / 2 - tube / 2), (topY + platY) / 2, sz * (W / 2 - tube / 2), frame)
      for (let k = 1; k < N; k++) shelf(lerp(platY + tube / 2, topY, k / (N - 1)))
      handle(1, topY)
      if (c.handles > 1) handle(-1, topY)
    } else if (c.kind === "ks") {
      // cage trolley: posts up to the cage top, welded-mesh walls, one push handle
      const cageTop = H - 0.06
      const cageH = cageTop - platY
      for (const sx of [-1, 1]) for (const sz of [-1, 1])
        box(tube, cageH, tube, sx * (L / 2 - tube / 2), platY + cageH / 2, sz * (W / 2 - tube / 2), frame)
      // top rail
      for (const sz of [-1, 1]) box(L, tube, tube, 0, cageTop - tube / 2, sz * (W / 2 - tube / 2), frame)
      for (const sx of [-1, 1]) box(tube, tube, W - tube * 2, sx * (L / 2 - tube / 2), cageTop - tube / 2, 0, frame)
      const wallH = cageH - tube * 2, wallY = platY + tube + wallH / 2
      // short sides (both) and long sides (0 / 1 / 2)
      for (let i = 0; i < c.meshShort; i++) {
        const sx = i === 0 ? -1 : 1
        meshPanel(sx * (L / 2 - tube / 2), wallY, 0, W - tube * 2, wallH, false)
      }
      for (let i = 0; i < c.meshLong; i++) {
        const sz = i === 0 ? -1 : 1
        meshPanel(0, wallY, sz * (W / 2 - tube / 2), L - tube * 2, wallH, true)
        if (c.doors && i === c.meshLong - 1) {
          // door split: a centre post and a mid rail on the door side
          box(tube, wallH, tube, 0, wallY, sz * (W / 2 - tube / 2), frame)
          box(L - tube * 2, tube, tube, 0, wallY, sz * (W / 2 - tube / 2), frame)
        }
      }
      handle(1, cageTop)
    } else {
      // platform trolley: flat deck; handle at one end, optionally with a mesh back
      handle(1, platY)
      if (c.meshBack) {
        const backH = H - 0.1 - platY
        meshPanel(L / 2 - 0.03, platY + backH / 2, 0, W - 0.1, backH, false)
      }
    }

    // ── dimension annotations (L × W × H in mm) — rotate with the trolley ──
    if (!this.dimMat) this.dimMat = new THREE.MeshBasicMaterial({ color: 0xff7a2a })
    const dim = (w, h, d, x, y, z) => { const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), this.dimMat); m.position.set(x, y, z); g.add(m) }
    const ox = 0.14, oz = 0.14
    // length: in front (+Z), on the floor
    dim(L, 0.008, 0.008, 0, 0.02, W / 2 + oz)
    dim(0.008, 0.06, 0.008, -L / 2, 0.02, W / 2 + oz)
    dim(0.008, 0.06, 0.008, L / 2, 0.02, W / 2 + oz)
    g.add(this.placeLabel(`${c.Lmm} мм`, 0, 0.02, W / 2 + oz + 0.02, "center"))
    // width: at the non-handle end (−X), on the floor
    dim(0.008, 0.008, W, -L / 2 - ox, 0.02, 0)
    dim(0.008, 0.06, 0.008, -L / 2 - ox, 0.02, -W / 2)
    dim(0.008, 0.06, 0.008, -L / 2 - ox, 0.02, W / 2)
    g.add(this.placeLabel(`${c.Wmm} мм`, -L / 2 - ox - 0.02, 0.02, 0, "right"))
    // handle height: vertical at the handle end (+X)
    dim(0.008, H, 0.008, L / 2 + ox, H / 2, W / 2 + 0.02)
    dim(0.06, 0.008, 0.008, L / 2 + ox, 0, W / 2 + 0.02)
    dim(0.06, 0.008, 0.008, L / 2 + ox, H, W / 2 + 0.02)
    g.add(this.placeLabel(`${c.Hmm} мм`, L / 2 + ox + 0.02, H / 2, W / 2 + 0.02, "left"))

    return g
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
    const unit = 0.11
    const worldW = unit * (w / h)
    sp.scale.set(worldW, unit, 1)
    const dx = align === "right" ? -worldW / 2 : align === "left" ? worldW / 2 : 0
    sp.position.set(x + dx, y, z)
    sp.renderOrder = 999
    return sp
  }

  frameCamera(c) {
    const reach = Math.max(c.L * 1.15, c.W * 1.3, c.H + 0.35)
    const dist = reach * 1.85 + 0.45
    this.camera.position.set(dist * 0.66, c.H * 0.55 + 0.3, dist * 0.74)
    this.camera.lookAt(0, c.H * 0.42, 0)
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
    if (!this.renderer) return
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
