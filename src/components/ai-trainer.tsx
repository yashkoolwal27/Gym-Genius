"use client";

import { useState } from "react";
import { useLocalStorage } from "@/hooks/use-local-storage";
import type { MealLog, WorkoutLog, WeightLog } from "@/lib/types";
import { getTrainerFeedback } from "@/lib/actions";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { BrainCircuit, Loader2, Sparkles, AlertTriangle } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { Skeleton } from "./ui/skeleton";
import { Alert, AlertDescription, AlertTitle } from "./ui/alert";

function FeedbackDisplay({ feedback }: { feedback: string }) {
  const sections = feedback.split(/(\*\*|###)/).filter(Boolean);
  
  const formattedSections = [];
  let currentSection = { title: "", content: "" };

  for (let i = 0; i < sections.length; i++) {
    const part = sections[i].trim();
    if (part === "**" || part === "###") {
      const title = sections[++i].replace(/\*\*/g, '').replace(/###/g, '').trim();
      if (currentSection.title) {
        formattedSections.push(currentSection);
      }
      currentSection = { title, content: "" };
    } else {
      currentSection.content += part + "\n";
    }
  }
  formattedSections.push(currentSection);

  return (
    <Card className="mt-6 bg-white/50 dark:bg-black/50 border-primary/20 shadow-lg">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-primary">
          <Sparkles className="w-6 h-6" />
          Your AI Trainer Feedback
        </CardTitle>
        <CardDescription>Here's a summary of your recent progress and some suggestions.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4 prose prose-sm dark:prose-invert max-w-none">
        {formattedSections.map((sec, index) => (
          <div key={index} className="p-4 border rounded-lg bg-background">
            {sec.title && <h3 className="font-semibold text-lg mb-2">{sec.title}</h3>}
            <div className="whitespace-pre-wrap text-muted-foreground">{sec.content.trim()}</div>
          </div>
        ))}
      </CardContent>
    </Card>
  );
}

export function AITrainer() {
  const [workoutLogs] = useLocalStorage<WorkoutLog[]>("workout-logs", []);
  const [mealLogs] = useLocalStorage<MealLog[]>("meal-logs", []);
  const [weightLogs] = useLocalStorage<WeightLog[]>("weight-logs", []);
  
  const [isLoading, setIsLoading] = useState(false);
  const [feedback, setFeedback] = useState<string | null>(null);
  const { toast } = useToast();

  const hasEnoughData = workoutLogs.length > 0 || mealLogs.length > 0 || weightLogs.length > 0;

  const handleGetFeedback = async () => {
    setIsLoading(true);
    setFeedback(null);
    
    const result = await getTrainerFeedback({
      workoutLogs,
      mealLogs,
      weightLogs,
    });
    
    setIsLoading(false);

    if (result.success && result.data?.feedback) {
      setFeedback(result.data.feedback);
    } else {
      toast({
        variant: "destructive",
        title: "Analysis Failed",
        description: result.error || "Could not get feedback from the AI trainer.",
      });
    }
  };

  return (
    <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <BrainCircuit /> Your Personal AI Trainer
        </CardTitle>
        <CardDescription>
          Click the button below to get personalized feedback on your recent activity. The AI will analyze your workout logs, meal entries, and weight progress to provide actionable insights.
        </CardDescription>
      </CardHeader>
      <CardContent>
        {!hasEnoughData && (
           <Alert variant="destructive">
             <AlertTriangle className="h-4 w-4" />
             <AlertTitle>Not Enough Data</AlertTitle>
             <AlertDescription>
               The AI Trainer needs some data to work with. Please log a few workouts, meals, or weight entries before you can get feedback.
             </AlertDescription>
           </Alert>
        )}
        
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

        {feedback && <FeedbackDisplay feedback={feedback} />}
      </CardContent>
      <CardFooter>
        <Button onClick={handleGetFeedback} disabled={isLoading || !hasEnoughData} size="lg">
          {isLoading ? (
            <><Loader2 className="mr-2 h-4 w-4 animate-spin" /> Analyzing Your Progress...</>
          ) : (
            <><Sparkles className="mr-2 h-4 w-4" /> Get My Feedback</>
          )}
        </Button>
      </CardFooter>
    </Card>
  );
}
