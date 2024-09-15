import screenshotCategories from '@/assets/screenshot-categories.png';
import screenshotChannel from '@/assets/screenshot-channel.png';
import screenshotFollowing from '@/assets/screenshot-following.png';
import screenshotSearch from '@/assets/screenshot-search.png';
import { FeatureCard } from '@/components/FeatureCard';
import { appStoreLink, playStoreLink } from '@/lib/constants';
import Image from 'next/image';
import Marquee from 'react-fast-marquee';
import { SiApple, SiGoogleplay } from 'react-icons/si';

const NUM_ROWS = 10;
const NUM_COLUMNS = 40;

export default function Home() {
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
      caption: 'Search channels or categories',
      screenshot: screenshotSearch,
    },
    {
      caption: 'Watch and chat with 7TV, BTTV, and FFZ emotes',
      screenshot: screenshotChannel,
    },
    {
      caption: 'Customizable settings',
      screenshot: screenshotChannel,
    },
    {
      caption: 'Dark mode',
      screenshot: screenshotChannel,
    },
  ];

  const downloadButtons = (
    <div className='grid w-full grid-cols-2 gap-4 font-medium text-neutral-100'>
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
    <article className='flex flex-col gap-8 sm:gap-16'>
      <section className='mt-24 flex flex-col items-center gap-8 sm:gap-16'>
        <div className='grid w-full items-center rounded-2xl border border-neutral-300 dark:border-neutral-900 [&>*]:col-start-1 [&>*]:row-start-1'>
          <div className='flex flex-col gap-4'>
            {Array.from({ length: NUM_ROWS }).map((_, index) => (
              <Marquee key={index} direction={index % 2 ? 'left' : 'right'}>
                {Array.from({ length: NUM_COLUMNS }).map((_, index) => (
                  <Image
                    key={index}
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
              className='max-h-[800px] rounded-xl border border-neutral-300 object-contain dark:border-neutral-900'
              src='/video.webm'
              autoPlay
              loop
              muted
              playsInline
              disableRemotePlayback
            />
          </div>
        </div>

        <div className='flex flex-col gap-8'>
          <h1 className='text-pretty text-center text-xl font-bold md:text-2xl'>
            Frosty lets you watch Twitch with 7TV, BTTV, and FFZ emotes
          </h1>

          {downloadButtons}
        </div>
      </section>

      <section className='flex flex-col gap-8 sm:grid sm:grid-cols-2'>
        {coreFeatures.map((feature, index) => (
          <FeatureCard key={index} {...feature} />
        ))}
      </section>
    </article>
  );
}
