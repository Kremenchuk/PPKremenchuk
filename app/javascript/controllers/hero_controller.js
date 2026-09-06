import { Controller } from "@hotwired/stimulus"
import { loadThree } from "../lib/three_loader"

// Scroll-morph hero.
//
// One metal rack stays as the constant anchor while the world around it flows
// through four contexts as the visitor scrolls (finger or mouse):
//
//   0  Warehouse   — galvanized rack, cardboard cargo, cold industrial light
//   1  Library     — warm reading room, shelves full of books
//   2  Production  — workshop, spare parts, pipes and a gear on the shelves
//   3  Designer    — a warm home piece with a vase of flowers, books, statuettes
//
// The rack finish, the props on the shelves, the lighting and the background all
// cross-fade continuously, so the scenes melt one into the next. Everything is
// procedural three.js geometry — no external model files.
//
// Markup contract (see welcome/index.html.haml):
//   section.scrollstage[data-controller="hero"]
//     > tall scroller (drives progress)
//       > sticky viewport
//           canvas[data-hero-target="canvas"]
//           .scrollstage__cap[data-hero-target="cap" data-scene="0..3"]
//           .scrollstage__dot[data-hero-target="dot" data-scene="0..3"]

const clamp = (v, a, b) => Math.min(b, Math.max(a, v))
const lerp = (a, b, t) => a + (b - a) * t
const smooth = (t) => t * t * (3 - 2 * t)

// ---- per-scene palette -------------------------------------------------
// finish: rack material; bgTop/bgBottom: CSS backdrop gradient; fog: depth tint;
// key/rim/ambient: light colours; camera: [x,y,z] view offset.
const SCENES = [
  { // 0 warehouse
    finish: { color: 0xb9bec7, metalness: 0.92, roughness: 0.34, wood: 0 },
    bgTop: [26, 32, 42], bgBottom: [11, 14, 20], fog: [20, 26, 36],
    key: 0xdfe8ff, keyI: 2.2, rim: 0x5b78ff, rimI: 1.1, amb: 0x243044, ambI: 0.7,
    camera: [0.2, 0.9, 8.6],
  },
  { // 1 library
    finish: { color: 0x6a4a33, metalness: 0.15, roughness: 0.55, wood: 0.6 },
    bgTop: [58, 40, 26], bgBottom: [22, 15, 12], fog: [40, 28, 20],
    key: 0xffdca8, keyI: 2.3, rim: 0xffb15a, rimI: 1.0, amb: 0x3a2a1c, ambI: 0.9,
    camera: [-0.5, 0.7, 8.2],
  },
  { // 2 production
    finish: { color: 0xff6a1a, metalness: 0.55, roughness: 0.42, wood: 0 },
    bgTop: [30, 34, 40], bgBottom: [14, 15, 18], fog: [26, 28, 34],
    key: 0xffffff, keyI: 2.4, rim: 0xff7a2a, rimI: 1.3, amb: 0x2a2d33, ambI: 0.75,
    camera: [0.5, 0.8, 8.4],
  },
  { // 3 designer home
    finish: { color: 0x8a5a2b, metalness: 0.08, roughness: 0.62, wood: 1 },
    bgTop: [244, 232, 218], bgBottom: [214, 196, 178], fog: [230, 218, 205],
    key: 0xfff0dc, keyI: 2.0, rim: 0xffd0a0, rimI: 0.7, amb: 0xe8dccb, ambI: 1.15,
    camera: [-0.2, 0.6, 8.0],
  },
]

export default class extends Controller {
  static targets = ["canvas", "cap", "dot"]

  connect() {
    this.reduceMotion = matchMedia("(prefers-reduced-motion: reduce)").matches
    this.progress = 0
    this.target = 0
    this.yaw = 0
    this.yawTarget = 0
    this.dragging = false
    this.visible = true
    this.ready = false

    this.onScroll = () => this.measure()
    this.onResize = () => this.resize()
    window.addEventListener("scroll", this.onScroll, { passive: true })
    window.addEventListener("resize", this.onResize)

    this.io = new IntersectionObserver(
      ([e]) => { this.visible = e.isIntersecting },
      { threshold: 0 }
    )
    this.io.observe(this.element)

    loadThree()
      .then((THREE) => this.init(THREE))
      .catch(() => this.element.classList.add("scrollstage--fallback"))
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
    window.removeEventListener("resize", this.onResize)
    if (this.io) this.io.disconnect()
    if (this.raf) cancelAnimationFrame(this.raf)
    if (this.renderer) {
      this.renderer.dispose()
      this.renderer.forceContextLoss?.()
    }
  }

  // ---- setup ----------------------------------------------------------
  init(THREE) {
    this.THREE = THREE
    const canvas = this.canvasTarget

    const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true })
    renderer.setClearColor(0x000000, 0)
    renderer.setPixelRatio(Math.min(devicePixelRatio, 2))
    renderer.shadowMap.enabled = true
    renderer.shadowMap.type = THREE.PCFSoftShadowMap
    renderer.outputColorSpace = THREE.SRGBColorSpace
    this.renderer = renderer

    const scene = new THREE.Scene()
    scene.fog = new THREE.Fog(0x1a2230, 9, 22)
    this.scene = scene

    const camera = new THREE.PerspectiveCamera(38, 1, 0.1, 100)
    camera.position.set(0.2, 0.9, 8.6)
    this.camera = camera

    // procedural environment for believable metal reflections
    this.applyEnvironment(THREE, scene, renderer)

    // lights
    this.key = new THREE.DirectionalLight(0xffffff, 2.2)
    this.key.position.set(5, 8, 6)
    this.key.castShadow = true
    this.key.shadow.mapSize.set(1024, 1024)
    this.key.shadow.camera.near = 1
    this.key.shadow.camera.far = 30
    this.key.shadow.camera.left = -6
    this.key.shadow.camera.right = 6
    this.key.shadow.camera.top = 6
    this.key.shadow.camera.bottom = -6
    this.key.shadow.bias = -0.0004
    scene.add(this.key)

    this.rim = new THREE.DirectionalLight(0x5b78ff, 1.1)
    this.rim.position.set(-6, 4, -4)
    scene.add(this.rim)

    this.amb = new THREE.HemisphereLight(0x8899bb, 0x141118, 0.9)
    scene.add(this.amb)

    // world root (spins) + rack
    this.world = new THREE.Group()
    scene.add(this.world)

    this.rackMat = new THREE.MeshStandardMaterial({ color: 0xb9bec7, metalness: 0.9, roughness: 0.34 })
    this.woodMat = new THREE.MeshStandardMaterial({ color: 0x8a5a2b, metalness: 0.05, roughness: 0.6 })
    this.rack = this.buildRack(THREE)
    this.world.add(this.rack)

    // shadow catcher
    const ground = new THREE.Mesh(
      new THREE.PlaneGeometry(40, 40),
      new THREE.ShadowMaterial({ opacity: 0.28 })
    )
    ground.rotation.x = -Math.PI / 2
    ground.position.y = this.floorY
    ground.receiveShadow = true
    this.world.add(ground)

    // scene prop groups on the shelves
    this.props = [
      this.buildWarehouse(THREE),
      this.buildLibrary(THREE),
      this.buildProduction(THREE),
      this.buildDesigner(THREE),
    ]
    this.props.forEach((g) => this.rack.add(g))

    // pointer drag to spin (mouse only — touch is reserved for scrolling the morph)
    canvas.addEventListener("pointerdown", this.onDown = (e) => {
      if (e.pointerType && e.pointerType !== "mouse") return
      this.dragging = true; this.lastX = e.clientX; canvas.setPointerCapture(e.pointerId)
    })
    canvas.addEventListener("pointermove", this.onMove = (e) => {
      if (!this.dragging) return
      this.yawTarget += (e.clientX - this.lastX) * 0.006
      this.lastX = e.clientX
    })
    const up = () => { this.dragging = false }
    canvas.addEventListener("pointerup", up)
    canvas.addEventListener("pointercancel", up)

    this.ready = true
    this.resize()
    this.measure()
    this.last = performance.now()
    this.loop()
  }

  applyEnvironment(THREE, scene, renderer) {
    // equirectangular gradient -> PMREM -> scene.environment
    const c = document.createElement("canvas")
    c.width = 16; c.height = 128
    const ctx = c.getContext("2d")
    const g = ctx.createLinearGradient(0, 0, 0, 128)
    g.addColorStop(0.0, "#dfe6f2")
    g.addColorStop(0.45, "#8b93a6")
    g.addColorStop(0.5, "#5b6274")
    g.addColorStop(1.0, "#20242c")
    ctx.fillStyle = g; ctx.fillRect(0, 0, 16, 128)
    const tex = new THREE.CanvasTexture(c)
    tex.mapping = THREE.EquirectangularReflectionMapping
    tex.colorSpace = THREE.SRGBColorSpace
    const pmrem = new THREE.PMREMGenerator(renderer)
    scene.environment = pmrem.fromEquirectangular(tex).texture
    tex.dispose(); pmrem.dispose()
  }

  // ---- rack ------------------------------------------------------------
  buildRack(THREE) {
    const g = new THREE.Group()
    const W = 2.6, D = 1.15, H = 3.3
    const post = 0.075
    this.rackDims = { W, D, H }
    this.floorY = -H / 2

    const postGeo = new THREE.BoxGeometry(post, H, post)
    const px = W / 2 - post / 2
    const pz = D / 2 - post / 2
    for (const sx of [-1, 1]) for (const sz of [-1, 1]) {
      const m = new THREE.Mesh(postGeo, this.rackMat)
      m.position.set(sx * px, 0, sz * pz)
      m.castShadow = m.receiveShadow = true
      g.add(m)
      // feet
      const foot = new THREE.Mesh(new THREE.BoxGeometry(post * 2.4, 0.06, post * 2.4), this.rackMat)
      foot.position.set(sx * px, -H / 2 + 0.03, sz * pz)
      foot.castShadow = true
      g.add(foot)
    }

    // shelves
    this.shelfY = []
    const N = 5
    const top = H / 2 - 0.12
    const bottom = -H / 2 + 0.18
    for (let i = 0; i < N; i++) {
      const y = lerp(bottom, top, i / (N - 1))
      this.shelfY.push(y)
      const shelf = new THREE.Mesh(new THREE.BoxGeometry(W - post, 0.05, D - post), this.rackMat)
      shelf.position.set(0, y, 0)
      shelf.castShadow = shelf.receiveShadow = true
      g.add(shelf)
      // front/back beams for a truer rack look
      for (const sz of [-1, 1]) {
        const beam = new THREE.Mesh(new THREE.BoxGeometry(W - post, 0.09, 0.05), this.rackMat)
        beam.position.set(0, y - 0.02, sz * (D / 2 - post / 2))
        beam.castShadow = true
        g.add(beam)
      }
    }

    // (no back cross-brace — removed per request)

    this.shelfSpan = { W: W - post * 3, D: D - post * 3 }
    return g
  }

  // ---- prop helpers ----------------------------------------------------
  box(THREE, w, h, d, color, rough = 0.8, metal = 0) {
    const m = new THREE.Mesh(
      new THREE.BoxGeometry(w, h, d),
      new THREE.MeshStandardMaterial({ color, roughness: rough, metalness: metal, transparent: true, opacity: 0 })
    )
    m.castShadow = true
    return m
  }
  cyl(THREE, rt, rb, h, color, rough = 0.6, metal = 0.2, seg = 16) {
    const m = new THREE.Mesh(
      new THREE.CylinderGeometry(rt, rb, h, seg),
      new THREE.MeshStandardMaterial({ color, roughness: rough, metalness: metal, transparent: true, opacity: 0 })
    )
    m.castShadow = true
    return m
  }
  ball(THREE, r, color, rough = 0.5, metal = 0) {
    const m = new THREE.Mesh(
      new THREE.SphereGeometry(r, 20, 16),
      new THREE.MeshStandardMaterial({ color, roughness: rough, metalness: metal, transparent: true, opacity: 0 })
    )
    m.castShadow = true
    return m
  }
  onShelf(i) { return this.shelfY[i] + 0.025 } // top surface of shelf i

  // ---- scene 0: warehouse ---------------------------------------------
  buildWarehouse(THREE) {
    const g = new THREE.Group()
    const spanW = this.shelfSpan.W, spanD = this.shelfSpan.D
    const tans = [0xc79a68, 0xb0864f, 0xcaa774, 0x9c7644, 0xd8b483]
    const pallet = (x, y) => {
      const top = this.box(THREE, 0.64, 0.03, spanD * 0.92, 0x9c7038, 0.85)
      top.position.set(x, y + 0.045, 0); g.add(top)
      for (const bx of [-1, 0, 1]) {
        const blk = this.box(THREE, 0.09, 0.05, spanD * 0.92, 0x7a5628, 0.85)
        blk.position.set(x + bx * 0.25, y + 0.02, 0); g.add(blk)
      }
    }
    for (let i = 0; i < this.shelfY.length; i++) {
      const y = this.onShelf(i)
      for (const side of [-1, 1]) {
        const cx = side * spanW * 0.24
        pallet(cx, y)
        let by = y + 0.06
        const stack = 2 + Math.floor(Math.random() * 2)
        for (let s = 0; s < stack; s++) {
          const w = 0.5 + Math.random() * 0.14
          const h = 0.2 + Math.random() * 0.12
          const d = spanD * (0.72 + Math.random() * 0.18)
          const b = this.box(THREE, w, h, d, tans[(i + s + (side > 0 ? 1 : 0)) % tans.length], 0.92)
          b.position.set(cx + (Math.random() - 0.5) * 0.05, by + h / 2, 0)
          b.rotation.y = (Math.random() - 0.5) * 0.12
          g.add(b)
          const strap = this.box(THREE, w * 0.1, h + 0.004, d + 0.004, 0x6f5326, 0.9)
          strap.position.copy(b.position); g.add(strap)
          by += h
        }
      }
      // a blue crate tucked at the back on alternating shelves
      if (i % 2 === 0) {
        const crate = this.box(THREE, 0.4, 0.26, spanD * 0.5, 0x2f6ea5, 0.6, 0.1)
        crate.position.set(0, y + 0.13, -spanD * 0.14); g.add(crate)
      }
    }
    return g
  }

  // ---- scene 1: library -----------------------------------------------
  buildLibrary(THREE) {
    const g = new THREE.Group()
    const spanW = this.shelfSpan.W, spanD = this.shelfSpan.D
    const spines = [0x8c3b2f, 0x2f5d50, 0x334a7a, 0x7a6a2f, 0x633b6e, 0x2f6b7a, 0xa8763a, 0x455a64, 0x9c4a3a, 0x3a6a4a]
    for (let i = 0; i < this.shelfY.length; i++) {
      const y = this.onShelf(i)
      const gapX = -spanW / 2 + spanW * (0.28 + Math.random() * 0.4) // leave a gap for objects
      let x = -spanW / 2 + 0.04
      while (x < spanW / 2 - 0.06) {
        if (Math.abs(x - gapX) < 0.16) { x = gapX + 0.16; continue } // skip the gap
        const t = 0.026 + Math.random() * 0.03
        const h = 0.4 + Math.random() * 0.18
        const b = this.box(THREE, t, h, spanD * 0.55, spines[(Math.random() * spines.length) | 0], 0.85)
        b.position.set(x + t / 2, y + h / 2, 0)
        b.rotation.z = Math.random() < 0.14 ? (Math.random() - 0.5) * 0.28 : 0
        g.add(b)
        x += t + 0.004
      }
      // horizontal stack of books in the gap
      const stackN = 3 + (i % 2)
      for (let s = 0; s < stackN; s++) {
        const b = this.box(THREE, 0.3, 0.032, spanD * 0.5, spines[(i + s) % spines.length], 0.85)
        b.position.set(gapX, y + 0.02 + s * 0.034, 0.01)
        b.rotation.y = (Math.random() - 0.5) * 0.06
        g.add(b)
      }
      // a small object resting on the stack
      if (i % 2) {
        const mug = this.cyl(THREE, 0.05, 0.045, 0.09, 0x2f6b7a, 0.5, 0, 16)
        mug.position.set(gapX, y + 0.02 + stackN * 0.034 + 0.05, 0.01); g.add(mug)
      } else {
        const box = this.box(THREE, 0.12, 0.08, 0.12, 0xb5643a, 0.6)
        box.position.set(gapX, y + 0.02 + stackN * 0.034 + 0.045, 0.01); g.add(box)
      }
    }
    // globe + a leaning picture frame
    const mid = Math.floor(this.shelfY.length / 2)
    const globe = this.ball(THREE, 0.13, 0x3a6a8c, 0.5)
    globe.position.set(-spanW / 2 + 0.2, this.onShelf(mid) + 0.15, 0); g.add(globe)
    const frame = this.box(THREE, 0.02, 0.22, 0.3, 0x8a6a3a, 0.6)
    frame.position.set(spanW / 2 - 0.16, this.onShelf(this.shelfY.length - 1) + 0.13, -spanD * 0.08)
    frame.rotation.y = -0.22; g.add(frame)
    return g
  }

  // ---- scene 2: production --------------------------------------------
  buildProduction(THREE) {
    const g = new THREE.Group()
    const spanW = this.shelfSpan.W, spanD = this.shelfSpan.D
    const steel = 0x9aa3ad
    const binCols = [0x3a6ea5, 0xb5442f, 0xd0a53a, 0x4a8a5a]
    for (let i = 0; i < this.shelfY.length; i++) {
      const y = this.onShelf(i)
      // a row of small parts bins at the front-left
      for (let bI = 0; bI < 3; bI++) {
        const bin = this.box(THREE, 0.3, 0.2, spanD * 0.42, binCols[(i + bI) % binCols.length], 0.6, 0.2)
        bin.position.set(-spanW / 2 + 0.24 + bI * 0.34, y + 0.1, spanD * 0.2); g.add(bin)
      }
      // pipes/rods stacked on the right
      for (let p = 0; p < 4; p++) {
        const pipe = this.cyl(THREE, 0.045, 0.045, spanW * 0.42, steel, 0.4, 0.85, 12)
        pipe.rotation.z = Math.PI / 2
        pipe.position.set(0.28, y + 0.05 + (p % 2 ? 0.05 : 0), -spanD * 0.22 + Math.floor(p / 2) * 0.11 + (p % 2 ? 0.055 : 0))
        g.add(pipe)
      }
      // a few scattered bolts
      for (let bo = 0; bo < 4; bo++) {
        const bolt = this.cyl(THREE, 0.02, 0.02, 0.06, 0x6a7079, 0.5, 0.8, 8)
        bolt.rotation.z = Math.PI / 2
        bolt.position.set(-spanW / 2 + 0.2 + Math.random() * 0.5, y + 0.03, -spanD * 0.12 + Math.random() * 0.2)
        g.add(bolt)
      }
    }
    // a spinning gear on the middle shelf
    const mid = Math.floor(this.shelfY.length / 2)
    const gear = new THREE.Group()
    gear.add(this.cyl(THREE, 0.15, 0.15, 0.06, 0x8a9199, 0.4, 0.85, 24))
    for (let t = 0; t < 12; t++) {
      const tooth = this.box(THREE, 0.045, 0.06, 0.045, 0x8a9199, 0.4, 0.85)
      const a = (t / 12) * Math.PI * 2
      tooth.position.set(Math.cos(a) * 0.18, 0, Math.sin(a) * 0.18)
      tooth.rotation.y = a; gear.add(tooth)
    }
    gear.rotation.x = Math.PI / 2
    gear.position.set(spanW / 2 - 0.34, this.onShelf(mid) + 0.17, 0)
    gear.userData.spin = true
    this.gear = gear
    g.add(gear)
    // a red toolbox with a handle on the bottom shelf
    const tb = this.box(THREE, 0.4, 0.16, spanD * 0.5, 0xb5442f, 0.5, 0.2)
    tb.position.set(-spanW / 2 + 0.34, this.onShelf(0) + 0.09, 0); g.add(tb)
    const handle = this.cyl(THREE, 0.012, 0.012, 0.24, 0x2a2d33, 0.5, 0.6, 8)
    handle.rotation.z = Math.PI / 2
    handle.position.set(-spanW / 2 + 0.34, this.onShelf(0) + 0.2, 0); g.add(handle)
    return g
  }

  // ---- scene 3: designer home -----------------------------------------
  buildDesigner(THREE) {
    const g = new THREE.Group()
    const spanW = this.shelfSpan.W
    const top = this.shelfY.length - 1

    // vase with flowers (upper shelf)
    const vase = this.cyl(THREE, 0.1, 0.13, 0.32, 0xdad2c4, 0.25, 0.0, 20)
    vase.position.set(-spanW / 2 + 0.26, this.onShelf(top - 1) + 0.16, 0)
    g.add(vase)
    const bloomColors = [0xe86a7c, 0xf4a63a, 0xe4c04a, 0xd85a8a, 0xf07f4f]
    for (let f = 0; f < 6; f++) {
      const stem = this.cyl(THREE, 0.006, 0.006, 0.34, 0x4f7a3a, 0.8, 0, 6)
      const a = (f / 6) * Math.PI * 2
      const dx = Math.cos(a) * 0.06, dz = Math.sin(a) * 0.06
      stem.position.set(vase.position.x + dx, vase.position.y + 0.26, dz)
      stem.rotation.z = -dx * 1.2
      stem.rotation.x = dz * 1.2
      g.add(stem)
      const bloom = this.ball(THREE, 0.05, bloomColors[f % bloomColors.length], 0.6)
      bloom.position.set(vase.position.x + dx * 1.9, vase.position.y + 0.42, dz * 1.9)
      g.add(bloom)
    }

    // stack of coffee-table books lying flat (middle)
    const mid = Math.floor(this.shelfY.length / 2)
    const bookCols = [0x2f5d50, 0xb5643a, 0xe4cfa8, 0x35485f]
    for (let s = 0; s < 4; s++) {
      const b = this.box(THREE, 0.42, 0.04, 0.3, bookCols[s % bookCols.length], 0.7)
      b.position.set(spanW / 2 - 0.32, this.onShelf(mid) + 0.02 + s * 0.043, 0)
      b.rotation.y = (Math.random() - 0.5) * 0.1
      g.add(b)
    }
    // a few standing books beside them
    for (let s = 0; s < 4; s++) {
      const t = 0.035
      const h = 0.34
      const b = this.box(THREE, t, h, 0.26, bookCols[(s + 1) % bookCols.length], 0.7)
      b.position.set(spanW / 2 - 0.6 - s * (t + 0.006), this.onShelf(mid) + h / 2, 0)
      g.add(b)
    }

    // two statuettes (abstract)
    const s1 = new THREE.Group() // bust: sphere on tapered base
    const base1 = this.cyl(THREE, 0.06, 0.1, 0.16, 0xcbb8a0, 0.3, 0.1, 18)
    const head1 = this.ball(THREE, 0.1, 0xd8cdbd, 0.35)
    head1.position.y = 0.17
    s1.add(base1); s1.add(head1)
    s1.position.set(-spanW / 2 + 0.28, this.onShelf(mid) + 0.08, 0)
    g.add(s1)

    const s2 = new THREE.Group() // figure: stacked cone + torus-ish
    const body2 = this.cyl(THREE, 0.02, 0.11, 0.3, 0xb98a4a, 0.4, 0.2, 20)
    const head2 = this.ball(THREE, 0.06, 0xb98a4a, 0.4)
    head2.position.y = 0.2
    s2.add(body2); s2.add(head2)
    s2.position.set(spanW / 2 - 0.28, this.onShelf(top - 1) + 0.15, 0)
    g.add(s2)

    // small potted plant (bottom)
    const pot = this.cyl(THREE, 0.11, 0.09, 0.14, 0xb5643a, 0.6, 0, 16)
    pot.position.set(0, this.onShelf(0) + 0.07, 0)
    g.add(pot)
    for (let l = 0; l < 5; l++) {
      const leaf = this.ball(THREE, 0.09, 0x4f7a3a, 0.7)
      const a = (l / 5) * Math.PI * 2
      leaf.position.set(pot.position.x + Math.cos(a) * 0.08, pot.position.y + 0.16 + Math.random() * 0.06, Math.sin(a) * 0.08)
      leaf.scale.set(1, 1.5, 0.6)
      g.add(leaf)
    }

    // ── extra décor for a lived-in look ──
    // a leaning framed picture on the top shelf
    const frame = this.box(THREE, 0.02, 0.26, 0.36, 0x2a2d33, 0.5)
    frame.position.set(spanW / 2 - 0.16, this.onShelf(top) + 0.15, -0.06)
    frame.rotation.y = -0.24; g.add(frame)
    const art = this.box(THREE, 0.006, 0.2, 0.28, 0x7a9e8e, 0.6)
    art.position.copy(frame.position); art.rotation.y = frame.rotation.y
    art.position.x += 0.014; g.add(art)
    // a shallow decorative bowl with a sphere on the top shelf
    const bowl = this.cyl(THREE, 0.12, 0.05, 0.06, 0x3a4a52, 0.4, 0.1, 20)
    bowl.position.set(-spanW / 2 + 0.62, this.onShelf(top) + 0.05, 0.02); g.add(bowl)
    const orb = this.ball(THREE, 0.06, 0xcaa15a, 0.35, 0.2)
    orb.position.set(-spanW / 2 + 0.62, this.onShelf(top) + 0.1, 0.02); g.add(orb)
    // a candle
    const candle = this.cyl(THREE, 0.035, 0.04, 0.14, 0xece3d2, 0.6, 0, 16)
    candle.position.set(spanW / 2 - 0.5, this.onShelf(mid) + 0.09, 0.05); g.add(candle)
    const flame = this.ball(THREE, 0.014, 0xffb347, 0.3)
    flame.position.set(spanW / 2 - 0.5, this.onShelf(mid) + 0.17, 0.05); flame.scale.set(1, 1.6, 1); g.add(flame)
    // a second small trailing plant on an upper shelf
    const pot2 = this.cyl(THREE, 0.07, 0.06, 0.09, 0xd8cdbd, 0.6, 0, 14)
    pot2.position.set(0.1, this.onShelf(top) + 0.05, 0.04); g.add(pot2)
    for (let l = 0; l < 4; l++) {
      const leaf = this.ball(THREE, 0.06, 0x5f8a4a, 0.7)
      const a = (l / 4) * Math.PI * 2
      leaf.position.set(0.1 + Math.cos(a) * 0.06, this.onShelf(top) + 0.12, 0.04 + Math.sin(a) * 0.05)
      leaf.scale.set(1, 1.4, 0.6); g.add(leaf)
    }
    return g
  }

  // ---- scroll + resize -------------------------------------------------
  measure() {
    const rect = this.element.getBoundingClientRect()
    const total = this.element.offsetHeight - window.innerHeight
    const scrolled = clamp(-rect.top, 0, total)
    this.target = total > 0 ? scrolled / total : 0
  }

  resize() {
    if (!this.ready) return
    const r = this.canvasTarget.getBoundingClientRect()
    this.renderer.setSize(r.width, r.height, false)
    this.camera.aspect = r.width / Math.max(1, r.height)
    this.camera.updateProjectionMatrix()
  }

  // ---- weights ---------------------------------------------------------
  weights(p) {
    const n = SCENES.length
    const seg = clamp(p, 0, 1) * (n - 1)
    const i = clamp(Math.floor(seg), 0, n - 2)
    const f = seg - i
    const w = [0, 0, 0, 0]
    w[i] = 1 - f
    w[i + 1] = f
    return w
  }

  // ---- render loop -----------------------------------------------------
  loop() {
    this.raf = requestAnimationFrame(() => this.loop())
    const now = performance.now()
    const dt = Math.min(0.05, (now - this.last) / 1000)
    this.last = now
    if (!this.visible || document.hidden) return

    // ease progress + yaw
    this.progress = lerp(this.progress, this.target, 1 - Math.pow(0.001, dt))
    if (!this.reduceMotion) this.yawTarget += dt * 0.12
    this.yaw = lerp(this.yaw, this.yawTarget, 1 - Math.pow(0.0001, dt))
    this.world.rotation.y = this.yaw

    const w = this.weights(this.progress)
    this.applyBlend(w)
    this.updateUI(w)

    if (this.gear && !this.reduceMotion) this.gear.rotation.z += dt * 0.6 * w[2]

    this.renderer.render(this.scene, this.camera)
  }

  applyBlend(w) {
    const THREE = this.THREE
    // rack finish
    let r = 0, g = 0, b = 0, metal = 0, rough = 0, wood = 0
    const cam = [0, 0, 0]
    const key = new THREE.Color(0, 0, 0), rim = new THREE.Color(0, 0, 0), amb = new THREE.Color(0, 0, 0)
    let keyI = 0, rimI = 0, ambI = 0
    const bgT = [0, 0, 0], bgB = [0, 0, 0], fog = [0, 0, 0]
    for (let s = 0; s < SCENES.length; s++) {
      const S = SCENES[s], k = w[s]
      if (k <= 0) continue
      const c = new THREE.Color(S.finish.color)
      r += c.r * k; g += c.g * k; b += c.b * k
      metal += S.finish.metalness * k; rough += S.finish.roughness * k; wood += S.finish.wood * k
      cam[0] += S.camera[0] * k; cam[1] += S.camera[1] * k; cam[2] += S.camera[2] * k
      key.add(new THREE.Color(S.key).multiplyScalar(k)); keyI += S.keyI * k
      rim.add(new THREE.Color(S.rim).multiplyScalar(k)); rimI += S.rimI * k
      amb.add(new THREE.Color(S.amb).multiplyScalar(k)); ambI += S.ambI * k
      for (let j = 0; j < 3; j++) { bgT[j] += S.bgTop[j] * k; bgB[j] += S.bgBottom[j] * k; fog[j] += S.fog[j] * k }
    }
    this.rackMat.color.setRGB(r, g, b)
    this.rackMat.metalness = metal
    this.rackMat.roughness = rough

    this.camera.position.lerp(new THREE.Vector3(cam[0], cam[1], cam[2]), 0.12)
    this.camera.lookAt(0, 0.1, 0)

    this.key.color.copy(key); this.key.intensity = keyI
    this.rim.color.copy(rim); this.rim.intensity = rimI
    this.amb.color.copy(amb); this.amb.intensity = ambI
    this.scene.fog.color.setRGB(fog[0] / 255, fog[1] / 255, fog[2] / 255)

    // css backdrop gradient
    const top = `rgb(${bgT.map((v) => Math.round(v)).join(",")})`
    const bot = `rgb(${bgB.map((v) => Math.round(v)).join(",")})`
    this.element.style.setProperty("--stage-top", top)
    this.element.style.setProperty("--stage-bottom", bot)

    // props cross-fade
    for (let s = 0; s < this.props.length; s++) {
      const k = w[s]
      const grp = this.props[s]
      grp.visible = k > 0.002
      if (!grp.visible) continue
      const o = smooth(k)
      const sc = lerp(0.86, 1, o)
      grp.scale.setScalar(sc)
      grp.position.y = lerp(0.12, 0, o)
      grp.traverse((m) => { if (m.material) m.material.opacity = o })
    }
  }

  updateUI(w) {
    if (this.hasCapTarget) {
      this.capTargets.forEach((el) => {
        const s = Number(el.dataset.scene)
        el.style.opacity = smooth(w[s] || 0)
      })
    }
    if (this.hasDotTarget) {
      const active = w.indexOf(Math.max(...w))
      this.dotTargets.forEach((el) => {
        el.classList.toggle("is-active", Number(el.dataset.scene) === active)
      })
    }
  }
}
