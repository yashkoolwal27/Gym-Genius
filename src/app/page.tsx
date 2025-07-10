
"use client";

import { useState } from "react";
import { Header } from "@/components/header";
import { Button } from "@/components/ui/button";
import { Calendar, Zap, Dumbbell, UtensilsCrossed, LineChart, FileText } from "lucide-react";
import StatCard from "@/components/dashboard/stat-card";
import RecentWorkouts from "@/components/dashboard/recent-workouts";
import ProteinIntakeChart from "@/components/dashboard/member-attendance-chart";
import UserProfileCard from "@/components/dashboard/featured-member";
import RecentMeals from "@/components/dashboard/recent-meals";
import Link from "next/link";
import { useLocalStorage } from "@/hooks/use-local-storage";
import { WeightLogDialog } from "@/components/dashboard/weight-log-dialog";
import type { WeightLog } from "@/lib/types";

export default function DashboardPage() {
  const [weightLogs, setWeightLogs] = useLocalStorage<WeightLog[]>("weight-logs", []);
  const [isWeightLogOpen, setIsWeightLogOpen] = useState(false);

  const latestWeight = weightLogs.length > 0 ? weightLogs[weightLogs.length - 1].weight : 182;
  const previousWeight = weightLogs.length > 1 ? weightLogs[weightLogs.length - 2].weight : null;
  
  let weightChangeText = "-1.2 lbs this week";
  if (previousWeight !== null) {
      const diff = latestWeight - previousWeight;
      const direction = diff > 0 ? "+" : "";
      weightChangeText = `${direction}${diff.toFixed(1)} lbs from last entry`;
  }

  const handleWeightLogged = (newLog: WeightLog) => {
    setWeightLogs([...weightLogs, newLog]);
  };

  return (
    <div className="flex-1 flex flex-col">
      <Header title="Your Dashboard" description="An overview of your fitness journey." />
      <div className="p-4 md:p-8 space-y-8 overflow-y-auto">
        
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
          <StatCard title="Workouts This Week" value="3" change="+1 from last week" icon={Zap} />
          <StatCard title="Active Calories" value="1,850" change="-150 from yesterday" icon={UtensilsCrossed} />
          <StatCard title="Current Weight" value={`${latestWeight} lbs`} change={weightChangeText} icon={LineChart} onClick={() => setIsWeightLogOpen(true)} />
          <StatCard title="Workout Streak" value="5 days" change="Keep it up!" icon={Calendar} />
        </div>
        
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium" asChild><Link href="/workout"><Dumbbell className="mr-2 h-5 w-5 text-primary" /> AI Workout Generator</Link></Button>
            <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium" asChild><Link href="/meal-planner"><UtensilsCrossed className="mr-2 h-5 w-5 text-primary" /> New Meal Plan</Link></Button>
            <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium" asChild><Link href="/progress-tracker"><LineChart className="mr-2 h-5 w-5 text-primary" /> View Progress</Link></Button>
            <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium" asChild><Link href="/educational-resources"><FileText className="mr-2 h-5 w-5 text-primary" /> Read Articles</Link></Button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2 space-y-8">
            <RecentWorkouts />
            <ProteinIntakeChart />
          </div>
          <div className="space-y-8">
            <UserProfileCard />
            <RecentMeals />
          </div>
        </div>

      </div>
      <WeightLogDialog 
        isOpen={isWeightLogOpen} 
        onClose={() => setIsWeightLogOpen(false)} 
        onWeightLogged={handleWeightLogged}
        lastWeight={latestWeight}
      />
    </div>
  )
}
