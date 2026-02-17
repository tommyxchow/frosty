import { emailLink, githubLink } from '@/lib/constants'

export function Footer() {
  return (
    <footer className='flex flex-col items-center justify-between gap-6 border-t py-8 md:flex-row'>
      <p className='text-muted-foreground text-xs'>
        © {new Date().getFullYear()} Frosty for Twitch. Built by{' '}
        <a
          href={githubLink}
          className='text-foreground hover:text-primary font-medium underline underline-offset-4'
        >
          Tommy Chow
        </a>
      </p>
      <div className='flex gap-6'>
        <a
          href={githubLink}
          className='text-muted-foreground hover:text-foreground text-xs'
        >
          GitHub
        </a>
        <a
          href={emailLink}
          className='text-muted-foreground hover:text-foreground text-xs'
        >
          Contact
        </a>
      </div>
    </footer>
  )
}
