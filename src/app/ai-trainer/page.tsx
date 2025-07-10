import { AITrainer } from "@/components/ai-trainer";
import { Header } from "@/components/header";

export default function AITrainerPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="AI Trainer" description="Get personalized feedback and insights from your AI coach." />
      <div className="p-4 md:p-8 overflow-y-auto">
        <AITrainer />
      </div>
    </div>
  );
}
