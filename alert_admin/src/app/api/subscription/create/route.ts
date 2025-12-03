import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Subscription from '../../../../../models/Subscription'
import UserTimeline from '../../../../../models/UserTimeline'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { userId, planId, amount } = body
    
    if (!userId || !planId || !amount) {
      return NextResponse.json({ success: false, error: 'Missing required fields' }, { status: 400 })
    }
    
    // Check if user already has a subscription
    const existingSubscription = await Subscription.findOne({ userId })
    if (existingSubscription) {
      return NextResponse.json({ success: false, error: 'User already has a subscription' }, { status: 400 })
    }
    
    const trialEndDate = new Date()
    trialEndDate.setDate(trialEndDate.getDate() + 7) // 7 days trial
    
    const subscription = new Subscription({
      userId,
      planId,
      amount,
      status: 'trial',
      trialStartDate: new Date(),
      trialEndDate
    })
    
    await subscription.save()
    
    // Add timeline event
    const timeline = new UserTimeline({
      userId,
      eventType: 'trial_started',
      title: 'Free Trial Started',
      description: '7-day free trial activated'
    })
    await timeline.save()
    
    return NextResponse.json({ success: true, subscription })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to create subscription' }, { status: 500 })
  }
}