
"use client"

import { Line, LineChart, CartesianGrid, XAxis, YAxis, Tooltip } from "recharts";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ChartContainer, ChartTooltipContent } from "@/components/ui/chart";
import type { WeightLog } from "@/lib/types";
import { format } from 'date-fns';

const chartConfig = {
    weight: {
      label: "Weight (kg)",
      color: "hsl(var(--primary))",
    },
};

interface WeightProgressChartProps {
    weightLogs: WeightLog[];
}

export default function WeightProgressChart({ weightLogs }: WeightProgressChartProps) {
    const formattedData = weightLogs
        .map(log => ({
            date: new Date(log.date),
            weight: log.weight,
        }))
        .sort((a, b) => a.date.getTime() - b.date.getTime())
        .map(log => ({
            ...log,
            date: format(log.date, 'MMM d'), // Format date for display on X-axis
        }));
    
    if (weightLogs.length < 2) {
        return (
            <Card>
                <CardHeader>
                    <CardTitle>Weight Progress</CardTitle>
                    <CardDescription>Your weight trend over time.</CardDescription>
                </CardHeader>
                <CardContent className="flex items-center justify-center h-64">
                    <p className="text-muted-foreground">Not enough data to display a chart. Log at least two weight entries.</p>
                </CardContent>
            </Card>
        );
    }

    return (
        <Card>
            <CardHeader>
                <CardTitle>Weight Progress</CardTitle>
                <CardDescription>Your weight trend over time.</CardDescription>
            </CardHeader>
            <CardContent>
                <ChartContainer config={chartConfig} className="h-64 w-full">
                    <LineChart accessibilityLayer data={formattedData} margin={{ left: 12, right: 12, top: 20 }}>
                        <CartesianGrid vertical={false} />
                        <XAxis
                            dataKey="date"
                            tickLine={false}
                            axisLine={false}
                            tickMargin={8}
                        />
                        <YAxis
                            domain={['dataMin - 2', 'dataMax + 2']}
                            tickFormatter={(value) => `${value}kg`}
                        />
                        <Tooltip
                            cursor={false}
                            content={<ChartTooltipContent 
                                indicator="line" 
                                labelKey="weight"
                                labelFormatter={(value, payload) => {
                                    if (payload && payload.length) {
                                      return format(new Date(payload[0].payload.originalDate), 'PPP');
                                    }
                                    return value;
                                }}
                            />}
                        />
                        <Line
                            dataKey="weight"
                            type="monotone"
                            stroke="var(--color-weight)"
                            strokeWidth={2}
                            dot={{
                                fill: "var(--color-weight)",
                            }}
                            activeDot={{
                                r: 6,
                            }}
                        />
                    </LineChart>
                </ChartContainer>
            </CardContent>
        </Card>
    );
}
