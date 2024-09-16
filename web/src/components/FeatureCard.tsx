import Image, { type StaticImageData } from 'next/image';

interface FeatureCardProps {
  caption: string;
  screenshot: StaticImageData;
}

export function FeatureCard({ caption, screenshot }: FeatureCardProps) {
  return (
    <figure className='grid items-end overflow-clip rounded-2xl border border-neutral-300 dark:border-neutral-900 [&>*]:col-start-1 [&>*]:row-start-1'>
      <div className='justify-self-center px-12 pt-12'>
        <Image
          className='max-h-[75vh] w-fit rounded-xl border dark:border-neutral-900'
          src={screenshot}
          alt={caption}
          placeholder='blur'
        />
      </div>
      <div className='border-t border-neutral-300 bg-neutral-100 px-4 py-8 dark:border-neutral-900 dark:bg-black'>
        <figcaption className='text-pretty text-center font-medium text-neutral-600 dark:text-neutral-300'>
          {caption}
        </figcaption>
      </div>
    </figure>
  );
}
