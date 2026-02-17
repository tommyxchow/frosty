'use client'

import { Header } from '@/components/Header'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { appStoreLink, emailLink, playStoreLink } from '@/lib/constants'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { AnimatePresence, motion } from 'motion/react'
import { useCallback, useState } from 'react'
import { SiApple, SiGoogleplay } from 'react-icons/si'

const features = [
  {
    title: 'Native emotes',
    description: '7TV, BetterTTV, and FrankerFaceZ — no extensions required.',
  },
  {
    title: 'Followed channels',
    description:
      'See who is live, pin favorites, and browse your followed list.',
  },
  {
    title: 'Explore categories',
    description:
      'Discover streams and categories with a fast, fluid interface.',
  },
  {
    title: 'Deeply customizable',
    description:
      'Themes, autocomplete, sleep timers, and local message history.',
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

function PhoneSkeleton({ className }: { className?: string }) {
  return (
    <div className={className}>
      <div className='border-border/50 aspect-[6/13] w-full overflow-hidden rounded-[44px] border bg-black p-[5px] shadow-xl'>
        <Skeleton className='size-full rounded-[40px]' />
      </div>
    </div>
  )
}

const STEP = 240

function Carousel() {
  const [current, setCurrent] = useState(0)

  const go = useCallback((delta: number) => {
    setCurrent((prev) => (prev + delta + features.length) % features.length)
  }, [])

  return (
    <div className='flex h-full flex-col items-center justify-center gap-8'>
      {/* Arrows + sliding track */}
      <div className='flex w-full items-center justify-center gap-2'>
        <Button
          variant='ghost'
          size='icon'
          className='shrink-0'
          onClick={() => go(-1)}
          aria-label='Previous feature'
        >
          <ChevronLeft />
        </Button>

        {/* Track — overflow clips offscreen phones */}
        <div className='relative w-full overflow-hidden'>
          {/* Hidden reference phone for container height */}
          <div className='pointer-events-none invisible'>
            <PhoneSkeleton className='mx-auto w-[180px] md:w-[220px]' />
          </div>

          {/* Animated phones on the track */}
          {features.map((_feature, i) => {
            let offset = i - current
            if (offset > features.length / 2) offset -= features.length
            if (offset < -features.length / 2) offset += features.length

            if (Math.abs(offset) > 2) return null

            return (
              <motion.div
                key={i}
                animate={{
                  x: offset * STEP,
                  opacity:
                    offset === 0 ? 1 : Math.abs(offset) === 1 ? 0.25 : 0,
                }}
                transition={{ type: 'spring', stiffness: 300, damping: 30 }}
                className='pointer-events-none absolute inset-0 flex justify-center'
              >
                <div
                  className={
                    offset !== 0 ? 'pointer-events-auto cursor-pointer' : ''
                  }
                  onClick={offset !== 0 ? () => go(offset) : undefined}
                >
                  <PhoneSkeleton className='w-[180px] md:w-[220px]' />
                </div>
              </motion.div>
            )
          })}
        </div>

        <Button
          variant='ghost'
          size='icon'
          className='shrink-0'
          onClick={() => go(1)}
          aria-label='Next feature'
        >
          <ChevronRight />
        </Button>
      </div>

      {/* Description — directly below images */}
      <AnimatePresence mode='wait'>
        <motion.p
          key={current}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.2 }}
          className='text-muted-foreground text-center text-sm'
        >
          {features[current]?.description}
        </motion.p>
      </AnimatePresence>
    </div>
  )
}

export default function Home() {
  return (
    <div className='grid min-h-dvh gap-2 p-2 md:grid-cols-2'>
      {/* Left cell — intro */}
      <div className='order-last flex flex-col rounded-3xl p-4 md:order-none md:p-6'>
        <Header />

        <div className='flex flex-1 flex-col items-center justify-center gap-4 text-center'>
          <h1 className='text-2xl font-bold tracking-tight text-balance md:text-3xl'>
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

        <footer className='text-muted-foreground flex items-center justify-between text-xs'>
          <p>© {new Date().getFullYear()} Frosty</p>
          <a href={emailLink} className='hover:text-foreground'>
            Contact
          </a>
        </footer>
      </div>

      {/* Right cell — carousel */}
      <div className='bg-muted/30 flex flex-col rounded-3xl p-6 md:p-10'>
        <Carousel />
      </div>
    </div>
  )
}
