
"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Utensils, Calendar as CalendarIcon, CheckCircle, PlusCircle, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Calendar } from "@/components/ui/calendar";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/hooks/use-toast";
import { useLocalStorage } from "@/hooks/use-local-storage";
import { cn } from "@/lib/utils";
import { format } from "date-fns";
import type { DietLog } from "@/lib/types";

const formSchema = z.object({
  date: z.date({
    required_error: "A date is required.",
  }),
  breakfast: z.string().optional(),
  lunch: z.string().optional(),
  dinner: z.string().optional(),
  snacks: z.string().optional(),
});

type FormValues = z.infer<typeof formSchema>;

export function DietLogger() {
  const { toast } = useToast();
  const [dietLogs, setDietLogs] = useLocalStorage<DietLog[]>("diet-logs", []);

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      date: new Date(),
      breakfast: "",
      lunch: "",
      dinner: "",
      snacks: "",
    },
  });

  function onSubmit(values: FormValues) {
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
      date: values.date.toISOString(),
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
    form.reset({
      date: new Date(),
      breakfast: "",
      lunch: "",
      dinner: "",
      snacks: "",
    });
  }

  return (
    <Card className="w-full shadow-xl border-none bg-card/70 mt-4">
      <CardHeader>
        <CardTitle className="flex items-center gap-2"><Utensils /> Log Your Daily Diet</CardTitle>
        <CardDescription>Manually enter your meals for the day to keep track of your intake.</CardDescription>
      </CardHeader>
      <CardContent>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            <FormField
              control={form.control}
              name="date"
              render={({ field }) => (
                <FormItem className="flex flex-col">
                  <FormLabel>Date</FormLabel>
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
                        disabled={(date) =>
                          date > new Date() || date < new Date("1900-01-01")
                        }
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

            <Button type="submit" className="w-full bg-accent hover:bg-accent/90 text-accent-foreground">
              <CheckCircle className="mr-2 h-4 w-4" /> Log Diet
            </Button>
          </form>
        </Form>
      </CardContent>
    </Card>
  );
}
