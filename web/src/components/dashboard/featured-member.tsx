
'use client';
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/hooks/use-auth";

export default function UserProfileCard() {
  const { user } = useAuth();
  
  return (
    <Card>
      <CardHeader>
        <CardTitle>Welcome Back!</CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col items-center text-center">
        <Avatar className="w-24 h-24 mb-4">
          <AvatarImage src="https://placehold.co/200x200.png" alt="User Avatar" data-ai-hint="person avatar"/>
          <AvatarFallback>{user?.email?.[0].toUpperCase() ?? 'U'}</AvatarFallback>
        </Avatar>
        <h3 className="text-lg font-semibold">{user?.email}</h3>
        <p className="text-sm text-muted-foreground">28 years • 6'1" • 82kg</p>
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
