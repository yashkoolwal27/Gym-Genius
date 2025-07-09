import { AIWorkoutGenerator } from "@/components/ai-workout-generator";
import { Header } from "@/components/header";

export default function WorkoutGeneratorPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="AI Workout Generator" description="Generate a personalized workout plan using AI." />
      <div className="flex-1 p-4 md:p-8 overflow-y-auto flex">
        <AIWorkoutGenerator />
      </div>
    </div>
  );
}
