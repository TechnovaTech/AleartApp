'use client';

import { useState } from 'react';

export default function PlansPage() {
  const [activeTab, setActiveTab] = useState('plans');

  const plans = [
    { id: 1, name: 'Basic', price: 99, duration: 'Monthly', users: 156, status: 'Active' },
    { id: 2, name: 'Pro', price: 299, duration: 'Monthly', users: 89, status: 'Active' },
    { id: 3, name: 'Enterprise', price: 999, duration: 'Monthly', users: 23, status: 'Active' },
  ];

  const subscriptions = [
    { id: 1, user: 'John Doe', plan: 'Pro', startDate: '2024-01-15', endDate: '2024-02-15', status: 'Active', amount: 299 },
    { id: 2, user: 'Jane Smith', plan: 'Basic', startDate: '2024-01-10', endDate: '2024-02-10', status: 'Expiring', amount: 99 },
    { id: 3, user: 'Mike Johnson', plan: 'Enterprise', startDate: '2024-01-01', endDate: '2024-02-01', status: 'Active', amount: 999 },
  ];

  return (
    <div className="p-6">
      <div className="flex justify-end items-center mb-6">
        <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
          Create New Plan
        </button>
      </div>

      {/* Tabs */}
      <div className="flex space-x-1 mb-6 bg-gray-100 p-1 rounded-lg w-fit">
        <button
          onClick={() => setActiveTab('plans')}
          className={`px-4 py-2 rounded-md transition-colors ${
            activeTab === 'plans' ? 'bg-white text-blue-600 shadow-sm' : 'text-gray-600 hover:text-gray-800'
          }`}
        >
          Plans Management
        </button>
        <button
          onClick={() => setActiveTab('subscriptions')}
          className={`px-4 py-2 rounded-md transition-colors ${
            activeTab === 'subscriptions' ? 'bg-white text-blue-600 shadow-sm' : 'text-gray-600 hover:text-gray-800'
          }`}
        >
          Active Subscriptions
        </button>
        <button
          onClick={() => setActiveTab('analytics')}
          className={`px-4 py-2 rounded-md transition-colors ${
            activeTab === 'analytics' ? 'bg-white text-blue-600 shadow-sm' : 'text-gray-600 hover:text-gray-800'
          }`}
        >
          Revenue Analytics
        </button>
      </div>

      {/* Plans Management */}
      {activeTab === 'plans' && (
        <div className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {plans.map((plan) => (
              <div key={plan.id} className="bg-white rounded-lg shadow-md p-6 border">
                <div className="flex justify-between items-start mb-4">
                  <h3 className="text-xl font-semibold text-gray-800">{plan.name}</h3>
                  <span className={`px-2 py-1 rounded-full text-xs ${
                    plan.status === 'Active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {plan.status}
                  </span>
                </div>
                <div className="mb-4">
                  <span className="text-3xl font-bold text-blue-600">₹{plan.price}</span>
                  <span className="text-gray-600">/{plan.duration}</span>
                </div>
                <div className="mb-4">
                  <p className="text-sm text-gray-600">{plan.users} active subscribers</p>
                </div>
                <div className="flex space-x-2">
                  <button className="flex-1 bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700">
                    Edit Plan
                  </button>
                  <button className="px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50">
                    ⚙️
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Active Subscriptions */}
      {activeTab === 'subscriptions' && (
        <div className="bg-white rounded-lg shadow-md">
          <div className="p-6 border-b">
            <div className="flex justify-between items-center">
              <h2 className="text-lg font-semibold">Active Subscriptions</h2>
              <div className="flex space-x-2">
                <input
                  type="text"
                  placeholder="Search subscriptions..."
                  className="px-3 py-2 border border-gray-300 rounded-md"
                />
                <select className="px-3 py-2 border border-gray-300 rounded-md">
                  <option>All Status</option>
                  <option>Active</option>
                  <option>Expiring</option>
                  <option>Expired</option>
                </select>
              </div>
            </div>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Plan</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Start Date</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">End Date</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Amount</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {subscriptions.map((sub) => (
                  <tr key={sub.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">{sub.user}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full">{sub.plan}</span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{sub.startDate}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{sub.endDate}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">₹{sub.amount}</td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 text-xs rounded-full ${
                        sub.status === 'Active' ? 'bg-green-100 text-green-800' : 
                        sub.status === 'Expiring' ? 'bg-yellow-100 text-yellow-800' : 'bg-red-100 text-red-800'
                      }`}>
                        {sub.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <button className="text-blue-600 hover:text-blue-900 mr-3">View</button>
                      <button className="text-green-600 hover:text-green-900 mr-3">Extend</button>
                      <button className="text-red-600 hover:text-red-900">Cancel</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Revenue Analytics */}
      {activeTab === 'analytics' && (
        <div className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h3 className="text-sm font-medium text-gray-500">Monthly Revenue</h3>
              <p className="text-2xl font-bold text-green-600">₹45,230</p>
              <p className="text-sm text-green-600">+12.5% from last month</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h3 className="text-sm font-medium text-gray-500">Active Subscriptions</h3>
              <p className="text-2xl font-bold text-blue-600">268</p>
              <p className="text-sm text-blue-600">+8 new this month</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h3 className="text-sm font-medium text-gray-500">Churn Rate</h3>
              <p className="text-2xl font-bold text-red-600">3.2%</p>
              <p className="text-sm text-red-600">-0.5% from last month</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h3 className="text-sm font-medium text-gray-500">Avg. Revenue Per User</h3>
              <p className="text-2xl font-bold text-purple-600">₹169</p>
              <p className="text-sm text-purple-600">+₹12 from last month</p>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h3 className="text-lg font-semibold mb-4">Plan Distribution</h3>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span>Basic Plan</span>
                  <div className="flex items-center space-x-2">
                    <div className="w-24 bg-gray-200 rounded-full h-2">
                      <div className="bg-blue-600 h-2 rounded-full" style={{width: '58%'}}></div>
                    </div>
                    <span className="text-sm">58%</span>
                  </div>
                </div>
                <div className="flex justify-between items-center">
                  <span>Pro Plan</span>
                  <div className="flex items-center space-x-2">
                    <div className="w-24 bg-gray-200 rounded-full h-2">
                      <div className="bg-green-600 h-2 rounded-full" style={{width: '33%'}}></div>
                    </div>
                    <span className="text-sm">33%</span>
                  </div>
                </div>
                <div className="flex justify-between items-center">
                  <span>Enterprise</span>
                  <div className="flex items-center space-x-2">
                    <div className="w-24 bg-gray-200 rounded-full h-2">
                      <div className="bg-purple-600 h-2 rounded-full" style={{width: '9%'}}></div>
                    </div>
                    <span className="text-sm">9%</span>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-md">
              <h3 className="text-lg font-semibold mb-4">Recent Transactions</h3>
              <div className="space-y-3">
                <div className="flex justify-between items-center py-2 border-b">
                  <div>
                    <p className="font-medium">John Doe - Pro Plan</p>
                    <p className="text-sm text-gray-500">2 hours ago</p>
                  </div>
                  <span className="text-green-600 font-medium">+₹299</span>
                </div>
                <div className="flex justify-between items-center py-2 border-b">
                  <div>
                    <p className="font-medium">Sarah Wilson - Basic Plan</p>
                    <p className="text-sm text-gray-500">5 hours ago</p>
                  </div>
                  <span className="text-green-600 font-medium">+₹99</span>
                </div>
                <div className="flex justify-between items-center py-2">
                  <div>
                    <p className="font-medium">Mike Chen - Enterprise</p>
                    <p className="text-sm text-gray-500">1 day ago</p>
                  </div>
                  <span className="text-green-600 font-medium">+₹999</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}