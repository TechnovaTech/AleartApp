'use client'

import { useState } from 'react'
import { Search, QrCode, Eye, Trash2, Download } from 'lucide-react'

const qrCodes = [
  { id: 1, user: 'John Doe', upiId: 'john@paytm', qrData: 'upi://pay?pa=john@paytm&pn=AlertPe%20Soundbox&cu=INR', createdAt: '2024-01-20', lastUsed: '2 hours ago', usageCount: 45, status: 'active' },
  { id: 2, user: 'Jane Smith', upiId: 'jane@gpay', qrData: 'upi://pay?pa=jane@gpay&pn=AlertPe%20Soundbox&cu=INR', createdAt: '2024-01-18', lastUsed: '1 day ago', usageCount: 32, status: 'active' },
  { id: 3, user: 'Mike Johnson', upiId: 'mike@phonepe', qrData: 'upi://pay?pa=mike@phonepe&pn=AlertPe%20Soundbox&cu=INR', createdAt: '2024-01-15', lastUsed: '5 days ago', usageCount: 12, status: 'inactive' },
  { id: 4, user: 'Sarah Wilson', upiId: 'sarah@paytm', qrData: 'upi://pay?pa=sarah@paytm&pn=AlertPe%20Soundbox&cu=INR', createdAt: '2024-01-22', lastUsed: '30 minutes ago', usageCount: 67, status: 'active' },
]

export default function QRPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')

  const filteredQRs = qrCodes.filter(qr => {
    const matchesSearch = qr.user.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         qr.upiId.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === 'all' || qr.status === statusFilter
    return matchesSearch && matchesStatus
  })

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">QR Code Management</h1>
        <p className="text-gray-600">View and manage all generated QR codes and UPI IDs</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Total QR Codes</h3>
              <p className="text-2xl font-bold text-blue-600">{qrCodes.length}</p>
            </div>
            <QrCode className="h-8 w-8 text-blue-500" />
          </div>
          <p className="text-xs text-blue-600 mt-1">All generated codes</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div>
            <h3 className="text-sm font-medium text-gray-500">Active QR Codes</h3>
            <p className="text-2xl font-bold text-green-600">
              {qrCodes.filter(qr => qr.status === 'active').length}
            </p>
          </div>
          <p className="text-xs text-green-600 mt-1">Currently in use</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div>
            <h3 className="text-sm font-medium text-gray-500">Total Scans</h3>
            <p className="text-2xl font-bold text-purple-600">
              {qrCodes.reduce((sum, qr) => sum + qr.usageCount, 0)}
            </p>
          </div>
          <p className="text-xs text-purple-600 mt-1">All time scans</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div>
            <h3 className="text-sm font-medium text-gray-500">Avg. Usage</h3>
            <p className="text-2xl font-bold text-yellow-600">
              {Math.round(qrCodes.reduce((sum, qr) => sum + qr.usageCount, 0) / qrCodes.length)}
            </p>
          </div>
          <p className="text-xs text-yellow-600 mt-1">Per QR code</p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg shadow-sm border mb-6">
        <div className="flex flex-col md:flex-row gap-4 items-center justify-between">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search by user name or UPI ID..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div className="flex gap-2">
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
            <button className="flex items-center px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
              <Download size={16} className="mr-2" />
              Export
            </button>
          </div>
        </div>
      </div>

      {/* QR Codes Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredQRs.map((qr) => (
          <div key={qr.id} className="bg-white rounded-lg shadow-sm border p-6">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center">
                <div className="h-10 w-10 bg-blue-500 rounded-full flex items-center justify-center">
                  <span className="text-white font-medium text-sm">
                    {qr.user.charAt(0)}
                  </span>
                </div>
                <div className="ml-3">
                  <h3 className="text-sm font-medium text-gray-900">{qr.user}</h3>
                  <p className="text-xs text-gray-500">{qr.upiId}</p>
                </div>
              </div>
              <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                qr.status === 'active' 
                  ? 'bg-green-100 text-green-800' 
                  : 'bg-gray-100 text-gray-800'
              }`}>
                {qr.status}
              </span>
            </div>

            {/* QR Code Visual */}
            <div className="bg-gray-50 p-4 rounded-lg mb-4 flex items-center justify-center">
              <div className="w-24 h-24 bg-white border-2 border-gray-300 rounded-lg flex items-center justify-center">
                <QrCode size={48} className="text-gray-400" />
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 gap-4 mb-4">
              <div className="text-center">
                <p className="text-lg font-bold text-blue-600">{qr.usageCount}</p>
                <p className="text-xs text-gray-500">Total Scans</p>
              </div>
              <div className="text-center">
                <p className="text-sm font-medium text-gray-900">{qr.lastUsed}</p>
                <p className="text-xs text-gray-500">Last Used</p>
              </div>
            </div>

            {/* Actions */}
            <div className="flex justify-between items-center pt-4 border-t">
              <p className="text-xs text-gray-500">Created: {qr.createdAt}</p>
              <div className="flex space-x-2">
                <button className="text-blue-600 hover:text-blue-900">
                  <Eye size={16} />
                </button>
                <button className="text-green-600 hover:text-green-900">
                  <Download size={16} />
                </button>
                <button className="text-red-600 hover:text-red-900">
                  <Trash2 size={16} />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}