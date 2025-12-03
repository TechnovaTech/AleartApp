import mongoose from 'mongoose'

const RazorpayMockWebhookLogSchema = new mongoose.Schema({
  eventType: {
    type: String,
    required: true
  },
  payload: {
    type: mongoose.Schema.Types.Mixed,
    required: true
  },
  subscriptionId: {
    type: String
  },
  mandateId: {
    type: String
  },
  userId: {
    type: String
  },
  processed: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
})

export default mongoose.models.RazorpayMockWebhookLog || mongoose.model('RazorpayMockWebhookLog', RazorpayMockWebhookLogSchema)