import { Header } from "@/components/header";
import { ProfileForm } from "@/components/profile-form";

export default function SettingsPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="Profile & Settings" description="Manage your profile and account settings." />
      <div className="p-4 md:p-8 overflow-y-auto">
        <ProfileForm />
      </div>
    </div>
  );
}
