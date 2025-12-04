import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import User from '../../../../../models/User'
import Subscription from '../../../../../models/Subscription'
import Plan from '../../../../../models/Plan'
import TrialConfig from '../../../../../models/TrialConfig'
import UserTimeline from '../../../../../models/UserTimeline'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const { userId, planId, trialDays, planAmount } = await request.json()

    if (!userId || !planId) {
      return NextResponse.json({
        success: false,
        message: 'User ID and Plan ID are required'
      }, { status: 400 })
    }

    // Check if user exists
    const user = await User.findById(userId)
    if (!user) {
      return NextResponse.json({
        success: false,
        message: 'User not found'
      }, { status: 404 })
    }

    // Check if plan exists
    const plan = await Plan.findById(planId)
    if (!plan) {
      return NextResponse.json({
        success: false,
        message: 'Plan not found'
      }, { status: 404 })
    }

    // Get trial configuration
    let trialConfig = await TrialConfig.findOne()
    if (!trialConfig) {
      // Create default trial config if not exists
      trialConfig = new TrialConfig({
        trialDurationDays: trialDays || 1,
        isTrialEnabled: true,
        trialFeatures: ['Basic alerts', 'Limited reports']
      })
      await trialConfig.save()
    }

    // Check if user already has an active subscription or trial
    const existingSubscription = await Subscription.findOne({
      userId,
      status: { $in: ['trial', 'active'] }
    })

    if (existingSubscription) {
      return NextResponse.json({
        success: false,
        message: 'User already has an active subscription or trial'
      }, { status: 400 })
    }

    // Calculate trial dates
    const trialStartDate = new Date()
    const trialEndDate = new Date()
    trialEndDate.setDate(trialStartDate.getDate() + (trialDays || trialConfig.trialDurationDays))

    // Create new subscription with trial status
    const subscription = new Subscription({
      userId,
      planId,
      status: 'trial',
      trialStartDate,
      trialEndDate,
      amount: planAmount || plan.price,
      subscriptionStartDate: trialEndDate, // Will start after trial ends
      nextRenewalDate: new Date(trialEndDate.getTime() + (30 * 24 * 60 * 60 * 1000)), // 30 days after trial
      createdAt: new Date(),
      updatedAt: new Date()
    })

    await subscription.save()

    // Update user subscription status
    await User.findByIdAndUpdate(userId, {
      subscription: 'trial',
      updatedAt: new Date()
    })

    // Add timeline event
    await UserTimeline.create({
      userId,
      eventType: 'trial_started',
      title: 'Free Trial Started',
      description: `Started ${trialDays || trialConfig.trialDurationDays} day free trial for ${plan.name}`,
      metadata: {
        planId,
        planName: plan.name,
        trialDays: trialDays || trialConfig.trialDurationDays,
        amount: planAmount || plan.price
      },
      timestamp: new Date()
    })

    return NextResponse.json({
      success: true,
      message: 'Free trial started successfully',
      subscription: {
        id: subscription._id,
        status: subscription.status,
        trialStartDate: subscription.trialStartDate,
        trialEndDate: subscription.trialEndDate,
        planName: plan.name,
        amount: subscription.amount
      }
    })

  } catch (error) {
    console.error('Error starting trial:', error)
    return NextResponse.json({
      success: false,
      message: 'Internal server error'
    }, { status: 500 })
  }
}