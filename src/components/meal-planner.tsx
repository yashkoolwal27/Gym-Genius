
"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { BrainCircuit, UtensilsCrossed, Save, Loader2, Sparkles, History } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { useToast } from "@/hooks/use-toast";
import { getMealPlan, getMealPlanFromHistory } from "@/lib/actions";
import { useLocalStorage } from "@/hooks/use-local-storage";
import type { MealPlan, DietLog } from "@/lib/types";
import { Skeleton } from "./ui/skeleton";
import { Alert, AlertDescription, AlertTitle } from "./ui/alert";

const formSchema = z.object({
    dietaryRestrictions: z.string().min(3, "Please describe any dietary restrictions."),
    preferences: z.string().min(3, "Please list your food preferences."),
    fitnessGoals: z.string().min(3, "Please describe your fitness goals."),
    numberOfMeals: z.coerce.number().min(1).max(5),
});

type FormValues = z.infer<typeof formSchema>;

function MealPlanDisplay({ plan, onSave }: { plan: string; onSave: () => void }) {
  const mealSections = plan.split('\n\n').filter(p => p.trim().length > 0);

  return (
    <Card className="mt-6 bg-white/50 dark:bg-black/50 border-primary/20 shadow-lg">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-primary">
          <Sparkles className="w-6 h-6" />
          Your Custom Meal Plan
        </CardTitle>
        <CardDescription>A delicious and nutritious meal plan tailored to your needs. Bon appétit!</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {mealSections.map((section, index) => (
          <div key={index} className="p-4 border rounded-lg bg-background">
            <h3 className="font-semibold text-lg mb-2">{section.split('\n')[0]}</h3>
            <ul className="list-disc pl-5 space-y-1 text-muted-foreground">
              {section.split('\n').slice(1).map((item, itemIndex) => (
                item.trim() && <li key={itemIndex}>{item.trim().replace(/^- /,'')}</li>
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

export function MealPlanner() {
  const [isLoading, setIsLoading] = useState(false);
  const [generatedPlan, setGeneratedPlan] = useState<string | null>(null);
  const [mealPlans, setMealPlans] = useLocalStorage<MealPlan[]>("meal-plans", []);
  const [dietLogs] = useLocalStorage<DietLog[]>("diet-logs", []);
  const { toast } = useToast();

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      dietaryRestrictions: "None",
      preferences: "Chicken, broccoli, rice, and berries",
      fitnessGoals: "Lose 10 pounds",
      numberOfMeals: 3,
    },
  });

  async function onManualSubmit(values: FormValues) {
    setIsLoading(true);
    setGeneratedPlan(null);
    const result = await getMealPlan(values);
    setIsLoading(false);

    if (result.success && result.data?.mealPlan) {
      setGeneratedPlan(result.data.mealPlan);
    } else {
      toast({
        variant: "destructive",
        title: "Oh no! Something went wrong.",
        description: result.error || "Failed to generate meal plan.",
      });
    }
  }
  
  async function onHistorySubmit() {
    setIsLoading(true);
    setGeneratedPlan(null);

    const pastMeals = dietLogs
      .flatMap(log => Object.values(log.meals))
      .filter(meal => meal.trim() !== "");

    if (pastMeals.length < 3) {
      toast({
          variant: "destructive",
          title: "Not Enough Data",
          description: "Please log at least a few meals before using this feature.",
      });
      setIsLoading(false);
      return;
    }
    
    // For simplicity, we'll grab the goals from the manual form.
    // In a real app, this might be stored in the user's profile.
    const { fitnessGoals, numberOfMeals } = form.getValues();

    const result = await getMealPlanFromHistory({ pastMeals, fitnessGoals, numberOfMeals });
    setIsLoading(false);

    if (result.success && result.data?.mealPlan) {
        setGeneratedPlan(result.data.mealPlan);
    } else {
        toast({
            variant: "destructive",
            title: "Oh no! Something went wrong.",
            description: result.error || "Failed to generate meal plan.",
        });
    }
  }


  const handleSavePlan = () => {
    if (generatedPlan) {
      const newPlan: MealPlan = {
        id: new Date().toISOString(),
        generatedPlan: generatedPlan,
        createdAt: new Date().toISOString(),
      };
      setMealPlans([...mealPlans, newPlan]);
      toast({
        title: "Plan Saved!",
        description: "Your meal plan has been saved to 'My Progress'.",
      });
    }
  };

  return (
    <Card className="w-full shadow-xl border-none bg-card/70 mt-4">
      <CardHeader>
        <CardTitle className="flex items-center gap-2"><UtensilsCrossed /> AI Meal Planner</CardTitle>
        <CardDescription>Describe your dietary needs, or use your history, and our AI will create a delicious meal plan for you.</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="grid md:grid-cols-2 gap-x-8 gap-y-6">
            <div className="space-y-6">
                <h3 className="text-lg font-semibold text-center md:text-left">Generate Manually</h3>
                <Form {...form}>
                  <form onSubmit={form.handleSubmit(onManualSubmit)} className="space-y-6">
                    <FormField
                      control={form.control}
                      name="fitnessGoals"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Fitness & Health Goals</FormLabel>
                          <FormControl>
                            <Input placeholder="e.g., Lose weight, build muscle" {...field} />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                    <FormField
                      control={form.control}
                      name="dietaryRestrictions"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Dietary Restrictions</FormLabel>
                          <FormControl>
                            <Input placeholder="e.g., Vegetarian, gluten-free, allergies" {...field} />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                    <FormField
                      control={form.control}
                      name="preferences"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Food Preferences</FormLabel>
                          <FormControl>
                            <Input placeholder="e.g., Loves salmon, hates olives" {...field} />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                     <FormField
                      control={form.control}
                      name="numberOfMeals"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Meals Per Day</FormLabel>
                          <FormControl>
                            <Input type="number" min="1" max="5" {...field} />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                    <Button type="submit" disabled={isLoading} className="w-full bg-accent hover:bg-accent/90 text-accent-foreground">
                      {isLoading ? (
                        <><Loader2 className="mr-2 h-4 w-4 animate-spin" /> Generating...</>
                      ) : (
                        <><BrainCircuit className="mr-2 h-4 w-4" /> Generate Manually</>
                      )}
                    </Button>
                  </form>
                </Form>
            </div>
            <div className="flex flex-col space-y-6">
                <h3 className="text-lg font-semibold text-center md:text-left">Generate from History</h3>
                <Alert>
                  <History className="h-4 w-4" />
                  <AlertTitle>Use Your Past Data!</AlertTitle>
                  <AlertDescription>
                    Let the AI analyze your logged meals to create a new plan based on what you typically eat. Ensure your fitness goals and desired number of meals are set on the left.
                  </AlertDescription>
                </Alert>
                <Button onClick={onHistorySubmit} disabled={isLoading || dietLogs.length < 1} className="w-full">
                   {isLoading ? (
                        <><Loader2 className="mr-2 h-4 w-4 animate-spin" /> Generating...</>
                      ) : (
                        <><History className="mr-2 h-4 w-4" /> Generate From My Diet History</>
                   )}
                </Button>
                 {dietLogs.length < 1 && <p className="text-xs text-center text-muted-foreground">Log some meals first to enable this feature.</p>}
            </div>
        </div>

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
        
        {generatedPlan && <MealPlanDisplay plan={generatedPlan} onSave={handleSavePlan} />}
      </CardContent>
    </Card>
  );
}
