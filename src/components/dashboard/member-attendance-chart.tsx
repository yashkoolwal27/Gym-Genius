"use client"

import { Bar, BarChart, CartesianGrid, XAxis, YAxis, ReferenceLine } from "recharts";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/ui/chart";

const chartData = [
  { date: "Mon", protein: 120 },
  { date: "Tue", protein: 140 },
  { date: "Wed", protein: 155 },
  { date: "Thu", protein: 130 },
  { date: "Fri", protein: 160 },
  { date: "Sat", protein: 170 },
  { date: "Sun", protein: 145 },
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
                <CardTitle>Daily Protein Intake</CardTitle>
                <CardDescription>This chart tracks your daily protein intake for the last week. The line indicates your goal.</CardDescription>
            </CardHeader>
            <CardContent>
                <ChartContainer config={chartConfig} className="h-64 w-full">
                    <BarChart accessibilityLayer data={chartData} margin={{ left: 12, right: 12 }}>
                        <CartesianGrid vertical={false} />
                        <XAxis
                            dataKey="date"
                            tickLine={false}
                            axisLine={false}
                            tickMargin={8}
                        />
                        <YAxis domain={[0, 'dataMax + 30']}/>
                        <ChartTooltip cursor={false} content={<ChartTooltipContent indicator="line" />} />
                        <ReferenceLine y={150} label={{ value: 'Goal', position: 'insideTopLeft' }} stroke="hsl(var(--foreground))" strokeDasharray="3 3" />
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
