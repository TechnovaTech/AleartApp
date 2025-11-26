'use client'

import { useState, useEffect } from 'react'
import { Search, Filter, Eye, Ban, CheckCircle, XCircle, Trash2, X } from 'lucide-react'

interface User {
  _id: string
  username: string
  email: string
  mobile: string
  isActive: boolean
  subscription: string
  role: string
  createdAt: string
  lastLogin: string
}

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [showModal, setShowModal] = useState(false)
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false)
  const [notification, setNotification] = useState<{type: 'success' | 'error', message: string} | null>(null)
  const [actionLoading, setActionLoading] = useState(false)
  const [selectedUsers, setSelectedUsers] = useState<string[]>([])
  const [isSelectionMode, setIsSelectionMode] = useState(false)

  useEffect(() => {
    fetchUsers()
  }, [])

  const fetchUsers = async () => {
    try {
      const response = await fetch('/api/users')
      const data = await response.json()
      if (data.success) {
        setUsers(data.users)
      }
    } catch (error) {
      console.error('Failed to fetch users:', error)
    } finally {
      setLoading(false)
    }
  }

  const showNotification = (type: 'success' | 'error', message: string) => {
    setNotification({ type, message })
    setTimeout(() => setNotification(null), 3000)
  }

  const toggleUserStatus = async (userId: string, currentStatus: boolean) => {
    // Update UI immediately
    if (selectedUser && selectedUser._id === userId) {
      setSelectedUser({...selectedUser, isActive: !currentStatus})
    }
    
    setActionLoading(true)
    try {
      const response = await fetch(`/api/users/${userId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isActive: !currentStatus })
      })
      if (response.ok) {
        await fetchUsers()
        showNotification('success', `User ${!currentStatus ? 'unblocked' : 'blocked'} successfully`)
      } else {
        // Revert UI change on error
        if (selectedUser && selectedUser._id === userId) {
          setSelectedUser({...selectedUser, isActive: currentStatus})
        }
        showNotification('error', 'Failed to update user status')
      }
    } catch (error) {
      // Revert UI change on error
      if (selectedUser && selectedUser._id === userId) {
        setSelectedUser({...selectedUser, isActive: currentStatus})
      }
      showNotification('error', 'Network error occurred')
    } finally {
      setActionLoading(false)
    }
  }

  const deleteUser = async (userId: string) => {
    setActionLoading(true)
    try {
      const response = await fetch(`/api/users/${userId}`, {
        method: 'DELETE'
      })
      if (response.ok) {
        await fetchUsers()
        setShowModal(false)
        setShowDeleteConfirm(false)
        showNotification('success', 'User deleted successfully')
      } else {
        showNotification('error', 'Failed to delete user')
      }
    } catch (error) {
      showNotification('error', 'Network error occurred')
    } finally {
      setActionLoading(false)
    }
  }

  const viewUserDetails = (user: User) => {
    setSelectedUser(user)
    setShowModal(true)
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString()
  }

  const getTimeAgo = (dateString: string) => {
    const now = new Date()
    const date = new Date(dateString)
    const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60))
    
    if (diffInHours < 1) return 'Just now'
    if (diffInHours < 24) return `${diffInHours} hours ago`
    const diffInDays = Math.floor(diffInHours / 24)
    return `${diffInDays} days ago`
  }

  const handleBulkAction = async (action: 'unblock' | 'delete') => {
    if (selectedUsers.length === 0) return
    
    setActionLoading(true)
    try {
      const promises = selectedUsers.map(userId => {
        if (action === 'unblock') {
          return fetch(`/api/users/${userId}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ isActive: true })
          })
        } else {
          return fetch(`/api/users/${userId}`, {
            method: 'DELETE'
          })
        }
      })
      
      await Promise.all(promises)
      await fetchUsers()
      setSelectedUsers([])
      setIsSelectionMode(false)
      showNotification('success', `${selectedUsers.length} user${selectedUsers.length > 1 ? 's' : ''} ${action === 'unblock' ? 'unblocked' : 'deleted'} successfully`)
    } catch (error) {
      showNotification('error', `Failed to ${action} selected users`)
    } finally {
      setActionLoading(false)
    }
  }

  const filteredUsers = users.filter(user => {
    const matchesSearch = user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.username.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === 'all' || 
                         (statusFilter === 'active' && user.isActive) ||
                         (statusFilter === 'blocked' && !user.isActive)
    return matchesSearch && matchesStatus
  })

  const activeUsers = users.filter(user => user.isActive).length
  const blockedUsers = users.filter(user => !user.isActive).length

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">User Management</h1>
        <p className="text-gray-600">Manage all registered users and their activities</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <h3 className="text-sm font-medium text-gray-500">Total Users</h3>
          <p className="text-2xl font-bold text-blue-600">{users.length}</p>
          <p className="text-xs text-gray-500">Registered users</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <h3 className="text-sm font-medium text-gray-500">Active Users</h3>
          <p className="text-2xl font-bold text-green-600">{activeUsers}</p>
          <p className="text-xs text-green-600">{users.length > 0 ? Math.round((activeUsers / users.length) * 100) : 0}% active rate</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <h3 className="text-sm font-medium text-gray-500">Premium Users</h3>
          <p className="text-2xl font-bold text-yellow-600">{users.filter(u => u.subscription === 'premium').length}</p>
          <p className="text-xs text-yellow-600">Premium subscribers</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <h3 className="text-sm font-medium text-gray-500">Blocked Users</h3>
          <p className="text-2xl font-bold text-red-600">{blockedUsers}</p>
          <p className="text-xs text-red-600">{users.length > 0 ? Math.round((blockedUsers / users.length) * 100) : 0}% of total</p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg shadow-sm border mb-6">
        <div className="flex flex-col md:flex-row gap-4 items-center justify-between">
          <div className="flex flex-1 gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="Search users by name or email..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="blocked">Blocked</option>
            </select>
          </div>
          <button
            onClick={() => {
              setIsSelectionMode(!isSelectionMode)
              setSelectedUsers([])
            }}
            className={`px-4 py-2 rounded-lg font-medium ${
              isSelectionMode 
                ? 'bg-red-100 text-red-700 hover:bg-red-200' 
                : 'bg-blue-100 text-blue-700 hover:bg-blue-200'
            }`}
          >
            {isSelectionMode ? 'Cancel Selection' : 'Select Users'}
          </button>
        </div>
        
        {isSelectionMode && selectedUsers.length > 0 && (
          <div className="mt-4 p-3 bg-blue-50 rounded-lg border border-blue-200">
            <div className="flex items-center justify-between">
              <span className="text-sm text-blue-700">
                {selectedUsers.length} user{selectedUsers.length > 1 ? 's' : ''} selected
              </span>
              <div className="flex gap-2">
                <button
                  onClick={() => handleBulkAction('unblock')}
                  className="px-3 py-1 bg-green-600 text-white rounded text-sm hover:bg-green-700"
                >
                  Unblock Selected
                </button>
                <button
                  onClick={() => handleBulkAction('delete')}
                  className="px-3 py-1 bg-red-600 text-white rounded text-sm hover:bg-red-700"
                >
                  Delete Selected
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Users Table */}
      <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                {isSelectionMode && (
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    <input
                      type="checkbox"
                      checked={selectedUsers.length === filteredUsers.length && filteredUsers.length > 0}
                      onChange={(e) => {
                        if (e.target.checked) {
                          setSelectedUsers(filteredUsers.map(u => u._id))
                        } else {
                          setSelectedUsers([])
                        }
                      }}
                      className="rounded border-gray-300"
                    />
                  </th>
                )}
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Username</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Subscription</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Join Date</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Active</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {loading ? (
                <tr>
                  <td colSpan={7} className="px-6 py-4 text-center text-gray-500">
                    Loading users...
                  </td>
                </tr>
              ) : filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-4 text-center text-gray-500">
                    No users found
                  </td>
                </tr>
              ) : (
                filteredUsers.map((user) => (
                  <tr key={user._id} className="hover:bg-gray-50">
                    {isSelectionMode && (
                      <td className="px-6 py-4 whitespace-nowrap">
                        <input
                          type="checkbox"
                          checked={selectedUsers.includes(user._id)}
                          onChange={(e) => {
                            if (e.target.checked) {
                              setSelectedUsers([...selectedUsers, user._id])
                            } else {
                              setSelectedUsers(selectedUsers.filter(id => id !== user._id))
                            }
                          }}
                          className="rounded border-gray-300"
                        />
                      </td>
                    )}
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="h-10 w-10 bg-blue-500 rounded-full flex items-center justify-center">
                          <span className="text-white font-medium text-sm">
                            {user.username.charAt(0)}
                          </span>
                        </div>
                        <div className="ml-4">
                          <div className="flex items-center gap-2">
                            <div className="text-sm font-medium text-gray-900">{user.username}</div>
                            {user.role === 'admin' && (
                              <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-purple-100 text-purple-800">
                                Admin
                              </span>
                            )}
                          </div>
                          <div className="text-sm text-gray-500">{user.email}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      @{user.username}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {user.subscription}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        user.isActive 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {user.isActive ? 'active' : 'blocked'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatDate(user.createdAt)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {getTimeAgo(user.lastLogin)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex space-x-2">
                        <button 
                          onClick={() => viewUserDetails(user)}
                          className="text-blue-600 hover:text-blue-900"
                          title="View Details"
                        >
                          <Eye size={16} />
                        </button>
                        <button 
                          onClick={() => toggleUserStatus(user._id, user.isActive)}
                          className={`${
                            user.isActive 
                              ? 'text-red-600 hover:text-red-900' 
                              : 'text-green-600 hover:text-green-900'
                          }`}
                          title={user.isActive ? 'Block User' : 'Unblock User'}
                        >
                          {user.isActive ? <Ban size={16} /> : <CheckCircle size={16} />}
                        </button>
                        <button 
                          onClick={() => {
                            setSelectedUser(user)
                            setShowDeleteConfirm(true)
                          }}
                          className="text-red-600 hover:text-red-900"
                          title="Delete User"
                        >
                          <Trash2 size={16} />
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

      {/* User Details Modal */}
      {showModal && selectedUser && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md mx-4">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold text-gray-800">User Details</h2>
              <button 
                onClick={() => setShowModal(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                <X size={20} />
              </button>
            </div>
            
            <div className="space-y-4">
              <div className="flex items-center space-x-4">
                <div className="h-16 w-16 bg-blue-500 rounded-full flex items-center justify-center">
                  <span className="text-white font-bold text-xl">
                    {selectedUser.username.charAt(0)}
                  </span>
                </div>
                <div>
                  <h3 className="text-lg font-semibold">{selectedUser.username}</h3>
                  <p className="text-gray-600">@{selectedUser.username}</p>
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-medium text-gray-500">Email</label>
                  <p className="text-sm text-gray-900">{selectedUser.email}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">Mobile</label>
                  <p className="text-sm text-gray-900">{selectedUser.mobile}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">Role</label>
                  <p className="text-sm text-gray-900 capitalize">{selectedUser.role}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">Subscription</label>
                  <p className="text-sm text-gray-900 capitalize">{selectedUser.subscription}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">Status</label>
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                    selectedUser.isActive 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-red-100 text-red-800'
                  }`}>
                    {selectedUser.isActive ? 'Active' : 'Blocked'}
                  </span>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">Joined</label>
                  <p className="text-sm text-gray-900">{formatDate(selectedUser.createdAt)}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">Last Login</label>
                  <p className="text-sm text-gray-900">{getTimeAgo(selectedUser.lastLogin)}</p>
                </div>
              </div>
              
              <div className="flex space-x-2 pt-4">
                <button 
                  onClick={() => toggleUserStatus(selectedUser._id, selectedUser.isActive)}
                  disabled={actionLoading}
                  className={`flex-1 px-4 py-2 rounded-lg font-medium disabled:opacity-50 ${
                    selectedUser.isActive 
                      ? 'bg-red-100 text-red-700 hover:bg-red-200' 
                      : 'bg-green-100 text-green-700 hover:bg-green-200'
                  }`}
                >
                  {actionLoading ? 'Processing...' : (selectedUser.isActive ? 'Block User' : 'Unblock User')}
                </button>
                <button 
                  onClick={() => setShowDeleteConfirm(true)}
                  disabled={actionLoading}
                  className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 font-medium disabled:opacity-50"
                >
                  Delete User
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm && selectedUser && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-sm mx-4">
            <div className="text-center">
              <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100 mb-4">
                <Trash2 className="h-6 w-6 text-red-600" />
              </div>
              <h3 className="text-lg font-medium text-gray-900 mb-2">Delete User</h3>
              <p className="text-sm text-gray-500 mb-6">
                Are you sure you want to delete <strong>{selectedUser.username}</strong>? This action cannot be undone.
              </p>
              <div className="flex space-x-3">
                <button
                  onClick={() => setShowDeleteConfirm(false)}
                  disabled={actionLoading}
                  className="flex-1 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 font-medium disabled:opacity-50"
                >
                  Cancel
                </button>
                <button
                  onClick={() => deleteUser(selectedUser._id)}
                  disabled={actionLoading}
                  className="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 font-medium disabled:opacity-50"
                >
                  {actionLoading ? 'Deleting...' : 'Delete'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Notification Toast */}
      {notification && (
        <div className={`fixed top-4 right-4 z-50 px-4 py-3 rounded-lg shadow-lg ${
          notification.type === 'success' 
            ? 'bg-green-500 text-white' 
            : 'bg-red-500 text-white'
        }`}>
          <div className="flex items-center space-x-2">
            {notification.type === 'success' ? (
              <CheckCircle size={20} />
            ) : (
              <XCircle size={20} />
            )}
            <span>{notification.message}</span>
          </div>
        </div>
      )}
    </div>
  )
}