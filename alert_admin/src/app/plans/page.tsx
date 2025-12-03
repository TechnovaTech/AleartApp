'use client';

import { useState, useEffect } from 'react';

interface Plan {
  _id?: string;
  name: string;
  price: number;
  duration: string;
  features: string[];
  isActive: boolean;
}

export default function PlansPage() {
  const [plans, setPlans] = useState<Plan[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editingPlan, setEditingPlan] = useState<Plan | null>(null);
  const [formData, setFormData] = useState<Plan>({
    name: '',
    price: 0,
    duration: 'monthly',
    features: [],
    isActive: true
  });

  useEffect(() => {
    fetchPlans();
  }, []);

  const fetchPlans = async () => {
    try {
      const response = await fetch('/api/plans');
      const data = await response.json();
      if (data.success) {
        setPlans(data.plans || []);
      }
    } catch (error) {
      console.error('Error fetching plans:', error);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const url = editingPlan ? `/api/plans/${editingPlan._id}` : '/api/plans';
      const method = editingPlan ? 'PUT' : 'POST';
      
      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });
      
      const data = await response.json();
      if (data.success) {
        fetchPlans();
        setShowForm(false);
        setEditingPlan(null);
        setFormData({ name: '', price: 0, duration: 'monthly', features: [], isActive: true });
      }
    } catch (error) {
      console.error('Error saving plan:', error);
    }
  };

  const handleEdit = (plan: Plan) => {
    setEditingPlan(plan);
    setFormData(plan);
    setShowForm(true);
  };

  const handleDelete = async (planId: string) => {
    if (confirm('Are you sure you want to delete this plan?')) {
      try {
        const response = await fetch(`/api/plans/${planId}`, { method: 'DELETE' });
        const data = await response.json();
        if (data.success) {
          fetchPlans();
        }
      } catch (error) {
        console.error('Error deleting plan:', error);
      }
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Subscription Plans</h1>
        <button
          onClick={() => setShowForm(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          Add New Plan
        </button>
      </div>

        {showForm && (
          <div className="bg-white p-6 rounded-lg shadow mb-6">
            <h2 className="text-xl font-semibold mb-4">
              {editingPlan ? 'Edit Plan' : 'Create New Plan'}
            </h2>
            <form onSubmit={handleSubmit}>
              <div className="grid grid-cols-2 gap-4 mb-4">
                <input
                  type="text"
                  placeholder="Plan Name"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  className="border p-2 rounded"
                  required
                />
                <input
                  type="number"
                  placeholder="Price"
                  value={formData.price}
                  onChange={(e) => setFormData({...formData, price: Number(e.target.value)})}
                  className="border p-2 rounded"
                  required
                />
              </div>
              <select
                value={formData.duration}
                onChange={(e) => setFormData({...formData, duration: e.target.value})}
                className="border p-2 rounded mb-4 w-full"
              >
                <option value="monthly">Monthly</option>
                <option value="yearly">Yearly</option>
              </select>
              <textarea
                placeholder="Features (one per line)"
                value={formData.features.join('\n')}
                onChange={(e) => setFormData({...formData, features: e.target.value.split('\n').filter(f => f.trim())})}
                className="border p-2 rounded mb-4 w-full h-32"
              />
              <div className="flex gap-2">
                <button type="submit" className="bg-green-600 text-white px-4 py-2 rounded">
                  {editingPlan ? 'Update' : 'Create'} Plan
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setShowForm(false);
                    setEditingPlan(null);
                    setFormData({ name: '', price: 0, duration: 'monthly', features: [], isActive: true });
                  }}
                  className="bg-gray-500 text-white px-4 py-2 rounded"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        )}

        <div className="grid gap-4">
          {plans.map((plan) => (
            <div key={plan._id} className="bg-white p-6 rounded-lg shadow">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="text-xl font-semibold">{plan.name}</h3>
                  <p className="text-2xl font-bold text-green-600">₹{plan.price}/{plan.duration}</p>
                  <ul className="mt-2">
                    {plan.features.map((feature, index) => (
                      <li key={index} className="text-gray-600">• {feature}</li>
                    ))}
                  </ul>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => handleEdit(plan)}
                    className="bg-blue-500 text-white px-3 py-1 rounded text-sm"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => handleDelete(plan._id!)}
                    className="bg-red-500 text-white px-3 py-1 rounded text-sm"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
    </div>
  );
}