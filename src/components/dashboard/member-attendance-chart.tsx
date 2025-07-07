"use client"

import { useState } from "react";
import { Bar, BarChart, CartesianGrid, XAxis, YAxis, ReferenceLine } from "recharts";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/ui/chart";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";

const dailyData = [
  { date: "Mon", protein: 120 },
  { date: "Tue", protein: 140 },
  { date: "Wed", protein: 155 },
  { date: "Thu", protein: 130 },
  { date: "Fri", protein: 160 },
  { date: "Sat", protein: 170 },
  { date: "Sun", protein: 145 },
];

const weeklyData = [
    { date: "Week 1", protein: 980 },
    { date: "Week 2", protein: 1050 },
    { date: "Week 3", protein: 1100 },
    { date: "Week 4", protein: 1020 },
];

const monthlyData = [
    { date: "Jan", protein: 4200 },
    { date: "Feb", protein: 4000 },
    { date: "Mar", protein: 4500 },
    { date: "Apr", protein: 4300 },
    { date: "May", protein: 4600 },
    { date: "Jun", protein: 4400 },
];

const yearlyData = [
    { date: "2022", protein: 50000 },
    { date: "2023", protein: 52000 },
    { date: "2024", protein: 55000 },
];

const chartConfig = {
    protein: {
      label: "Protein (g)",
      color: "hsl(var(--primary))",
    },
};

const dataMap = {
    daily: { data: dailyData, goal: 150, description: "This chart tracks your daily protein intake for the last week.", domain: [0, 'dataMax + 30'] },
    weekly: { data: weeklyData, goal: 1050, description: "This chart tracks your weekly protein intake for the last month.", domain: [0, 'dataMax + 100'] },
    monthly: { data: monthlyData, goal: 4400, description: "This chart tracks your monthly protein intake for the last 6 months.", domain: [0, 'dataMax + 500'] },
    yearly: { data: yearlyData, goal: 52000, description: "This chart tracks your yearly protein intake.", domain: [0, 'dataMax + 5000'] },
} as const;


export default function DietAndExerciseChart() {
    const [view, setView] = useState<keyof typeof dataMap>("daily");
    const { data, goal, description, domain } = dataMap[view];

    return (
        <Card>
            <CardHeader className="flex flex-row items-start justify-between">
                <div>
                    <CardTitle>Protein Intake Trends</CardTitle>
                    <CardDescription>{description}</CardDescription>
                </div>
                <Tabs defaultValue="daily" onValueChange={(value) => setView(value as keyof typeof dataMap)} className="w-auto">
                    <TabsList>
                        <TabsTrigger value="daily">Daily</TabsTrigger>
                        <TabsTrigger value="weekly">Weekly</TabsTrigger>
                        <TabsTrigger value="monthly">Monthly</TabsTrigger>
                        <TabsTrigger value="yearly">Yearly</TabsTrigger>
                    </TabsList>
                </Tabs>
            </CardHeader>
            <CardContent>
                <ChartContainer config={chartConfig} className="h-64 w-full">
                    <BarChart accessibilityLayer data={data} margin={{ left: 12, right: 12 }}>
                        <CartesianGrid vertical={false} />
                        <XAxis
                            dataKey="date"
                            tickLine={false}
                            axisLine={false}
                            tickMargin={8}
                        />
                        <YAxis domain={domain as [number, string]}/>
                        <ChartTooltip cursor={false} content={<ChartTooltipContent indicator="line" />} />
                        <ReferenceLine y={goal} label={{ value: 'Goal', position: 'insideTopLeft' }} stroke="hsl(var(--foreground))" strokeDasharray="3 3" />
                        <Bar
                            dataKey="protein"
                            fill="var(--color-protein)"
                            radius={4}
                        />
                    </BarChart>
                </ChartContainer>
            </CardContent>
        </Card>
    )
}
