
"use client";

import { useState, useEffect } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Utensils, CheckCircle, Loader2, ChevronRight, ChevronLeft, Search } from "lucide-react";
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
import { Input } from "./ui/input";
import { Progress } from "./ui/progress";

const foodCategories = [
    { id: "Fruits", label: "Fruits", image: "https://placehold.co/200x200.png", hint: "apples bananas" },
    { id: "Dairy & Eggs", label: "Dairy & Eggs", image: "https://placehold.co/200x200.png", hint: "milk cheese eggs" },
    { id: "Grains & Pulses", label: "Grains & Pulses", image: "https://placehold.co/200x200.png", hint: "bread rice beans" },
    { id: "Meat & Seafood", label: "Meat & Seafood", image: "https://placehold.co/200x200.png", hint: "chicken fish steak" },
    { id: "Bakery & Sweets", label: "Bakery & Sweets", image: "https://placehold.co/200x200.png", hint: "cake cookies chocolate" },
    { id: "Beverages", label: "Beverages", image: "https://placehold.co/200x200.png", hint: "juice coffee soda" },
    { id: "Spices & Oils", label: "Spices & Oils", image: "https://placehold.co/200x200.png", hint: "olive-oil spices herbs" },
    { id: "Munchies", label: "Munchies", image: "https://placehold.co/200x200.png", hint: "chips popcorn nuts" },
    { id: "Breakfast", label: "Breakfast", image: "https://placehold.co/200x200.png", hint: "Breakfast meals food" },
    { id: "Lunch", label: "Lunch", image: "https://placehold.co/200x200.png", hint: "Lunch meals food"},
    { id: "Dinner", label: "Dinner", image: "https://placehold.co/200x200.png", hint: "Dinner meals food"},
    { id: "Snacks", label: "Snacks", image: "https://placehold.co/200x200.png", hint: "Snacks food"},
    { id: "High-Protein", label: "High-Protein", image: "https://placehold.co/200x200.png", hint: "foodmeat poultry fish dairy"},
    { id: "High-Carb", label: "High-Carb", image: "https://placehold.co/200x200.png", hint: "foodgrains grains pulses"},
    { id: "Low-Carb", label: "Low-Carb", image: "https://placehold.co/200x200.png", hint: "foodgrains grains pulses"},
    { id: "Healthy Fats", label: "Healthy Fats", image: "https://placehold.co/200x200.png", hint: "fooddairy eggs"},
    { id: "Muscle Gain", label: "Muscle Gain", image: "https://placehold.co/200x200.png", hint: "foodprotein"},
    { id: "Fat Loss", label: "Fat Loss", image: "https://placehold.co/200x200.png", hint: "foodfat"},
    { id: "Maintenance", label: "Maintenance", image: "https://placehold.co/200x200.png", hint: "foodprotein"},
];

const mealTypeOptions = ["Breakfast", "Lunch", "Dinner", "Snack / Pre Workout", "Snack / Post Workout"];
const macronutrientOptions = ["High-Protein", "High-Carb", "Low-Carb", "Healthy Fats"];
const fitnessGoalOptions = ["Muscle Gain", "Fat Loss", "Maintenance"];

const formSchema = z.object({
  mealType: z.string({ required_error: "Please select a meal type." }),
  macronutrients: z.string({ required_error: "Please select a macronutrient profile." }),
  fitnessGoals: z.string({ required_error: "Please select a fitness goal." }),
  foodCategory: z.string({ required_error: "Please select a food category." }),
});

type FormValues = z.infer<typeof formSchema>;


export function DietLogger() {
  const { toast } = useToast();
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [mealLogs, setMealLogs] = useLocalStorage<MealLog[]>("meal-logs", []);
  
  const [step, setStep] = useState(1);
  const [categorySearchQuery, setCategorySearchQuery] = useState("");
  const [itemSearchQuery, setItemSearchQuery] = useState("");
  const [date, setDate] = useState<Date | undefined>(undefined);
  const [today, setToday] = useState<Date | undefined>(undefined);
  const [selectedFoodItems, setSelectedFoodItems] = useState<FoodItem[]>([]);

  const totalSteps = 4;
  const progress = (step / totalSteps) * 100;

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
    setItemSearchQuery('');
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
  
  const filteredCategories = foodCategories.filter(category =>
    category.label.toLowerCase().includes(categorySearchQuery.toLowerCase())
  );

  const renderStepContent = () => {
      switch (step) {
          case 1:
              return (
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
              );
          case 2:
              return (
                <ScrollArea className="h-[500px] -mx-4">
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 px-4 pt-4">
                        {filteredCategories.map((cat) => {
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
              );
          case 3:
              const categoryKey = form.getValues("foodCategory") as FoodCategory;
              const itemsInCategory = foodData[categoryKey] || [];
              const itemsToShow = itemsInCategory.filter(item => 
                  item.name.toLowerCase().includes(itemSearchQuery.toLowerCase())
              );

              return (
                <>
                  <div className="relative mb-4">
                      <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                      <Input
                          placeholder="Search for an item..."
                          className="pl-10"
                          value={itemSearchQuery}
                          onChange={(e) => setItemSearchQuery(e.target.value)}
                      />
                  </div>
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
                </>
              );
          case 4:
            const totalCalories = selectedFoodItems.reduce((sum, item) => sum + item.calories, 0);
            const totalProtein = selectedFoodItems.reduce((sum, item) => sum + item.protein, 0);
              return (
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
                          <FormField control={form.control} name="mealType" render={({ field }) => ( <FormItem><FormLabel>Meal Type</FormLabel><Select onValueChange={field.onChange} defaultValue={field.value}><FormControl><SelectTrigger><SelectValue placeholder="Select a meal type" /></SelectTrigger></FormControl><SelectContent>{mealTypeOptions.map(option => <SelectItem key={option} value={option}>{option}</SelectItem>)}</SelectContent></Select><FormMessage /></FormItem> )} />
                          <FormField control={form.control} name="fitnessGoals" render={({ field }) => ( <FormItem><FormLabel>Primary Fitness Goal</FormLabel><Select onValueChange={field.onChange} defaultValue={field.value}><FormControl><SelectTrigger><SelectValue placeholder="Select a fitness goal" /></SelectTrigger></FormControl><SelectContent>{fitnessGoalOptions.map(option => <SelectItem key={option} value={option}>{option}</SelectItem>)}</SelectContent></Select><FormMessage /></FormItem> )} />
                          <FormField control={form.control} name="macronutrients" render={({ field }) => ( <FormItem><FormLabel>Primary Macronutrient</FormLabel><Select onValueChange={field.onChange} defaultValue={field.value}><FormControl><SelectTrigger><SelectValue placeholder="Select macro profile" /></SelectTrigger></FormControl><SelectContent>{macronutrientOptions.map(option => <SelectItem key={option} value={option}>{option}</SelectItem>)}</SelectContent></Select><FormMessage /></FormItem> )} />
                      </div>
                    </form>
                  </Form>
              );
          default:
              return null;
      }
  };

  const getHeaderContent = () => {
    switch(step) {
      case 1: return { title: "Select Meal Date", description: "First, choose the date for the meal you want to log." };
      case 2: return { title: "Select Food Category", description: `Choose a category for your meal on ${date ? format(date, "PPP") : 'the selected date'}.` };
      case 3: return { title: "Select Your Food", description: `Choose items for your meal from the '${form.getValues("foodCategory")}' category.` };
      case 4: return { title: "Add Meal Details & Save", description: "Finalize the details for your meal and save it to your log." };
      default: return { title: "Add Meal", description: "Log your meals to keep track of your diet." };
    }
  };

  const { title, description } = getHeaderContent();

  return (
    <div className="flex-1 flex flex-col bg-background">
       <div className="p-6 border-b">
         <Progress value={progress} className="mb-4 h-2" />
         <div className="flex items-center gap-4">
             {step > 1 && (
                 <Button variant="outline" size="icon" className="h-8 w-8 flex-shrink-0" onClick={() => setStep(s => s - 1)}>
                     <ChevronLeft className="h-4 w-4" />
                 </Button>
             )}
             <div className="flex-1 flex justify-between items-center gap-4">
                <div>
                  <CardTitle className="flex items-center gap-2 text-2xl">{title}</CardTitle>
                  <CardDescription className="mt-1">{description}</CardDescription>
                </div>
                {step === 2 && (
                    <div className="relative w-full max-w-xs">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                        <Input
                            placeholder="Search food categories..."
                            className="pl-10"
                            value={categorySearchQuery}
                            onChange={(e) => setCategorySearchQuery(e.target.value)}
                        />
                    </div>
                )}
             </div>
         </div>
       </div>

      <div className="flex-1 p-6 overflow-y-auto">
        {renderStepContent()}
      </div>

      <div className="p-6 border-t">
        {step === 1 && <p className="w-full text-center text-muted-foreground">Select a date to continue.</p>}
        {step === 2 && <p className="w-full text-center text-muted-foreground">Select a food category to choose items.</p>}
        {step === 3 && (
            <Button onClick={handleNextFromItems} className="w-full" size="lg" disabled={selectedFoodItems.length === 0}>
                Next - Finalize Meal <ChevronRight className="ml-2 h-4 w-4" />
            </Button>
        )}
        {step === 4 && (
            <Button onClick={form.handleSubmit(onSubmit)} className="w-full bg-accent hover:bg-accent/90 text-accent-foreground" size="lg" disabled={isLoading}>
                {isLoading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <CheckCircle className="mr-2 h-4 w-4" />}
                {isLoading ? "Saving..." : "Log Meal"}
            </Button>
        )}
      </div>
    </div>
  );
}
