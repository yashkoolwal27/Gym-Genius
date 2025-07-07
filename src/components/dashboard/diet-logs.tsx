import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";

const dietData = [
  { label: "Protein Intake", value: 120, goal: 150, unit: "g" },
  { label: "Carbs Intake", value: 220, goal: 300, unit: "g" },
  { label: "Fat Intake", value: 50, goal: 70, unit: "g" },
];

export default function DietLogs() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Recent Diet Logs</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {dietData.map((item) => (
          <div key={item.label}>
            <div className="flex justify-between items-baseline mb-1">
              <p className="text-sm font-medium">{item.label}</p>
              <p className="text-sm text-muted-foreground">
                <span className="font-semibold text-foreground">{item.value}{item.unit}</span> / {item.goal}{item.unit}
              </p>
            </div>
            <Progress value={(item.value / item.goal) * 100} className="h-2" />
          </div>
        ))}
      </CardContent>
    </Card>
  )
}
