
"use client";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { useLocalStorage } from "@/hooks/use-local-storage";
import type { WorkoutLog } from "@/lib/types";
import { format } from "date-fns";

export default function RecentWorkouts() {
    const [loggedWorkouts] = useLocalStorage<WorkoutLog[]>("workout-logs", []);

    const recentWorkouts = loggedWorkouts
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
      .slice(0, 5);

    return (
        <Card>
            <CardHeader>
                <CardTitle>Your Recent Workouts</CardTitle>
            </CardHeader>
            <CardContent>
                {recentWorkouts.length > 0 ? (
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Date</TableHead>
                                <TableHead>Workout Type</TableHead>
                                <TableHead>Exercises</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {recentWorkouts.map((workout) => (
                                <TableRow key={workout.id}>
                                    <TableCell className="font-medium">{format(new Date(workout.date), "MMM d, yyyy")}</TableCell>
                                    <TableCell>
                                        <div className="flex flex-wrap gap-1">
                                            {workout.exerciseTypes.map(type => (
                                                <Badge key={type} variant="secondary">{type}</Badge>
                                            ))}
                                        </div>
                                    </TableCell>
                                    <TableCell>{workout.exercises.length} exercises</TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                ) : (
                    <div className="text-center text-muted-foreground p-8">
                        <p>You haven't logged any workouts yet.</p>
                        <p className="text-sm">Go to the "Exercise" page to log your first session!</p>
                    </div>
                )}
            </CardContent>
        </Card>
    )
}
