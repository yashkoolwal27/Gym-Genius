
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
            originalDate: new Date(log.date),
            weight: log.weight,
        }))
        .sort((a, b) => a.originalDate.getTime() - b.originalDate.getTime())
        .map(log => ({
            date: format(log.originalDate, 'MMM d'),
            weight: log.weight,
            originalDate: log.originalDate.toISOString(),
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
            </Header>
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
                                labelFormatter={(value, payload) => {
                                    if (payload && payload.length && payload[0].payload.originalDate) {
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
