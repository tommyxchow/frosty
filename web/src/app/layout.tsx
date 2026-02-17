import { Providers } from '@/components/Providers'
import { type Metadata } from 'next'
import { Inter, JetBrains_Mono } from 'next/font/google'
import { twJoin } from 'tailwind-merge'
import './globals.css'

const fontSans = Inter({ subsets: ['latin'], variable: '--font-sans' })
const fontMono = JetBrains_Mono({
  subsets: ['latin'],
  variable: '--font-mono',
})

export const metadata: Metadata = {
  title: 'Frosty for Twitch',
  description: 'Frosty lets you watch Twitch with 7TV, BTTV, and FFZ emotes',
  metadataBase: new URL('https://frostyapp.io'),
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html
      lang='en'
      style={{ colorScheme: 'light dark' }}
      suppressHydrationWarning
    >
      <body
        className={twJoin(
          'selection:bg-primary selection:text-primary-foreground min-h-dvh font-sans underline-offset-4 antialiased',
          fontSans.variable,
          fontMono.variable,
        )}
      >
        <Providers>
          <main>{children}</main>
        </Providers>
      </body>
    </html>
  )
}
