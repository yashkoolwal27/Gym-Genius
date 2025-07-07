import { Header } from "@/components/header";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { FileText } from "lucide-react";

export default function ReportsPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="Reports" description="View your generated fitness reports." />
      <div className="p-4 md:p-8 overflow-y-auto">
        <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70">
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><FileText /> Reports</CardTitle>
            <CardDescription>This page is under construction. Check back later for your reports!</CardDescription>
          </CardHeader>
          <CardContent>
            <p>Coming soon...</p>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
