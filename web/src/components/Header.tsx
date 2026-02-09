import { donateLink, githubLink } from '@/lib/constants'
import Image from 'next/image'
import Link from 'next/link'
import { SiBuymeacoffee, SiGithub } from 'react-icons/si'
import { ThemeToggle } from './ThemeToggle'

export function Header() {
  return (
    <header className='divide-border border-border sticky top-0 z-50 flex w-full max-w-screen-lg justify-between gap-4 divide-x border-b bg-inherit'>
      <Link
        className='border-border hover:bg-accent flex items-center gap-2 border-r px-4 transition'
        href='/'
      >
        <Image alt='Logo' src='/logo.svg' width={32} height={32} priority />
      </Link>

      <div className='divide-border flex items-center divide-x'>
        <a
          className='hover:bg-accent p-4 transition'
          href={donateLink}
          target='_blank'
          rel='noreferrer'
        >
          <SiBuymeacoffee className='size-6' />
        </a>

        <a
          className='hover:bg-accent p-4 transition'
          href={githubLink}
          target='_blank'
          rel='noreferrer'
        >
          <SiGithub className='size-6' />
        </a>

        <ThemeToggle />
      </div>
    </header>
  )
}
