'use client'

import { useState } from 'react'
import { Download, Calendar, FileText, TrendingUp } from 'lucide-react'

const reports = [
  { id: 1, name: 'User Registration Report', description: 'Monthly user registration statistics', generated: '2024-01-24', size: '2.3 MB', type: 'PDF' },
  { id: 2, name: 'Payment Analytics', description: 'Revenue and transaction analysis', generated: '2024-01-23', size: '1.8 MB', type: 'Excel' },
  { id: 3, name: 'QR Code Usage Report', description: 'QR code generation and usage metrics', generated: '2024-01-22', size: '1.2 MB', type: 'PDF' },
  { id: 4, name: 'Feature Usage Analytics', description: 'App feature usage statistics', generated: '2024-01-21', size: '950 KB', type: 'Excel' },
]

export default function ReportsPage() {
  const [dateRange, setDateRange] = useState({ start: '', end: '' })
  const [reportType, setReportType] = useState('all')

  const generateReport = (type: string) => {
    console.log(`Generating ${type} report for ${dateRange.start} to ${dateRange.end}`)
    alert(`${type} report generation started. You'll receive an email when ready.`)
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">Reports & Insights</h1>
        <p className="text-gray-600">Generate and download comprehensive reports</p>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Reports Generated</h3>
              <p className="text-2xl font-bold text-blue-600">{reports.length}</p>
            </div>
            <FileText className="h-8 w-8 text-blue-500" />
          </div>
          <p className="text-xs text-blue-600 mt-1">This month</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Total Downloads</h3>
              <p className="text-2xl font-bold text-green-600">156</p>
            </div>
            <Download className="h-8 w-8 text-green-500" />
          </div>
          <p className="text-xs text-green-600 mt-1">All time</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Data Size</h3>
              <p className="text-2xl font-bold text-purple-600">6.2 MB</p>
            </div>
            <TrendingUp className="h-8 w-8 text-purple-500" />
          </div>
          <p className="text-xs text-purple-600 mt-1">Total generated</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Scheduled</h3>
              <p className="text-2xl font-bold text-yellow-600">3</p>
            </div>
            <Calendar className="h-8 w-8 text-yellow-500" />
          </div>
          <p className="text-xs text-yellow-600 mt-1">Auto reports</p>
        </div>
      </div>

      {/* Generate New Report */}
      <div className="bg-white p-6 rounded-lg shadow-sm border mb-8">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Generate New Report</h3>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Report Type</label>
            <select
              value={reportType}
              onChange={(e) => setReportType(e.target.value)}
              className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="users">User Analytics</option>
              <option value="payments">Payment Report</option>
              <option value="qr">QR Code Usage</option>
              <option value="features">Feature Analytics</option>
              <option value="comprehensive">Comprehensive Report</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
            <input
              type="date"
              value={dateRange.start}
              onChange={(e) => setDateRange({...dateRange, start: e.target.value})}
              className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">End Date</label>
            <input
              type="date"
              value={dateRange.end}
              onChange={(e) => setDateRange({...dateRange, end: e.target.value})}
              className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div className="flex items-end">
            <button
              onClick={() => generateReport(reportType)}
              className="w-full flex items-center justify-center px-4 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
            >
              <FileText size={16} className="mr-2" />
              Generate
            </button>
          </div>
        </div>
      </div>

      {/* Quick Report Buttons */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <button
          onClick={() => generateReport('daily')}
          className="p-4 bg-blue-50 border border-blue-200 rounded-lg hover:bg-blue-100 text-left"
        >
          <h4 className="font-semibold text-blue-800">Daily Summary</h4>
          <p className="text-sm text-blue-600">Today's activity report</p>
        </button>
        <button
          onClick={() => generateReport('weekly')}
          className="p-4 bg-green-50 border border-green-200 rounded-lg hover:bg-green-100 text-left"
        >
          <h4 className="font-semibold text-green-800">Weekly Report</h4>
          <p className="text-sm text-green-600">Last 7 days summary</p>
        </button>
        <button
          onClick={() => generateReport('monthly')}
          className="p-4 bg-purple-50 border border-purple-200 rounded-lg hover:bg-purple-100 text-left"
        >
          <h4 className="font-semibold text-purple-800">Monthly Report</h4>
          <p className="text-sm text-purple-600">Current month analytics</p>
        </button>
        <button
          onClick={() => generateReport('custom')}
          className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg hover:bg-yellow-100 text-left"
        >
          <h4 className="font-semibold text-yellow-800">Custom Range</h4>
          <p className="text-sm text-yellow-600">Select date range</p>
        </button>
      </div>

      {/* Recent Reports */}
      <div className="bg-white rounded-lg shadow-sm border">
        <div className="p-6 border-b">
          <h3 className="text-lg font-semibold text-gray-800">Recent Reports</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Report Name</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Generated</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Size</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {reports.map((report) => (
                <tr key={report.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{report.name}</div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-500">{report.description}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {report.generated}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {report.size}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      report.type === 'PDF' 
                        ? 'bg-red-100 text-red-800' 
                        : 'bg-green-100 text-green-800'
                    }`}>
                      {report.type}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button className="text-blue-600 hover:text-blue-900 mr-3">
                      <Download size={16} />
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