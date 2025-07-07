import { BrainCircuit } from 'lucide-react';
import { cn } from '@/lib/utils';

export function Logo({ className }: { className?: string }) {
  return (
    <div className={cn("flex items-center gap-2 text-xl font-bold text-primary", className)}>
      <BrainCircuit className="h-7 w-7" />
      <h1 className="font-headline">Gym Genius</h1>
    </div>
  );
}
