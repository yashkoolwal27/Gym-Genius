
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
import { Weight, Loader2, Save } from "lucide-react";
import type { WeightLog } from "@/lib/types";

const formSchema = z.object({
  weight: z.coerce.number({ required_error: "Weight is required." }).positive("Weight must be a positive number."),
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
    },
  });

  const onSubmit = (values: WeightFormValues) => {
    setIsLoading(true);
    const newLog: WeightLog = {
        id: crypto.randomUUID(),
        date: new Date().toISOString(),
        weight: values.weight,
    };
    onWeightLogged(newLog);
    toast({
      title: "Weight Logged!",
      description: `Your weight of ${values.weight} lbs has been saved.`,
    });
    setIsLoading(false);
    onClose();
    form.reset({ weight: values.weight });
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
                  <FormLabel>Current Weight (lbs)</FormLabel>
                  <FormControl>
                    <Input type="number" step="0.1" placeholder="e.g., 182.5" {...field} />
                  </FormControl>
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
