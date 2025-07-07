import { Header } from "@/components/header";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Settings } from "lucide-react";

export default function SettingsPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="Settings" description="Manage your account settings." />
      <div className="p-4 md:p-8 overflow-y-auto">
        <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70">
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><Settings /> Settings</CardTitle>
            <CardDescription>This page is under construction. Customize your experience here soon!</CardDescription>
          </CardHeader>
          <CardContent>
            <p>Coming soon...</p>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
