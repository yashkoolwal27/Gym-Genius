import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Bell, User, Zap, BookOpen } from "lucide-react"

const activities = [
    { icon: User, text: "New member joined", subtext: "Michael Brown just joined FitTrack Pro", time: "Today, 09:42 AM", iconBg: "bg-blue-100 text-blue-500" },
    { icon: Zap, text: "Workout completed", subtext: "HIIT Session completed by John Wilson", time: "Today, 08:15 AM", iconBg: "bg-orange-100 text-orange-500" },
    { icon: BookOpen, text: "Diet plan updated", subtext: "Sarah Johnson updated her diet plan", time: "Yesterday, 03:00 PM", iconBg: "bg-purple-100 text-purple-500" },
    { icon: Bell, text: "Progress report generated", subtext: "Monthly progress report generated for all members", time: "Yesterday, 11:30 AM", iconBg: "bg-green-100 text-green-500" },
]

export default function RecentActivity() {
    return (
        <Card>
            <CardHeader>
                <CardTitle>Recent Activity</CardTitle>
            </CardHeader>
            <CardContent>
                <div className="space-y-6">
                    {activities.map((activity, index) => (
                        <div key={index} className="flex items-start gap-4">
                            <div className={`rounded-full p-2 ${activity.iconBg}`}>
                                <activity.icon className="h-5 w-5" />
                            </div>
                            <div className="flex-1">
                                <p className="font-medium">{activity.text}</p>
                                <p className="text-sm text-muted-foreground">{activity.subtext}</p>
                                <p className="text-xs text-muted-foreground mt-1">{activity.time}</p>
                            </div>
                        </div>
                    ))}
                </div>
            </CardContent>
        </Card>
    )
}
