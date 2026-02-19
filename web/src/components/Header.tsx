'use client'

import { ThemeToggle } from '@/components/ThemeToggle'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  donateLink,
  emailAddress,
  emailLink,
  githubLink,
} from '@/lib/constants'
import { Copy, Heart, Mail, Menu, Shield } from 'lucide-react'
import Image from 'next/image'
import Link from 'next/link'
import { SiGithub } from 'react-icons/si'
import { toast } from 'sonner'

function ContactDropdown() {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger render={<Button variant='ghost' />}>
        <Mail />
        Contact
      </DropdownMenuTrigger>
      <DropdownMenuContent align='end'>
        <DropdownMenuItem render={<a href={emailLink} />}>
          <Mail />
          Send email
        </DropdownMenuItem>
        <DropdownMenuItem
          onClick={() => {
            void navigator.clipboard.writeText(emailAddress)
            toast.success('Email copied to clipboard')
          }}
        >
          <Copy />
          Copy email
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}

export function Header() {
  return (
    <header>
      <nav className='flex items-center justify-between'>
        <Link href='/' className='flex items-center gap-2'>
          <Image src='/logo.svg' alt='' width={28} height={28} />
          <span className='font-semibold'>Frosty</span>
        </Link>

        {/* Desktop actions */}
        <div className='hidden items-center gap-1 lg:flex'>
          <Button
            variant='ghost'
            render={<a href={githubLink} target='_blank' rel='noreferrer' />}
          >
            <SiGithub />
            GitHub
          </Button>
          <Button
            variant='ghost'
            render={<a href={donateLink} target='_blank' rel='noreferrer' />}
          >
            <Heart />
            Donate
          </Button>
          <Button variant='ghost' render={<Link href='/privacy' />}>
            <Shield />
            Privacy
          </Button>
          <ContactDropdown />
          <ThemeToggle />
        </div>

        {/* Mobile actions */}
        <div className='flex items-center gap-1 lg:hidden'>
          <Button
            variant='ghost'
            render={<a href={githubLink} target='_blank' rel='noreferrer' />}
          >
            <SiGithub />
            GitHub
          </Button>
          <ThemeToggle />
          <DropdownMenu>
            <DropdownMenuTrigger
              render={<Button variant='ghost' size='icon' aria-label='Menu' />}
            >
              <Menu />
            </DropdownMenuTrigger>
            <DropdownMenuContent align='end'>
              <DropdownMenuItem
                render={
                  <a href={donateLink} target='_blank' rel='noreferrer' />
                }
              >
                <Heart />
                Donate
              </DropdownMenuItem>
              <DropdownMenuItem render={<Link href='/privacy' />}>
                <Shield />
                Privacy
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem render={<a href={emailLink} />}>
                <Mail />
                Send email
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={() => {
                  void navigator.clipboard.writeText(emailAddress)
                  toast.success('Email copied to clipboard')
                }}
              >
                <Copy />
                Copy email
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </nav>
    </header>
  )
}
