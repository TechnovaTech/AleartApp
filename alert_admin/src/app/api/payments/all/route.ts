import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Payment from '../../../../../models/Payment'
import User from '../../../../../models/User'

export async function GET(request: NextRequest) {
  try {
    await dbConnect()
    
    // Get all payments with user data sorted by timestamp (newest first)
    const payments = await Payment.find({})
      .populate({
        path: 'userId',
        model: User,
        select: 'username email'
      })
      .sort({ timestamp: -1 })
      .limit(100) // Limit to last 100 payments
    
    console.log('Fetched payments:', payments.length)
    console.log('Sample payment:', payments[0])
    return NextResponse.json({ success: true, payments })
  } catch (error) {
    console.error('Payment fetch error:', error)
    return NextResponse.json({ success: false, error: 'Failed to fetch payments' }, { status: 500 })
  }
}

