'use client'

import { useState, useEffect } from 'react'
import { Settings, Save, Calendar, CheckCircle } from 'lucide-react'

interface TrialConfig {
  _id?: string
  trialDurationDays: number
  isTrialEnabled: boolean
  trialFeatures: string[]
}

export default function TrialSettingsPage() {
  const [config, setConfig] = useState<TrialConfig>({
    trialDurationDays: 7,
    isTrialEnabled: true,
    trialFeatures: []
  })
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState('')

  useEffect(() => {
    fetchTrialConfig()
  }, [])

  const fetchTrialConfig = async () => {
    try {
      const response = await fetch('/api/config/trial')
      const data = await response.json()
      if (data.success) {
        setConfig(data.config)
      }
    } catch (error) {
      console.error('Failed to fetch trial config:', error)
    } finally {
      setLoading(false)
    }
  }

  const saveConfig = async () => {
    setSaving(true)
    try {
      const response = await fetch('/api/config/trial', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(config),
      })
      
      const data = await response.json()
      if (data.success) {
        setMessage('Trial settings saved successfully!')
        setTimeout(() => setMessage(''), 3000)
      } else {
        setMessage('Failed to save settings')
      }
    } catch (error) {
      setMessage('Failed to save settings')
    } finally {
      setSaving(false)
    }
  }

  const addFeature = () => {
    setConfig({
      ...config,
      trialFeatures: [...config.trialFeatures, '']
    })
  }

  const updateFeature = (index: number, value: string) => {
    const newFeatures = [...config.trialFeatures]
    newFeatures[index] = value
    setConfig({
      ...config,
      trialFeatures: newFeatures
    })
  }

  const removeFeature = (index: number) => {
    setConfig({
      ...config,
      trialFeatures: config.trialFeatures.filter((_, i) => i !== index)
    })
  }

  if (loading) {
    return (
      <div className="p-6">
        <div className="text-center">Loading trial settings...</div>
      </div>
    )
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">Free Trial Settings</h1>
        <p className="text-gray-600">Configure free trial duration and features</p>
      </div>

      {message && (
        <div className="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded">
          {message}
        </div>
      )}

      <div className="bg-white rounded-lg shadow-sm border p-6">
        <div className="space-y-6">
          {/* Trial Duration */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              <Calendar className="inline w-4 h-4 mr-2" />
              Trial Duration (Days)
            </label>
            <input
              type="number"
              min="1"
              max="30"
              value={config.trialDurationDays}
              onChange={(e) => setConfig({
                ...config,
                trialDurationDays: parseInt(e.target.value) || 7
              })}
              className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          {/* Trial Enabled */}
          <div>
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={config.isTrialEnabled}
                onChange={(e) => setConfig({
                  ...config,
                  isTrialEnabled: e.target.checked
                })}
                className="mr-2 rounded border-gray-300"
              />
              <CheckCircle className="w-4 h-4 mr-2 text-green-500" />
              Enable Free Trial
            </label>
          </div>

          {/* Trial Features */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Trial Features
            </label>
            <div className="space-y-2">
              {config.trialFeatures.map((feature, index) => (
                <div key={index} className="flex gap-2">
                  <input
                    type="text"
                    value={feature}
                    onChange={(e) => updateFeature(index, e.target.value)}
                    placeholder="Enter feature name"
                    className="flex-1 p-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <button
                    onClick={() => removeFeature(index)}
                    className="px-3 py-2 bg-red-500 text-white rounded hover:bg-red-600"
                  >
                    Remove
                  </button>
                </div>
              ))}
              <button
                onClick={addFeature}
                className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
              >
                Add Feature
              </button>
            </div>
          </div>

          {/* Save Button */}
          <div className="pt-4 border-t">
            <button
              onClick={saveConfig}
              disabled={saving}
              className="flex items-center px-6 py-3 bg-green-500 text-white rounded-lg hover:bg-green-600 disabled:opacity-50"
            >
              <Save className="w-4 h-4 mr-2" />
              {saving ? 'Saving...' : 'Save Settings'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}