'use client';

import { ThemeProvider } from 'next-themes';

interface ProvidersProps {
  children: React.ReactNode;
}

export function Providers({ children }: ProvidersProps) {
  return <ThemeProvider attribute='class'>{children}</ThemeProvider>;
}
