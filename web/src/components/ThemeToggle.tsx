'use client';

import { useTheme } from 'next-themes';
import { useEffect, useState } from 'react';
import { HiMoon, HiSun } from 'react-icons/hi2';

export function ThemeToggle() {
  const { resolvedTheme, setTheme } = useTheme();

  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return <div className='size-6' />;

  const isDarkMode = resolvedTheme === 'dark';

  return (
    <button
      className='p-4 transition hover:bg-neutral-200 dark:hover:bg-neutral-900'
      aria-label={`Toggle ${isDarkMode ? 'light mode' : 'dark mode'}`}
      onClick={() => setTheme(isDarkMode ? 'light' : 'dark')}
    >
      {isDarkMode ? (
        <HiSun className='size-6' />
      ) : (
        <HiMoon className='size-6' />
      )}
    </button>
  );
}
