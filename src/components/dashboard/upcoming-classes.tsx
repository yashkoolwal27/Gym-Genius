import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Plus } from "lucide-react"

const classes = [
    { time: "10:00 AM", title: "HIIT Class: John Wilson", description: "High-intensity interval training session", initial: "JW", color: "bg-orange-500" },
    { time: "11:00 AM", title: "Yoga: Sarah Johnson", description: "Morning vinyasa and stretching", initial: "SJ", color: "bg-purple-500" },
    { time: "02:15 PM", title: "Strength Training: Michael Brown", description: "Full-body weight-training session", initial: "MB", color: "bg-blue-500" },
    { time: "04:00 PM", title: "Nutrition Workshop", description: "Learn about balanced diets and meal planning", initial: "N", color: "bg-green-500" },
]

export default function UpcomingClasses() {
    return (
        <Card>
            <CardHeader className="flex flex-row items-center justify-between">
                <CardTitle>Upcoming Classes</CardTitle>
                <Button variant="outline" size="sm"><Plus className="h-4 w-4 mr-2" /> Add Filter</Button>
            </CardHeader>
            <CardContent>
                <div className="space-y-6">
                    {classes.map((item, index) => (
                        <div key={index} className="flex items-start gap-4">
                            <div className="text-right flex-shrink-0 w-20">
                                <p className="font-bold text-sm">{item.time}</p>
                            </div>
                            <div className="border-l-2 pl-4 border-primary/30 flex-1">
                                <div className="flex items-center gap-3">
                                    <div className={`w-8 h-8 rounded-full flex items-center justify-center text-white font-bold text-sm ${item.color}`}>
                                        {item.initial}
                                    </div>
                                    <p className="font-semibold">{item.title}</p>
                                </div>
                                <p className="text-sm text-muted-foreground ml-11">{item.description}</p>
                            </div>
                        </div>
                    ))}
                </div>
            </CardContent>
        </Card>
    )
}
