import { MealPlanner } from "@/components/meal-planner";
import { Header } from "@/components/header";

export default function MealPlannerPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="Diet Plans" description="Generate a meal plan tailored to your needs." />
      <div className="p-4 md:p-8 overflow-y-auto">
        <MealPlanner />
      </div>
    </div>
  );
}
