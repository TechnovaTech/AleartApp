import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '../../../../lib/mongodb';
import mongoose from 'mongoose';

const QRCodeSchema = new mongoose.Schema({
  upiId: { type: String, required: true },
  userId: { type: String, required: true },
  qrData: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

const QRCode = mongoose.models.QRCode || mongoose.model('QRCode', QRCodeSchema);

export async function POST(request: NextRequest) {
  try {
    const { upiId, userId } = await request.json();

    if (!upiId || !userId) {
      return NextResponse.json({ error: 'UPI ID and User ID are required' }, { status: 400 });
    }

    await dbConnect();
    
    const qrCode = new QRCode({
      upiId,
      userId,
      qrData: `upi://pay?pa=${upiId}&pn=AlertPe%20Soundbox&cu=INR`,
    });

    await qrCode.save();

    return NextResponse.json({ success: true, qrCode }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to save QR code' }, { status: 500 });
  }
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId');

    if (!userId) {
      return NextResponse.json({ error: 'User ID is required' }, { status: 400 });
    }

    await dbConnect();
    
    let qrCodes;
    if (userId === 'all') {
      qrCodes = await QRCode.find({})
        .sort({ createdAt: -1 })
        .limit(50)
        .lean();
    } else {
      qrCodes = await QRCode.find({ userId })
        .sort({ createdAt: -1 })
        .limit(10)
        .lean();
    }

    return NextResponse.json({ qrCodes }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch QR codes' }, { status: 500 });
  }
}

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}