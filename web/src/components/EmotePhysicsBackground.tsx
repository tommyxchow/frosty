'use client'

import { motion } from 'motion/react'
import { useEffect, useRef, useSyncExternalStore } from 'react'

// ─── 7TV emotes (xQc's channel set) ─────────────────────────────────────────
// Curated from xQc's 7TV emote set — images load directly from cdn.7tv.app.
const EMOTE_IDS = [
  '01FZ975PV8000B4AWRZNMVNEXN', // LOL
  '01GBPSCGR00007Q17796BDN5AJ', // Classic
  '01JP0FG0NN10YJPYVTZN5K67WY', // LO
  '01F6MZGCNG000255K4X1K7NTHR', // GIGACHAD
  '01HTKMB7680004B0MV8TERR9A4', // AURA
  '01F00Z3A9G0007E4VV006YKSK9', // OMEGALUL
  '01FHNBZRW8000C3ZWT2Z63JS92', // Sadge
  '01EZTCN91800012PTN006Q50PR', // Pog
  '01F6T8NM9R0007M5BTFWSP1YSJ', // Clueless
  '01FFWH9WV80000JT8GHDKHJNZC', // Aware
  '01F010F9GR0007E4VV006YKSKN', // PepeLaugh
  '01F6MA6Y100002B6P5MWZ5D916', // Hmm
  '01F6NACCD80006SZ7ZW5FMWKWK', // Prayge
  '01FG1NDHJR0001XDR7G9054X2Q', // HUH
  '01G7YR9X5G0003Z50SB3FM5WR4', // Happi
  '01GFBTYEV80008P4E5PB4NX0XC', // DIESOFCRINGE
  '01F6MDFCSR0000WDA7ERT623YT', // NODDERS
  '01F6MQ33FG000FFJ97ZB8MWV52', // catJAM
  '01EZY967K0000CYST6006V20T8', // pepeJAM
  '01F6NMMEER00015NVG2J8ZH77N', // peepoHey
  '01H3ZS4R1R0003PH84VNH1WMYC', // Madge
  '01F6MMQCM80009C9ZSNZT3GTK1', // PagChomp
  '01FAJR9X80000136YH153JYZTB', // modCheck
  '01G7RNEB2R00029YRR37CZ24HX', // LockIn
  '01F6MG1HPR0009K1N00D4GG63Z', // ICANT
  '01GBEBQQN00001RAQMJBWFVDXF', // COOKING
  '01JJ0D0C2XWZ640NP4WJKB8MYX', // Cooked
  '01GY1RDSR8000ENJJARE9FMTJR', // SLAY
  '01FBZESCNR000A6AWCB1X558GZ', // Chatting
  '01GF1Y2Q5G0000BGNJSP34TQRD', // widepeepoHappy
]

const EMOTE_URLS = EMOTE_IDS.map(
  (id) => `https://cdn.7tv.app/emote/${id}/2x.webp`,
)

// ─── Physics constants ───────────────────────────────────────────────────────
const PARTICLE_COUNT = 25
const EMOTE_SIZE = 40
const TARGET_OPACITY = 0.3
const INITIAL_SPEED = 0.4
const MIN_SPEED = 0.2
const MAX_SPEED = 2.5
const FRICTION = 0.998
const RESTITUTION = 0.8
const REPULSE_RADIUS = 130
const REPULSE_STRENGTH = 1.6
const CENTER_ZONE_X = 0.6 // fraction of container width
const CENTER_ZONE_Y = 0.5 // fraction of container height
const CENTER_PUSH = 0.15

// ─── Types ───────────────────────────────────────────────────────────────────
interface ParticleState {
  x: number
  y: number
  vx: number
  vy: number
  rotation: number
  rotationSpeed: number
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
function rand(min: number, max: number) {
  return Math.random() * (max - min) + min
}

function spawnInEdgeZone(w: number, h: number): { x: number; y: number } {
  // Spawn emotes in the outer ring, avoiding the center zone
  const half = EMOTE_SIZE / 2
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

function createParticle(w: number, h: number): ParticleState {
  const { x, y } = spawnInEdgeZone(w, h)
  const angle = rand(0, Math.PI * 2)
  return {
    x,
    y,
    vx: Math.cos(angle) * INITIAL_SPEED,
    vy: Math.sin(angle) * INITIAL_SPEED,
    rotation: rand(-0.3, 0.3),
    rotationSpeed: rand(-0.003, 0.003),
  }
}

// ─── Component ───────────────────────────────────────────────────────────────
const desktopQuery = '(min-width: 768px)'
function subscribeDesktop(callback: () => void) {
  const mq = window.matchMedia(desktopQuery)
  mq.addEventListener('change', callback)
  return () => mq.removeEventListener('change', callback)
}
function getDesktopSnapshot() {
  return window.matchMedia(desktopQuery).matches
}
function getDesktopServerSnapshot() {
  return false
}

export function EmotePhysicsBackground() {
  const containerRef = useRef<HTMLDivElement>(null)
  const isDesktop = useSyncExternalStore(
    subscribeDesktop,
    getDesktopSnapshot,
    getDesktopServerSnapshot,
  )

  useEffect(() => {
    if (!isDesktop) return

    const container = containerRef.current
    if (container === null) return

    const elements =
      container.querySelectorAll<HTMLImageElement>('[data-emote]')
    if (elements.length === 0) return

    let cancelled = false
    let rafId = 0
    let w = 0
    let h = 0
    const mouseRef = { current: null as { x: number; y: number } | null }

    // Initialize dimensions
    const rect = container.getBoundingClientRect()
    w = rect.width
    h = rect.height

    // Initialize particle states
    const particles: ParticleState[] = []
    elements.forEach(() => {
      if (w > 0 && h > 0) {
        particles.push(createParticle(w, h))
      }
    })

    // Resize handling
    const ro = new ResizeObserver((entries) => {
      const entry = entries[0]
      if (entry === undefined) return
      const { width, height } = entry.contentRect
      if (width > 0 && height > 0) {
        w = width
        h = height
        const half = EMOTE_SIZE / 2
        for (const p of particles) {
          p.x = Math.max(half, Math.min(p.x, w - half))
          p.y = Math.max(half, Math.min(p.y, h - half))
        }
      }
    })
    ro.observe(container)

    // Mouse tracking on the parent panel (content z-10 sits above container)
    const panel = container.parentElement ?? container
    function onMouseMove(e: MouseEvent) {
      const r = container!.getBoundingClientRect()
      mouseRef.current = { x: e.clientX - r.left, y: e.clientY - r.top }
    }
    function onMouseLeave() {
      mouseRef.current = null
    }
    panel.addEventListener('mousemove', onMouseMove)
    panel.addEventListener('mouseleave', onMouseLeave)

    function tick() {
      if (cancelled) return

      const m = mouseRef.current
      const centerX = w / 2
      const centerY = h / 2
      const zoneRadiusX = (w * CENTER_ZONE_X) / 2
      const zoneRadiusY = (h * CENTER_ZONE_Y) / 2

      for (let i = 0; i < particles.length; i++) {
        const p = particles[i]
        const el = elements[i]
        if (p === undefined || el === undefined) continue

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

        // Mouse repulsion
        if (m !== null) {
          const dx = p.x - m.x
          const dy = p.y - m.y
          const distSq = dx * dx + dy * dy
          if (distSq < REPULSE_RADIUS * REPULSE_RADIUS && distSq > 0.01) {
            const dist = Math.sqrt(distSq)
            const force =
              ((REPULSE_RADIUS - dist) / REPULSE_RADIUS) * REPULSE_STRENGTH
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

        // Wall bounce
        const half = EMOTE_SIZE / 2
        if (p.x - half < 0) {
          p.x = half
          p.vx = Math.abs(p.vx) * RESTITUTION
        } else if (p.x + half > w) {
          p.x = w - half
          p.vx = -Math.abs(p.vx) * RESTITUTION
        }
        if (p.y - half < 0) {
          p.y = half
          p.vy = Math.abs(p.vy) * RESTITUTION
        } else if (p.y + half > h) {
          p.y = h - half
          p.vy = -Math.abs(p.vy) * RESTITUTION
        }

        // Rotation
        p.rotation += p.rotationSpeed

        // Write to DOM — only transform, no layout thrash
        el.style.transform = `translate3d(${p.x - half}px, ${p.y - half}px, 0) rotate(${p.rotation}rad)`
      }

      rafId = requestAnimationFrame(tick)
    }

    // Start loop only if we have particles
    if (particles.length > 0) {
      tick()
    }

    return () => {
      cancelled = true
      cancelAnimationFrame(rafId)
      ro.disconnect()
      panel.removeEventListener('mousemove', onMouseMove)
      panel.removeEventListener('mouseleave', onMouseLeave)
    }
  }, [isDesktop])

  if (!isDesktop) return null

  return (
    <div ref={containerRef} className='absolute inset-0 overflow-hidden'>
      {EMOTE_URLS.slice(0, PARTICLE_COUNT).map((url, i) => (
        <motion.img
          key={url}
          data-emote
          src={url}
          alt=''
          draggable={false}
          crossOrigin='anonymous'
          initial={{ opacity: 0 }}
          animate={{ opacity: TARGET_OPACITY }}
          transition={{ duration: 0.6, delay: i * 0.04, ease: 'easeOut' }}
          className='pointer-events-none absolute top-0 left-0 select-none'
          style={{
            width: EMOTE_SIZE,
            height: EMOTE_SIZE,
            willChange: 'transform',
          }}
        />
      ))}
    </div>
  )
}
