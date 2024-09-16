import screenshotCategories from '@/assets/screenshot-categories.png';
import screenshotChannel from '@/assets/screenshot-channel.png';
import screenshotFollowing from '@/assets/screenshot-following.png';
import screenshotSettings from '@/assets/screenshot-settings.png';
import { FeatureCard } from '@/components/FeatureCard';
import {
  appStoreLink,
  bttvLink,
  emailLink,
  ffzLink,
  githubLink,
  playStoreLink,
  sevenTvLink,
  twitchLink,
} from '@/lib/constants';
import Image from 'next/image';
import Marquee from 'react-fast-marquee';
import { SiApple, SiGoogleplay } from 'react-icons/si';

const NUM_ROWS = 10;
const NUM_COLUMNS = 40;

const coreFeatures = [
  {
    caption: 'See and pin followed channels',
    screenshot: screenshotFollowing,
  },
  {
    caption: 'Explore top streams and categories',
    screenshot: screenshotCategories,
  },
  {
    caption: 'Watch and chat with 7TV, BTTV, and FFZ emotes',
    screenshot: screenshotChannel,
  },
  {
    caption: 'Customize a variety of settings',
    screenshot: screenshotSettings,
  },
];

const faqs = [
  {
    question: 'Why are some Twitch features not in Frosty?',
    answer:
      'The Twitch API only exposes a limited set of functionality to developers. Features like predictions, polls, pinned messages, VODs with chat, stream qualities, total view count for categories and more are not available.',
  },
  {
    question: 'Why is the stream delayed on iOS?',
    answer:
      'There is a delay of around 15 seconds due to how the native iOS player works. As a workaround, Frosty has a message delay option that lets you set the delay (in seconds) before each message is rendered.',
  },
  {
    question: 'Is ad block planned?',
    answer:
      'Ad block is not planned because it would probably violate the Twitch terms of service.',
  },
  {
    question: 'Will Frosty support Apple/Android TV?',
    answer:
      "Not yet, because Flutter (the framework that Frosty is built upon) doesn't officially support TVs.",
  },
  {
    question: 'Where can I report a bug or request a new feature?',
    answer: (
      <>
        You can open a new issue on the{' '}
        <a
          className='underline'
          href={githubLink}
          target='_blank'
          rel='noreferrer'
        >
          GitHub repo
        </a>{' '}
        or email{' '}
        <a
          className='underline'
          href={emailLink}
          target='_blank'
          rel='noreferrer'
        >
          contact@frostyapp.io
        </a>
        .
      </>
    ),
  },
];

export default function Home() {
  const downloadButtons = (
    <div className='grid w-full grid-cols-2 gap-4 font-semibold text-neutral-100 md:gap-8'>
      <a
        className='flex items-center justify-center gap-2 rounded-xl bg-blue-800 p-4 transition hover:bg-blue-900'
        href={appStoreLink}
        target='_blank'
        rel='noreferrer'
      >
        <SiApple />
        App Store
      </a>
      <a
        className='flex items-center justify-center gap-2 rounded-xl bg-green-800 p-4 transition hover:bg-green-900'
        href={playStoreLink}
        target='_blank'
        rel='noreferrer'
      >
        <SiGoogleplay />
        Google Play
      </a>
    </div>
  );

  return (
    <article className='mt-24 flex flex-col gap-8 md:gap-16'>
      <section className='grid w-full items-center rounded-2xl border border-neutral-300 dark:border-neutral-900 [&>*]:col-start-1 [&>*]:row-start-1'>
        <div className='flex flex-col gap-4'>
          {Array.from({ length: NUM_ROWS }).map((_, rowIndex) => (
            <Marquee key={rowIndex} direction={rowIndex % 2 ? 'left' : 'right'}>
              {Array.from({ length: NUM_COLUMNS }).map((_, colIndex) => (
                <Image
                  key={colIndex}
                  width={32}
                  height={32}
                  alt='pepeD'
                  unoptimized
                  src='https://cdn.7tv.app/emote/6072a16fdcae02001b44e614/4x.webp'
                />
              ))}
            </Marquee>
          ))}
        </div>

        <div className='z-10 justify-self-center p-8'>
          <video
            className='h-[75vh] max-h-[800px] rounded-xl border border-neutral-300 bg-black object-contain py-4 dark:border-neutral-900'
            src='/video.webm'
            autoPlay
            loop
            muted
            playsInline
            disableRemotePlayback
          />
        </div>
      </section>

      <section className='flex flex-col gap-4 md:gap-8'>
        <h1 className='text-pretty text-center text-xl font-semibold decoration-2 underline-offset-4 md:text-2xl'>
          Frosty lets you watch{' '}
          <a
            className='text-twitch-purple underline'
            href={twitchLink}
            target='_blank'
            rel='noreferrer'
          >
            Twitch
          </a>{' '}
          with{' '}
          <a
            className='text-twitch-purple underline'
            href={sevenTvLink}
            target='_blank'
            rel='noreferrer'
          >
            7TV
          </a>
          ,{' '}
          <a
            className='text-twitch-purple underline'
            href={bttvLink}
            target='_blank'
            rel='noreferrer'
          >
            BTTV
          </a>
          , and{' '}
          <a
            className='text-twitch-purple underline'
            href={ffzLink}
            target='_blank'
            rel='noreferrer'
          >
            FFZ
          </a>{' '}
          emotes
        </h1>

        {downloadButtons}
      </section>

      <div className='flex flex-col gap-8 md:grid md:grid-cols-2'>
        {coreFeatures.map((feature, index) => (
          <FeatureCard key={index} {...feature} />
        ))}
      </div>

      <section
        className='mt-8 flex flex-col items-center gap-8 sm:mt-0'
        id='faq'
      >
        <h2 className='text-lg font-semibold md:text-xl'>
          Frequently asked questions
        </h2>

        <div className='w-full divide-y divide-neutral-300 overflow-clip rounded-xl border border-neutral-300 dark:divide-neutral-900 dark:border-neutral-900'>
          {faqs.map((faq, index) => (
            <details key={index}>
              <summary className='p-8 font-medium transition hover:cursor-pointer hover:bg-neutral-200 dark:hover:bg-neutral-950'>
                {faq.question}
              </summary>
              <p className='border-t border-neutral-300 p-8 text-neutral-600 dark:border-neutral-900 dark:text-neutral-300'>
                {faq.answer}
              </p>
            </details>
          ))}
        </div>
      </section>
    </article>
  );
}
