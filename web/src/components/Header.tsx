import { ThemeToggle } from '@/components/ThemeToggle'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { donateLink, emailLink, githubLink } from '@/lib/constants'
import { Github, Heart, Mail, Menu } from 'lucide-react'
import Image from 'next/image'
import Link from 'next/link'

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
          <Button variant='ghost' render={<a href={emailLink} />}>
            <Mail />
            Contact
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
            render={
              <a href={githubLink} target='_blank' rel='noreferrer' />
            }
          >
            <Github />
            GitHub
          </Button>
          <ThemeToggle />
        </div>

        {/* Mobile actions */}
        <div className='flex items-center gap-1 lg:hidden'>
          <ThemeToggle />
          <DropdownMenu>
            <DropdownMenuTrigger
              render={<Button variant='ghost' size='icon' aria-label='Menu' />}
            >
              <Menu />
            </DropdownMenuTrigger>
            <DropdownMenuContent align='end'>
              <DropdownMenuItem render={<a href={emailLink} />}>
                <Mail />
                Contact
              </DropdownMenuItem>
              <DropdownMenuItem
                render={
                  <a href={donateLink} target='_blank' rel='noreferrer' />
                }
              >
                <Heart />
                Donate
              </DropdownMenuItem>
              <DropdownMenuItem
                render={
                  <a href={githubLink} target='_blank' rel='noreferrer' />
                }
              >
                <Github />
                GitHub
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </nav>
    </header>
  )
}
