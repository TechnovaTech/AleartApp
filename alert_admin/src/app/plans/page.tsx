'use client'

import { useState, useEffect } from 'react'
import { Plus, Edit, Trash2, ToggleLeft, ToggleRight } from 'lucide-react'

interface Plan {
  _id: string
  name: string
  monthlyPrice: number
  yearlyPrice: number
  features: string[]
  isActive: boolean
  createdAt: string
}

export default function PlansPage() {
  const [plans, setPlans] = useState<Plan[]>([])
  const [showForm, setShowForm] = useState(false)
  const [editingPlan, setEditingPlan] = useState<Plan | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchPlans()
  }, [])

  const fetchPlans = async () => {
    try {
      const response = await fetch('/api/plans')
      const data = await response.json()
      if (data.success) {
        setPlans(data.plans)
      }
    } catch (error) {
      console.error('Failed to fetch plans:', error)
    } finally {
      setLoading(false)
    }
  }

  const togglePlanStatus = async (planId: string, currentStatus: boolean) => {
    try {
      const response = await fetch(`/api/plans/${planId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isActive: !currentStatus })
      })
      
      if (response.ok) {
        fetchPlans()
      }
    } catch (error) {
      console.error('Failed to toggle plan status:', error)
    }
  }

  const deletePlan = async (planId: string) => {
    if (confirm('Are you sure you want to delete this plan?')) {
      try {
        const response = await fetch(`/api/plans/${planId}`, {
          method: 'DELETE'
        })
        
        if (response.ok) {
          fetchPlans()
        }
      } catch (error) {
        console.error('Failed to delete plan:', error)
      }
    }
  }

  const openEditForm = (plan: Plan) => {
    setEditingPlan(plan)
    setShowForm(true)
  }

  const closeForm = () => {
    setShowForm(false)
    setEditingPlan(null)
  }

  if (loading) {
    return <div className="p-6">Loading...</div>
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Plans Management</h1>
        <button
          onClick={() => setShowForm(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700"
        >
          <Plus size={20} />
          Add Plan
        </button>
      </div>

      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4 max-w-5xl">
        {plans.map((plan) => (
          <div key={plan._id} className="bg-white p-4 rounded-xl border border-gray-200 shadow-md relative w-full max-w-sm">
            <div className="absolute top-4 right-4 flex gap-2">
              <button
                onClick={() => togglePlanStatus(plan._id, plan.isActive)}
                className={`p-2 rounded-lg transition-colors ${
                  plan.isActive 
                    ? 'bg-green-100 text-green-700 hover:bg-green-200' 
                    : 'bg-gray-100 text-gray-500 hover:bg-gray-200'
                }`}
                title={plan.isActive ? 'Disable Plan' : 'Enable Plan'}
              >
                {plan.isActive ? (
                  <ToggleRight size={20} />
                ) : (
                  <ToggleLeft size={20} />
                )}
              </button>
              
              <button
                onClick={() => openEditForm(plan)}
                className="p-2 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors"
                title="Edit Plan"
              >
                <Edit size={16} />
              </button>
              
              <button
                onClick={() => deletePlan(plan._id)}
                className="p-2 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 transition-colors"
                title="Delete Plan"
              >
                <Trash2 size={16} />
              </button>
            </div>

            <div className="pr-24">
              <div className="flex items-center gap-3 mb-4">
                <h3 className="text-xl font-bold text-gray-800">{plan.name}</h3>
                <span className={`px-2 py-1 rounded-full text-xs font-semibold ${
                  plan.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                }`}>
                  {plan.isActive ? 'Active' : 'Inactive'}
                </span>
              </div>
              
              <div className="mb-4">
                <div className="flex items-baseline gap-1 mb-2">
                  <span className="text-2xl font-bold text-blue-600">₹{plan.monthlyPrice}</span>
                  <span className="text-gray-500 text-sm">/month</span>
                </div>
                <div className="flex items-baseline gap-1">
                  <span className="text-2xl font-bold text-green-600">₹{plan.yearlyPrice}</span>
                  <span className="text-gray-500 text-sm">/year</span>
                </div>
              </div>
              
              <div className="space-y-2">
                {plan.features.map((feature, index) => (
                  <div key={index} className="flex items-center gap-2">
                    <div className="w-4 h-4 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0">
                      <svg className="w-2.5 h-2.5 text-white" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                      </svg>
                    </div>
                    <span className="text-gray-700 text-sm">{feature}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>

      {showForm && (
        <PlanForm
          plan={editingPlan}
          onClose={closeForm}
          onSuccess={() => {
            fetchPlans()
            closeForm()
          }}
        />
      )}
    </div>
  )
}

function PlanForm({ plan, onClose, onSuccess }: {
  plan: Plan | null
  onClose: () => void
  onSuccess: () => void
}) {
  const [formData, setFormData] = useState({
    name: plan?.name || '',
    monthlyPrice: plan?.monthlyPrice || 0,
    yearlyPrice: plan?.yearlyPrice || 0,
    features: plan?.features || ['']
  })
  const [loading, setLoading] = useState(false)

  const addFeature = () => {
    setFormData(prev => ({
      ...prev,
      features: [...prev.features, '']
    }))
  }

  const updateFeature = (index: number, value: string) => {
    setFormData(prev => ({
      ...prev,
      features: prev.features.map((f, i) => i === index ? value : f)
    }))
  }

  const removeFeature = (index: number) => {
    setFormData(prev => ({
      ...prev,
      features: prev.features.filter((_, i) => i !== index)
    }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const filteredFeatures = formData.features.filter(f => f.trim())
      const url = plan ? `/api/plans/${plan._id}` : '/api/plans'
      const method = plan ? 'PUT' : 'POST'

      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...formData,
          features: filteredFeatures
        })
      })

      if (response.ok) {
        onSuccess()
      }
    } catch (error) {
      console.error('Failed to save plan:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-md mx-4 max-h-[90vh] overflow-y-auto">
        <h2 className="text-xl font-bold mb-4">
          {plan ? 'Edit Plan' : 'Add New Plan'}
        </h2>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1">Plan Name</label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
              className="w-full p-2 border rounded-lg"
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">Monthly Price (₹)</label>
              <input
                type="number"
                value={formData.monthlyPrice}
                onChange={(e) => setFormData(prev => ({ ...prev, monthlyPrice: Number(e.target.value) }))}
                className="w-full p-2 border rounded-lg"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Yearly Price (₹)</label>
              <input
                type="number"
                value={formData.yearlyPrice}
                onChange={(e) => setFormData(prev => ({ ...prev, yearlyPrice: Number(e.target.value) }))}
                className="w-full p-2 border rounded-lg"
                required
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium mb-1">Features</label>
            {formData.features.map((feature, index) => (
              <div key={index} className="flex gap-2 mb-2">
                <input
                  type="text"
                  value={feature}
                  onChange={(e) => updateFeature(index, e.target.value)}
                  className="flex-1 p-2 border rounded-lg"
                  placeholder="Enter feature"
                />
                {formData.features.length > 1 && (
                  <button
                    type="button"
                    onClick={() => removeFeature(index)}
                    className="px-3 py-2 text-red-600 hover:bg-red-50 rounded-lg"
                  >
                    ×
                  </button>
                )}
              </div>
            ))}
            <button
              type="button"
              onClick={addFeature}
              className="text-blue-600 text-sm hover:underline"
            >
              + Add Feature
            </button>
          </div>

          <div className="flex gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-4 py-2 border rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {loading ? 'Saving...' : (plan ? 'Update' : 'Create')}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}