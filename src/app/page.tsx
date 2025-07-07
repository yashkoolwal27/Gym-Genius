import { Header } from "@/components/header";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { AlertCircle, Calendar, PlusCircle, UserPlus, Zap, Dumbbell, UtensilsCrossed, LineChart, BookOpen } from "lucide-react";
import StatCard from "@/components/dashboard/stat-card";
import RecentWorkouts from "@/components/dashboard/recent-workouts";
import DietAndExerciseChart from "@/components/dashboard/member-attendance-chart";
import FeaturedMember from "@/components/dashboard/featured-member";
import DietLogs from "@/components/dashboard/diet-logs";
import RecentActivity from "@/components/dashboard/recent-activity";
import UpcomingClasses from "@/components/dashboard/upcoming-classes";
import Link from "next/link";

export default function DashboardPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="Dashboard" description="An overview of your fitness journey." />
      <div className="p-4 md:p-8 space-y-8 overflow-y-auto">
        <div className="space-y-6">
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
            <StatCard title="Workouts This Month" value="12" change="+2 from last month" iconBg="bg-blue-100" iconColor="text-blue-500" icon={Zap} />
            <StatCard title="Calories Today" value="1,850" change="-150 from yesterday" iconBg="bg-purple-100" iconColor="text-purple-500" icon={UtensilsCrossed} />
            <StatCard title="Weight" value="182 lbs" change="-1.2 lbs this week" iconBg="bg-green-100" iconColor="text-green-500" icon={LineChart} />
            <StatCard title="Streak" value="5 days" change="Keep it up!" iconBg="bg-orange-100" iconColor="text-orange-500" icon={Calendar} />
          </div>

          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
             <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium" asChild><Link href="/workout-generator"><Dumbbell className="mr-2 h-5 w-5 text-primary" /> New Workout</Link></Button>
             <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium" asChild><Link href="/meal-planner"><UtensilsCrossed className="mr-2 h-5 w-5 text-primary" /> New Meal Plan</Link></Button>
             <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium" asChild><Link href="/progress-tracker"><LineChart className="mr-2 h-5 w-5 text-primary" /> View Progress</Link></Button>
             <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium" asChild><Link href="/educational-resources"><BookOpen className="mr-2 h-5 w-5 text-primary" /> Learn More</Link></Button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2 space-y-8">
            <RecentWorkouts />
            <DietAndExerciseChart />
          </div>
          <div className="space-y-8">
            <FeaturedMember />
            <DietLogs />
          </div>
        </div>
        
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <RecentActivity />
            <UpcomingClasses />
        </div>

      </div>
    </div>
  )
}
