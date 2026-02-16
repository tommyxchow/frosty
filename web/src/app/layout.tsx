import { Footer } from '@/components/Footer'
import { Header } from '@/components/Header'
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
          'border-border selection:bg-primary selection:text-primary-foreground mx-auto flex min-h-dvh max-w-screen-lg flex-col font-sans underline-offset-4 antialiased lg:border-x',
          fontSans.variable,
          fontMono.variable,
        )}
      >
        <Providers>
          <Header />
          <main className='grow'>{children}</main>
          <Footer />
        </Providers>
      </body>
    </html>
  )
}
