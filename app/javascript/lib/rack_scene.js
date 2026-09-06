// Procedural materials, textures and environment for the product 3D viewers.
// Everything is generated in-canvas so there are no image assets to ship and
// the metals still get believable reflections from a small PMREM environment.

// ---- canvas texture helpers -------------------------------------------
function noiseCanvas(size, base, spread) {
  const c = document.createElement("canvas")
  c.width = c.height = size
  const ctx = c.getContext("2d")
  const img = ctx.createImageData(size, size)
  for (let i = 0; i < img.data.length; i += 4) {
    const v = base + (Math.random() - 0.5) * spread
    img.data[i] = img.data[i + 1] = img.data[i + 2] = Math.max(0, Math.min(255, v))
    img.data[i + 3] = 255
  }
  ctx.putImageData(img, 0, 0)
  return c
}

function galvanizedCanvas() {
  const c = document.createElement("canvas")
  c.width = c.height = 256
  const ctx = c.getContext("2d")
  ctx.fillStyle = "#c2c8cf"
  ctx.fillRect(0, 0, 256, 256)
  // spangle: irregular crystalline flakes typical of hot-dip galvanising
  for (let i = 0; i < 900; i++) {
    const x = Math.random() * 256, y = Math.random() * 256, r = 4 + Math.random() * 14
    const l = 150 + Math.random() * 90
    ctx.fillStyle = `rgba(${l},${l + 4},${l + 10},${0.15 + Math.random() * 0.25})`
    ctx.beginPath()
    ctx.moveTo(x, y)
    for (let s = 0; s < 5; s++) {
      const a = (s / 5) * Math.PI * 2
      ctx.lineTo(x + Math.cos(a) * r * (0.6 + Math.random() * 0.6), y + Math.sin(a) * r * (0.6 + Math.random() * 0.6))
    }
    ctx.closePath()
    ctx.fill()
  }
  return c
}

function woodCanvas() {
  const c = document.createElement("canvas")
  c.width = 256; c.height = 256
  const ctx = c.getContext("2d")
  const g = ctx.createLinearGradient(0, 0, 0, 256)
  g.addColorStop(0, "#9c6a38"); g.addColorStop(0.5, "#8a5a2b"); g.addColorStop(1, "#7a4d24")
  ctx.fillStyle = g; ctx.fillRect(0, 0, 256, 256)
  for (let i = 0; i < 60; i++) {
    const y = Math.random() * 256
    ctx.strokeStyle = `rgba(60,36,16,${0.05 + Math.random() * 0.12})`
    ctx.lineWidth = 0.5 + Math.random() * 1.6
    ctx.beginPath()
    ctx.moveTo(0, y)
    for (let x = 0; x <= 256; x += 16) ctx.lineTo(x, y + Math.sin(x * 0.05 + i) * 2.4)
    ctx.stroke()
  }
  return c
}

export function makeRackScene(THREE, renderer) {
  renderer.outputColorSpace = THREE.SRGBColorSpace

  // --- environment (equirect gradient -> PMREM) for metal reflections ---
  const ec = document.createElement("canvas")
  ec.width = 16; ec.height = 128
  const ectx = ec.getContext("2d")
  const eg = ectx.createLinearGradient(0, 0, 0, 128)
  eg.addColorStop(0.0, "#ffffff")
  eg.addColorStop(0.42, "#c7ccd6")
  eg.addColorStop(0.5, "#9aa1ad")
  eg.addColorStop(1.0, "#3a3f47")
  ectx.fillStyle = eg; ectx.fillRect(0, 0, 16, 128)
  const etex = new THREE.CanvasTexture(ec)
  etex.mapping = THREE.EquirectangularReflectionMapping
  etex.colorSpace = THREE.SRGBColorSpace
  const pmrem = new THREE.PMREMGenerator(renderer)
  const envMap = pmrem.fromEquirectangular(etex).texture
  etex.dispose(); pmrem.dispose()

  // --- shared maps ---
  const galv = new THREE.CanvasTexture(galvanizedCanvas())
  const roughN = new THREE.CanvasTexture(noiseCanvas(128, 150, 60))
  const wood = new THREE.CanvasTexture(woodCanvas())
  for (const t of [galv, roughN, wood]) {
    t.wrapS = t.wrapT = THREE.RepeatWrapping
    t.colorSpace = THREE.SRGBColorSpace
  }
  wood.colorSpace = THREE.SRGBColorSpace

  const materials = {
    galvanized: new THREE.MeshStandardMaterial({
      color: 0xe6eaf0, metalness: 0.66, roughness: 0.34,
      map: galv, roughnessMap: roughN, envMap, envMapIntensity: 1.55,
    }),
    painted: new THREE.MeshStandardMaterial({
      color: 0xff6a1a, metalness: 0.35, roughness: 0.44,
      roughnessMap: roughN, envMap, envMapIntensity: 0.9,
    }),
    steelDeck: new THREE.MeshStandardMaterial({
      color: 0xc2c8d0, metalness: 0.62, roughness: 0.44,
      map: galv, roughnessMap: roughN, envMap, envMapIntensity: 1.3,
    }),
    // RAL5005 powder coat — the blue frame of the trolleys
    bluePaint: new THREE.MeshStandardMaterial({
      color: 0x1f4f9e, metalness: 0.4, roughness: 0.45,
      roughnessMap: roughN, envMap, envMapIntensity: 0.9,
    }),
    wood: new THREE.MeshStandardMaterial({
      color: 0xffffff, metalness: 0.0, roughness: 0.62,
      map: wood, envMap, envMapIntensity: 0.4,
    }),
  }

  return { envMap, materials }
}
