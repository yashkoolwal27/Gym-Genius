import { Header } from "@/components/header";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { AlertCircle, Calendar, DollarSign, PlusCircle, UserPlus, Users, Utensils, Zap } from "lucide-react";
import StatCard from "@/components/dashboard/stat-card";
import RecentWorkouts from "@/components/dashboard/recent-workouts";
import DietAndExerciseChart from "@/components/dashboard/member-attendance-chart";
import FeaturedMember from "@/components/dashboard/featured-member";
import DietLogs from "@/components/dashboard/diet-logs";
import RecentActivity from "@/components/dashboard/recent-activity";
import UpcomingClasses from "@/components/dashboard/upcoming-classes";

export default function DashboardPage() {
  return (
    <div className="flex-1">
      <Header />
      <div className="p-4 md:p-8 space-y-8">
        <div className="space-y-6">
          <Alert variant="destructive" className="bg-destructive/10 border-destructive/20 text-destructive">
            <AlertCircle className="h-4 w-4" />
            <AlertTitle>Missed Workout: John Wilson</AlertTitle>
            <AlertDescription className="text-destructive/80">
              John missed his scheduled HIIT session today. Give him a call or send a text. Today, 09:42 AM
            </AlertDescription>
          </Alert>

          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
            <StatCard title="Active Members" value="312" change="+4.7% increase" iconBg="bg-blue-100" iconColor="text-blue-500" icon={Users} />
            <StatCard title="Workouts Completed" value="1,128" change="+8.2% increase" iconBg="bg-orange-100" iconColor="text-orange-500" icon={Zap} />
            <StatCard title="Diet Plans Followed" value="214" change="-1.2% decrease" iconBg="bg-purple-100" iconColor="text-purple-500" icon={Utensils} />
            <StatCard title="Total Revenue" value="$24,350" change="+12.5% increase" iconBg="bg-green-100" iconColor="text-green-500" icon={DollarSign} />
          </div>

          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
             <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium"><UserPlus className="mr-2 h-5 w-5 text-primary" /> New Member</Button>
             <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium"><Zap className="mr-2 h-5 w-5 text-primary" /> Log Workout</Button>
             <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium"><PlusCircle className="mr-2 h-5 w-5 text-primary" /> Add Diet Plan</Button>
             <Button variant="outline" className="bg-card justify-start h-12 text-base font-medium"><Calendar className="mr-2 h-5 w-5 text-primary" /> Schedule</Button>
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
