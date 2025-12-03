import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Subscription from '../../../../../models/Subscription'
import User from '../../../../../models/User'

export async function GET() {
  try {
    await dbConnect()
    
    const subscriptions = await Subscription.find().sort({ createdAt: -1 })
    
    // Populate user data
    const subscriptionsWithUsers = await Promise.all(
      subscriptions.map(async (subscription) => {
        const user = await User.findById(subscription.userId)
        return {
          ...subscription.toObject(),
          user: user ? {
            username: user.username,
            email: user.email
          } : null
        }
      })
    )
    
    return NextResponse.json({ success: true, subscriptions: subscriptionsWithUsers })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch subscriptions' }, { status: 500 })
  }
}