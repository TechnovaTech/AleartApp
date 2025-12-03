import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../lib/mongodb'
import RazorpayMockWebhookLog from '../../../../models/RazorpayMockWebhookLog'

export async function GET() {
  try {
    await dbConnect()
    
    const logs = await RazorpayMockWebhookLog.find().sort({ createdAt: -1 }).limit(100)
    
    return NextResponse.json({ success: true, logs })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch webhook logs' }, { status: 500 })
  }
}