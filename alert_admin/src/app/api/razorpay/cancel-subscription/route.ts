import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import razorpay from '../../../../../lib/razorpay'
import Subscription from '../../../../../models/Subscription'
import UserTimeline from '../../../../../models/UserTimeline'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
}

export async function OPTIONS() {
  return new NextResponse(null, { status: 200, headers: corsHeaders })
}

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const { userId } = await request.json()
    
    if (!userId) {
      return NextResponse.json({ 
        success: false, 
        error: 'User ID is required' 
      }, { status: 400, headers: corsHeaders })
    }
    
    // Find user's subscription
    const subscription = await Subscription.findOne({ userId })
    
    if (!subscription || !subscription.razorpaySubscriptionId) {
      return NextResponse.json({ 
        success: false, 
        error: 'No active subscription found' 
      }, { status: 404, headers: corsHeaders })
    }
    
    // Cancel subscription in Razorpay
    await razorpay.subscriptions.cancel(subscription.razorpaySubscriptionId, false)
    
    // Update subscription status
    subscription.status = 'cancelled'
    await subscription.save()
    
    // Add timeline event
    await UserTimeline.create({
      userId,
      eventType: 'subscription_cancelled',
      title: 'Subscription Cancelled',
      description: 'Subscription cancelled by user request',
      metadata: { 
        subscriptionId: subscription.razorpaySubscriptionId,
        cancelledAt: new Date()
      }
    })
    
    return NextResponse.json({ 
      success: true, 
      message: 'Subscription cancelled successfully' 
    }, { headers: corsHeaders })
    
  } catch (error: any) {
    console.error('Cancel subscription error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message || 'Failed to cancel subscription' 
    }, { status: 500, headers: corsHeaders })
  }
}