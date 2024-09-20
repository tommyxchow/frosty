import Image, { type StaticImageData } from 'next/image';

interface FeatureCardProps {
  caption: string;
  screenshot: StaticImageData;
}

export function FeatureCard({ caption, screenshot }: FeatureCardProps) {
  return (
    <figure className='flex flex-col items-center gap-4'>
      <Image
        className='max-h-[75vh] w-fit border border-neutral-300 dark:border-neutral-900'
        src={screenshot}
        alt={caption}
        placeholder='blur'
      />
      <figcaption className='text-pretty text-center text-sm text-neutral-500 dark:text-neutral-400'>
        {caption}
      </figcaption>
    </figure>
  );
}
