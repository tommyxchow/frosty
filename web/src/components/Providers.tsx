'use client'
// react-scan must be imported before react
import { scan } from 'react-scan'

import { ThemeProvider } from 'next-themes'
import { useEffect } from 'react'

interface ProvidersProps {
  children: React.ReactNode
}

export function Providers({ children }: ProvidersProps) {
  useEffect(() => {
    scan({
      enabled: true,
    })
  }, [])

  return (
    <ThemeProvider attribute='class' disableTransitionOnChange>
      {children}
    </ThemeProvider>
  )
}
