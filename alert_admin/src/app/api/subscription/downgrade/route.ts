import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Subscription from '../../../../../models/Subscription'
import UserTimeline from '../../../../../models/UserTimeline'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { userId, subscriptionFailureReason } = body
    
    if (!userId) {
      return NextResponse.json({ success: false, error: 'User ID required' }, { status: 400 })
    }
    
    const subscription = await Subscription.findOne({ userId })
    if (!subscription) {
      return NextResponse.json({ success: false, error: 'Subscription not found' }, { status: 404 })
    }
    
    // Downgrade to free plan
    subscription.status = 'expired'
    subscription.subscriptionFailureReason = subscriptionFailureReason || 'Payment failed'
    subscription.updatedAt = new Date()
    await subscription.save()
    
    // Add timeline event
    const timeline = new UserTimeline({
      userId,
      eventType: 'subscription-renewal-failed',
      title: 'Subscription Renewal Failed',
      description: `Subscription downgraded to free plan. Reason: ${subscriptionFailureReason || 'Payment failed'}`,
      metadata: { subscriptionFailureReason }
    })
    await timeline.save()
    
    return NextResponse.json({ success: true, subscription })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to downgrade subscription' }, { status: 500 })
  }
}