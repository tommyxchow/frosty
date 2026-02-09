import Image, { type StaticImageData } from 'next/image'

interface FeatureCardProps {
  caption: string
  screenshot: StaticImageData
}

export function FeatureCard({ caption, screenshot }: FeatureCardProps) {
  return (
    <figure className='flex flex-col items-center gap-4'>
      <Image
        className='border-border max-h-[75vh] w-fit border'
        src={screenshot}
        alt={caption}
        placeholder='blur'
      />
      <figcaption className='text-muted-foreground text-center text-sm text-pretty'>
        {caption}
      </figcaption>
    </figure>
  )
}
