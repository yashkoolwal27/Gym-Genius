
"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { BrainCircuit, Dumbbell, Save, Loader2, Sparkles, CheckSquare, Square } from "lucide-react";
import { format } from "date-fns";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Calendar } from "@/components/ui/calendar";
import { useToast } from "@/hooks/use-toast";
import { getWorkoutPlan } from "@/lib/actions";
import { useLocalStorage } from "@/hooks/use-local-storage";
import type { WorkoutPlan } from "@/lib/types";
import { Skeleton } from "./ui/skeleton";
import { cn } from "@/lib/utils";
import { CalendarIcon } from "lucide-react";

const workoutTypes = ["Strength Training", "Cardio", "HIIT", "Yoga", "Pilates", "CrossFit"];

const formSchema = z.object({
  fitnessLevel: z.enum(['Beginner', 'Intermediate', 'Advanced']),
  goals: z.string().min(3, "Please describe your fitness goals."),
  availableEquipment: z.string().min(3, "Please list your available equipment."),
  workoutDays: z.coerce.number().min(1).max(7),
  exerciseTypes: z.array(z.string()).min(1, "Please select at least one workout type."),
  workoutDate: z.date({ required_error: "Please select a date."}),
  workoutTime: z.string({ required_error: "Please select a time."}),
});

type FormValues = z.infer<typeof formSchema>;

function WorkoutPlanDisplay({ plan, onSave }: { plan: string; onSave: () => void }) {
  const planSections = plan.split('\n\n').filter(p => p.trim().length > 0);

  return (
    <Card className="mt-6 bg-white/50 dark:bg-black/50 border-primary/20 shadow-lg">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-primary">
          <Sparkles className="w-6 h-6" />
          Your Custom Workout Plan
        </CardTitle>
        <CardDescription>Here's a personalized workout plan designed to help you reach your goals.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4 whitespace-pre-wrap font-mono text-sm">
        {plan}
      </CardContent>
      <CardFooter>
        <Button onClick={onSave}><Save className="mr-2 h-4 w-4" /> Save Plan</Button>
      </CardFooter>
    </Card>
  );
}

export function AIWorkoutGenerator() {
  const [isLoading, setIsLoading] = useState(false);
  const [generatedPlan, setGeneratedPlan] = useState<string | null>(null);
  const [workouts, setWorkouts] = useLocalStorage<WorkoutPlan[]>("workout-plans", []);
  const { toast } = useToast();

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      fitnessLevel: "Beginner",
      goals: "Build muscle and improve overall fitness",
      availableEquipment: "Dumbbells, resistance bands",
      workoutDays: 3,
      exerciseTypes: ["Strength Training"],
      workoutDate: new Date(),
      workoutTime: "08:00",
    },
  });

  async function onSubmit(values: FormValues) {
    setIsLoading(true);
    setGeneratedPlan(null);
    const formattedValues = {
        ...values,
        workoutDate: format(values.workoutDate, "yyyy-MM-dd"),
    };
    const result = await getWorkoutPlan(formattedValues);
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
        <CardDescription>Tell us about your goals and preferences, and our AI will create a workout plan for you.</CardDescription>
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
                        <SelectTrigger>
                            <SelectValue placeholder="Select your fitness level" />
                        </SelectTrigger>
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
                        <FormLabel>Days Per Week</FormLabel>
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
                  <FormLabel>Fitness Goals</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g., Lose 10 pounds, run a 5k" {...field} />
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
                    <Input placeholder="e.g., Full gym access, dumbbells, bodyweight only" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
             <FormField
                control={form.control}
                name="exerciseTypes"
                render={({ field }) => (
                    <FormItem>
                        <FormLabel>Preferred Workout Types</FormLabel>
                         <FormControl>
                            <div className="grid grid-cols-2 md:grid-cols-3 gap-2 pt-2">
                                {workoutTypes.map((type) => {
                                    const isSelected = field.value.includes(type);
                                    return (
                                        <Button
                                            key={type}
                                            type="button"
                                            variant={isSelected ? "secondary" : "outline"}
                                            onClick={() => {
                                                const newValue = isSelected
                                                    ? field.value.filter(t => t !== type)
                                                    : [...field.value, type];
                                                field.onChange(newValue);
                                            }}
                                            className="justify-start"
                                        >
                                            {isSelected ? <CheckSquare className="mr-2 h-4 w-4" /> : <Square className="mr-2 h-4 w-4" />}
                                            {type}
                                        </Button>
                                    );
                                })}
                            </div>
                        </FormControl>
                        <FormMessage />
                    </FormItem>
                )}
             />
             <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <FormField
                    control={form.control}
                    name="workoutDate"
                    render={({ field }) => (
                        <FormItem className="flex flex-col">
                        <FormLabel>Start Date</FormLabel>
                        <Popover>
                            <PopoverTrigger asChild>
                            <FormControl>
                                <Button
                                variant={"outline"}
                                className={cn(
                                    "w-full pl-3 text-left font-normal",
                                    !field.value && "text-muted-foreground"
                                )}
                                >
                                {field.value ? (
                                    format(field.value, "PPP")
                                ) : (
                                    <span>Pick a date</span>
                                )}
                                <CalendarIcon className="ml-auto h-4 w-4 opacity-50" />
                                </Button>
                            </FormControl>
                            </PopoverTrigger>
                            <PopoverContent className="w-auto p-0" align="start">
                            <Calendar
                                mode="single"
                                selected={field.value}
                                onSelect={field.onChange}
                                initialFocus
                            />
                            </PopoverContent>
                        </Popover>
                        <FormMessage />
                        </FormItem>
                    )}
                />
                <FormField
                    control={form.control}
                    name="workoutTime"
                    render={({ field }) => (
                        <FormItem>
                        <FormLabel>Preferred Time</FormLabel>
                        <FormControl>
                            <Input type="time" {...field} />
                        </FormControl>
                        <FormMessage />
                        </FormItem>
                    )}
                />
             </div>
           
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
