'use client'

import { animate, type AnimationPlaybackControls } from 'motion'
import { useEffect, useRef } from 'react'

// ─── 7TV emotes ─────────────────────────────────────────────────────────────
// Curated mix of channel, global, and popular emotes.
// Images load directly from cdn.7tv.app.
const EMOTE_IDS = [
  // ─── xQc channel set ───
  '01FZ975PV8000B4AWRZNMVNEXN', // LOL
  '01GBPSCGR00007Q17796BDN5AJ', // Classic
  '01JP0FG0NN10YJPYVTZN5K67WY', // LO
  '01F6MZGCNG000255K4X1K7NTHR', // GIGACHAD
  '01HTKMB7680004B0MV8TERR9A4', // AURA
  '01F00Z3A9G0007E4VV006YKSK9', // OMEGALUL
  '01HMBMJPV0000D32KQCYBK4S1D', // aga
  '01F71VQYHR000D3ZZ6Q11NR7TV', // WW
  '01FS5ZCFG0000500DPPCXJWCP8', // o7
  '01F7CTADRG000351ERP2WA0ME9', // FLASHBANG
  '01F6T8NM9R0007M5BTFWSP1YSJ', // Clueless
  '01F22WE74G000F9Q0G00A2DE8N', // LULW
  '01F6TCFKM0000CBRZV8MZ7ZGGH', // Deadass
  '01F6MG1HPR0009K1N00D4GG63Z', // ICANT
  '01FHNBZRW8000C3ZWT2Z63JS92', // Sadge
  '01EZTCN91800012PTN006Q50PR', // Pog
  '01FFWH9WV80000JT8GHDKHJNZC', // Aware
  '01F010F9GR0007E4VV006YKSKN', // PepeLaugh
  '01F6MA6Y100002B6P5MWZ5D916', // Hmm
  '01F6NACCD80006SZ7ZW5FMWKWK', // Prayge
  '01FG1NDHJR0001XDR7G9054X2Q', // HUH
  '01GFBTYEV80008P4E5PB4NX0XC', // DIESOFCRINGE
  '01F6MDFCSR0000WDA7ERT623YT', // NODDERS
  '01F6MQ33FG000FFJ97ZB8MWV52', // catJAM
  '01EZY967K0000CYST6006V20T8', // pepeJAM
  '01F6NMMEER00015NVG2J8ZH77N', // peepoHey
  '01H3ZS4R1R0003PH84VNH1WMYC', // Madge
  '01F6MMQCM80009C9ZSNZT3GTK1', // PagChomp
  '01FAJR9X80000136YH153JYZTB', // modCheck
  '01G7RNEB2R00029YRR37CZ24HX', // LockIn
  '01G7YR9X5G0003Z50SB3FM5WR4', // Happi
  '01GBEBQQN00001RAQMJBWFVDXF', // COOKING
  '01JJ0D0C2XWZ640NP4WJKB8MYX', // Cooked
  '01GY1RDSR8000ENJJARE9FMTJR', // SLAY
  '01FBZESCNR000A6AWCB1X558GZ', // Chatting
  '01GF1Y2Q5G0000BGNJSP34TQRD', // widepeepoHappy

  // ─── 7TV global emotes ───
  '01FCY771D800007PQ2DF3GDTN6', // RainTime
  '01FE3XY508000AA32JP519W2EW', // PETPET
  '01GGD5PJA8000FH13S498E9D8X', // ppL
  '01GB2TN09G000AZXHZ8HNEZX6G', // Clap2
  '01GAM8EFQ00004MXFXAJYKA859', // Clap
  '01GAFTZ9K80003DHH026MC7JW0', // PepePls
  '01GAZ199Z8000FEWHS6AT5QZV0', // peepoHappy
  '01GAZ4SBX80007YCE2RXBT44B2', // peepoSad
  '01GB9W8JN80004CKF2H1TWA99H', // FeelsDankMan
  '01GB2S7H7000018VJGJ4A9BMFS', // BillyApprove
  '01GB8EQNJ8000497KFBZWNSDFZ', // forsenPls
  '01GB54CZTG0004ZBZEDT30HE2M', // RoxyPotato
  '01GB4P2HX0000BJ5HR8F6XV9Q0', // gachiBASS
  '01FKSDK14G0008TM5NY9QEG0QV', // PartyParrot
  '01G98W833R0000BRQD106P0ZNT', // WAYTOODANK
  '01GB2ZJFBG000DTBJYANG8XYFP', // AlienDance
  '01GGCQPCGR000C7MT8JZGP6E89', // ApuApustaja
  '01GB9W2CDG000BFSD141G0MGSA', // BasedGod
  '01G98V5RFG0001CD052SPS435F', // GuitarTime
  '01HM524VE80004SKSHMCZWXH1T', // peepoPls
  '01HM4P26CR000449DZBT4FVMA5', // TeaTime
  '01HM4PGHC80007635TAZG67FT5', // WineTime
  '01G98V81Q80000BRQD106P0ZEK', // PianoTime
  '01G98TT6BR000A39K5ZSQFTPWR', // CrayonTime
  '01HM6NJ2X000035ZKVAPWBNW26', // nymnCorn
  '01J107C3E8000DX4MZBQSYGRXS', // sevenTV
  '01FTEZEE900001E12995B12GR4', // nanaAYAYA
  '01J8NMZ2HG0005G1FWF2H9Y615', // BibleThump
  '01H16FA16G0005EZED5J0EY7KN', // glorp
  '01GG3YGWK8000DWE419062SG28', // Stare
  '01F9EM2ETG000E7SC8F953GXCX', // gachiGASM
  '01GB32XE6R00018VJGJ4A9BNCV', // AYAYA
  '01GB4XE3ZR000DKFRGM9Q1M7VS', // RareParrot
  '01GB4FWTR8000DGEZ8VYY59RBN', // FeelsWeirdMan
  '01GB4CK01800090V9B3D8CGEEX', // EZ
  '01GB46137R000BJ5HR8F6XV8J1', // FeelsOkayMan
  '01GB4EV0Q800090V9B3D8CGEHV', // FeelsStrongMan
  '01GBFDVP18000CRDCG0DV7KEMY', // 7Cinema

  // ─── Popular / trending ───
  '01F6MKTFTG0009C9ZSNZTFV2ZF', // NOOOO
  '01F6N31ETR0004P7N4A9PKS5X9', // BOOBA
  '01F6ME7ADR0000WDA7ERT9H30R', // COPIUM
  '01F5VW2TKR0003RCV2Z6JBHCST', // catKISS
  '01F6MXJD8R000F76KNAAV5HDGD', // Bedge
  '01F6BN89H80006VBW12DRB1DJ0', // donowall
  '01F61B1440000991F7SWQNMVX7', // KEKW
  '01F6RD7B88000B4N55W5NS55R7', // LETSGO
  '01F6QV6G8R0000TEKRM6BFG0Z3', // ratJAM
  '01GDDQVMH000038Q48APH8VE3Q', // AINTNOWAY
  '01F6NET6G00009JYTB75QDKV1S', // peepoClap
  '01F6NTA4X80007X1R6PNS21T6E', // peepoGiggles
  '01GBFAYKGR000FWWN7MDZZ8XQN', // RAGEY
  '01F6PPENA80002RDNAW6F35V4X', // YEP
  '01F6NPHCN0000BEKN8ZXWQNSDC', // monkaW
  '01F6NM2T080003C6R1CKK0T0P2', // WICKED
  '01F6MMZW3R00012ZP6HJJ38G2E', // SadgeCry
  '01G4ZTECKR0002P97QQ94BDSP4', // WHAT
  '01F9Q9PA100009VDTF4G64R32V', // Nerdge
  '01FYQZVG280006SX8JX4TD7SJA', // VIBE
  '01GQ3WPTDR000300KQF1J7PFF8', // NOWAYING
  '01H0405680000AJFXTYVX2PNJ7', // uuh
  '01F6NPFQXG000AAS5FM9Q6GVCC', // 5Head
  '01EZY51MDR000CYST6006V20T4', // NOPERS
  '01GN5QQ1X8000C0QTR0C8JV0GR', // LETHIMCOOK
  '01EZTD6KQ800012PTN006Q50PV', // Pepega
  '01F6P0803G000898NRWSAKGYXT', // POGGERS
  '01F2ZWD6CR000DSBG200DM9SGM', // pepeD
  '01GA4TYKW0000EN50T4AGZ0CK8', // lebronJAM
  '01F6M3N17G000B5V5G2M2RYJN7', // PogU
  '01F9DGR2YG000E7SC8F959BREV', // RIPBOZO
  '01F6NCKMP000052X5637DW2XDY', // meow
  '01F6NPEJT0000B70V1XA8MNBC9', // popCat
  '01F7GJ0N4R00074A83FVHRDMDB', // Okayge
  '01EZPJCXQ8000C438200A44F38', // dinkDonk
  '01GM78BAGR0001WBT5AMQY9YG3', // D:
  '01F6Q045KR0005589X3BDQHRAY', // peepoRun
  '01EZPGMA6G00047EF100A1SBTF', // TrollDespair
  '01G9FN8YF000080GCW6BK847N1', // MONKE
  '01F6N2GFVR000F76KNAAVCSDGX', // PauseChamp
  '01F0HMZ1ZG0004V54C00A616CB', // Weirdge
  '01H0SQNM9R0005HNCSM10SYJEQ', // CAUGHT
  '01F6NHAQMR00015NVG2J8J00CX', // Amogus
  '01F8YE5QNR00081476FRV8XDEZ', // Deadge
]

const EMOTE_URLS = EMOTE_IDS.map(
  (id) => `https://cdn.7tv.app/emote/${id}/2x.webp`,
)

// ─── Scaling ────────────────────────────────────────────────────────────────
const MAX_PARTICLES = 100

function computeParticleCount(w: number, h: number): number {
  const diagonal = Math.sqrt(w * w + h * h)
  return Math.max(12, Math.min(MAX_PARTICLES, Math.round(diagonal / 38)))
}

function computeEmoteSize(w: number): number {
  if (w < 480) return 28
  if (w < 768) return 32
  if (w < 1920) return 40
  return 44
}

function computeTargetOpacity(w: number): number {
  // Kept low enough that emotes behind text don't break WCAG AA contrast
  // (4.5:1 body text, 3:1 large text). Center zone avoidance is the main
  // safeguard — emotes rarely overlap text directly.
  if (w < 480) return 0.25
  if (w < 768) return 0.3
  return 0.35
}

function computeRepulseRadius(w: number): number {
  if (w < 480) return 80
  if (w < 768) return 100
  return 130
}

// ─── Physics constants ──────────────────────────────────────────────────────
const INITIAL_SPEED = 0.4
const MIN_SPEED = 0.2
const MAX_SPEED = 2.5
const FRICTION = 0.998
const RESTITUTION = 0.8
const REPULSE_STRENGTH = 1.6
const CENTER_ZONE_X = 0.6
const CENTER_ZONE_Y = 0.5
const CENTER_PUSH = 0.15

// ─── Types ──────────────────────────────────────────────────────────────────
interface ParticleState {
  x: number
  y: number
  vx: number
  vy: number
  rotation: number
  rotationSpeed: number
  halfW: number
  measured: boolean
}

// ─── Helpers ────────────────────────────────────────────────────────────────
function rand(min: number, max: number) {
  return Math.random() * (max - min) + min
}

function shuffle<T>(array: T[]): T[] {
  const a = [...array]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j]!, a[i]!]
  }
  return a
}

function spawnInEdgeZone(
  w: number,
  h: number,
  size: number,
): { x: number; y: number } {
  const half = size / 2
  const zoneRx = (w * CENTER_ZONE_X) / 2
  const zoneRy = (h * CENTER_ZONE_Y) / 2
  let x: number
  let y: number
  do {
    x = rand(half, w - half)
    y = rand(half, h - half)
  } while (((x - w / 2) / zoneRx) ** 2 + ((y - h / 2) / zoneRy) ** 2 < 1)
  return { x, y }
}

function createParticle(w: number, h: number, halfW: number): ParticleState {
  const { x, y } = spawnInEdgeZone(w, h, halfW * 2)
  const angle = rand(0, Math.PI * 2)
  return {
    x,
    y,
    vx: Math.cos(angle) * INITIAL_SPEED,
    vy: Math.sin(angle) * INITIAL_SPEED,
    rotation: rand(-0.3, 0.3),
    rotationSpeed: rand(-0.003, 0.003),
    halfW,
    measured: false,
  }
}

// ─── Component ──────────────────────────────────────────────────────────────
export function EmotePhysicsBackground() {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const container = containerRef.current
    if (container === null) return

    const elements =
      container.querySelectorAll<HTMLImageElement>('[data-emote]')
    if (elements.length === 0) return

    // Assign shuffled URLs client-side to avoid hydration mismatch
    const urls = shuffle(EMOTE_URLS)
    elements.forEach((el, i) => {
      if (i < urls.length) el.src = urls[i]!
    })

    let cancelled = false
    let rafId = 0
    let w = 0
    let h = 0
    let activeCount = 0
    let emoteSize = 40
    let repulseRadius = 130
    let currentPointer: { x: number; y: number } | null = null
    const particles: ParticleState[] = []
    const animations: AnimationPlaybackControls[] = []

    // ── Sync visible particle count to container size ──
    function syncCount(newW: number, newH: number, initial: boolean) {
      const newCount = Math.min(
        computeParticleCount(newW, newH),
        elements.length,
      )
      const newSize = computeEmoteSize(newW)
      repulseRadius = computeRepulseRadius(newW)
      container!.style.opacity = String(computeTargetOpacity(newW))
      emoteSize = newSize
      const halfW = newSize / 2

      for (const p of particles) {
        if (!p.measured) p.halfW = halfW
      }

      if (newCount > activeCount) {
        for (let i = activeCount; i < newCount; i++) {
          const el = elements[i]
          if (el === undefined) break
          if (i >= particles.length) {
            particles.push(createParticle(newW, newH, halfW))
          }
          el.style.display = ''
          el.style.height = `${newSize}px`
          if (initial) {
            animations.push(
              animate(
                el,
                { opacity: 1, filter: ['blur(4px)', 'blur(0px)'] },
                { duration: 0.5, delay: i * 0.06, ease: 'easeOut' },
              ),
            )
          } else {
            el.style.opacity = '1'
            el.style.filter = ''
          }
        }
      } else if (newCount < activeCount) {
        for (let i = newCount; i < activeCount; i++) {
          const el = elements[i]
          if (el !== undefined) {
            el.style.display = 'none'
            el.style.opacity = '0'
          }
        }
      }

      // Update size on already-visible elements
      for (let i = 0; i < Math.min(newCount, activeCount); i++) {
        const el = elements[i]
        if (el !== undefined) el.style.height = `${newSize}px`
      }

      activeCount = newCount
    }

    // Initialize dimensions
    const rect = container.getBoundingClientRect()
    w = rect.width
    h = rect.height
    if (w > 0 && h > 0) syncCount(w, h, true)

    // ── Resize handling ──
    const ro = new ResizeObserver((entries) => {
      const entry = entries[0]
      if (entry === undefined) return
      const { width, height } = entry.contentRect
      if (width > 0 && height > 0) {
        w = width
        h = height
        syncCount(w, h, false)
        const halfH = emoteSize / 2
        for (let i = 0; i < activeCount; i++) {
          const p = particles[i]
          if (p === undefined) continue
          p.x = Math.max(p.halfW, Math.min(p.x, w - p.halfW))
          p.y = Math.max(halfH, Math.min(p.y, h - halfH))
        }
      }
    })
    ro.observe(container)

    // ── Pointer tracking (mouse + touch) ──
    const panel = container.parentElement ?? container
    function updatePointer(clientX: number, clientY: number) {
      const r = container!.getBoundingClientRect()
      currentPointer = { x: clientX - r.left, y: clientY - r.top }
    }
    function clearPointer() {
      currentPointer = null
    }
    function onMouseMove(e: MouseEvent) {
      updatePointer(e.clientX, e.clientY)
    }
    function onTouchMove(e: TouchEvent) {
      const touch = e.touches[0]
      if (touch !== undefined) updatePointer(touch.clientX, touch.clientY)
    }
    panel.addEventListener('mousemove', onMouseMove)
    panel.addEventListener('mouseleave', clearPointer)
    panel.addEventListener('touchmove', onTouchMove, { passive: true })
    panel.addEventListener('touchend', clearPointer)

    // ── Physics loop ──
    function tick() {
      if (cancelled) return

      if (activeCount > 0) {
        const m = currentPointer
        const centerX = w / 2
        const centerY = h / 2
        const zoneRadiusX = (w * CENTER_ZONE_X) / 2
        const zoneRadiusY = (h * CENTER_ZONE_Y) / 2
        const halfH = emoteSize / 2

        // Per-particle forces, friction, speed limits, and integration
        for (let i = 0; i < activeCount; i++) {
          const p = particles[i]
          if (p === undefined) continue

          // Center avoidance — soft elliptical repulsion
          const cdx = p.x - centerX
          const cdy = p.y - centerY
          const normDist = (cdx / zoneRadiusX) ** 2 + (cdy / zoneRadiusY) ** 2
          if (normDist < 1 && normDist > 0.001) {
            const strength = (1 - normDist) * CENTER_PUSH
            const dist = Math.sqrt(cdx * cdx + cdy * cdy) || 1
            p.vx += (cdx / dist) * strength
            p.vy += (cdy / dist) * strength
          }

          // Pointer repulsion
          if (m !== null) {
            const dx = p.x - m.x
            const dy = p.y - m.y
            const distSq = dx * dx + dy * dy
            if (distSq < repulseRadius * repulseRadius && distSq > 0.01) {
              const dist = Math.sqrt(distSq)
              const force =
                ((repulseRadius - dist) / repulseRadius) * REPULSE_STRENGTH
              p.vx += (dx / dist) * force
              p.vy += (dy / dist) * force
            }
          }

          // Friction
          p.vx *= FRICTION
          p.vy *= FRICTION

          // Maintain minimum speed — keeps emotes always drifting
          const speed = Math.sqrt(p.vx * p.vx + p.vy * p.vy)
          if (speed < MIN_SPEED) {
            if (speed > 0.001) {
              const scale = MIN_SPEED / speed
              p.vx *= scale
              p.vy *= scale
            } else {
              const angle = rand(0, Math.PI * 2)
              p.vx = Math.cos(angle) * MIN_SPEED
              p.vy = Math.sin(angle) * MIN_SPEED
            }
          } else if (speed > MAX_SPEED) {
            const ratio = MAX_SPEED / speed
            p.vx *= ratio
            p.vy *= ratio
          }

          // Integrate position
          p.x += p.vx
          p.y += p.vy

          // Lazily measure actual rendered width once image loads
          const el = elements[i]
          if (
            el !== undefined &&
            !p.measured &&
            el.naturalWidth > 0 &&
            el.naturalHeight > 0
          ) {
            p.halfW = ((el.naturalWidth / el.naturalHeight) * emoteSize) / 2
            p.measured = true
          }
        }

        // Particle-particle elastic collision
        for (let i = 0; i < activeCount; i++) {
          const a = particles[i]
          if (a === undefined) continue
          const rA = Math.max(a.halfW, halfH)
          for (let j = i + 1; j < activeCount; j++) {
            const b = particles[j]
            if (b === undefined) continue
            const rB = Math.max(b.halfW, halfH)
            const dx = b.x - a.x
            const dy = b.y - a.y
            const distSq = dx * dx + dy * dy
            const minDist = rA + rB
            if (distSq < minDist * minDist && distSq > 0.01) {
              const dist = Math.sqrt(distSq)
              const nx = dx / dist
              const ny = dy / dist
              // Separate overlapping particles
              const overlap = (minDist - dist) / 2
              a.x -= nx * overlap
              a.y -= ny * overlap
              b.x += nx * overlap
              b.y += ny * overlap
              // Elastic velocity exchange along collision normal
              const dvx = a.vx - b.vx
              const dvy = a.vy - b.vy
              const dvDotN = dvx * nx + dvy * ny
              if (dvDotN > 0) {
                a.vx -= dvDotN * nx * RESTITUTION
                a.vy -= dvDotN * ny * RESTITUTION
                b.vx += dvDotN * nx * RESTITUTION
                b.vy += dvDotN * ny * RESTITUTION
              }
            }
          }
        }

        // Wall bounce and DOM write
        for (let i = 0; i < activeCount; i++) {
          const p = particles[i]
          const el = elements[i]
          if (p === undefined || el === undefined) continue

          if (p.x - p.halfW < 0) {
            p.x = p.halfW
            p.vx = Math.abs(p.vx) * RESTITUTION
          } else if (p.x + p.halfW > w) {
            p.x = w - p.halfW
            p.vx = -Math.abs(p.vx) * RESTITUTION
          }
          if (p.y - halfH < 0) {
            p.y = halfH
            p.vy = Math.abs(p.vy) * RESTITUTION
          } else if (p.y + halfH > h) {
            p.y = h - halfH
            p.vy = -Math.abs(p.vy) * RESTITUTION
          }

          // Rotation
          p.rotation += p.rotationSpeed

          // Write to DOM — only transform, no layout thrash
          el.style.transform = `translate3d(${p.x - p.halfW}px, ${p.y - halfH}px, 0) rotate(${p.rotation}rad)`
        }
      }

      rafId = requestAnimationFrame(tick)
    }

    tick()

    return () => {
      cancelled = true
      cancelAnimationFrame(rafId)
      for (const a of animations) a.stop()
      ro.disconnect()
      panel.removeEventListener('mousemove', onMouseMove)
      panel.removeEventListener('mouseleave', clearPointer)
      panel.removeEventListener('touchmove', onTouchMove)
      panel.removeEventListener('touchend', clearPointer)
    }
  }, [])

  return (
    <div ref={containerRef} className='absolute inset-0 overflow-hidden'>
      {Array.from({ length: MAX_PARTICLES }, (_, i) => (
        // eslint-disable-next-line @next/next/no-img-element -- imperative DOM manipulation requires plain <img>
        <img
          key={i}
          data-emote
          alt=''
          draggable={false}
          crossOrigin='anonymous'
          className='pointer-events-none absolute top-0 left-0 select-none'
          style={{
            willChange: 'transform',
            display: 'none',
            opacity: 0,
            filter: 'blur(4px)',
          }}
        />
      ))}
    </div>
  )
}
