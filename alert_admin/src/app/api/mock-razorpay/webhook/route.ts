import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import RazorpayMockWebhookLog from '../../../../../models/RazorpayMockWebhookLog'
import Subscription from '../../../../../models/Subscription'
import UserTimeline from '../../../../../models/UserTimeline'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { event, payload } = body
    
    // Log webhook
    const webhookLog = new RazorpayMockWebhookLog({
      eventType: event,
      payload,
      subscriptionId: payload.subscription?.id,
      mandateId: payload.mandate?.id
    })
    await webhookLog.save()
    
    // Process webhook based on event type
    if (event === 'subscription.charged') {
      const subscriptionId = payload.subscription?.id
      const subscription = await Subscription.findOne({ razorpaySubscriptionId: subscriptionId })
      
      if (subscription) {
        // Extend subscription
        const nextRenewal = new Date()
        nextRenewal.setMonth(nextRenewal.getMonth() + 1)
        
        subscription.status = 'active'
        subscription.nextRenewalDate = nextRenewal
        subscription.updatedAt = new Date()
        await subscription.save()
        
        // Add timeline event
        const timeline = new UserTimeline({
          userId: subscription.userId,
          eventType: 'subscription_renewed',
          title: 'Subscription Renewed',
          description: `Subscription renewed for ₹${payload.payment?.amount / 100}`
        })
        await timeline.save()
        
        webhookLog.userId = subscription.userId
        webhookLog.processed = true
        await webhookLog.save()
      }
    } else if (event === 'subscription.payment_failed') {
      const subscriptionId = payload.subscription?.id
      const subscription = await Subscription.findOne({ razorpaySubscriptionId: subscriptionId })
      
      if (subscription) {
        // Downgrade subscription
        subscription.status = 'expired'
        subscription.subscriptionFailureReason = payload.error?.description || 'Payment failed'
        subscription.updatedAt = new Date()
        await subscription.save()
        
        // Add timeline event
        const timeline = new UserTimeline({
          userId: subscription.userId,
          eventType: 'subscription-renewal-failed',
          title: 'Subscription Renewal Failed',
          description: `Payment failed: ${payload.error?.description || 'Unknown error'}`,
          metadata: { failureReason: payload.error?.description }
        })
        await timeline.save()
        
        webhookLog.userId = subscription.userId
        webhookLog.processed = true
        await webhookLog.save()
      }
    }
    
    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Webhook processing failed' }, { status: 500 })
  }
}