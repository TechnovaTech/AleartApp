'use client';

import { useState, useEffect } from 'react';

interface User {
  _id: string;
  username: string;
  email: string;
  isActive: boolean;
}

export default function PushNotificationsPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [sendToAll, setSendToAll] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const response = await fetch('/api/users');
      const data = await response.json();
      if (data.success) {
        setUsers(data.users || []);
      }
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const handleSendNotification = async () => {
    if (!title.trim() || !message.trim()) {
      alert('Please enter both title and message');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('/api/admin/send-notification', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title,
          body: message,
          sendToAll: true
        })
      });
      
      const data = await response.json();
      if (data.success) {
        alert(`Notification sent successfully`);
        setTitle('');
        setMessage('');
      }
    } catch (error) {
      console.error('Error sending notification:', error);
      alert('Failed to send notification');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-800 mb-2">Push Notifications</h1>
          <p className="text-gray-600">Send notifications to app users</p>
        </div>

        <div className="bg-white p-6 rounded-lg shadow max-w-2xl">
          <h2 className="text-xl font-semibold mb-4">Send Notification</h2>
          
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Title
              </label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full border border-gray-300 rounded-md px-3 py-2"
                placeholder="Notification title"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Message
              </label>
              <textarea
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                rows={4}
                className="w-full border border-gray-300 rounded-md px-3 py-2"
                placeholder="Notification message"
              />
            </div>

            <button
              onClick={handleSendNotification}
              disabled={loading}
              className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50"
            >
              {loading ? 'Sending...' : 'Send to All Users'}
            </button>
          </div>
        </div>

        <div className="mt-6 bg-white p-6 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-4">Quick Templates</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <button
              onClick={() => {
                setTitle('Welcome to AlertPe!');
                setMessage('Thank you for using AlertPe. Start monitoring your UPI payments now!');
              }}
              className="p-4 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              <div className="font-medium">Welcome Message</div>
            </button>
            
            <button
              onClick={() => {
                setTitle('Subscription Reminder');
                setMessage('Your free trial is ending soon. Upgrade to premium to continue.');
              }}
              className="p-4 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              <div className="font-medium">Trial Reminder</div>
            </button>
            
            <button
              onClick={() => {
                setTitle('New Feature Available');
                setMessage('Check out the new features in AlertPe! Update your app now.');
              }}
              className="p-4 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              <div className="font-medium">Feature Update</div>
            </button>
          </div>
        </div>
    </div>
  );
}