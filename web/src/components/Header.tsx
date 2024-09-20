import { donateLink, githubLink } from '@/lib/constants';
import Image from 'next/image';
import Link from 'next/link';
import { SiBuymeacoffee, SiGithub } from 'react-icons/si';
import { ThemeToggle } from './ThemeToggle';

export function Header() {
  return (
    <header className='sticky top-0 z-50 flex w-full max-w-screen-lg justify-between gap-4 divide-x divide-neutral-300 border-b border-inherit bg-inherit dark:divide-neutral-900 dark:from-black'>
      <Link
        className='flex items-center gap-2 border-r border-inherit px-4 transition hover:bg-neutral-200 dark:hover:bg-neutral-900'
        href='/'
      >
        <div className='relative size-8'>
          <Image alt='Logo' src={`/logo.svg`} layout='fill' priority />
        </div>
      </Link>

      <div className='flex items-center divide-x divide-inherit'>
        <a
          className='p-4 transition hover:bg-neutral-200 dark:hover:bg-neutral-900'
          href={donateLink}
          target='_blank'
          rel='noreferrer'
        >
          <SiBuymeacoffee className='size-6' />
        </a>

        <a
          className='p-4 transition hover:bg-neutral-200 dark:hover:bg-neutral-900'
          href={githubLink}
          target='_blank'
          rel='noreferrer'
        >
          <SiGithub className='size-6' />
        </a>

        <ThemeToggle />
      </div>
    </header>
  );
}
