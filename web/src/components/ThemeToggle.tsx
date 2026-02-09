'use client'

import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { useTheme } from 'next-themes'
import { useEffect, useState } from 'react'
import { HiComputerDesktop, HiMoon, HiSun } from 'react-icons/hi2'

export function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    // eslint-disable-next-line -- intentional hydration pattern
    setMounted(true)
  }, [])

  if (!mounted) return <div className='w-4' />

  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        aria-label='Toggle theme'
        render={<Button variant='outline' size='icon' />}
      >
        {theme === 'dark' && <HiMoon />}
        {theme === 'light' && <HiSun />}
        {theme === 'system' && <HiComputerDesktop />}
      </DropdownMenuTrigger>
      <DropdownMenuContent align='end'>
        <DropdownMenuItem onClick={() => setTheme('light')}>
          <HiSun className='mr-2' />
          Light
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => setTheme('dark')}>
          <HiMoon className='mr-2' />
          Dark
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => setTheme('system')}>
          <HiComputerDesktop className='mr-2' />
          System
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
