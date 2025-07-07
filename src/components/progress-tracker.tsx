"use client";

import { useLocalStorage } from "@/hooks/use-local-storage";
import type { WorkoutPlan, MealPlan } from "@/lib/types";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { Dumbbell, UtensilsCrossed, CalendarDays } from 'lucide-react';
import { format } from 'date-fns';

export function ProgressTracker() {
  const [workouts] = useLocalStorage<WorkoutPlan[]>("workout-plans", []);
  const [mealPlans] = useLocalStorage<MealPlan[]>("meal-plans", []);

  return (
    <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70">
      <CardHeader>
        <CardTitle className="flex items-center gap-2"><CalendarDays /> My Saved Plans</CardTitle>
        <CardDescription>Review your saved workout and meal plans. Stay consistent!</CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div>
            <h3 className="text-xl font-semibold flex items-center gap-2 mb-4"><Dumbbell /> Saved Workout Plans</h3>
            {workouts.length > 0 ? (
                <Accordion type="single" collapsible className="w-full">
                    {workouts.sort((a,b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()).map((workout) => (
                        <AccordionItem value={workout.id} key={workout.id}>
                            <AccordionTrigger>
                                <div className="flex flex-col text-left">
                                    <span>Workout Plan</span>
                                    <span className="text-sm text-muted-foreground">Saved on {format(new Date(workout.createdAt), "PPP")}</span>
                                </div>
                            </AccordionTrigger>
                            <AccordionContent>
                                <div className="p-4 bg-background rounded-md whitespace-pre-wrap font-mono text-sm">
                                    {workout.generatedPlan}
                                </div>
                            </AccordionContent>
                        </AccordionItem>
                    ))}
                </Accordion>
            ) : (
                <p className="text-muted-foreground italic text-center py-4">You haven't saved any workout plans yet.</p>
            )}
        </div>

        <div>
            <h3 className="text-xl font-semibold flex items-center gap-2 mb-4"><UtensilsCrossed /> Saved Meal Plans</h3>
            {mealPlans.length > 0 ? (
                <Accordion type="single" collapsible className="w-full">
                     {mealPlans.sort((a,b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()).map((meal) => (
                        <AccordionItem value={meal.id} key={meal.id}>
                            <AccordionTrigger>
                                <div className="flex flex-col text-left">
                                    <span>Meal Plan</span>
                                    <span className="text-sm text-muted-foreground">Saved on {format(new Date(meal.createdAt), "PPP")}</span>
                                </div>
                            </AccordionTrigger>
                            <AccordionContent>
                                <div className="p-4 bg-background rounded-md whitespace-pre-wrap font-mono text-sm">
                                    {meal.generatedPlan}
                                </div>
                            </AccordionContent>
                        </AccordionItem>
                    ))}
                </Accordion>
            ) : (
                <p className="text-muted-foreground italic text-center py-4">You haven't saved any meal plans yet.</p>
            )}
        </div>
      </CardContent>
    </Card>
  );
}
