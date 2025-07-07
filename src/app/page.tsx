import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Dumbbell, UtensilsCrossed, BarChart, BookOpen } from "lucide-react";

import { Logo } from "@/components/logo";
import { WorkoutGenerator } from "@/components/workout-generator";
import { MealPlanner } from "@/components/meal-planner";
import { ProgressTracker } from "@/components/progress-tracker";
import { EducationalResources } from "@/components/educational-resources";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center p-4 sm:p-8 md:p-12 bg-background">
      <header className="w-full max-w-4xl mx-auto mb-8">
        <Logo />
        <p className="text-muted-foreground mt-2">Your AI-powered fitness and diet coach.</p>
      </header>

      <div className="w-full">
        <Tabs defaultValue="workout" className="w-full">
          <TabsList className="grid w-full max-w-4xl mx-auto grid-cols-2 md:grid-cols-4 h-auto md:h-12">
            <TabsTrigger value="workout" className="py-2.5">
              <Dumbbell className="w-4 h-4 mr-2" /> Workout
            </TabsTrigger>
            <TabsTrigger value="meal" className="py-2.5">
              <UtensilsCrossed className="w-4 h-4 mr-2" /> Meal Plan
            </TabsTrigger>
            <TabsTrigger value="progress" className="py-2.5">
              <BarChart className="w-4 h-4 mr-2" /> My Progress
            </TabsTrigger>
            <TabsTrigger value="resources" className="py-2.5">
              <BookOpen className="w-4 h-4 mr-2" /> Resources
            </TabsTrigger>
          </TabsList>

          <div className="mt-6">
            <TabsContent value="workout">
              <WorkoutGenerator />
            </TabsContent>
            <TabsContent value="meal">
              <MealPlanner />
            </TabsContent>
            <TabsContent value="progress">
              <ProgressTracker />
            </TabsContent>
            <TabsContent value="resources">
              <EducationalResources />
            </TabsContent>
          </div>
        </Tabs>
      </div>
    </main>
  );
}
