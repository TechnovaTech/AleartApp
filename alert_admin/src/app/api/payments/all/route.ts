import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Payment from '../../../../../models/Payment'
import User from '../../../../../models/User'

export async function GET(request: NextRequest) {
  try {
    await dbConnect()
    
    // Get all payments sorted by timestamp (newest first)
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
    
    console.log('Fetched payments:', paymentsWithUsers.length)
    console.log('Sample payment with user:', paymentsWithUsers[0])
    return NextResponse.json({ success: true, payments: paymentsWithUsers })
  } catch (error) {
    console.error('Payment fetch error:', error)
    return NextResponse.json({ success: false, error: 'Failed to fetch payments' }, { status: 500 })
  }
}

