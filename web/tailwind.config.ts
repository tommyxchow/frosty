import forms from '@tailwindcss/forms';
import typography from '@tailwindcss/typography';
import { type Config } from 'tailwindcss';

export default {
  darkMode: 'class',
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['var(--font-sans)'],
      },
      colors: {
        'twitch-purple': '#9146ff',
      },
    },
  },
  plugins: [forms, typography],
} satisfies Config;
