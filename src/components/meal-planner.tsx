
"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { BrainCircuit, UtensilsCrossed, Save, Loader2, Sparkles, History, ChevronLeft } from "lucide-react";

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
type View = 'selector' | 'manual' | 'history';

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
  const [view, setView] = useState<View>('selector');
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

  const renderContent = () => {
    if (view === 'manual') {
      return (
        <div>
          <Button variant="ghost" onClick={() => setView('selector')} className="mb-4">
            <ChevronLeft className="mr-2 h-4 w-4" /> Back to options
          </Button>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onManualSubmit)} className="space-y-6">
              <FormField control={form.control} name="fitnessGoals" render={({ field }) => ( <FormItem><FormLabel>Fitness & Health Goals</FormLabel><FormControl><Input placeholder="e.g., Lose weight, build muscle" {...field} /></FormControl><FormMessage /></FormItem> )} />
              <FormField control={form.control} name="dietaryRestrictions" render={({ field }) => ( <FormItem><FormLabel>Dietary Restrictions</FormLabel><FormControl><Input placeholder="e.g., Vegetarian, gluten-free, allergies" {...field} /></FormControl><FormMessage /></FormItem> )} />
              <FormField control={form.control} name="preferences" render={({ field }) => ( <FormItem><FormLabel>Food Preferences</FormLabel><FormControl><Input placeholder="e.g., Loves salmon, hates olives" {...field} /></FormControl><FormMessage /></FormItem> )} />
              <FormField control={form.control} name="numberOfMeals" render={({ field }) => ( <FormItem><FormLabel>Meals Per Day</FormLabel><FormControl><Input type="number" min="1" max="5" {...field} /></FormControl><FormMessage /></FormItem> )} />
              <Button type="submit" disabled={isLoading} className="w-full bg-accent hover:bg-accent/90 text-accent-foreground">
                {isLoading ? ( <><Loader2 className="mr-2 h-4 w-4 animate-spin" /> Generating...</> ) : ( <><BrainCircuit className="mr-2 h-4 w-4" /> Generate Manually</> )}
              </Button>
            </form>
          </Form>
        </div>
      );
    }

    if (view === 'history') {
      return (
         <div>
          <Button variant="ghost" onClick={() => setView('selector')} className="mb-4">
            <ChevronLeft className="mr-2 h-4 w-4" /> Back to options
          </Button>
          <Alert>
            <History className="h-4 w-4" />
            <AlertTitle>Use Your Past Data!</AlertTitle>
            <AlertDescription>
              Let the AI analyze your logged meals to create a new plan based on what you typically eat. We'll use your most recent fitness goals and meal count preferences.
            </AlertDescription>
          </Alert>
           <FormField control={form.control} name="fitnessGoals" render={({ field }) => ( <FormItem className="my-4"><FormLabel>Confirm Fitness Goal</FormLabel><FormControl><Input placeholder="e.g., Lose weight, build muscle" {...field} /></FormControl><FormMessage /></FormItem> )} />
           <FormField control={form.control} name="numberOfMeals" render={({ field }) => ( <FormItem className="my-4"><FormLabel>Confirm Meals Per Day</FormLabel><FormControl><Input type="number" min="1" max="5" {...field} /></FormControl><FormMessage /></FormItem> )} />
          <Button onClick={onHistorySubmit} disabled={isLoading || dietLogs.length < 1} className="w-full mt-4">
             {isLoading ? ( <><Loader2 className="mr-2 h-4 w-4 animate-spin" /> Generating...</> ) : ( <><History className="mr-2 h-4 w-4" /> Generate From My Diet History</> )}
          </Button>
           {dietLogs.length < 1 && <p className="text-xs text-center text-muted-foreground mt-2">Log some meals first to enable this feature.</p>}
        </div>
      )
    }

    // Default to selector
    return (
       <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <Card className="p-6 text-center flex flex-col items-center justify-center bg-background/70 hover:bg-background transition-colors cursor-pointer" onClick={() => setView('manual')}>
              <BrainCircuit className="h-10 w-10 text-primary mb-4" />
              <h3 className="text-lg font-semibold">Generate Manually</h3>
              <p className="text-sm text-muted-foreground mt-1">Provide your preferences for a custom plan.</p>
          </Card>
          <Card className="p-6 text-center flex flex-col items-center justify-center bg-background/70 hover:bg-background transition-colors cursor-pointer" onClick={() => setView('history')}>
              <History className="h-10 w-10 text-primary mb-4" />
              <h3 className="text-lg font-semibold">Use My History</h3>
              <p className="text-sm text-muted-foreground mt-1">Let the AI generate a plan from your past meals.</p>
          </Card>
      </div>
    );
  }

  return (
    <Card className="w-full shadow-xl border-none bg-card/70 mt-4">
      <CardHeader>
        <CardTitle className="flex items-center gap-2"><UtensilsCrossed /> AI Meal Planner</CardTitle>
        <CardDescription>Choose how you want to generate your new meal plan.</CardDescription>
      </CardHeader>
      <CardContent>
        {renderContent()}

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
