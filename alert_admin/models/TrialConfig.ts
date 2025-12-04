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
  mandateVerificationAmount: {
    type: Number,
    default: 5,
    min: 1,
    max: 100
  },
  isMandateVerificationEnabled: {
    type: Boolean,
    default: true
  },
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