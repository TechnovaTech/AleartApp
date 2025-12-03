import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Subscription from '../../../../../models/Subscription'
import UserTimeline from '../../../../../models/UserTimeline'
import SubscriptionReminder from '../../../../../models/SubscriptionReminder'

export async function POST() {
  try {
    await dbConnect()
    
    const now = new Date()
    let processedCount = 0
    let remindersCreated = 0
    
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
    
    // Create renewal reminders (24h and 1h before)
    const activeSubscriptions = await Subscription.find({
      status: 'active',
      nextRenewalDate: { $exists: true }
    })
    
    for (const subscription of activeSubscriptions) {
      const renewalDate = new Date(subscription.nextRenewalDate)
      const twentyFourHoursBefore = new Date(renewalDate.getTime() - 24 * 60 * 60 * 1000)
      const oneHourBefore = new Date(renewalDate.getTime() - 60 * 60 * 1000)
      
      // Check if we need to create 24h reminder
      if (now >= twentyFourHoursBefore && now < renewalDate) {
        const existing24h = await SubscriptionReminder.findOne({
          userId: subscription.userId,
          subscriptionId: subscription._id,
          reminderType: '24h',
          renewalDate: renewalDate
        })
        
        if (!existing24h) {
          const reminder24h = new SubscriptionReminder({
            userId: subscription.userId,
            subscriptionId: subscription._id,
            reminderType: '24h',
            renewalDate: renewalDate
          })
          await reminder24h.save()
          
          // Add timeline event
          const timeline24h = new UserTimeline({
            userId: subscription.userId,
            eventType: 'renewal-reminder-24h',
            title: 'Renewal Reminder - 24 Hours',
            description: 'Your subscription renews in 24 hours'
          })
          await timeline24h.save()
          
          remindersCreated++
        }
      }
      
      // Check if we need to create 1h reminder
      if (now >= oneHourBefore && now < renewalDate) {
        const existing1h = await SubscriptionReminder.findOne({
          userId: subscription.userId,
          subscriptionId: subscription._id,
          reminderType: '1h',
          renewalDate: renewalDate
        })
        
        if (!existing1h) {
          const reminder1h = new SubscriptionReminder({
            userId: subscription.userId,
            subscriptionId: subscription._id,
            reminderType: '1h',
            renewalDate: renewalDate
          })
          await reminder1h.save()
          
          // Add timeline event
          const timeline1h = new UserTimeline({
            userId: subscription.userId,
            eventType: 'renewal-reminder-1h',
            title: 'Renewal Reminder - 1 Hour',
            description: 'Your subscription renews in 1 hour'
          })
          await timeline1h.save()
          
          remindersCreated++
        }
      }
    }
    
    return NextResponse.json({ 
      success: true, 
      message: `Processed ${processedCount} subscriptions, created ${remindersCreated} reminders`,
      processedCount,
      remindersCreated
    })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Scheduler failed' }, { status: 500 })
  }
}