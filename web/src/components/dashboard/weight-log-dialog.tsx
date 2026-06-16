
"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
  DialogClose,
} from "@/components/ui/dialog";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { useToast } from "@/hooks/use-toast";
import { Weight, Loader2, Save, CalendarIcon } from "lucide-react";
import type { WeightLog } from "@/lib/types";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Calendar } from "@/components/ui/calendar";
import { cn } from "@/lib/utils";
import { format } from "date-fns";

const formSchema = z.object({
  weight: z.coerce.number({ required_error: "Weight is required." }).positive("Weight must be a positive number."),
  date: z.date({ required_error: "Date is required." }),
});

type WeightFormValues = z.infer<typeof formSchema>;

interface WeightLogDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onWeightLogged: (log: WeightLog) => void;
  lastWeight: number;
}

export function WeightLogDialog({ isOpen, onClose, onWeightLogged, lastWeight }: WeightLogDialogProps) {
  const { toast } = useToast();
  const [isLoading, setIsLoading] = useState(false);

  const form = useForm<WeightFormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      weight: lastWeight || 0,
      date: new Date(),
    },
  });

  const onSubmit = (values: WeightFormValues) => {
    setIsLoading(true);
    const newLog: WeightLog = {
        id: crypto.randomUUID(),
        date: values.date.toISOString(),
        weight: values.weight,
    };
    onWeightLogged(newLog);
    toast({
      title: "Weight Logged!",
      description: `Your weight of ${values.weight} kg for ${format(values.date, "PPP")} has been saved.`,
    });
    setIsLoading(false);
    onClose();
    form.reset({ weight: values.weight, date: new Date() });
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2"><Weight/> Log Your Weight</DialogTitle>
          <DialogDescription>
            Enter your current weight. Consistent tracking is key to progress!
          </DialogDescription>
        </DialogHeader>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4 py-4">
            <FormField
              control={form.control}
              name="weight"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Current Weight (kg)</FormLabel>
                  <FormControl>
                    <Input type="number" step="0.1" placeholder="e.g., 82.5" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
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
          </form>
        </Form>
        <DialogFooter>
          <DialogClose asChild>
            <Button type="button" variant="outline">
              Cancel
            </Button>
          </DialogClose>
          <Button onClick={form.handleSubmit(onSubmit)} disabled={isLoading}>
            {isLoading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Save className="mr-2 h-4 w-4"/>}
            {isLoading ? "Saving..." : "Save Weight"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
