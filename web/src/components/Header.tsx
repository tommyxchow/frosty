import { ThemeToggle } from '@/components/ThemeToggle'
import { Button } from '@/components/ui/button'
import { donateLink, githubLink } from '@/lib/constants'
import { Github } from 'lucide-react'
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

        <div className='flex items-center gap-1'>
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
      </nav>
    </header>
  )
}
