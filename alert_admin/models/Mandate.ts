import mongoose from 'mongoose'

const MandateSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true
  },
  mandateId: {
    type: String,
    required: true,
    unique: true
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected', 'cancelled'],
    default: 'pending'
  },
  amount: {
    type: Number,
    required: true
  },
  frequency: {
    type: String,
    default: 'monthly'
  },
  bankAccount: {
    type: String
  },
  approvalUrl: {
    type: String
  },
  approvedAt: {
    type: Date
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

export default mongoose.models.Mandate || mongoose.model('Mandate', MandateSchema)