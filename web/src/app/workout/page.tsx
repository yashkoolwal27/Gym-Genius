import { WorkoutGenerator } from "@/components/workout-generator";
import { Header } from "@/components/header";

export default function WorkoutPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="Workout" description="Manually enter your workout details to track your progress." />
      <div className="flex-1 p-4 md:p-8 overflow-y-auto flex">
        <WorkoutGenerator />
      </div>
    </div>
  );
}
