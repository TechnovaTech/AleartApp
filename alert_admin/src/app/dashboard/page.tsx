'use client'

import { useRouter } from 'next/navigation'
import { 
  Users, 
  CreditCard, 
  QrCode, 
  BarChart3, 
  Bell, 
  Settings, 
  HelpCircle,
  FileText,
  TrendingUp,
  TrendingDown,
  Activity,
  Smartphone
} from 'lucide-react'

const modules = [
  { id: 'users', name: 'User Management', icon: Users, count: '1,234' },
  { id: 'payments', name: 'Payment Monitoring', icon: CreditCard, count: '₹45,678' },
  { id: 'qr', name: 'QR Code Management', icon: QrCode, count: '567' },
  { id: 'analytics', name: 'Analytics', icon: BarChart3, count: '89%' },
  { id: 'notifications', name: 'Notifications', icon: Bell, count: '12' },
  { id: 'settings', name: 'Settings', icon: Settings, count: '' },
  { id: 'reports', name: 'Reports', icon: FileText, count: '23' },
  { id: 'support', name: 'Support', icon: HelpCircle, count: '5' },
]

export default function Dashboard() {
  const router = useRouter()

  return (
    <div className="p-6 space-y-6">
      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Total Users</h3>
              <p className="text-3xl font-bold text-blue-600">1,234</p>
              <p className="text-sm text-green-600 mt-1 flex items-center">
                <TrendingUp size={16} className="mr-1" />
                +12% this month
              </p>
            </div>
            <Users className="h-12 w-12 text-blue-500" />
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Revenue</h3>
              <p className="text-3xl font-bold text-green-600">₹45,678</p>
              <p className="text-sm text-green-600 mt-1 flex items-center">
                <TrendingUp size={16} className="mr-1" />
                +18% this month
              </p>
            </div>
            <CreditCard className="h-12 w-12 text-green-500" />
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">QR Codes</h3>
              <p className="text-3xl font-bold text-purple-600">567</p>
              <p className="text-sm text-green-600 mt-1 flex items-center">
                <TrendingUp size={16} className="mr-1" />
                +8% this month
              </p>
            </div>
            <QrCode className="h-12 w-12 text-purple-500" />
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Success Rate</h3>
              <p className="text-3xl font-bold text-yellow-600">94.5%</p>
              <p className="text-sm text-green-600 mt-1 flex items-center">
                <TrendingUp size={16} className="mr-1" />
                +2% this month
              </p>
            </div>
            <Activity className="h-12 w-12 text-yellow-500" />
          </div>
        </div>
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* User Growth Chart */}
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">User Growth Trend</h3>
          <div className="h-64 bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg p-4">
            <div className="h-full flex items-end justify-between space-x-2">
              {[40, 65, 45, 80, 60, 90, 75, 95, 70, 85, 100, 120].map((height, i) => (
                <div key={i} className="flex-1 bg-blue-500 rounded-t" style={{height: `${height}%`}}></div>
              ))}
            </div>
          </div>
          <div className="mt-4 flex justify-between text-sm text-gray-600">
            <span>Jan</span>
            <span>Dec</span>
          </div>
        </div>

        {/* Revenue Chart */}
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Revenue Analytics</h3>
          <div className="h-64 bg-gradient-to-br from-green-50 to-green-100 rounded-lg p-4">
            <div className="h-full flex items-end justify-between space-x-2">
              {[30, 55, 35, 70, 50, 80, 65, 85, 60, 75, 90, 100].map((height, i) => (
                <div key={i} className="flex-1 bg-green-500 rounded-t" style={{height: `${height}%`}}></div>
              ))}
            </div>
          </div>
          <div className="mt-4 flex justify-between text-sm text-gray-600">
            <span>Jan</span>
            <span>Dec</span>
          </div>
        </div>
      </div>

      {/* Analytics Cards */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Top Features</h3>
          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <span className="text-sm text-gray-600">QR Generation</span>
              <div className="flex items-center">
                <div className="w-24 bg-gray-200 rounded-full h-2 mr-2">
                  <div className="bg-blue-500 h-2 rounded-full" style={{width: '85%'}}></div>
                </div>
                <span className="text-sm font-medium">85%</span>
              </div>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm text-gray-600">Payment Alerts</span>
              <div className="flex items-center">
                <div className="w-24 bg-gray-200 rounded-full h-2 mr-2">
                  <div className="bg-green-500 h-2 rounded-full" style={{width: '92%'}}></div>
                </div>
                <span className="text-sm font-medium">92%</span>
              </div>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm text-gray-600">Reports</span>
              <div className="flex items-center">
                <div className="w-24 bg-gray-200 rounded-full h-2 mr-2">
                  <div className="bg-yellow-500 h-2 rounded-full" style={{width: '67%'}}></div>
                </div>
                <span className="text-sm font-medium">67%</span>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Device Analytics</h3>
          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <div className="flex items-center">
                <Smartphone className="h-4 w-4 text-green-500 mr-2" />
                <span className="text-sm text-gray-600">Android</span>
              </div>
              <span className="text-sm font-medium text-green-600">78%</span>
            </div>
            <div className="flex justify-between items-center">
              <div className="flex items-center">
                <Smartphone className="h-4 w-4 text-blue-500 mr-2" />
                <span className="text-sm text-gray-600">iOS</span>
              </div>
              <span className="text-sm font-medium text-blue-600">22%</span>
            </div>
          </div>
          <div className="mt-4 h-32 bg-gray-50 rounded-lg flex items-center justify-center">
            <div className="text-center">
              <div className="w-20 h-20 bg-gradient-to-r from-green-400 to-blue-500 rounded-full mx-auto mb-2"></div>
              <p className="text-sm text-gray-600">Device Distribution</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Recent Activity</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between py-2">
              <div className="flex items-center">
                <div className="w-2 h-2 bg-green-500 rounded-full mr-3"></div>
                <span className="text-sm text-gray-600">New user registered</span>
              </div>
              <span className="text-xs text-gray-400">2m ago</span>
            </div>
            <div className="flex items-center justify-between py-2">
              <div className="flex items-center">
                <div className="w-2 h-2 bg-blue-500 rounded-full mr-3"></div>
                <span className="text-sm text-gray-600">Payment received</span>
              </div>
              <span className="text-xs text-gray-400">5m ago</span>
            </div>
            <div className="flex items-center justify-between py-2">
              <div className="flex items-center">
                <div className="w-2 h-2 bg-purple-500 rounded-full mr-3"></div>
                <span className="text-sm text-gray-600">QR code generated</span>
              </div>
              <span className="text-xs text-gray-400">8m ago</span>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Access Modules */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h2 className="text-xl font-semibold mb-4">Quick Access</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {modules.map((module) => {
            const Icon = module.icon
            return (
              <div
                key={module.id}
                onClick={() => router.push(module.id === '' ? '/dashboard' : `/dashboard/${module.id}`)}
                className="bg-gradient-to-br from-blue-50 to-blue-100 p-4 rounded-lg border border-blue-200 hover:shadow-md transition-all cursor-pointer"
              >
                <div className="flex items-center justify-between mb-3">
                  <Icon className="h-6 w-6 text-blue-600" />
                  {module.count && (
                    <span className="bg-blue-600 text-white px-2 py-1 rounded-full text-xs font-bold">
                      {module.count}
                    </span>
                  )}
                </div>
                <h3 className="font-medium text-gray-800 text-sm">{module.name}</h3>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}