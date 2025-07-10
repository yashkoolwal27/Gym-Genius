import { DietLogger } from "@/components/diet-logger";
import { Header } from "@/components/header";

export default function AddMealPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="Add Meal" description="Log your meals to keep track of your diet." />
      <div className="p-4 md:p-8 overflow-y-auto">
        <DietLogger />
      </div>
    </div>
  );
}
