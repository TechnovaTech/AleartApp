import mongoose from 'mongoose'

const PaymentSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  amount: { type: String, required: true },
  paymentApp: { type: String, required: true },
  upiId: { type: String, required: true },
  transactionId: { type: String, required: true },
  notificationText: { type: String, required: true },
  status: { type: String, default: 'Received' },
  timestamp: { type: Date, default: Date.now },
  date: { type: String, required: true },
  time: { type: String, required: true }
})

export default mongoose.models.Payment || mongoose.model('Payment', PaymentSchema)