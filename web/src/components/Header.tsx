'use client'

import { ThemeToggle } from '@/components/ThemeToggle'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  donateLink,
  emailAddress,
  emailLink,
  githubLink,
} from '@/lib/constants'
import { Copy, Github, Heart, Mail, Shield } from 'lucide-react'
import Image from 'next/image'
import Link from 'next/link'
import { toast } from 'sonner'

function ContactDropdown({ iconOnly }: { iconOnly?: boolean }) {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        render={
          iconOnly ? (
            <Button variant='ghost' size='icon' aria-label='Contact' />
          ) : (
            <Button variant='ghost' />
          )
        }
      >
        <Mail />
        {iconOnly ? null : 'Contact'}
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
          <ContactDropdown />
          <Button variant='ghost' render={<Link href='/privacy' />}>
            <Shield />
            Privacy
          </Button>
          <Button
            variant='ghost'
            render={<a href={donateLink} target='_blank' rel='noreferrer' />}
          >
            <Heart />
            Donate
          </Button>
          <Button
            variant='ghost'
            render={<a href={githubLink} target='_blank' rel='noreferrer' />}
          >
            <Github />
            GitHub
          </Button>
          <ThemeToggle />
        </div>

        {/* Mobile actions */}
        <div className='flex items-center gap-1 lg:hidden'>
          <ContactDropdown iconOnly />
          <Button
            variant='ghost'
            size='icon'
            render={<Link href='/privacy' aria-label='Privacy' />}
          >
            <Shield />
          </Button>
          <Button
            variant='ghost'
            size='icon'
            render={
              <a
                href={donateLink}
                target='_blank'
                rel='noreferrer'
                aria-label='Donate'
              />
            }
          >
            <Heart />
          </Button>
          <Button
            variant='ghost'
            size='icon'
            render={
              <a
                href={githubLink}
                target='_blank'
                rel='noreferrer'
                aria-label='GitHub'
              />
            }
          >
            <Github />
          </Button>
          <ThemeToggle />
        </div>
      </nav>
    </header>
  )
}
