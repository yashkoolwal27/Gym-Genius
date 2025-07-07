import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { MoreVertical } from "lucide-react";

const workouts = [
  { id: "#W18342", name: "John Wilson", workout: "HIIT", date: "Mar 12, 2024", status: "Completed", calories: "520 kcal" , avatar: "https://placehold.co/100x100.png", hint: "man face"},
  { id: "#W18305", name: "Sarah Johnson", workout: "Yoga", date: "Mar 12, 2024", status: "Completed", calories: "316 kcal" , avatar: "https://placehold.co/100x100.png", hint: "woman face"},
  { id: "#W18114", name: "Michael Brown", workout: "Strength Training", date: "Mar 12, 2024", status: "Completed", calories: "450 kcal" , avatar: "https://placehold.co/100x100.png", hint: "man portrait"},
  { id: "#W18077", name: "Emily Davis", workout: "Pilates", date: "Mar 11, 2024", status: "Completed", calories: "280 kcal" , avatar: "https://placehold.co/100x100.png", hint: "woman portrait"},
  { id: "#W18152", name: "Robert Miller", workout: "Cardio", date: "Mar 11, 2024", status: "Upcoming", calories: "Pending" , avatar: "https://placehold.co/100x100.png", hint: "man glasses"},
];

export default function RecentWorkouts() {
    return (
        <Card>
            <CardHeader>
                <CardTitle>Recent Workouts</CardTitle>
            </CardHeader>
            <CardContent>
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Member ID</TableHead>
                            <TableHead>Name</TableHead>
                            <TableHead>Workout</TableHead>
                            <TableHead>Date</TableHead>
                            <TableHead>Status</TableHead>
                            <TableHead>Calories Burned</TableHead>
                            <TableHead></TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {workouts.map((workout) => (
                            <TableRow key={workout.id}>
                                <TableCell className="font-medium">{workout.id}</TableCell>
                                <TableCell>
                                    <div className="flex items-center gap-3">
                                        <Avatar className="h-8 w-8">
                                            <AvatarImage src={workout.avatar} alt={workout.name} data-ai-hint={workout.hint}/>
                                            <AvatarFallback>{workout.name.charAt(0)}</AvatarFallback>
                                        </Avatar>
                                        <span>{workout.name}</span>
                                    </div>
                                </TableCell>
                                <TableCell>{workout.workout}</TableCell>
                                <TableCell>{workout.date}</TableCell>
                                <TableCell>
                                    <Badge variant={workout.status === "Completed" ? "secondary" : "outline"} className={workout.status === "Completed" ? "bg-green-100 text-green-700 border-green-200" : "bg-yellow-100 text-yellow-700 border-yellow-200"}>
                                        {workout.status}
                                    </Badge>
                                </TableCell>
                                <TableCell className="font-semibold text-green-600">{workout.calories}</TableCell>
                                <TableCell>
                                    <MoreVertical className="h-5 w-5 text-muted-foreground" />
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </CardContent>
        </Card>
    )
}
