import { Providers } from '@/components/Providers'
import { type Metadata } from 'next'
import { Inter, JetBrains_Mono } from 'next/font/google'
import { twJoin } from 'tailwind-merge'
import './globals.css'

const fontSans = Inter({
  subsets: ['latin'],
  variable: '--font-sans',
  axes: ['opsz'],
})
const fontMono = JetBrains_Mono({
  subsets: ['latin'],
  variable: '--font-mono',
})

export const metadata: Metadata = {
  metadataBase: new URL('https://frostyapp.io'),
  title: {
    default: 'Frosty for Twitch',
    template: '%s — Frosty',
  },
  description:
    'A fast, open-source Twitch client for iOS and Android with native 7TV, BTTV, and FFZ emote support.',
  openGraph: {
    siteName: 'Frosty',
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
  },
  alternates: {
    canonical: '/',
  },
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
