import { cn } from '@/lib/utils';
import { Dumbbell } from 'lucide-react';

export function Logo({ className }: { className?: string }) {
  return (
    <div className={cn("flex items-center gap-3", className)}>
      <div className="bg-primary p-2 rounded-lg">
        <Dumbbell className="h-6 w-6 text-primary-foreground" />
      </div>
      <h1 className="font-bold text-xl">FitTrack Pro</h1>
    </div>
  );
}
