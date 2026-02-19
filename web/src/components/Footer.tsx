import { tommyLink } from '@/lib/constants'

export function Footer() {
  return (
    <footer className='relative z-30 pb-2 text-center md:pb-4'>
      <p className='text-muted-foreground/60 text-xs'>
        Made by{' '}
        <a
          href={tommyLink}
          target='_blank'
          rel='noreferrer'
          className='underline underline-offset-4 transition-colors hover:text-muted-foreground'
        >
          Tommy Chow
        </a>
      </p>
    </footer>
  )
}
