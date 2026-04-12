'use client'

import { Toaster } from '@/components/ui/sonner'
import { MotionConfig } from 'motion/react'
import { ThemeProvider } from 'next-themes'

interface ProvidersProps {
  children: React.ReactNode
}

export function Providers({ children }: ProvidersProps) {
  return (
    <MotionConfig reducedMotion='user'>
      <ThemeProvider attribute='class' disableTransitionOnChange>
        {children}
        <Toaster position='top-center' />
      </ThemeProvider>
    </MotionConfig>
  )
}
