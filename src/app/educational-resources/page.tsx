import { EducationalResources } from "@/components/educational-resources";
import { Header } from "@/components/header";

export default function EducationalResourcesPage() {
  return (
    <div className="flex-1 flex flex-col">
      <Header title="Knowledge Base" description="Learn more about fitness and nutrition." />
      <div className="p-4 md:p-8 overflow-y-auto">
        <EducationalResources />
      </div>
    </div>
  );
}
