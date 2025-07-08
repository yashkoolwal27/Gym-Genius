import type {Metadata} from 'next';
import './globals.css';
import { Toaster } from "@/components/ui/toaster";
import { Sidebar } from '@/components/sidebar';

export const metadata: Metadata = {
  title: 'Gym Genius',
  description: 'Your personal AI fitness and nutrition guide.',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
      </head>
      <body className="font-body antialiased">
        <div className="min-h-screen bg-secondary/40 flex">
          <Sidebar />
          <main className="flex-1 flex flex-col md:ml-64">
            {children}
          </main>
        </div>
        <Toaster />
      </body>
    </html>
  );
}
