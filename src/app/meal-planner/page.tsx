
"use client"

import { useState } from "react";
import { MealPlanner } from "@/components/meal-planner";
import { Header } from "@/components/header";
import { DietLogger } from "@/components/diet-logger";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { BrainCircuit, BookCheck } from "lucide-react";
import Image from "next/image";
import { cn } from "@/lib/utils";

type View = "selector" | "ai-planner" | "diet-logger";

export default function MealPlannerPage() {
  const [view, setView] = useState<View>("selector");

  const renderContent = () => {
    switch (view) {
      case "ai-planner":
        return <MealPlanner />;
      case "diet-logger":
        return <DietLogger />;
      default:
        return (
           <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mt-8">
            <Card 
              className="relative rounded-lg overflow-hidden cursor-pointer group transform hover:scale-105 transition-transform duration-300"
              onClick={() => setView("ai-planner")}
            >
              <Image 
                src="https://placehold.co/600x400.png" 
                alt="AI Meal Planner" 
                width={600} 
                height={400} 
                className="object-cover w-full h-full"
                data-ai-hint="healthy food"
              />
              <div className="absolute inset-0 bg-black/50 group-hover:bg-black/60 transition-colors duration-300" />
              <CardHeader className="absolute inset-0 flex flex-col items-center justify-center text-center p-4">
                <BrainCircuit className="h-12 w-12 text-white/80 mb-4" />
                <h3 className="text-2xl font-bold text-white">AI Meal Planner</h3>
                <p className="text-white/80 mt-2">Let our AI create a custom meal plan for you.</p>
              </CardHeader>
            </Card>

            <Card 
              className="relative rounded-lg overflow-hidden cursor-pointer group transform hover:scale-105 transition-transform duration-300"
              onClick={() => setView("diet-logger")}
            >
              <Image 
                src="https://placehold.co/600x400.png" 
                alt="Log Your Daily Diet" 
                width={600} 
                height={400} 
                className="object-cover w-full h-full"
                data-ai-hint="food journal"
              />
              <div className="absolute inset-0 bg-black/50 group-hover:bg-black/60 transition-colors duration-300" />
              <CardHeader className="absolute inset-0 flex flex-col items-center justify-center text-center p-4">
                <BookCheck className="h-12 w-12 text-white/80 mb-4" />
                <h3 className="text-2xl font-bold text-white">Log Your Daily Diet</h3>
                <p className="text-white/80 mt-2">Manually track your food intake.</p>
              </CardHeader>
            </Card>
          </div>
        );
    }
  };

  return (
    <div className="flex-1 flex flex-col">
      <Header title="Diet Plans" description="Generate meal plans or log your daily intake." />
      <div className="p-4 md:p-8 overflow-y-auto">
        <div className="w-full max-w-4xl mx-auto">
          {renderContent()}
        </div>
      </div>
    </div>
  );
}
