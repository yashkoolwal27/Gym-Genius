"use client"

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/ui/chart";
import { Area, AreaChart, CartesianGrid, XAxis } from "recharts";

const chartData = [
    { month: "Mon", attendance: 186 },
    { month: "Tue", attendance: 305 },
    { month: "Wed", attendance: 237 },
    { month: "Thu", attendance: 273 },
    { month: "Fri", attendance: 201 },
    { month: "Sat", attendance: 321 },
    { month: "Sun", attendance: 280 },
]

const chartConfig = {
    attendance: {
      label: "Attendance",
      color: "hsl(217, 91%, 60%)",
    },
}

export default function MemberAttendanceChart() {
    return (
        <Card>
            <CardHeader className="flex-row items-center justify-between">
                <div>
                    <CardTitle>Member Attendance Trends</CardTitle>
                    <CardDescription>January - July 2024</CardDescription>
                </div>
                <div className="flex gap-2">
                    <Button variant="outline" size="sm">Daily</Button>
                    <Button variant="secondary" size="sm">Weekly</Button>
                    <Button variant="outline" size="sm">Monthly</Button>
                </div>
            </CardHeader>
            <CardContent>
                <ChartContainer config={chartConfig} className="h-64 w-full">
                    <AreaChart accessibilityLayer data={chartData} margin={{ left: 12, right: 12 }}>
                        <CartesianGrid vertical={false} />
                        <XAxis
                            dataKey="month"
                            tickLine={false}
                            axisLine={false}
                            tickMargin={8}
                        />
                        <ChartTooltip cursor={false} content={<ChartTooltipContent indicator="line" />} />
                        <Area
                            dataKey="attendance"
                            type="natural"
                            fill="var(--color-attendance)"
                            fillOpacity={0.1}
                            stroke="var(--color-attendance)"
                        />
                    </AreaChart>
                </ChartContainer>
            </CardContent>
        </Card>
    )
}
