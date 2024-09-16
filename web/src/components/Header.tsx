import { donateLink, githubLink } from '@/lib/constants';
import Image from 'next/image';
import Link from 'next/link';
import { SiBuymeacoffee, SiGithub } from 'react-icons/si';
import { ThemeToggle } from './ThemeToggle';

export function Header() {
  return (
    <header className='fixed top-0 z-50 flex w-full max-w-screen-lg items-center justify-between gap-4 bg-gradient-to-b from-neutral-100 to-transparent px-4 py-8 dark:from-black lg:px-0'>
      <Link className='flex items-center gap-2' href='/'>
        <div className='relative size-8'>
          <Image alt='Logo' src={`/logo.svg`} layout='fill' priority />
        </div>

        <h1 className='text-xl font-semibold'>Frosty</h1>
      </Link>

      <div className='flex items-center gap-4'>
        <a
          className='transition-opacity hover:opacity-50'
          href={donateLink}
          target='_blank'
          rel='noreferrer'
        >
          <SiBuymeacoffee className='size-6' />
        </a>

        <a
          className='transition-opacity hover:opacity-50'
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
