'use client'

import { useState } from 'react'
import { Send, Bell, Users, Smartphone, Plus, Eye } from 'lucide-react'

const notifications = [
  { id: 1, title: 'App Update Available', message: 'New version 2.1.0 is now available with bug fixes', type: 'update', sent: '2024-01-24 10:30', recipients: 1234, status: 'sent' },
  { id: 2, title: 'Maintenance Notice', message: 'Scheduled maintenance on Jan 25, 2024 from 2:00 AM to 4:00 AM', type: 'maintenance', sent: '2024-01-23 18:00', recipients: 1234, status: 'sent' },
  { id: 3, title: 'New Feature Launch', message: 'Introducing multi-language support in AlertPe', type: 'feature', sent: '2024-01-22 14:15', recipients: 1180, status: 'sent' },
]

export default function NotificationsPage() {
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [formData, setFormData] = useState({
    title: '',
    message: '',
    type: 'general',
    target: 'all'
  })

  const handleSendNotification = () => {
    // Handle sending notification
    console.log('Sending notification:', formData)
    setShowCreateForm(false)
    setFormData({ title: '', message: '', type: 'general', target: 'all' })
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-800 mb-2">Notification Management</h1>
            <p className="text-gray-600">Send push notifications and manage user communications</p>
          </div>
          <button
            onClick={() => setShowCreateForm(true)}
            className="flex items-center px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
          >
            <Plus size={16} className="mr-2" />
            Send Notification
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Total Sent</h3>
              <p className="text-2xl font-bold text-blue-600">{notifications.length}</p>
            </div>
            <Send className="h-8 w-8 text-blue-500" />
          </div>
          <p className="text-xs text-blue-600 mt-1">This month</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Active Users</h3>
              <p className="text-2xl font-bold text-green-600">1,180</p>
            </div>
            <Users className="h-8 w-8 text-green-500" />
          </div>
          <p className="text-xs text-green-600 mt-1">Can receive notifications</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Delivery Rate</h3>
              <p className="text-2xl font-bold text-purple-600">96.8%</p>
            </div>
            <Smartphone className="h-8 w-8 text-purple-500" />
          </div>
          <p className="text-xs text-purple-600 mt-1">Average delivery rate</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Open Rate</h3>
              <p className="text-2xl font-bold text-yellow-600">78.5%</p>
            </div>
            <Bell className="h-8 w-8 text-yellow-500" />
          </div>
          <p className="text-xs text-yellow-600 mt-1">Users who opened</p>
        </div>
      </div>

      {/* Create Notification Form */}
      {showCreateForm && (
        <div className="bg-white p-6 rounded-lg shadow-sm border mb-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Send New Notification</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Title</label>
              <input
                type="text"
                value={formData.title}
                onChange={(e) => setFormData({...formData, title: e.target.value})}
                className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Notification title"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Type</label>
              <select
                value={formData.type}
                onChange={(e) => setFormData({...formData, type: e.target.value})}
                className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="general">General</option>
                <option value="update">App Update</option>
                <option value="maintenance">Maintenance</option>
                <option value="feature">New Feature</option>
                <option value="promotion">Promotion</option>
              </select>
            </div>
          </div>
          <div className="mt-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">Message</label>
            <textarea
              value={formData.message}
              onChange={(e) => setFormData({...formData, message: e.target.value})}
              rows={4}
              className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Notification message"
            />
          </div>
          <div className="mt-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">Target Audience</label>
            <select
              value={formData.target}
              onChange={(e) => setFormData({...formData, target: e.target.value})}
              className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="all">All Users (1,234)</option>
              <option value="active">Active Users (1,180)</option>
              <option value="new">New Users (78)</option>
              <option value="inactive">Inactive Users (54)</option>
            </select>
          </div>
          <div className="flex justify-end space-x-3 mt-6">
            <button
              onClick={() => setShowCreateForm(false)}
              className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleSendNotification}
              className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
            >
              Send Notification
            </button>
          </div>
        </div>
      )}

      {/* Notifications History */}
      <div className="bg-white rounded-lg shadow-sm border">
        <div className="p-6 border-b">
          <h3 className="text-lg font-semibold text-gray-800">Notification History</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Recipients</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sent At</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {notifications.map((notification) => (
                <tr key={notification.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <div>
                      <div className="text-sm font-medium text-gray-900">{notification.title}</div>
                      <div className="text-sm text-gray-500 truncate max-w-xs">{notification.message}</div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      notification.type === 'update' 
                        ? 'bg-blue-100 text-blue-800'
                        : notification.type === 'maintenance'
                        ? 'bg-yellow-100 text-yellow-800'
                        : notification.type === 'feature'
                        ? 'bg-green-100 text-green-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {notification.type}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {notification.recipients.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {notification.sent}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                      {notification.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button className="text-blue-600 hover:text-blue-900">
                      <Eye size={16} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}