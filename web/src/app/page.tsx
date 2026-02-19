'use client'

import screenshotCategories from '@/assets/screenshot-categories.png'
import screenshotFollowing from '@/assets/screenshot-following.png'
import screenshotSettings from '@/assets/screenshot-settings.png'
import { EmotePhysicsBackground } from '@/components/EmotePhysicsBackground'
import { Footer } from '@/components/Footer'
import { Header } from '@/components/Header'
import { Button } from '@/components/ui/button'
import {
  appStoreLink,
  bttvLink,
  ffzLink,
  playStoreLink,
  sevenTvLink,
} from '@/lib/constants'
import { cn } from '@/lib/utils'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { AnimatePresence, motion } from 'motion/react'
import Image, { type StaticImageData } from 'next/image'
import {
  useCallback,
  useEffect,
  useRef,
  useState,
  useSyncExternalStore,
} from 'react'
import { SiApple, SiGoogleplay } from 'react-icons/si'

const features = [
  {
    title: 'Native emotes',
    description: 'Watch and chat with 7TV, BetterTTV, and FrankerFaceZ emotes.',
    media: { type: 'video' as const, src: '/video.webm' },
  },
  {
    title: 'Followed channels',
    description:
      'See who is live, pin favorites, and browse your followed list.',
    media: { type: 'image' as const, src: screenshotFollowing },
  },
  {
    title: 'Explore categories',
    description: 'Browse top streams and trending categories across Twitch.',
    media: { type: 'image' as const, src: screenshotCategories },
  },
  {
    title: 'Deeply customizable',
    description:
      'Themes, autocomplete, sleep timers, and local message history.',
    media: { type: 'image' as const, src: screenshotSettings },
  },
]

// ─── Entrance animation variants ─────────────────────────────────────────────
const item = {
  hidden: { opacity: 0, y: 20, filter: 'blur(4px)' },
  visible: {
    opacity: 1,
    y: 0,
    filter: 'blur(0px)',
    transition: { duration: 0.5, ease: 'easeOut' as const },
  },
}

const staggerContainer = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.12 } },
}

function DownloadButtons() {
  return (
    <div className='flex flex-wrap justify-center gap-3'>
      <Button
        variant='outline'
        size='lg'
        className='bg-background h-14 rounded-xl px-6'
        render={<a href={appStoreLink} target='_blank' rel='noreferrer' />}
      >
        <SiApple className='mr-2.5 size-6 text-blue-500 dark:text-blue-400' />
        <div className='flex flex-col items-start'>
          <span className='text-xs leading-tight font-normal opacity-60'>
            Download on the
          </span>
          <span className='text-base leading-tight font-semibold'>
            App Store
          </span>
        </div>
      </Button>
      <Button
        variant='outline'
        size='lg'
        className='bg-background h-14 rounded-xl px-6'
        render={<a href={playStoreLink} target='_blank' rel='noreferrer' />}
      >
        <SiGoogleplay className='mr-2.5 size-5 text-green-500 dark:text-green-400' />
        <div className='flex flex-col items-start'>
          <span className='text-xs leading-tight font-normal opacity-60'>
            Get it on
          </span>
          <span className='text-base leading-tight font-semibold'>
            Google Play
          </span>
        </div>
      </Button>
    </div>
  )
}

function PhoneFrame({
  children,
  className,
}: {
  children?: React.ReactNode
  className?: string
}) {
  return (
    <div className={cn('aspect-[6/13]', className)}>
      <div className='border-border/50 size-full overflow-hidden rounded-4xl border bg-black p-1 shadow-xl'>
        <div className='relative size-full overflow-hidden rounded-4xl'>
          {children}
        </div>
      </div>
    </div>
  )
}

function PhoneMedia({
  media,
  title,
  isCurrent,
}: {
  media:
    | { type: 'video'; src: string }
    | { type: 'image'; src: StaticImageData }
  title: string
  isCurrent: boolean
}) {
  const videoRef = useRef<HTMLVideoElement>(null)

  useEffect(() => {
    if (media.type !== 'video') return
    const video = videoRef.current
    if (!video) return
    if (isCurrent) {
      void video.play()
    } else {
      video.pause()
    }
  }, [isCurrent, media.type])

  return (
    <div className='relative size-full bg-black'>
      {media.type === 'video' ? (
        <video
          ref={videoRef}
          src={media.src}
          loop
          muted
          playsInline
          className='size-full object-contain'
        />
      ) : (
        <Image src={media.src} alt={title} fill className='object-contain' />
      )}
    </div>
  )
}

const STEP_MOBILE = 260
const STEP_DESKTOP = 370
const stepQuery = '(min-width: 768px)'
function subscribeStep(callback: () => void) {
  const mq = window.matchMedia(stepQuery)
  mq.addEventListener('change', callback)
  return () => mq.removeEventListener('change', callback)
}
function getStepSnapshot() {
  return window.matchMedia(stepQuery).matches ? STEP_DESKTOP : STEP_MOBILE
}
function getStepServerSnapshot() {
  return STEP_DESKTOP
}

function Carousel() {
  const [current, setCurrent] = useState(0)
  const [hovered, setHovered] = useState<number | null>(null)
  const step = useSyncExternalStore(
    subscribeStep,
    getStepSnapshot,
    getStepServerSnapshot,
  )

  const touchStartRef = useRef(0)
  const regionRef = useRef<HTMLDivElement>(null)

  const go = useCallback((delta: number) => {
    setCurrent((prev) =>
      Math.max(0, Math.min(features.length - 1, prev + delta)),
    )
    regionRef.current?.focus()
  }, [])

  return (
    <div className='flex h-full flex-col items-center justify-center gap-4'>
      {/* Phone track with overlay arrows */}
      <div
        ref={regionRef}
        role='region'
        aria-roledescription='carousel'
        aria-label='App features'
        tabIndex={0}
        className='relative h-full max-h-130 min-h-0 w-full shrink touch-pan-y overflow-hidden focus-visible:outline-none md:max-h-200'
        onKeyDown={(e) => {
          if (e.key === 'ArrowLeft') {
            e.preventDefault()
            go(-1)
          } else if (e.key === 'ArrowRight') {
            e.preventDefault()
            go(1)
          }
        }}
        onTouchStart={(e) => {
          touchStartRef.current = e.touches[0]!.clientX
        }}
        onTouchEnd={(e) => {
          const delta = e.changedTouches[0]!.clientX - touchStartRef.current
          if (delta > 50) go(-1)
          else if (delta < -50) go(1)
        }}
      >
        {/* Animated phones on the track */}
        {features.map((feature, i) => {
          const offset = i - current

          if (Math.abs(offset) > 2) return null

          return (
            <motion.div
              key={feature.title}
              role='group'
              aria-roledescription='slide'
              aria-label={`${i + 1} of ${features.length}: ${feature.title}`}
              initial={{ x: offset * step, opacity: 0 }}
              animate={{
                x: offset * step,
                opacity:
                  offset === 0
                    ? 1
                    : Math.abs(offset) === 1
                      ? hovered === i
                        ? 0.5
                        : 0.25
                      : 0,
              }}
              transition={{ type: 'spring', stiffness: 300, damping: 30 }}
              className='pointer-events-none absolute inset-0 flex items-center justify-center'
            >
              <div
                className={cn(
                  'flex h-full items-center justify-center',
                  Math.abs(offset) === 1 &&
                    'pointer-events-auto cursor-pointer',
                )}
                {...(Math.abs(offset) === 1
                  ? {
                      role: 'button',
                      tabIndex: 0,
                      'aria-label': `Go to ${feature.title}`,
                      onMouseEnter: () => setHovered(i),
                      onMouseLeave: () => setHovered(null),
                      onClick: () => go(offset),
                      onKeyDown: (e: React.KeyboardEvent) => {
                        if (e.key === 'Enter' || e.key === ' ') {
                          e.preventDefault()
                          go(offset)
                        }
                      },
                    }
                  : undefined)}
              >
                <PhoneFrame className='h-full max-h-130 max-w-60 md:max-h-190 md:max-w-88'>
                  <PhoneMedia
                    media={feature.media}
                    title={feature.title}
                    isCurrent={offset === 0}
                  />
                </PhoneFrame>
              </div>
            </motion.div>
          )
        })}

        {/* Arrow overlays */}
        <AnimatePresence>
          {current > 0 && (
            <motion.div
              key='prev'
              initial={{ opacity: 0, x: -8 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -8 }}
              transition={{ duration: 0.2, ease: 'easeOut' }}
              className='absolute top-1/2 left-4 z-10 -translate-y-1/2'
            >
              <Button
                variant='ghost'
                size='icon'
                onClick={() => go(-1)}
                aria-label='Previous feature'
              >
                <ChevronLeft />
              </Button>
            </motion.div>
          )}
          {current < features.length - 1 && (
            <motion.div
              key='next'
              initial={{ opacity: 0, x: 8 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 8 }}
              transition={{ duration: 0.2, ease: 'easeOut' }}
              className='absolute top-1/2 right-4 z-10 -translate-y-1/2'
            >
              <Button
                variant='ghost'
                size='icon'
                onClick={() => go(1)}
                aria-label='Next feature'
              >
                <ChevronRight />
              </Button>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Description */}
      <span className='sr-only' aria-live='polite' aria-atomic>
        {features[current]?.title}: {features[current]?.description}
      </span>
      <div className='min-h-10 px-4 text-center' aria-hidden>
        <AnimatePresence mode='wait'>
          <motion.p
            key={current}
            initial={{ opacity: 0, y: 4, filter: 'blur(4px)' }}
            animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
            exit={{ opacity: 0, y: -4, filter: 'blur(4px)' }}
            transition={{ duration: 0.3, ease: 'easeOut' }}
            className='text-muted-foreground text-sm'
          >
            {features[current]?.description}
          </motion.p>
        </AnimatePresence>
      </div>
    </div>
  )
}

export default function Home() {
  return (
    <div className='grid h-dvh grid-rows-[auto_1fr] overflow-hidden md:grid-cols-2 md:grid-rows-none'>
      {/* Left cell — intro */}
      <motion.div
        className='bg-muted/50 dark:bg-muted/30 relative flex flex-col gap-4 overflow-hidden px-4'
        initial='hidden'
        animate='visible'
        variants={staggerContainer}
      >
        <EmotePhysicsBackground />
        <motion.div variants={item} className='relative z-20 pt-4'>
          <Header />
        </motion.div>

        <motion.div
          variants={staggerContainer}
          className='relative z-10 flex flex-1 flex-col items-center justify-center gap-4 text-center md:gap-6'
        >
          <motion.div variants={item} className='flex flex-col gap-3 md:gap-4'>
            <h1 className='text-2xl font-semibold tracking-tight text-pretty md:text-4xl'>
              Watch Twitch on mobile with
              <br />
              <a
                href={sevenTvLink}
                target='_blank'
                rel='noreferrer'
                className='text-primary underline'
              >
                7TV
              </a>
              ,{' '}
              <a
                href={bttvLink}
                target='_blank'
                rel='noreferrer'
                className='text-primary underline'
              >
                BTTV
              </a>
              , and{' '}
              <a
                href={ffzLink}
                target='_blank'
                rel='noreferrer'
                className='text-primary underline'
              >
                FFZ
              </a>{' '}
              emotes
            </h1>
            <p className='text-muted-foreground mx-auto max-w-md text-sm text-balance md:max-w-lg md:text-base'>
              Frosty is a fast, open-source Twitch client for iOS and Android
              with native 7TV, BTTV, and FFZ support.
            </p>
          </motion.div>
          <motion.div variants={item}>
            <DownloadButtons />
          </motion.div>
        </motion.div>
        <motion.div variants={item} className='z-30'>
          <Footer />
        </motion.div>
      </motion.div>

      {/* Right cell — carousel */}
      <motion.div
        className='flex min-h-0 flex-col overflow-hidden py-4'
        initial={{ opacity: 0, y: 30, filter: 'blur(4px)' }}
        animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
        transition={{ duration: 0.6, ease: 'easeOut', delay: 0.4 }}
      >
        <Carousel />
      </motion.div>
    </div>
  )
}
