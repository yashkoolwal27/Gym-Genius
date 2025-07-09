"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { LayoutDashboard, Settings, Dumbbell, UtensilsCrossed, LineChart, FileText } from "lucide-react"

import { cn } from "@/lib/utils"
import { Button } from "./ui/button"

const navItems = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/workout-generator", label: "Workout", icon: Dumbbell },
  { href: "/meal-planner", label: "Diet Plans", icon: UtensilsCrossed },
  { href: "/progress-tracker", label: "Progress", icon: LineChart },
  { href: "/reports", label: "Reports", icon: FileText },
  { href: "/settings", label: "Settings", icon: Settings },
]

export function SidebarNav({ className }: { className?: string }) {
  const pathname = usePathname()

  return (
    <nav className={cn("space-y-1", className)}>
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
  )
}
