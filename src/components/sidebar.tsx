import { Logo } from "@/components/logo";
import { SidebarNav } from "@/components/sidebar-nav";

export function Sidebar() {
  return (
    <aside className="hidden h-full z-10 w-64 flex-shrink-0 border-r bg-card md:flex md:flex-col">
      <div className="flex h-20 items-center border-b px-6">
        <Logo />
      </div>
      <SidebarNav className="flex-1 px-4 py-6" />
    </aside>
  );
}
