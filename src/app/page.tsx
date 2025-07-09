import { Header } from "@/components/header";
import { Button } from "@/components/ui/button";
import { Calendar, Zap, Dumbbell, UtensilsCrossed, LineChart, FileText } from "lucide-react";
import StatCard from "@/components/dashboard/stat-card";
import RecentWorkouts from "@/components/dashboard/recent-workouts";
import ProteinIntakeChart from "@/components/dashboard/member-attendance-chart";
import UserProfileCard from "@/components/dashboard/featured-member";
import DietLogs from "@/components/dashboard/diet-logs";
import Link from "next/link";

export default function DashboardPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="Your Dashboard" description="An overview of your fitness journey." />
      <div className="p-4 md:p-8 space-y-8 overflow-y-auto">
        
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
          <StatCard title="Workouts This Week" value="3" change="+1 from last week" icon={Zap} />
          <StatCard title="Active Calories" value="1,850" change="-150 from yesterday" icon={UtensilsCrossed} />
          <StatCard title="Current Weight" value="182 lbs" change="-1.2 lbs this week" icon={LineChart} />
          <StatCard title="Workout Streak" value="5 days" change="Keep it up!" icon={Calendar} />
        </div>
        
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium" asChild><Link href="/workout-generator"><Dumbbell className="mr-2 h-5 w-5 text-primary" /> AI Workout Generator</Link></Button>
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
            <DietLogs />
          </div>
        </div>

      </div>
    </div>
  )
}
