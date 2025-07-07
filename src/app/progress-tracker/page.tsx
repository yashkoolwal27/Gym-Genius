import { ProgressTracker } from "@/components/progress-tracker";
import { Header } from "@/components/header";

export default function ProgressTrackerPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="My Progress" description="Track your saved workout and meal plans." />
      <div className="p-4 md:p-8 overflow-y-auto">
        <ProgressTracker />
      </div>
    </div>
  );
}
