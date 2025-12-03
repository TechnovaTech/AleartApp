import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Subscription from '../../../../../models/Subscription'
import UserTimeline from '../../../../../models/UserTimeline'

export async function POST() {
  try {
    await dbConnect()
    
    const now = new Date()
    let processedCount = 0
    
    // Find expired trials
    const expiredTrials = await Subscription.find({
      status: 'trial',
      trialEndDate: { $lte: now }
    })
    
    for (const subscription of expiredTrials) {
      subscription.status = 'expired'
      subscription.updatedAt = now
      await subscription.save()
      
      // Add timeline event
      const timeline = new UserTimeline({
        userId: subscription.userId,
        eventType: 'subscription_expired',
        title: 'Trial Expired',
        description: 'Free trial period has ended'
      })
      await timeline.save()
      
      processedCount++
    }
    
    // Find subscriptions due for renewal
    const dueForRenewal = await Subscription.find({
      status: 'active',
      nextRenewalDate: { $lte: now }
    })
    
    for (const subscription of dueForRenewal) {
      // Mock renewal process
      const nextRenewal = new Date()
      nextRenewal.setMonth(nextRenewal.getMonth() + 1)
      
      subscription.nextRenewalDate = nextRenewal
      subscription.updatedAt = now
      await subscription.save()
      
      // Add timeline event
      const timeline = new UserTimeline({
        userId: subscription.userId,
        eventType: 'subscription_renewed',
        title: 'Subscription Renewed',
        description: `Subscription renewed for ₹${subscription.amount}`
      })
      await timeline.save()
      
      processedCount++
    }
    
    return NextResponse.json({ 
      success: true, 
      message: `Processed ${processedCount} subscriptions`,
      processedCount 
    })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Scheduler failed' }, { status: 500 })
  }
}