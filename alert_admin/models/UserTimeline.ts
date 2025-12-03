import mongoose from 'mongoose'

const UserTimelineSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true
  },
  eventType: {
    type: String,
    required: true,
    enum: ['registration', 'trial_started', 'subscription_created', 'payment_received', 'mandate_approved', 'subscription_renewed', 'subscription_expired']
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String
  },
  metadata: {
    type: mongoose.Schema.Types.Mixed
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
})

export default mongoose.models.UserTimeline || mongoose.model('UserTimeline', UserTimelineSchema)