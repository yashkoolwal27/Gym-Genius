import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { MoreHorizontal } from "lucide-react";

export default function FeaturedMember() {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>Featured Member</CardTitle>
        <MoreHorizontal className="h-5 w-5 text-muted-foreground" />
      </CardHeader>
      <CardContent className="flex flex-col items-center text-center">
        <Avatar className="w-24 h-24 mb-4">
          <AvatarImage src="https://placehold.co/200x200.png" alt="John Wilson" data-ai-hint="man portrait"/>
          <AvatarFallback>JW</AvatarFallback>
        </Avatar>
        <h3 className="text-lg font-semibold">John Wilson</h3>
        <p className="text-sm text-muted-foreground">28 years • 6'1" • 182lbs</p>
        <div className="flex w-full justify-around mt-4 pt-4 border-t">
            <div className="text-center">
                <p className="text-2xl font-bold">520</p>
                <p className="text-xs text-muted-foreground">Calories Burned</p>
            </div>
            <div className="text-center">
                <p className="text-2xl font-bold">72</p>
                <p className="text-xs text-muted-foreground">Workouts Completed</p>
            </div>
            <div className="text-center">
                <p className="text-2xl font-bold">5.2</p>
                <p className="text-xs text-muted-foreground">BMI Change</p>
            </div>
        </div>
      </CardContent>
    </Card>
  )
}
