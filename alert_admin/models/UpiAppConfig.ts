import mongoose from 'mongoose'

const UpiAppConfigSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  packageName: {
    type: String,
    required: true,
    unique: true
  },
  icon: {
    type: String,
    required: true
  },
  priority: {
    type: Number,
    default: 0
  },
  isActive: {
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

export default mongoose.models.UpiAppConfig || mongoose.model('UpiAppConfig', UpiAppConfigSchema)