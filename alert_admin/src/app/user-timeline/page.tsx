'use client'

import { useState, useEffect } from 'react'
import { Activity, User, Calendar } from 'lucide-react'

interface TimelineEvent {
  _id: string
  userId: string
  eventType: string
  title: string
  description?: string
  metadata?: any
  timestamp: string
  user?: {
    username: string
    email: string
  }
}

export default function UserTimelinePage() {
  const [events, setEvents] = useState<TimelineEvent[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedUserId, setSelectedUserId] = useState<string>('')

  useEffect(() => {
    fetchTimelineEvents()
  }, [])

  const fetchTimelineEvents = async () => {
    try {
      const response = await fetch('/api/timeline/all')
      const data = await response.json()
      if (data.success) {
        setEvents(data.events)
      }
    } catch (error) {
      console.error('Failed to fetch timeline events:', error)
    } finally {
      setLoading(false)
    }
  }

  const getEventIcon = (eventType: string) => {
    switch (eventType) {
      case 'registration': return '👤'
      case 'trial_started': return '🎯'
      case 'subscription_created': return '💳'
      case 'payment_received': return '💰'
      case 'mandate_approved': return '✅'
      case 'subscription_renewed': return '🔄'
      case 'subscription_expired': return '⚠️'
      default: return 'ℹ️'
    }
  }

  const getEventColor = (eventType: string) => {
    switch (eventType) {
      case 'registration': return 'bg-blue-100 border-blue-200'
      case 'trial_started': return 'bg-purple-100 border-purple-200'
      case 'subscription_created': return 'bg-green-100 border-green-200'
      case 'payment_received': return 'bg-orange-100 border-orange-200'
      case 'mandate_approved': return 'bg-teal-100 border-teal-200'
      case 'subscription_renewed': return 'bg-indigo-100 border-indigo-200'
      case 'subscription_expired': return 'bg-red-100 border-red-200'
      default: return 'bg-gray-100 border-gray-200'
    }
  }

  const filteredEvents = selectedUserId 
    ? events.filter(event => event.userId === selectedUserId)
    : events

  const uniqueUsers = Array.from(new Set(events.map(event => event.userId)))

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">User Timeline</h1>
        <p className="text-gray-600">Track user activities and events</p>
      </div>

      {/* Filter */}
      <div className="mb-6">
        <select
          value={selectedUserId}
          onChange={(e) => setSelectedUserId(e.target.value)}
          className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="">All Users</option>
          {uniqueUsers.map(userId => (
            <option key={userId} value={userId}>
              {events.find(e => e.userId === userId)?.user?.username || userId}
            </option>
          ))}
        </select>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Total Events</h3>
              <p className="text-2xl font-bold text-blue-600">{filteredEvents.length}</p>
            </div>
            <Activity className="h-8 w-8 text-blue-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Active Users</h3>
              <p className="text-2xl font-bold text-green-600">{uniqueUsers.length}</p>
            </div>
            <User className="h-8 w-8 text-green-500" />
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Today's Events</h3>
              <p className="text-2xl font-bold text-purple-600">
                {filteredEvents.filter(event => 
                  new Date(event.timestamp).toDateString() === new Date().toDateString()
                ).length}
              </p>
            </div>
            <Calendar className="h-8 w-8 text-purple-500" />
          </div>
        </div>
      </div>

      {/* Timeline */}
      <div className="bg-white rounded-lg shadow-sm border p-6">
        {loading ? (
          <div className="text-center py-8">Loading timeline events...</div>
        ) : filteredEvents.length === 0 ? (
          <div className="text-center py-8 text-gray-500">No timeline events found</div>
        ) : (
          <div className="space-y-4">
            {filteredEvents.map((event, index) => (
              <div key={event._id} className="flex items-start space-x-4">
                {/* Timeline line */}
                <div className="flex flex-col items-center">
                  <div className={`w-10 h-10 rounded-full border-2 flex items-center justify-center text-lg ${getEventColor(event.eventType)}`}>
                    {getEventIcon(event.eventType)}
                  </div>
                  {index < filteredEvents.length - 1 && (
                    <div className="w-0.5 h-8 bg-gray-200 mt-2"></div>
                  )}
                </div>
                
                {/* Event content */}
                <div className="flex-1 min-w-0">
                  <div className="bg-gray-50 rounded-lg p-4">
                    <div className="flex items-center justify-between mb-2">
                      <h3 className="text-sm font-semibold text-gray-900">{event.title}</h3>
                      <span className="text-xs text-gray-500">
                        {new Date(event.timestamp).toLocaleString()}
                      </span>
                    </div>
                    
                    {event.description && (
                      <p className="text-sm text-gray-600 mb-2">{event.description}</p>
                    )}
                    
                    <div className="flex items-center text-xs text-gray-500">
                      <span className="font-medium">
                        {event.user?.username || event.userId}
                      </span>
                      {event.user?.email && (
                        <span className="ml-2">({event.user.email})</span>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}