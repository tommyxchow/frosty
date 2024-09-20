import { Footer } from '@/components/Footer';
import { Header } from '@/components/Header';
import { Providers } from '@/components/Providers';
import { type Metadata } from 'next';
import { Inter } from 'next/font/google';
import { twJoin } from 'tailwind-merge';
import './globals.css';

const fontSans = Inter({ subsets: ['latin'], variable: '--font-sans' });

export const metadata: Metadata = {
  title: 'Frosty for Twitch',
  description: 'Frosty lets you watch Twitch with 7TV, BTTV, and FFZ emotes',
  metadataBase: new URL('https://frostyapp.io'),
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang='en' suppressHydrationWarning>
      <body
        className={twJoin(
          'mx-auto min-h-screen max-w-screen-lg border-neutral-300 bg-neutral-100 font-sans text-neutral-950 dark:border-neutral-900 dark:bg-black dark:text-neutral-100 lg:border-x',
          fontSans.variable,
        )}
      >
        <Providers>
          <Header />
          <main className='grow'>{children}</main>
          <Footer />
        </Providers>
      </body>
    </html>
  );
}
