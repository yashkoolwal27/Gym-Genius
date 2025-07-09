import { WorkoutLogger } from "@/components/workout-logger";
import { Header } from "@/components/header";

export default function LogWorkoutPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="Log a Workout" description="Manually enter your workout details to track your progress." />
      <div className="flex-1 p-4 md:p-8 overflow-y-auto flex">
        <WorkoutLogger />
      </div>
    </div>
  );
}
