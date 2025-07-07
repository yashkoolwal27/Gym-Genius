"use client";

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { BookOpen, HeartPulse, Apple, Droplets } from "lucide-react";
import Image from "next/image";

const articles = [
  {
    title: "The Ultimate Guide to Compound Exercises",
    description: "Learn why compound movements are key to building strength and muscle efficiently.",
    icon: HeartPulse,
    image: "https://placehold.co/600x400.png",
    hint: "gym weightlifting"
  },
  {
    title: "Understanding Macronutrients",
    description: "A deep dive into carbs, proteins, and fats and how they fuel your body and goals.",
    icon: Apple,
    image: "https://placehold.co/600x400.png",
    hint: "healthy food"
  },
  {
    title: "The Importance of Rest and Recovery",
    description: "Discover why rest days are just as important as your workout days for making progress.",
    icon: BookOpen,
    image: "https://placehold.co/600x400.png",
    hint: "yoga meditation"
  },
  {
    title: "Hydration 101: Are You Drinking Enough?",
    description: "Explore the critical role of water in fitness, performance, and overall health.",
    icon: Droplets,
    image: "https://placehold.co/600x400.png",
    hint: "water bottle"
  }
];


export function EducationalResources() {
  return (
    <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70">
      <CardHeader>
        <CardTitle className="flex items-center gap-2"><BookOpen /> Knowledge Base</CardTitle>
        <CardDescription>Expand your fitness and nutrition knowledge with these articles.</CardDescription>
      </CardHeader>
      <CardContent className="grid gap-6 md:grid-cols-2">
        {articles.map((article, index) => (
            <Card key={index} className="overflow-hidden hover:shadow-lg transition-shadow group">
                <div className="overflow-hidden">
                    <Image src={article.image} alt={article.title} width={600} height={400} className="w-full h-40 object-cover group-hover:scale-105 transition-transform duration-300" data-ai-hint={article.hint} />
                </div>
                <CardHeader>
                    <CardTitle className="flex items-start gap-3 text-lg">
                        <article.icon className="w-6 h-6 text-primary flex-shrink-0 mt-1" />
                        <span>{article.title}</span>
                    </CardTitle>
                </CardHeader>
                <CardContent>
                    <p className="text-muted-foreground text-sm">{article.description}</p>
                </CardContent>
            </Card>
        ))}
      </CardContent>
    </Card>
  );
}
