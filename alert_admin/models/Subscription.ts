import mongoose from 'mongoose'

const SubscriptionSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true
  },
  planId: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['trial', 'active', 'expired', 'cancelled'],
    default: 'trial'
  },
  trialStartDate: {
    type: Date
  },
  trialEndDate: {
    type: Date
  },
  subscriptionStartDate: {
    type: Date
  },
  subscriptionEndDate: {
    type: Date
  },
  nextRenewalDate: {
    type: Date
  },
  mandateId: {
    type: String
  },
  razorpaySubscriptionId: {
    type: String
  },
  amount: {
    type: Number,
    required: true
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

export default mongoose.models.Subscription || mongoose.model('Subscription', SubscriptionSchema)