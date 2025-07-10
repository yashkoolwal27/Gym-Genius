
"use client"

import { MealPlanner } from "@/components/meal-planner";
import { Header } from "@/components/header";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { DietLogger } from "@/components/diet-logger";

export default function MealPlannerPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="Diet Plans" description="Generate meal plans or log your daily intake." />
      <div className="p-4 md:p-8 overflow-y-auto">
        <Tabs defaultValue="ai-planner" className="w-full max-w-4xl mx-auto">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="ai-planner">AI Meal Planner</TabsTrigger>
            <TabsTrigger value="diet-logger">Log Your Daily Diet</TabsTrigger>
          </TabsList>
          <TabsContent value="ai-planner">
            <MealPlanner />
          </TabsContent>
          <TabsContent value="diet-logger">
            <DietLogger />
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
