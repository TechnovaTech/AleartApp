import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Payment from '../../../../../models/Payment'
import User from '../../../../../models/User'

export async function GET(request: NextRequest) {
  try {
    await dbConnect()
    
    // Add no-cache headers
    const headers = {
      'Cache-Control': 'no-store, no-cache, must-revalidate, proxy-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0'
    }
    
    // Get all payments
    const payments = await Payment.find({})
      .sort({ timestamp: -1 })
      .limit(100)
    
    // Manually fetch user data for each payment
    const paymentsWithUsers = await Promise.all(
      payments.map(async (payment) => {
        try {
          const user = await User.findById(payment.userId).select('username email')
          return {
            ...payment.toObject(),
            user: user ? { username: user.username, email: user.email } : null
          }
        } catch (err) {
          return {
            ...payment.toObject(),
            user: null
          }
        }
      })
    )
    
    return NextResponse.json({ success: true, payments: paymentsWithUsers }, { headers })
  } catch (error) {
    console.error('Payment fetch error:', error)
    return NextResponse.json({ success: false, error: 'Failed to fetch payments' }, { status: 500, headers })
  }
}

