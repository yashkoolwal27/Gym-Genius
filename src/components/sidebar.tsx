"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { Bell, DollarSign, FileText, LayoutDashboard, LineChart, Settings, Users, Utensils } from "lucide-react"

import { cn } from "@/lib/utils"
import { Logo } from "@/components/logo"
import { Button } from "./ui/button"

const navItems = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/#", label: "Members", icon: Users },
  { href: "/#", label: "Diet Plans", icon: Utensils },
  { href: "/#", label: "Progress", icon: LineChart },
  { href: "/#", label: "Reports", icon: FileText },
  { href: "/#", label: "Alerts", icon: Bell, badge: 2 },
  { href: "/#", label: "Subsidies", icon: DollarSign },
]

export function Sidebar() {
  const pathname = usePathname()

  return (
    <aside className="w-64 flex-shrink-0 bg-card border-r flex flex-col">
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
              {item.badge && <span className="ml-auto bg-primary text-primary-foreground text-xs rounded-full h-5 w-5 flex items-center justify-center">{item.badge}</span>}
            </Link>
          </Button>
        ))}
      </nav>
      <div className="p-4 border-t">
        <Button
          variant="ghost"
          className="w-full justify-start h-11 text-base"
          asChild
        >
          <Link href="/#">
            <Settings className="mr-3 h-5 w-5" />
            Settings
          </Link>
        </Button>
      </div>
    </aside>
  )
}
