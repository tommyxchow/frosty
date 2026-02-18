'use client'

import { Toaster } from '@/components/ui/sonner'
import { MotionConfig } from 'motion/react'
import { ThemeProvider } from 'next-themes'
import { useEffect } from 'react'

interface ProvidersProps {
  children: React.ReactNode
}

export function Providers({ children }: ProvidersProps) {
  useEffect(() => {
    if (process.env.NODE_ENV === 'development') {
      void import('react-scan').then(({ scan }) => {
        scan({ enabled: true })
      })
    }
  }, [])

  return (
    <MotionConfig reducedMotion='user'>
      <ThemeProvider attribute='class' disableTransitionOnChange>
        {children}
        <Toaster position='top-center' />
      </ThemeProvider>
    </MotionConfig>
  )
}
