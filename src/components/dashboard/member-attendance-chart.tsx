"use client"

import { Bar, BarChart, CartesianGrid, XAxis, YAxis } from "recharts";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/ui/chart";

const chartData = [
  { category: "Poultry", protein: 45 },
  { category: "Red Meat", protein: 55 },
  { category: "Fish", protein: 40 },
  { category: "Dairy & Eggs", protein: 30 },
  { category: "Plant-Based", protein: 25 },
  { category: "Supplements", protein: 50 },
];

const chartConfig = {
    protein: {
      label: "Protein (g)",
      color: "hsl(var(--primary))",
    },
};

export default function DietAndExerciseChart() {
    return (
        <Card>
            <CardHeader>
                <CardTitle>Protein Intake by Category</CardTitle>
                <CardDescription>This chart tracks your protein intake from various sources.</CardDescription>
            </CardHeader>
            <CardContent>
                <ChartContainer config={chartConfig} className="h-64 w-full">
                    <BarChart accessibilityLayer data={chartData} margin={{ left: 12, right: 12 }}>
                        <CartesianGrid vertical={false} />
                        <XAxis
                            dataKey="category"
                            tickLine={false}
                            axisLine={false}
                            tickMargin={8}
                            interval={0}
                        />
                        <YAxis />
                        <ChartTooltip cursor={false} content={<ChartTooltipContent indicator="line" />} />
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
