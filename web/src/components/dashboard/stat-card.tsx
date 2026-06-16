import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { ArrowUp, ArrowDown } from "lucide-react";
import type { LucideIcon } from "lucide-react";

interface StatCardProps {
  title: string;
  value: string;
  change: string;
  icon: LucideIcon;
  onClick?: () => void;
}

export default function StatCard({ title, value, change, icon: Icon, onClick }: StatCardProps) {
  const isIncrease = change.startsWith('+');
  const isDecrease = change.startsWith('-');

  return (
    <Card onClick={onClick} className={cn(onClick && "cursor-pointer hover:bg-muted/50 transition-colors")}>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">{title}</CardTitle>
        <div className="p-2 rounded-lg bg-primary/10">
          <Icon className="h-5 w-5 text-primary" />
        </div>
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        <div className="flex items-center text-xs text-muted-foreground">
          {(isIncrease || isDecrease) && (
            <span className={cn(
              "flex items-center gap-1", 
              isIncrease && "text-green-600",
              isDecrease && "text-red-600"
            )}>
              {isIncrease ? <ArrowUp className="h-4 w-4" /> : <ArrowDown className="h-4 w-4" />}
              {change.substring(1).split(' ')[0]}
            </span>
          )}
          <span className="ml-1">{change.substring(change.indexOf(' '))}</span>
        </div>
      </CardContent>
    </Card>
  )
}
