
"use client";

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { useLocalStorage } from "@/hooks/use-local-storage";
import type { MealLog } from "@/lib/types";
import { Badge } from "../ui/badge";

export default function RecentMeals() {
  const [mealLogs] = useLocalStorage<MealLog[]>("meal-logs", []);

  const recentMeals = mealLogs
    .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
    .slice(0, 3);

  return (
    <Card>
      <CardHeader>
        <CardTitle>Recent Meals</CardTitle>
        <CardDescription>Your last few logged meals.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {recentMeals.length > 0 ? (
          recentMeals.map((meal) => (
            <div key={meal.id} className="p-3 rounded-lg border bg-background/50">
              <p className="font-semibold text-sm">{meal.mealType}</p>
              <p className="text-xs text-muted-foreground truncate">{meal.mealDetails}</p>
              <div className="flex flex-wrap gap-1 mt-2">
                <Badge variant="secondary">{meal.macronutrients}</Badge>
                <Badge variant="secondary">{meal.fitnessGoals}</Badge>
                <Badge variant="secondary">{meal.foodCategory}</Badge>
              </div>
            </div>
          ))
        ) : (
          <div className="text-center text-muted-foreground py-4">
            <p className="text-sm">No meals logged yet.</p>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
