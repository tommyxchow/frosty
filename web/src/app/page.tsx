'use client'

import screenshotCategories from '@/assets/screenshot-categories.png'
import screenshotFollowing from '@/assets/screenshot-following.png'
import screenshotSettings from '@/assets/screenshot-settings.png'
import { Header } from '@/components/Header'
import { Button } from '@/components/ui/button'
import { appStoreLink, playStoreLink } from '@/lib/constants'
import { cn } from '@/lib/utils'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { AnimatePresence, motion } from 'motion/react'
import Image, { type StaticImageData } from 'next/image'
import { useCallback, useEffect, useRef, useState } from 'react'
import { SiApple, SiGoogleplay } from 'react-icons/si'

const features = [
  {
    title: 'Native emotes',
    description: '7TV, BetterTTV, and FrankerFaceZ — no extensions required.',
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
    description:
      'Discover streams and categories with a fast, fluid interface.',
    media: { type: 'image' as const, src: screenshotCategories },
  },
  {
    title: 'Deeply customizable',
    description:
      'Themes, autocomplete, sleep timers, and local message history.',
    media: { type: 'image' as const, src: screenshotSettings },
  },
]

function DownloadButtons() {
  return (
    <div className='flex flex-wrap justify-center gap-3'>
      <Button
        variant='default'
        size='lg'
        className='h-11 rounded-full px-6 font-semibold'
        render={<a href={appStoreLink} target='_blank' rel='noreferrer' />}
      >
        <SiApple className='mr-2 size-4' />
        App Store
      </Button>
      <Button
        variant='outline'
        size='lg'
        className='h-11 rounded-full px-6 font-semibold'
        render={<a href={playStoreLink} target='_blank' rel='noreferrer' />}
      >
        <SiGoogleplay className='mr-2 size-3.5' />
        Google Play
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

  if (media.type === 'video') {
    return (
      <video
        ref={videoRef}
        src={media.src}
        loop
        muted
        playsInline
        className='size-full object-cover'
      />
    )
  }
  return <Image src={media.src} alt={title} fill className='object-cover' />
}

const STEP_MOBILE = 220
const STEP_DESKTOP = 370

function Carousel() {
  const [current, setCurrent] = useState(0)
  const [hovered, setHovered] = useState<number | null>(null)
  const [step, setStep] = useState(STEP_DESKTOP)

  useEffect(() => {
    const update = () =>
      setStep(window.innerWidth >= 768 ? STEP_DESKTOP : STEP_MOBILE)
    update()
    window.addEventListener('resize', update)
    return () => window.removeEventListener('resize', update)
  }, [])

  const touchStart = useRef(0)

  const go = useCallback((delta: number) => {
    setCurrent((prev) =>
      Math.max(0, Math.min(features.length - 1, prev + delta)),
    )
  }, [])

  return (
    <div className='flex h-full flex-col items-center justify-center gap-4'>
      {/* Phone track with overlay arrows */}
      <div
        className='relative min-h-0 h-full w-full shrink max-h-120 touch-pan-y overflow-hidden md:max-h-200'
        onTouchStart={(e) => {
          touchStart.current = e.touches[0]!.clientX
        }}
        onTouchEnd={(e) => {
          const delta = e.changedTouches[0]!.clientX - touchStart.current
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
              key={i}
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
                  offset !== 0 && 'pointer-events-auto cursor-pointer',
                )}
                onMouseEnter={offset !== 0 ? () => setHovered(i) : undefined}
                onMouseLeave={offset !== 0 ? () => setHovered(null) : undefined}
                onClick={offset !== 0 ? () => go(offset) : undefined}
              >
                <PhoneFrame className='h-full max-h-110 max-w-48 md:max-h-190 md:max-w-88'>
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
              className='absolute left-1 top-1/2 z-10 -translate-y-1/2'
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
              className='absolute right-1 top-1/2 z-10 -translate-y-1/2'
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
      <div className='px-4 text-center'>
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
    <div className='grid h-dvh grid-rows-[auto_1fr] gap-2 p-2 md:grid-cols-2 md:grid-rows-none'>
      {/* Left cell — intro */}
      <div className='flex flex-col gap-4 rounded-3xl p-2'>
        <Header />

        <div className='flex flex-1 flex-col items-center justify-center gap-4 text-center'>
          <h1 className='text-lg font-medium tracking-tight text-balance md:text-3xl md:font-bold'>
            Watch Twitch with <span className='text-primary'>emotes</span>
          </h1>
          <p className='text-muted-foreground max-w-sm text-sm text-balance'>
            A fast, open-source Twitch client for iOS and Android with native
            7TV, BTTV, and FFZ support.
          </p>
          <div className='pt-2'>
            <DownloadButtons />
          </div>
        </div>
      </div>

      {/* Right cell — carousel */}
      <div className='bg-muted/50 dark:bg-muted/30 flex flex-col overflow-hidden rounded-3xl py-4'>
        <Carousel />
      </div>
    </div>
  )
}
