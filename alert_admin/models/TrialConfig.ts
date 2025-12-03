import mongoose from 'mongoose'

const TrialConfigSchema = new mongoose.Schema({
  trialDurationDays: {
    type: Number,
    required: true,
    default: 7
  },
  isTrialEnabled: {
    type: Boolean,
    default: true
  },
  trialFeatures: [{
    type: String
  }],
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
})

export default mongoose.models.TrialConfig || mongoose.model('TrialConfig', TrialConfigSchema)