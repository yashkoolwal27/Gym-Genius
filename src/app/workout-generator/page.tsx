import { WorkoutGenerator } from "@/components/workout-generator";
import { Header } from "@/components/header";

export default function WorkoutGeneratorPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="AI Workout Generator" description="Create a personalized workout plan." />
      <div className="p-4 md:p-8 overflow-y-auto">
        <WorkoutGenerator />
      </div>
    </div>
  );
}
