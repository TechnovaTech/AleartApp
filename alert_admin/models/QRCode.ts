import mongoose from 'mongoose';

const QRCodeSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
  },
  upiId: {
    type: String,
    required: true,
  },
  qrData: {
    type: String,
    required: true,
  },
}, {
  timestamps: true,
});

export default mongoose.models.QRCode || mongoose.model('QRCode', QRCodeSchema);