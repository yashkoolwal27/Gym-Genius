
"use client";

import { useLocalStorage } from "@/hooks/use-local-storage";
import type { WorkoutPlan, MealPlan, WorkoutLog, DietLog, WeightLog } from "@/lib/types";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { Dumbbell, UtensilsCrossed, CalendarDays, Weight, Repeat, PlusCircle, Sprout, Soup, Fish, Apple } from 'lucide-react';
import { format } from 'date-fns';
import { Badge } from "./ui/badge";
import { Button } from "./ui/button";
import Link from "next/link";
import WeightProgressChart from "./weight-progress-chart";

export function ProgressTracker() {
  const [workouts] = useLocalStorage<WorkoutPlan[]>("workout-plans", []);
  const [mealPlans] = useLocalStorage<MealPlan[]>("meal-plans", []);
  const [loggedWorkouts] = useLocalStorage<WorkoutLog[]>("workout-logs", []);
  const [dietLogs] = useLocalStorage<DietLog[]>("diet-logs", []);
  const [weightLogs] = useLocalStorage<WeightLog[]>("weight-logs", []);

  return (
    <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70">
      <CardHeader>
        <CardTitle className="flex items-center gap-2"><CalendarDays /> My Saved Plans & Logs</CardTitle>
        <CardDescription>Review your saved plans and logged workouts. Stay consistent!</CardDescription>
      </CardHeader>
      <CardContent className="space-y-8">
        
        <div>
          <h3 className="text-xl font-semibold flex items-center gap-2 mb-4"><Weight /> Weight Progress</h3>
          <WeightProgressChart weightLogs={weightLogs} />
        </div>
        
        <div>
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-xl font-semibold flex items-center gap-2"><Dumbbell /> Logged Workouts</h3>
              <Button asChild>
                <Link href="/workout">
                  <PlusCircle className="mr-2 h-4 w-4" /> Log New Workout
                </Link>
              </Button>
            </div>
            {loggedWorkouts.length > 0 ? (
                <Accordion type="single" collapsible className="w-full">
                    {loggedWorkouts.sort((a,b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()).map((log) => (
                        <AccordionItem value={log.id} key={log.id}>
                            <AccordionTrigger>
                                <div className="flex flex-col text-left">
                                    <span>Workout on {format(new Date(log.date), "PPP")} at {log.time}</span>
                                    <span className="text-sm text-muted-foreground">Logged on {format(new Date(log.createdAt), "PPP")}</span>
                                </div>
                            </AccordionTrigger>
                            <AccordionContent>
                                <div className="p-4 bg-background rounded-md space-y-4">
                                    <div className="flex flex-wrap gap-2 mb-4">
                                      {log.exerciseTypes.map(type => <Badge key={type} variant="secondary">{type}</Badge>)}
                                    </div>
                                    {log.exercises.map(exercise => (
                                        <div key={exercise.id} className="pb-2">
                                            <h4 className="font-semibold">{exercise.name}</h4>
                                            <ul className="pl-4 mt-2 space-y-1">
                                                {exercise.sets.map(set => (
                                                    <li key={set.id} className="flex items-center gap-6 text-sm text-muted-foreground">
                                                        <span className="flex items-center"><Repeat className="inline h-4 w-4 mr-2" />{set.reps || "0"} reps</span>
                                                        <span className="flex items-center"><Weight className="inline h-4 w-4 mr-2" />{set.weight || "0 kg"}</span>
                                                    </li>
                                                ))}
                                            </ul>
                                        </div>
                                    ))}
                                </div>
                            </AccordionContent>
                        </AccordionItem>
                    ))}
                </Accordion>
            ) : (
                <p className="text-muted-foreground italic text-center py-4">You haven't logged any workouts yet.</p>
            )}
        </div>
        
        <div>
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-xl font-semibold flex items-center gap-2"><UtensilsCrossed /> Logged Daily Diets</h3>
               <Button asChild>
                <Link href="/meal-planner">
                  <PlusCircle className="mr-2 h-4 w-4" /> Log New Diet
                </Link>
              </Button>
            </div>
            {dietLogs.length > 0 ? (
                <Accordion type="single" collapsible className="w-full">
                    {dietLogs.sort((a,b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()).map((log) => (
                        <AccordionItem value={log.id} key={log.id}>
                            <AccordionTrigger>
                                <div className="flex flex-col text-left">
                                    <span>Diet Log for {format(new Date(log.date), "PPP")}</span>
                                    <span className="text-sm text-muted-foreground">Logged on {format(new Date(log.createdAt), "PPP")}</span>
                                </div>
                            </AccordionTrigger>
                            <AccordionContent>
                                <div className="p-4 bg-background rounded-md space-y-4 text-sm">
                                    {log.meals.breakfast && <div><h4 className="font-semibold flex items-center gap-2 mb-1"><Sprout className="h-4 w-4 text-primary" />Breakfast</h4><p className="text-muted-foreground whitespace-pre-wrap pl-6">{log.meals.breakfast}</p></div>}
                                    {log.meals.lunch && <div><h4 className="font-semibold flex items-center gap-2 mb-1"><Soup className="h-4 w-4 text-primary" />Lunch</h4><p className="text-muted-foreground whitespace-pre-wrap pl-6">{log.meals.lunch}</p></div>}
                                    {log.meals.dinner && <div><h4 className="font-semibold flex items-center gap-2 mb-1"><Fish className="h-4 w-4 text-primary" />Dinner</h4><p className="text-muted-foreground whitespace-pre-wrap pl-6">{log.meals.dinner}</p></div>}
                                    {log.meals.snacks && <div><h4 className="font-semibold flex items-center gap-2 mb-1"><Apple className="h-4 w-4 text-primary" />Snacks</h4><p className="text-muted-foreground whitespace-pre-wrap pl-6">{log.meals.snacks}</p></div>}
                                </div>
                            </AccordionContent>
                        </AccordionItem>
                    ))}
                </Accordion>
            ) : (
                <p className="text-muted-foreground italic text-center py-4">You haven't logged any daily diets yet.</p>
            )}
        </div>

        <div>
            <h3 className="text-xl font-semibold flex items-center gap-2 mb-4"><Dumbbell /> Saved AI Workout Plans</h3>
            {workouts.length > 0 ? (
                <Accordion type="single" collapsible className="w-full">
                    {workouts.sort((a,b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()).map((workout) => (
                        <AccordionItem value={workout.id} key={workout.id}>
                            <AccordionTrigger>
                                <div className="flex flex-col text-left">
                                    <span>AI Generated Workout Plan</span>
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
                <p className="text-muted-foreground italic text-center py-4">You haven't saved any AI workout plans yet.</p>
            )}
        </div>

        <div>
            <h3 className="text-xl font-semibold flex items-center gap-2 mb-4"><UtensilsCrossed /> Saved AI Meal Plans</h3>
            {mealPlans.length > 0 ? (
                <Accordion type="single" collapsible className="w-full">
                     {mealPlans.sort((a,b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()).map((meal) => (
                        <AccordionItem value={meal.id} key={meal.id}>
                            <AccordionTrigger>
                                <div className="flex flex-col text-left">
                                    <span>AI Meal Plan</span>
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
                <p className="text-muted-foreground italic text-center py-4">You haven't saved any AI meal plans yet.</p>
            )}
        </div>
      </CardContent>
    </Card>
  );
}
