import type { Metadata } from 'next'
import Image from 'next/image'
import Link from 'next/link'

export const metadata: Metadata = {
  title: 'Privacy Policy',
  description:
    'Privacy policy for Frosty, an open-source Twitch client for iOS and Android.',
  alternates: {
    canonical: '/privacy',
  },
}

function ExtLink({
  href,
  children,
}: {
  href: string
  children: React.ReactNode
}) {
  return (
    <a
      href={href}
      target='_blank'
      rel='noreferrer'
      className='text-muted-foreground decoration-muted-foreground/40 hover:text-foreground hover:decoration-foreground/40 underline underline-offset-4 transition-colors'
    >
      {children}
    </a>
  )
}

export default function Privacy() {
  return (
    <div className='mx-auto max-w-2xl px-6 py-12 font-mono'>
      <Link href='/' className='mb-12 flex items-center gap-2'>
        <Image src='/logo.svg' alt='' width={24} height={24} />
        <span className='text-foreground font-sans text-sm font-semibold'>
          Frosty
        </span>
      </Link>

      <h1 className='text-foreground text-2xl font-bold tracking-tight'>
        Privacy Policy
      </h1>
      <p className='text-muted-foreground mt-1 text-sm'>
        Last updated: February 2026
      </p>

      <p className='text-muted-foreground mt-8 text-sm leading-relaxed'>
        Frosty is an unofficial open-source mobile Twitch client for iOS and
        Android. We are dedicated to protecting your privacy. Frosty does not
        collect or share any personal information. However, we may gather
        anonymous usage data and crash logs solely to improve the app. For more
        information, please refer to the sections below.
      </p>

      <h2 className='text-foreground mt-10 text-lg font-semibold tracking-tight'>
        Third-party services
      </h2>
      <p className='text-muted-foreground mt-3 text-sm leading-relaxed'>
        Frosty uses and interacts with the following services in order to
        provide the best experience possible:
      </p>

      <h3 className='text-foreground mt-8 text-base font-semibold'>Twitch</h3>
      <p className='text-muted-foreground mt-2 text-sm leading-relaxed'>
        Frosty uses the official Twitch API to showcase live channels, connect
        to chat, and provide additional features. You can optionally log in with
        your Twitch account to access user-specific features, such as sending
        chat messages and viewing your followed channels.
      </p>
      <p className='text-muted-foreground mt-3 text-sm leading-relaxed'>
        If you log in using Twitch, Frosty will only ask you for the necessary
        and required permissions to function. Frosty will then obtain your OAuth
        access token and send requests to receive and transmit data to Twitch
        only on your behalf. This access token is stored and encrypted locally
        on your device only.
      </p>
      <p className='text-muted-foreground mt-3 text-sm leading-relaxed'>
        For more information on how Twitch handles your data, please refer to
        their{' '}
        <ExtLink href='https://www.twitch.tv/p/en/legal/privacy-notice/'>
          privacy policy
        </ExtLink>
        .
      </p>

      <h3 className='text-foreground mt-8 text-base font-semibold'>
        7TV, BetterTTV, and FrankerFaceZ
      </h3>
      <p className='text-muted-foreground mt-2 text-sm leading-relaxed'>
        Frosty uses APIs from 7TV, BetterTTV (BTTV), and FrankerFaceZ (FFZ) to
        display custom badges and emotes in chat. When you view a channel,
        Frosty will request these services using the channel&apos;s public
        Twitch ID or username to obtain emotes and badges associated with that
        channel.
      </p>
      <p className='text-muted-foreground mt-3 text-sm leading-relaxed'>
        For more information on how these services handle your data, please
        refer to their respective privacy policies:{' '}
        <ExtLink href='https://7tv.app/legal/privacy'>7TV</ExtLink>,{' '}
        <ExtLink href='https://betterttv.com/privacy'>BTTV</ExtLink>, and{' '}
        <ExtLink href='https://www.frankerfacez.com/privacy'>FFZ</ExtLink>.
      </p>

      <h3 className='text-foreground mt-8 text-base font-semibold'>Firebase</h3>
      <p className='text-muted-foreground mt-2 text-sm leading-relaxed'>
        Frosty utilizes Firebase for crash reporting, performance monitoring,
        and analytics to aid in the development of new features, improvements,
        and bug fixes. Data collected may include device model, OS version,
        crash traces, session analytics, and network performance traces. This
        data is anonymous and does not contain any personal information. You can
        opt out of this data collection by turning off crash logs and analytics
        in the settings.
      </p>
      <p className='text-muted-foreground mt-3 text-sm leading-relaxed'>
        Firebase retains analytics and crash data according to its default
        retention periods. For more information, please refer to the{' '}
        <ExtLink href='https://firebase.google.com/support/privacy'>
          Firebase privacy policy
        </ExtLink>
        .
      </p>

      <h2 className='text-foreground mt-10 text-lg font-semibold tracking-tight'>
        Data retention
      </h2>
      <p className='text-muted-foreground mt-3 text-sm leading-relaxed'>
        Frosty does not operate its own servers or databases. All data
        collection is handled by Firebase, which retains data according to its
        default retention policies.
      </p>

      <h2 className='text-foreground mt-10 text-lg font-semibold tracking-tight'>
        Privacy policy updates
      </h2>
      <p className='text-muted-foreground mt-3 text-sm leading-relaxed'>
        We may occasionally update this privacy policy, and the most recent
        version will always be available on this page. We recommend reviewing
        this privacy policy periodically for any changes. Changes to this
        privacy policy become effective when they are posted on this page.
      </p>

      <h2 className='text-foreground mt-10 text-lg font-semibold tracking-tight'>
        Contact
      </h2>
      <p className='text-muted-foreground mt-3 text-sm leading-relaxed'>
        If you have any questions or suggestions about this privacy policy,
        please feel free to contact us at{' '}
        <ExtLink href='mailto:contact@frostyapp.io'>
          contact@frostyapp.io
        </ExtLink>
        .
      </p>
    </div>
  )
}
