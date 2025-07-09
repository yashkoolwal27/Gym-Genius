'use client';
import { useAuth } from "@/hooks/use-auth";
import { usePathname } from "next/navigation";
import { Sidebar } from "./sidebar";

export function AppContent({ children }: { children: React.ReactNode }) {
    const { user, loading } = useAuth();
    const pathname = usePathname();

    const publicPaths = ['/login', '/signup'];
    const isPublicPath = publicPaths.includes(pathname);
    
    // If it is a public path, just render the children (the login/signup page)
    if (isPublicPath) {
        return <>{children}</>;
    }
    
    // If it is a protected path and user is logged in, show the app shell
    if (user) {
        return (
            <div className="min-h-screen bg-secondary/40 flex">
                <Sidebar />
                <main className="flex-1 flex flex-col md:ml-64">
                    {children}
                </main>
            </div>
        );
    }
    
    // This case (protected path, no user) is handled by the redirect in AuthProvider,
    // which shows a loader. So returning children here is fine, as the provider will handle it.
    return <>{children}</>;
}
