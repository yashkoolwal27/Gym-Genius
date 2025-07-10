
"use client";

import { useState, useEffect } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Utensils, Calendar as CalendarIcon, CheckCircle, ChevronLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Calendar } from "@/components/ui/calendar";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/hooks/use-toast";
import { useLocalStorage } from "@/hooks/use-local-storage";
import { format } from "date-fns";
import type { DietLog } from "@/lib/types";

const formSchema = z.object({
  breakfast: z.string().optional(),
  lunch: z.string().optional(),
  dinner: z.string().optional(),
  snacks: z.string().optional(),
});

type FormValues = z.infer<typeof formSchema>;

export function DietLogger() {
  const { toast } = useToast();
  const [dietLogs, setDietLogs] = useLocalStorage<DietLog[]>("diet-logs", []);
  const [step, setStep] = useState(1);
  const [date, setDate] = useState<Date | undefined>(undefined);
  const [today, setToday] = useState<Date | undefined>(undefined);

  useEffect(() => {
    // Set today's date for disabling future dates in the calendar
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    setToday(now);
  }, []);

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      breakfast: "",
      lunch: "",
      dinner: "",
      snacks: "",
    },
  });

  function onSubmit(values: FormValues) {
    if (!date) {
        toast({ variant: "destructive", title: "Date Error", description: "No date was selected. Please go back and select a date." });
        return;
    }
    if (!values.breakfast && !values.lunch && !values.dinner && !values.snacks) {
      toast({
        variant: "destructive",
        title: "Empty Log",
        description: "Please enter at least one meal to log your diet.",
      });
      return;
    }

    const newLog: DietLog = {
      id: crypto.randomUUID(),
      createdAt: new Date().toISOString(),
      date: date.toISOString(),
      meals: {
        breakfast: values.breakfast || "",
        lunch: values.lunch || "",
        dinner: values.dinner || "",
        snacks: values.snacks || "",
      },
    };
    setDietLogs([...dietLogs, newLog]);
    toast({
      title: "Diet Logged!",
      description: "Your daily diet has been saved to your progress.",
    });
    form.reset();
    setDate(undefined);
    setStep(1);
  }
  
  if (step === 1) {
      return (
        <Card className="w-full flex-1 flex flex-col shadow-xl border-none bg-card/70 mt-4">
            <CardHeader>
                <CardTitle className="text-2xl font-bold tracking-tight">Select Date</CardTitle>
                <CardDescription>Choose the date you want to log your meals for.</CardDescription>
            </CardHeader>
            <CardContent className="flex-1 flex justify-center items-center p-0 sm:p-6">
                <Calendar
                    mode="single"
                    selected={date}
                    onSelect={(d) => {
                        setDate(d);
                        if (d) setStep(2);
                    }}
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
        </Card>
      )
  }

  return (
    <Card className="w-full shadow-xl border-none bg-card/70 mt-4">
      <CardHeader>
        <div className="flex items-center gap-4">
            <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => setStep(1)}>
                <ChevronLeft className="h-4 w-4" />
            </Button>
            <div>
                <CardTitle className="flex items-center gap-2"><Utensils /> Log Your Daily Diet</CardTitle>
                <CardDescription>
                    Enter meals for {date ? format(date, "PPP") : "the selected date"}.
                </CardDescription>
            </div>
        </div>
      </CardHeader>
      <CardContent>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            <FormField
              control={form.control}
              name="breakfast"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Breakfast</FormLabel>
                  <FormControl>
                    <Textarea placeholder="e.g., Oatmeal with berries, 2 eggs" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="lunch"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Lunch</FormLabel>
                  <FormControl>
                    <Textarea placeholder="e.g., Grilled chicken salad with vinaigrette" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            
            <FormField
              control={form.control}
              name="dinner"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Dinner</FormLabel>
                  <FormControl>
                    <Textarea placeholder="e.g., Salmon with quinoa and roasted vegetables" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            
            <FormField
              control={form.control}
              name="snacks"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Snacks</FormLabel>
                  <FormControl>
                    <Textarea placeholder="e.g., Greek yogurt, almonds, an apple" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
          </form>
        </Form>
      </CardContent>
      <CardFooter>
          <Button onClick={form.handleSubmit(onSubmit)} className="w-full bg-accent hover:bg-accent/90 text-accent-foreground">
            <CheckCircle className="mr-2 h-4 w-4" /> Log Diet
          </Button>
      </CardFooter>
    </Card>
  );
}
