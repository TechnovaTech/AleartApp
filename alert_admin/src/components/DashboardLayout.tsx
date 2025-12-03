'use client'

import { useState } from 'react'
import { useRouter, usePathname } from 'next/navigation'
import { 
  Users, 
  CreditCard, 
  QrCode, 
  BarChart3, 
  Bell, 
  Settings, 
  HelpCircle,
  Volume2,
  Menu,
  X,
  LogOut,
  FileText,
  Home,
  Calendar,
  Activity,
  Webhook,
  Shield
} from 'lucide-react'

const modules = [
  { id: '', name: 'Dashboard', icon: Home },
  { id: 'users', name: 'User Management', icon: Users },
  { id: 'payments', name: 'Payment Monitoring', icon: CreditCard },
  { id: 'subscription-management', name: 'Subscriptions', icon: CreditCard },
  { id: 'mandates', name: 'Mandate Management', icon: Shield },
  { id: 'qr', name: 'QR Code Management', icon: QrCode },
  { id: 'plans', name: 'Plans & Pricing', icon: Calendar },
  { id: 'trial-settings', name: 'Trial Settings', icon: Settings },
  { id: 'user-timeline', name: 'User Timeline', icon: Activity },
  { id: 'webhook-logs', name: 'Webhook Logs', icon: Webhook },
  { id: 'analytics', name: 'Analytics', icon: BarChart3 },
  { id: 'notifications', name: 'Notifications', icon: Bell },
  { id: 'reports', name: 'Reports', icon: FileText },
  { id: 'support', name: 'Support', icon: HelpCircle },
]

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const router = useRouter()
  const pathname = usePathname()

  const handleLogout = () => {
    router.push('/')
  }

  const getActiveModule = () => {
    if (pathname === '/dashboard') return 'Dashboard'
    const path = pathname.substring(1)
    return modules.find(m => m.id === path)?.name || 'Dashboard'
  }

  return (
    <div className="h-screen bg-gray-100 flex overflow-hidden">
      {/* Sidebar */}
      <div className={`${sidebarOpen ? 'w-64' : 'w-16'} bg-blue-500 transition-all duration-300 flex flex-col flex-shrink-0`}>
        {/* Header */}
        <div className="p-4 border-b border-blue-400">
          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <Volume2 className="w-8 h-8 text-white" />
              {sidebarOpen && (
                <span className="ml-2 text-white font-bold text-lg">AlertPe Admin</span>
              )}
            </div>
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="text-white hover:bg-blue-400 p-1 rounded"
            >
              {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
            </button>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-4">
          <ul className="space-y-2">
            {modules.map((module) => {
              const Icon = module.icon
              const isActive = module.id === '' ? pathname === '/dashboard' : pathname === `/${module.id}`
              return (
                <li key={module.id}>
                  <button
                    onClick={() => router.push(module.id === '' ? '/dashboard' : `/${module.id}`)}
                    className={`w-full flex items-center p-3 rounded-lg transition-colors ${
                      isActive
                        ? 'bg-blue-400 text-white'
                        : 'text-blue-100 hover:bg-blue-400 hover:text-white'
                    }`}
                  >
                    <Icon size={20} />
                    {sidebarOpen && (
                      <span className="ml-3 font-medium">{module.name}</span>
                    )}
                  </button>
                </li>
              )
            })}
          </ul>
        </nav>

        {/* Logout */}
        <div className="p-4 border-t border-blue-400">
          <button
            onClick={handleLogout}
            className="w-full flex items-center p-3 text-blue-100 hover:bg-blue-400 hover:text-white rounded-lg transition-colors"
          >
            <LogOut size={20} />
            {sidebarOpen && <span className="ml-3">Logout</span>}
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top Bar */}
        <header className="bg-white shadow-sm p-4 border-b">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-gray-800">
              {getActiveModule()}
            </h1>
            <div className="flex items-center space-x-4">
              <div className="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-medium">
                Online
              </div>
              <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                <span className="text-white font-bold text-sm">A</span>
              </div>
            </div>
          </div>
        </header>

        {/* Content Area */}
        <main className="flex-1 overflow-y-auto">
          {children}
        </main>
      </div>
    </div>
  )
}