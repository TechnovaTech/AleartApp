import mongoose from 'mongoose'

const PlanSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  monthlyPrice: {
    type: Number,
    required: true
  },
  yearlyPrice: {
    type: Number,
    required: true
  },
  features: [{
    type: String,
    required: true
  }],
  isActive: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
})

export default mongoose.models.Plan || mongoose.model('Plan', PlanSchema)