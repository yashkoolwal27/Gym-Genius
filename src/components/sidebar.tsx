"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { LayoutDashboard, Settings, Dumbbell, UtensilsCrossed, LineChart, FileText } from "lucide-react"

import { cn } from "@/lib/utils"
import { Logo } from "@/components/logo"
import { Button } from "./ui/button"

const navItems = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/workout-generator", label: "Exercise", icon: Dumbbell },
  { href: "/meal-planner", label: "Diet Plans", icon: UtensilsCrossed },
  { href: "/progress-tracker", label: "Progress", icon: LineChart },
  { href: "/reports", label: "Reports", icon: FileText },
  { href: "/settings", label: "Settings", icon: Settings },
]

export function Sidebar() {
  const pathname = usePathname()

  return (
    <aside className="fixed h-full z-10 w-64 flex-shrink-0 bg-card border-r flex flex-col">
      <div className="h-20 flex items-center px-6 border-b">
        <Logo />
      </div>
      <nav className="flex-1 py-6 px-4 space-y-1">
        {navItems.map((item) => (
          <Button
            key={item.label}
            variant={pathname === item.href ? "secondary" : "ghost"}
            className="w-full justify-start h-11 text-base"
            asChild
          >
            <Link href={item.href}>
              <item.icon className="mr-3 h-5 w-5" />
              {item.label}
            </Link>
          </Button>
        ))}
      </nav>
    </aside>
  )
}
