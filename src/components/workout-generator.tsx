"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { BrainCircuit, Dumbbell, Save, Loader2, Sparkles } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { getWorkoutPlan } from "@/lib/actions";
import { useLocalStorage } from "@/hooks/use-local-storage";
import type { WorkoutPlan } from "@/lib/types";
import { Skeleton } from "./ui/skeleton";

const formSchema = z.object({
  fitnessLevel: z.enum(['Beginner', 'Intermediate', 'Advanced']),
  goals: z.string().min(3, "Goals must be at least 3 characters."),
  availableEquipment: z.string().min(3, "Please list available equipment."),
  workoutDays: z.coerce.number().min(1).max(7),
  workoutType: z.string().min(3, "Workout type must be at least 3 characters."),
});

type FormValues = z.infer<typeof formSchema>;

function WorkoutPlanDisplay({ plan, onSave }: { plan: string; onSave: () => void }) {
  const exercises = plan.split('\n\n').filter(p => p.trim().length > 0);

  return (
    <Card className="mt-6 bg-white/50 dark:bg-black/50 border-primary/20 shadow-lg">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-primary">
          <Sparkles className="w-6 h-6" />
          Your Custom Workout Plan
        </CardTitle>
        <CardDescription>Here is your AI-generated workout plan. Remember to warm up before each session and cool down afterwards.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {exercises.map((exercise, index) => (
          <div key={index} className="p-4 border rounded-lg bg-background">
            <h3 className="font-semibold text-lg mb-2">{exercise.split('\n')[0]}</h3>
            <ul className="list-disc pl-5 space-y-1 text-muted-foreground">
              {exercise.split('\n').slice(1).map((step, stepIndex) => (
                step.trim() && <li key={stepIndex}>{step.trim().replace(/^- /,'')}</li>
              ))}
            </ul>
          </div>
        ))}
      </CardContent>
      <CardFooter>
        <Button onClick={onSave}><Save className="mr-2 h-4 w-4" /> Save Plan</Button>
      </CardFooter>
    </Card>
  );
}


export function WorkoutGenerator() {
  const [isLoading, setIsLoading] = useState(false);
  const [generatedPlan, setGeneratedPlan] = useState<string | null>(null);
  const [workouts, setWorkouts] = useLocalStorage<WorkoutPlan[]>("workout-plans", []);
  const { toast } = useToast();

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      fitnessLevel: "Beginner",
      goals: "General fitness and weight loss",
      availableEquipment: "Dumbbells and resistance bands",
      workoutDays: 3,
      workoutType: "Full body strength training",
    },
  });

  async function onSubmit(values: FormValues) {
    setIsLoading(true);
    setGeneratedPlan(null);
    const result = await getWorkoutPlan(values);
    setIsLoading(false);

    if (result.success && result.data?.workoutPlan) {
      setGeneratedPlan(result.data.workoutPlan);
    } else {
      toast({
        variant: "destructive",
        title: "Oh no! Something went wrong.",
        description: result.error || "Failed to generate workout plan.",
      });
    }
  }
  
  const handleSavePlan = () => {
    if (generatedPlan) {
      const newPlan: WorkoutPlan = {
        id: new Date().toISOString(),
        generatedPlan: generatedPlan,
        createdAt: new Date().toISOString(),
      };
      setWorkouts([...workouts, newPlan]);
      toast({
        title: "Plan Saved!",
        description: "Your workout plan has been saved to 'My Progress'.",
      });
    }
  };

  return (
    <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70">
      <CardHeader>
        <CardTitle className="flex items-center gap-2"><Dumbbell /> AI Workout Generator</CardTitle>
        <CardDescription>Tell us about your goals and we'll generate a personalized workout plan for you.</CardDescription>
      </CardHeader>
      <CardContent>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <FormField
                  control={form.control}
                  name="fitnessLevel"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Fitness Level</FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger><SelectValue placeholder="Select your fitness level" /></SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          <SelectItem value="Beginner">Beginner</SelectItem>
                          <SelectItem value="Intermediate">Intermediate</SelectItem>
                          <SelectItem value="Advanced">Advanced</SelectItem>
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="workoutDays"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Workout Days per Week</FormLabel>
                      <FormControl>
                        <Input type="number" min="1" max="7" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
            </div>

            <FormField
              control={form.control}
              name="goals"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Your Fitness Goals</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g., Lose weight, build muscle, improve endurance" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="availableEquipment"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Available Equipment</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g., Dumbbells, resistance bands, gym access" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            
            <FormField
              control={form.control}
              name="workoutType"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Preferred Workout Type</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g., Strength training, cardio, HIIT" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <Button type="submit" disabled={isLoading} className="w-full bg-accent hover:bg-accent/90 text-accent-foreground">
              {isLoading ? (
                <><Loader2 className="mr-2 h-4 w-4 animate-spin" /> Generating...</>
              ) : (
                <><BrainCircuit className="mr-2 h-4 w-4" /> Generate Plan</>
              )}
            </Button>
          </form>
        </Form>
        
        {isLoading && (
          <div className="space-y-4 mt-6">
            <Skeleton className="h-8 w-1/2" />
            <Skeleton className="h-4 w-3/4" />
            <div className="space-y-2 pt-4">
              <Skeleton className="h-24 w-full" />
              <Skeleton className="h-24 w-full" />
            </div>
          </div>
        )}
        
        {generatedPlan && <WorkoutPlanDisplay plan={generatedPlan} onSave={handleSavePlan} />}
      </CardContent>
    </Card>
  );
}
