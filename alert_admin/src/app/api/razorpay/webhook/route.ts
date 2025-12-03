import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Subscription from '../../../../../models/Subscription'
import UserTimeline from '../../../../../models/UserTimeline'
import crypto from 'crypto'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.text()
    const signature = request.headers.get('x-razorpay-signature')
    
    // Verify webhook signature
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_WEBHOOK_SECRET!)
      .update(body)
      .digest('hex')
    
    if (signature !== expectedSignature) {
      return NextResponse.json({ error: 'Invalid signature' }, { status: 400 })
    }
    
    const event = JSON.parse(body)
    
    switch (event.event) {
      case 'subscription.activated':
        await handleSubscriptionActivated(event.payload.subscription.entity)
        break
        
      case 'subscription.charged':
        await handleSubscriptionCharged(event.payload.payment.entity, event.payload.subscription.entity)
        break
        
      case 'subscription.cancelled':
        await handleSubscriptionCancelled(event.payload.subscription.entity)
        break
        
      case 'subscription.completed':
        await handleSubscriptionCompleted(event.payload.subscription.entity)
        break
        
      case 'payment.failed':
        await handlePaymentFailed(event.payload.payment.entity)
        break
    }
    
    return NextResponse.json({ success: true })
    
  } catch (error) {
    console.error('Webhook error:', error)
    return NextResponse.json({ error: 'Webhook processing failed' }, { status: 500 })
  }
}

async function handleSubscriptionActivated(subscriptionData: any) {
  const subscription = await Subscription.findOne({ 
    razorpaySubscriptionId: subscriptionData.id 
  })
  
  if (subscription) {
    subscription.status = 'active'
    subscription.subscriptionStartDate = new Date(subscriptionData.start_at * 1000)
    await subscription.save()
    
    // Add timeline event
    await UserTimeline.create({
      userId: subscription.userId,
      eventType: 'subscription_activated',
      title: 'Subscription Activated',
      description: 'Your premium subscription has been activated successfully',
      metadata: { subscriptionId: subscriptionData.id }
    })
  }
}

async function handleSubscriptionCharged(paymentData: any, subscriptionData: any) {
  const subscription = await Subscription.findOne({ 
    razorpaySubscriptionId: subscriptionData.id 
  })
  
  if (subscription) {
    subscription.nextRenewalDate = new Date(subscriptionData.current_end * 1000)
    await subscription.save()
    
    // Add timeline event
    await UserTimeline.create({
      userId: subscription.userId,
      eventType: 'payment_success',
      title: 'Payment Successful',
      description: `Payment of ₹${paymentData.amount / 100} processed successfully`,
      metadata: { 
        paymentId: paymentData.id,
        amount: paymentData.amount / 100
      }
    })
  }
}

async function handleSubscriptionCancelled(subscriptionData: any) {
  const subscription = await Subscription.findOne({ 
    razorpaySubscriptionId: subscriptionData.id 
  })
  
  if (subscription) {
    subscription.status = 'cancelled'
    await subscription.save()
    
    // Add timeline event
    await UserTimeline.create({
      userId: subscription.userId,
      eventType: 'subscription_cancelled',
      title: 'Subscription Cancelled',
      description: 'Your subscription has been cancelled',
      metadata: { subscriptionId: subscriptionData.id }
    })
  }
}

async function handleSubscriptionCompleted(subscriptionData: any) {
  const subscription = await Subscription.findOne({ 
    razorpaySubscriptionId: subscriptionData.id 
  })
  
  if (subscription) {
    subscription.status = 'expired'
    await subscription.save()
    
    // Add timeline event
    await UserTimeline.create({
      userId: subscription.userId,
      eventType: 'subscription_expired',
      title: 'Subscription Expired',
      description: 'Your subscription has expired',
      metadata: { subscriptionId: subscriptionData.id }
    })
  }
}

async function handlePaymentFailed(paymentData: any) {
  // Find subscription by payment ID or other means
  const subscription = await Subscription.findOne({ 
    razorpaySubscriptionId: paymentData.subscription_id 
  })
  
  if (subscription) {
    subscription.subscriptionFailureReason = paymentData.error_description
    subscription.status = 'expired' // Downgrade to free plan
    await subscription.save()
    
    // Add timeline event
    await UserTimeline.create({
      userId: subscription.userId,
      eventType: 'payment_failed',
      title: 'Payment Failed - Downgraded to Free Plan',
      description: `Payment failed: ${paymentData.error_description}. Account downgraded to Free Plan (Limited).`,
      metadata: { 
        paymentId: paymentData.id,
        errorCode: paymentData.error_code,
        downgradedAt: new Date()
      }
    })
  }
}