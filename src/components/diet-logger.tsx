
"use client";

import { useState, useEffect } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Utensils, CheckCircle, Loader2, ChevronRight, ChevronLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { useToast } from "@/hooks/use-toast";
import { useLocalStorage } from "@/hooks/use-local-storage";
import type { MealLog, FoodItem } from "@/lib/types";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { useRouter } from "next/navigation";
import { Calendar } from "./ui/calendar";
import { format } from 'date-fns';
import { formatInTimeZone } from 'date-fns-tz';
import Image from "next/image";
import { cn } from "@/lib/utils";
import { foodData, FoodCategory } from "@/lib/foods";
import { ScrollArea } from "./ui/scroll-area";
import { Badge } from "./ui/badge";

const foodCategories = [
    { id: "Fruits", label: "Fruits", image: "https://placehold.co/200x200.png", hint: "apples bananas" },
    { id: "Dairy & Eggs", label: "Dairy & Eggs", image: "https://placehold.co/200x200.png", hint: "milk cheese eggs" },
    { id: "Grains & Pulses", label: "Grains & Pulses", image: "https://placehold.co/200x200.png", hint: "bread rice beans" },
    { id: "Meat & Seafood", label: "Meat & Seafood", image: "https://placehold.co/200x200.png", hint: "chicken fish steak" },
    { id: "Bakery & Sweets", label: "Bakery & Sweets", image: "https://placehold.co/200x200.png", hint: "cake cookies chocolate" },
    { id: "Beverages", label: "Beverages", image: "https://placehold.co/200x200.png", hint: "juice coffee soda" },
    { id: "Spices & Oils", label: "Spices & Oils", image: "https://placehold.co/200x200.png", hint: "olive-oil spices herbs" },
    { id: "Munchies", label: "Munchies", image: "https://placehold.co/200x200.png", hint: "chips popcorn nuts" },
];

const formSchema = z.object({
  mealType: z.string({ required_error: "Please select a meal type." }),
  macronutrients: z.string({ required_error: "Please select a macronutrient profile." }),
  fitnessGoals: z.string({ required_error: "Please select a fitness goal." }),
  foodCategory: z.string({ required_error: "Please select a food category." }),
});

type FormValues = z.infer<typeof formSchema>;

const mealTypeOptions = ["Breakfast", "Lunch", "Dinner", "Snack / Pre/Post Workout"];
const macronutrientOptions = ["High-Protein", "High-Carb", "Low-Carb", "Healthy Fats"];
const fitnessGoalOptions = ["Muscle Gain", "Fat Loss", "Maintenance"];

export function DietLogger() {
  const { toast } = useToast();
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [mealLogs, setMealLogs] = useLocalStorage<MealLog[]>("meal-logs", []);
  
  const [step, setStep] = useState(1);
  const [date, setDate] = useState<Date | undefined>(undefined);
  const [today, setToday] = useState<Date | undefined>(undefined);
  const [selectedFoodItems, setSelectedFoodItems] = useState<FoodItem[]>([]);

  useEffect(() => {
    const todayStr = formatInTimeZone(new Date(), 'Asia/Kolkata', 'yyyy-MM-dd');
    setToday(new Date(todayStr));
  }, []);

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {},
  });

  function onSubmit(values: FormValues) {
    if (!date) {
        toast({ variant: "destructive", title: "Date not selected", description: "Please go back and select a date."});
        return;
    }
    if (selectedFoodItems.length === 0) {
        toast({ variant: "destructive", title: "No items selected", description: "Please select at least one food item." });
        return;
    }

    setIsLoading(true);

    const mealDetails = selectedFoodItems.map(item => item.name).join(', ');

    const newLog: MealLog = {
      id: crypto.randomUUID(),
      createdAt: new Date().toISOString(),
      date: date.toISOString(),
      mealDetails,
      ...values,
    };
    
    setMealLogs([...mealLogs, newLog]);

    toast({
      title: "Meal Logged!",
      description: "Your meal has been successfully saved.",
    });

    form.reset();
    setSelectedFoodItems([]);
    setIsLoading(false);
    router.push('/');
  }

  const handleDateSelect = (selectedDate: Date | undefined) => {
    setDate(selectedDate);
    if (selectedDate) {
      setStep(2);
    }
  };

  const handleCategorySelect = (categoryId: string) => {
    form.setValue("foodCategory", categoryId);
    setStep(3);
  };
  
  const toggleFoodItem = (item: FoodItem) => {
    setSelectedFoodItems(prev => 
        prev.some(i => i.name === item.name)
            ? prev.filter(i => i.name !== item.name)
            : [...prev, item]
    );
  };

  const handleNextFromItems = () => {
    if (selectedFoodItems.length > 0) {
      setStep(4);
    } else {
      toast({
        variant: 'destructive',
        title: 'No Items Selected',
        description: 'Please select at least one food item to continue.',
      });
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

  if (step === 2) {
    return (
        <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70 flex-1 flex flex-col">
            <CardHeader>
                <div className="flex items-center gap-4">
                    <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => setStep(1)}>
                        <ChevronLeft className="h-4 w-4" />
                    </Button>
                    <div>
                        <CardTitle className="flex items-center gap-2"><Utensils /> Select Food Category</CardTitle>
                        <CardDescription>
                            Choose a category for your meal on {date ? format(date, "PPP") : 'the selected date'}.
                        </CardDescription>
                    </div>
                </div>
            </CardHeader>
            <CardContent className="flex-1">
                <ScrollArea className="h-[500px] -mx-4">
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 px-4 pt-4">
                        {foodCategories.map((cat) => {
                            const isSelected = form.getValues("foodCategory") === cat.id;
                            return (
                                <div
                                    key={cat.id}
                                    onClick={() => handleCategorySelect(cat.id)}
                                    className={cn(
                                        "rounded-lg cursor-pointer group border-2 p-2 text-center space-y-2 transition-all",
                                        isSelected ? "border-primary bg-primary/5" : "border-transparent bg-muted/50 hover:bg-muted/100"
                                    )}
                                >
                                    <div className="aspect-square w-full relative overflow-hidden rounded-md">
                                        <Image
                                            src={cat.image}
                                            alt={cat.label}
                                            width={200}
                                            height={200}
                                            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                                            data-ai-hint={cat.hint}
                                        />
                                    </div>
                                    <h3 className="font-medium text-sm text-foreground">{cat.label}</h3>
                                </div>
                            );
                        })}
                    </div>
                </ScrollArea>
            </CardContent>
            <CardFooter>
                 <p className="w-full text-center text-muted-foreground">Select a category to continue.</p>
            </CardFooter>
        </Card>
    );
  }
  
  if (step === 3) {
    const categoryKey = form.getValues("foodCategory") as FoodCategory;
    const itemsToShow = foodData[categoryKey] || [];

    return (
        <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70 flex flex-col flex-1">
            <CardHeader>
                <div className="flex items-center gap-4">
                    <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => setStep(2)}>
                        <ChevronLeft className="h-4 w-4" />
                    </Button>
                    <div>
                        <CardTitle className="flex items-center gap-2"><Utensils /> Select Your Food</CardTitle>
                        <CardDescription>
                            Choose items for your meal on {date ? format(date, "PPP") : 'the selected date'}.
                        </CardDescription>
                    </div>
                </div>
            </CardHeader>
            <CardContent className="flex-1">
                <ScrollArea className="h-[500px] -mx-4">
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 px-4 pt-4">
                        {itemsToShow.map((item) => {
                            const isSelected = selectedFoodItems.some(i => i.name === item.name);
                            return (
                                <div
                                    key={item.name}
                                    onClick={() => toggleFoodItem(item)}
                                    className={cn(
                                        "rounded-lg cursor-pointer group border-2 p-2 text-center space-y-2 transition-all",
                                        isSelected ? "border-primary bg-primary/5" : "border-transparent bg-muted/50 hover:bg-muted/100"
                                    )}
                                >
                                    <div className="aspect-square w-full relative overflow-hidden rounded-md">
                                        <Image
                                            src={item.image}
                                            alt={item.name}
                                            width={200}
                                            height={200}
                                            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                                            data-ai-hint={item.hint}
                                        />
                                    </div>
                                    <h3 className="font-medium text-sm text-foreground">{item.name}</h3>
                                    <p className="text-xs text-muted-foreground">
                                        {item.calories} kcal, {item.protein}g protein
                                    </p>
                                </div>
                            );
                        })}
                    </div>
                </ScrollArea>
            </CardContent>
            <CardFooter>
                 <Button onClick={handleNextFromItems} className="w-full" size="lg">
                    Next - Finalize Meal <ChevronRight className="ml-2 h-4 w-4" />
                </Button>
            </CardFooter>
        </Card>
    );
  }

  if (step === 4) {
      const totalCalories = selectedFoodItems.reduce((sum, item) => sum + item.calories, 0);
      const totalProtein = selectedFoodItems.reduce((sum, item) => sum + item.protein, 0);

      return (
        <Card className="w-full max-w-2xl mx-auto shadow-xl border-none bg-card/70">
          <CardHeader>
            <div className="flex items-center gap-4">
                <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => setStep(3)}>
                    <ChevronLeft className="h-4 w-4" />
                </Button>
                <div>
                  <CardTitle className="flex items-center gap-2"><Utensils /> Add Meal Details & Save</CardTitle>
                  <CardDescription>
                    Finalize the details for your meal on {date ? format(date, "PPP") : "the selected date"}.
                  </CardDescription>
                </div>
            </div>
          </CardHeader>
          <CardContent>
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                
                <Card>
                    <CardHeader>
                        <CardTitle className="text-lg">Your Selected Items</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="flex flex-wrap gap-2">
                            {selectedFoodItems.map(item => <Badge key={item.name} variant="secondary">{item.name}</Badge>)}
                        </div>
                        <div className="mt-4 text-sm font-medium">
                            <p>Total Calories: <span className="text-primary">{totalCalories.toFixed(0)} kcal</span></p>
                            <p>Total Protein: <span className="text-primary">{totalProtein.toFixed(1)} g</span></p>
                        </div>
                    </CardContent>
                </Card>

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
                      name="fitnessGoals"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Primary Fitness Goal</FormLabel>
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
                      name="macronutrients"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Primary Macronutrient</FormLabel>
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
                </div>
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

  return null;
}

    