
"use client";

import { useState, useEffect } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Utensils, CheckCircle, Loader2, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/hooks/use-toast";
import { useLocalStorage } from "@/hooks/use-local-storage";
import type { MealLog } from "@/lib/types";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { useRouter } from "next/navigation";
import { Calendar } from "./ui/calendar";
import { format, formatInTimeZone } from 'date-fns';

const formSchema = z.object({
  mealType: z.string({ required_error: "Please select a meal type." }),
  macronutrients: z.string({ required_error: "Please select a macronutrient profile." }),
  fitnessGoals: z.string({ required_error: "Please select a fitness goal." }),
  foodCategory: z.string({ required_error: "Please select a food category." }),
  mealDetails: z.string().min(10, { message: "Please describe your meal in at least 10 characters." }),
});

type FormValues = z.infer<typeof formSchema>;

const mealTypeOptions = ["Breakfast", "Lunch", "Dinner", "Snack / Pre/Post Workout"];
const macronutrientOptions = ["High-Protein", "High-Carb", "Low-Carb", "Healthy Fats"];
const fitnessGoalOptions = ["Muscle Gain", "Fat Loss", "Maintenance"];
const foodCategoryOptions = ["Veggies & Fruits", "Dairy & Eggs", "Grains & Pulses", "Meat & Seafood", "Bakery & Sweets", "Beverages", "Spices & Oils"];

export function DietLogger() {
  const { toast } = useToast();
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [mealLogs, setMealLogs] = useLocalStorage<MealLog[]>("meal-logs", []);
  
  const [step, setStep] = useState(1);
  const [date, setDate] = useState<Date | undefined>(undefined);
  const [today, setToday] = useState<Date | undefined>(undefined);

  useEffect(() => {
    const todayStr = formatInTimeZone(new Date(), 'Asia/Kolkata', 'yyyy-MM-dd');
    setToday(new Date(todayStr));
  }, []);

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
        mealDetails: "",
    },
  });

  function onSubmit(values: FormValues) {
    if (!date) {
        toast({ variant: "destructive", title: "Date not selected", description: "Please go back and select a date."});
        return;
    }

    setIsLoading(true);

    const newLog: MealLog = {
      id: crypto.randomUUID(),
      createdAt: new Date().toISOString(),
      date: date.toISOString(),
      ...values,
    };
    
    setMealLogs([...mealLogs, newLog]);

    toast({
      title: "Meal Logged!",
      description: "Your meal has been successfully saved.",
    });

    form.reset();
    setIsLoading(false);
    router.push('/');
  }

  const handleDateSelect = (selectedDate: Date | undefined) => {
    setDate(selectedDate);
    if (selectedDate) {
      setStep(2);
    }
  };
  
  if (step === 1) {
    return (
       <Card className="w-full flex-1 flex flex-col shadow-xl border-none bg-card/70">
        <CardHeader>
            <div className="flex justify-between items-center">
                <CardTitle className="text-2xl font-bold tracking-tight">Select Meal Date</CardTitle>
            </div>
        </CardHeader>
        <CardContent className="flex-1 flex justify-center items-center p-0 sm:p-6">
            <Calendar
                mode="single"
                selected={date}
                onSelect={handleDateSelect}
                disabled={{ after: today }}
                className="w-full h-full flex flex-col"
                classNames={{
                    months: "flex flex-col sm:flex-row space-y-4 sm:space-x-4 sm:space-y-0 flex-1",
                    month: "flex flex-col flex-1",
                    table: "w-full border-collapse flex flex-col flex-1",
                    head_row: "flex justify-around",
                    row: "flex w-full mt-2 flex-1",
                    head_cell: "text-muted-foreground rounded-md flex-1 font-normal text-base",
                    cell: "p-0 relative text-center flex-1",
                    day: "w-full h-full text-base p-0 font-normal aria-selected:opacity-100 rounded-md",
                    day_selected: "bg-primary text-primary-foreground hover:bg-primary/90 focus:bg-primary/90",
                    day_today: "bg-accent text-accent-foreground",
                    day_disabled: "text-muted-foreground/50 cursor-not-allowed",
                }}
            />
        </CardContent>
         <CardFooter className="flex-col sm:flex-row items-center gap-4 border-t pt-6 transition-all duration-300 min-h-[98px] sm:min-h-[82px]">
            <div className="flex w-full justify-center items-center">
                <p className="text-muted-foreground">Select a date to log your meal.</p>
            </div>
        </CardFooter>
      </Card>
    )
  }

  return (
    <Card className="w-full max-w-2xl mx-auto shadow-xl border-none bg-card/70">
      <CardHeader>
        <CardTitle className="flex items-center gap-2"><Utensils /> Add Your Meal</CardTitle>
        <CardDescription>
          Log a meal for {date ? format(date, "PPP") : "the selected date"} with its details for better tracking.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <FormField
                  control={form.control}
                  name="mealType"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Meal Type</FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger><SelectValue placeholder="Select a meal type" /></SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          {mealTypeOptions.map(option => <SelectItem key={option} value={option}>{option}</SelectItem>)}
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                 <FormField
                  control={form.control}
                  name="macronutrients"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Macronutrients</FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger><SelectValue placeholder="Select macro profile" /></SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          {macronutrientOptions.map(option => <SelectItem key={option} value={option}>{option}</SelectItem>)}
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                 <FormField
                  control={form.control}
                  name="fitnessGoals"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Fitness Goals</FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger><SelectValue placeholder="Select a fitness goal" /></SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          {fitnessGoalOptions.map(option => <SelectItem key={option} value={option}>{option}</SelectItem>)}
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                 <FormField
                  control={form.control}
                  name="foodCategory"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Food Category</FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger><SelectValue placeholder="Select a food category" /></SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          {foodCategoryOptions.map(option => <SelectItem key={option} value={option}>{option}</SelectItem>)}
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />
            </div>

            <FormField
              control={form.control}
              name="mealDetails"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Meal Details</FormLabel>
                  <FormControl>
                    <Textarea placeholder="e.g., Grilled chicken breast with a side of steamed broccoli and quinoa." {...field} rows={4} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
          </form>
        </Form>
      </CardContent>
      <CardFooter>
          <Button onClick={form.handleSubmit(onSubmit)} className="w-full bg-accent hover:bg-accent/90 text-accent-foreground" disabled={isLoading}>
            {isLoading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <CheckCircle className="mr-2 h-4 w-4" />}
            {isLoading ? "Saving..." : "Log Meal"}
          </Button>
      </CardFooter>
    </Card>
  );
}
