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
    <div className='grid w-full grid-cols-2 divide-x divide-neutral-300 border-y border-neutral-300 font-semibold dark:divide-neutral-900 dark:border-neutral-900'>
      <a
        className='flex items-center justify-center gap-2 p-4 transition hover:bg-blue-700 hover:text-neutral-100 dark:hover:bg-blue-800'
        href={appStoreLink}
        target='_blank'
        rel='noreferrer'
      >
        <SiApple className='text-blue-500 dark:text-blue-500' />
        App Store
      </a>
      <a
        className='flex items-center justify-center gap-2 p-4 transition hover:bg-green-700 hover:text-neutral-100 dark:hover:bg-green-800'
        href={playStoreLink}
        target='_blank'
        rel='noreferrer'
      >
        <SiGoogleplay className='text-green-500 dark:text-green-400' />
        Google Play
      </a>
    </div>
  );

  return (
    <article className='flex flex-col'>
      <section>
        <div className='grid w-full items-center [&>*]:col-start-1 [&>*]:row-start-1'>
          <div className='flex flex-col gap-4'>
            {Array.from({ length: NUM_ROWS }).map((_, rowIndex) => (
              <Marquee
                key={rowIndex}
                direction={rowIndex % 2 ? 'left' : 'right'}
              >
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
          <div className='z-10 justify-self-center p-8 pt-16'>
            <video
              className='h-[75vh] max-h-[800px] border border-neutral-300 bg-black object-contain py-4 dark:border-neutral-900'
              src='/video.webm'
              autoPlay
              loop
              muted
              playsInline
              disableRemotePlayback
            />
          </div>
        </div>

        <h1 className='text-pretty p-8 pb-16 text-center text-xl font-semibold decoration-2 underline-offset-4 md:text-2xl'>
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
      </section>

      {downloadButtons}

      <section className='flex flex-col gap-16 p-16 md:grid md:grid-cols-2'>
        {coreFeatures.map((feature, index) => (
          <FeatureCard key={index} {...feature} />
        ))}
      </section>

      {downloadButtons}

      <section className='flex flex-col items-center' id='faq'>
        <h2 className='p-8 text-lg font-semibold md:text-xl'>
          Frequently asked questions
        </h2>

        <div className='w-full divide-y divide-neutral-300 border-y border-neutral-300 dark:divide-neutral-900 dark:border-neutral-900'>
          {faqs.map((faq, index) => (
            <details key={index}>
              <summary className='p-8 font-medium transition hover:cursor-pointer hover:bg-neutral-200 dark:hover:bg-neutral-900'>
                {faq.question}
              </summary>
              <p className='border-t border-neutral-300 px-12 py-8 text-neutral-600 dark:border-neutral-900 dark:text-neutral-300'>
                {faq.answer}
              </p>
            </details>
          ))}
        </div>
      </section>
    </article>
  );
}
