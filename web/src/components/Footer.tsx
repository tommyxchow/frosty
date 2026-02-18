import { tommyLink } from '@/lib/constants'

export function Footer() {
  return (
    <footer className='absolute inset-x-0 bottom-8 z-30 text-center'>
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
