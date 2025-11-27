'use client'

import { useState, useEffect } from 'react'
import { Search, Download, Eye, TrendingUp, TrendingDown } from 'lucide-react'

interface Payment {
  _id: string
  userId: string
  amount: number
  paymentApp: string
  payerName: string
  upiId: string
  transactionId: string
  notificationText: string
  date: string
  time: string
  timestamp: string
  user?: {
    username: string
    email: string
  }
}

export default function PaymentsPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [payments, setPayments] = useState<Payment[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedPayments, setSelectedPayments] = useState<string[]>([])
  const [viewPayment, setViewPayment] = useState<Payment | null>(null)
  
  useEffect(() => {
    fetchPayments()
    // Auto-refresh every 3 seconds for real-time updates
    const interval = setInterval(fetchPayments, 3000)
    return () => clearInterval(interval)
  }, [])
  
  const fetchPayments = async () => {
    try {
      const response = await fetch('/api/payments/all')
      const data = await response.json()
      console.log('API Response:', data)
      if (data.success) {
        console.log('Payments received:', data.payments)
        setPayments(data.payments || [])
      } else {
        console.error('API Error:', data.error)
      }
    } catch (error) {
      console.error('Error fetching payments:', error)
    } finally {
      setLoading(false)
    }
  }
  
  const handleSelectAll = () => {
    if (selectedPayments.length === filteredPayments.length) {
      setSelectedPayments([])
    } else {
      setSelectedPayments(filteredPayments.map(p => p._id))
    }
  }
  
  const handleSelectPayment = (paymentId: string) => {
    setSelectedPayments(prev => 
      prev.includes(paymentId) 
        ? prev.filter(id => id !== paymentId)
        : [...prev, paymentId]
    )
  }
  
  const handleDeleteSelected = async () => {
    if (selectedPayments.length === 0) return
    
    if (!confirm(`Are you sure you want to delete ${selectedPayments.length} payment(s)?`)) {
      return
    }
    
    try {
      const response = await fetch('/api/payments/delete', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ paymentIds: selectedPayments })
      })
      
      const data = await response.json()
      
      if (data.success) {
        setSelectedPayments([])
        fetchPayments()
        alert(`${data.deletedCount} payments deleted successfully`)
      } else {
        alert(`Error: ${data.error}`)
      }
    } catch (error) {
      console.error('Error deleting payments:', error)
      alert('Failed to delete payments. Please try again.')
    }
  }

  const filteredPayments = payments.filter(payment => {
    const matchesSearch = payment.payerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         payment.transactionId.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesSearch
  })

  const totalAmount = payments.reduce((sum, payment) => sum + Number(payment.amount), 0)

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">SMS Payment Detection</h1>
        <p className="text-gray-600">Real-time UPI payments captured from SMS notifications</p>
        <div className="mt-2 flex items-center justify-between">
          <div className="flex items-center">
            <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse mr-2"></div>
            <span className="text-sm text-green-600 font-medium">Live SMS monitoring active</span>
          </div>
          <div className="flex items-center">
            <div className="w-2 h-2 bg-blue-500 rounded-full animate-pulse mr-2"></div>
            <span className="text-sm text-blue-600 font-medium">Auto-refresh every 3 seconds</span>
          </div>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Total Revenue</h3>
              <p className="text-2xl font-bold text-green-600">₹{totalAmount.toLocaleString()}</p>
            </div>
            <TrendingUp className="h-8 w-8 text-green-500" />
          </div>
          <p className="text-xs text-green-600 mt-1">From SMS payments</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">SMS Payments</h3>
              <p className="text-2xl font-bold text-blue-600">{payments.length}</p>
            </div>
            <TrendingUp className="h-8 w-8 text-blue-500" />
          </div>
          <p className="text-xs text-blue-600 mt-1">Real-time detection</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div>
            <h3 className="text-sm font-medium text-gray-500">Unique Users</h3>
            <p className="text-2xl font-bold text-purple-600">
              {new Set(payments.map(p => p.userId)).size}
            </p>
          </div>
          <p className="text-xs text-purple-600 mt-1">Active users</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div>
            <h3 className="text-sm font-medium text-gray-500">Payment Apps</h3>
            <p className="text-2xl font-bold text-orange-600">
              {new Set(payments.map(p => p.paymentApp)).size}
            </p>
          </div>
          <p className="text-xs text-orange-600 mt-1">Different UPI apps</p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg shadow-sm border mb-6">
        <div className="flex flex-col md:flex-row gap-4 items-center justify-between">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search by payer name or transaction ID..."
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
              <option value="all">All Payments</option>
              <option value="today">Today</option>
              <option value="week">This Week</option>
            </select>
            {selectedPayments.length > 0 && (
              <button 
                onClick={handleDeleteSelected}
                className="flex items-center px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
              >
                Delete Selected ({selectedPayments.length})
              </button>
            )}
            <button className="flex items-center px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
              <Download size={16} className="mr-2" />
              Export
            </button>
          </div>
        </div>
      </div>

      {/* Payments Table */}
      <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <input
                    type="checkbox"
                    checked={selectedPayments.length === filteredPayments.length && filteredPayments.length > 0}
                    onChange={handleSelectAll}
                    className="rounded border-gray-300"
                  />
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Transaction ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Subscribed User</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Payer UPI ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Payment App</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date & Time</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {loading ? (
                <tr>
                  <td colSpan={7} className="px-6 py-4 text-center text-gray-500">
                    Loading payments...
                  </td>
                </tr>
              ) : filteredPayments.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-4 text-center text-gray-500">
                    No SMS payments found
                  </td>
                </tr>
              ) : (
                filteredPayments.map((payment) => (
                  <tr key={payment._id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <input
                        type="checkbox"
                        checked={selectedPayments.includes(payment._id)}
                        onChange={() => handleSelectPayment(payment._id)}
                        className="rounded border-gray-300"
                      />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {payment.transactionId}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-blue-600 font-medium">
                      {payment.user?.username || payment.userId || 'Unknown User'}
                      <div className="text-xs text-gray-500">{payment.user?.email || 'No email'}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-semibold text-green-600">
                      ₹{payment.amount.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {payment.upiId}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {payment.paymentApp}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {payment.date} {payment.time}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex gap-2">
                        <button 
                          onClick={() => setViewPayment(payment)}
                          className="text-blue-600 hover:text-blue-900"
                          title="View Details"
                        >
                          <Eye size={16} />
                        </button>
                        <button 
                          onClick={async () => {
                            if (confirm('Are you sure you want to delete this payment?')) {
                              try {
                                console.log('Deleting payment:', payment._id)
                                const response = await fetch('/api/payments/delete', {
                                  method: 'POST',
                                  headers: { 'Content-Type': 'application/json' },
                                  body: JSON.stringify({ paymentIds: [payment._id] })
                                })
                                const data = await response.json()
                                console.log('Delete response:', data)
                                if (data.success) {
                                  fetchPayments()
                                  alert('Payment deleted successfully')
                                } else {
                                  console.error('Delete error:', data.error)
                                  alert(`Error: ${data.error}`)
                                }
                              } catch (error) {
                                console.error('Delete exception:', error)
                                alert('Failed to delete payment')
                              }
                            }
                          }}
                          className="text-red-600 hover:text-red-900"
                          title="Delete Payment"
                        >
                          <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                            <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
                            <path fillRule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
                          </svg>
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
      
      {/* View Payment Modal */}
      {viewPayment && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">Payment Details</h3>
              <button 
                onClick={() => setViewPayment(null)}
                className="text-gray-500 hover:text-gray-700"
              >
                ×
              </button>
            </div>
            <div className="space-y-3">
              <div>
                <label className="text-sm font-medium text-gray-500">Transaction ID</label>
                <p className="text-sm text-gray-900">{viewPayment.transactionId}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Payer Name</label>
                <p className="text-sm text-gray-900">{viewPayment.payerName}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Amount</label>
                <p className="text-lg font-semibold text-green-600">₹{viewPayment.amount.toLocaleString()}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">UPI ID</label>
                <p className="text-sm text-gray-900">{viewPayment.upiId}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Payment App</label>
                <p className="text-sm text-gray-900">{viewPayment.paymentApp}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Date & Time</label>
                <p className="text-sm text-gray-900">{viewPayment.date} {viewPayment.time}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">User ID</label>
                <p className="text-sm text-gray-900">{viewPayment.userId}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">SMS Text</label>
                <p className="text-sm text-gray-900 bg-gray-50 p-2 rounded">{viewPayment.notificationText}</p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}