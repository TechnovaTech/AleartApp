import mongoose from 'mongoose'

const SubscriptionReminderSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true
  },
  subscriptionId: {
    type: String,
    required: true
  },
  reminderType: {
    type: String,
    enum: ['24h', '1h'],
    required: true
  },
  renewalDate: {
    type: Date,
    required: true
  },
  sent: {
    type: Boolean,
    default: false
  },
  sentAt: {
    type: Date
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
})

export default mongoose.models.SubscriptionReminder || mongoose.model('SubscriptionReminder', SubscriptionReminderSchema)