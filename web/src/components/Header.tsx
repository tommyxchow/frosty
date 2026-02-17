import { ThemeToggle } from '@/components/ThemeToggle'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { donateLink, emailLink, githubLink } from '@/lib/constants'
import { Github, Menu } from 'lucide-react'
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
        <div className='hidden items-center gap-1 md:flex'>
          <Button variant='ghost' size='sm' render={<a href={emailLink} />}>
            Contact
          </Button>
          <Button
            variant='ghost'
            size='sm'
            render={<a href={donateLink} target='_blank' rel='noreferrer' />}
          >
            Donate
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

        {/* Mobile actions */}
        <div className='flex items-center gap-1 md:hidden'>
          <ThemeToggle />
          <DropdownMenu>
            <DropdownMenuTrigger
              render={<Button variant='ghost' size='icon' aria-label='Menu' />}
            >
              <Menu />
            </DropdownMenuTrigger>
            <DropdownMenuContent align='end'>
              <DropdownMenuItem render={<a href={emailLink} />}>
                Contact
              </DropdownMenuItem>
              <DropdownMenuItem
                render={
                  <a href={donateLink} target='_blank' rel='noreferrer' />
                }
              >
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
