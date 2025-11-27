import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Payment from '../../../../../models/Payment'

export async function GET(request: NextRequest) {
  try {
    await dbConnect()
    
    // Get all payments sorted by timestamp (newest first)
    const payments = await Payment.find({})
      .sort({ timestamp: -1 })
      .limit(100) // Limit to last 100 payments
    
    return NextResponse.json({ success: true, payments })
  } catch (error) {
    console.error('Payment fetch error:', error)
    return NextResponse.json({ success: false, error: 'Failed to fetch payments' }, { status: 500 })
  }
}