import { tommyLink } from '@/lib/constants';

export function Footer() {
  return (
    <footer className='flex w-full items-center justify-center gap-4 px-4 py-8 text-sm lg:px-0'>
      <p className='text-neutral-500 dark:text-neutral-400'>
        Designed and developed by{' '}
        <a
          className='underline'
          href={tommyLink}
          target='_blank'
          rel='noreferrer'
        >
          Tommy Chow
        </a>
      </p>
    </footer>
  );
}
