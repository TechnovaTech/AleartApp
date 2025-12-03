import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import razorpay from '../../../../../lib/razorpay'
import Subscription from '../../../../../models/Subscription'
import Plan from '../../../../../models/Plan'
import User from '../../../../../models/User'

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
    
    const { userId, planId, amount } = await request.json()
    
    if (!userId || !planId) {
      return NextResponse.json({ 
        success: false, 
        error: 'Missing required fields' 
      }, { status: 400, headers: corsHeaders })
    }
    
    // Get user and plan details
    const user = await User.findById(userId)
    const plan = await Plan.findById(planId)
    
    if (!user || !plan) {
      return NextResponse.json({ 
        success: false, 
        error: 'User or plan not found' 
      }, { status: 404, headers: corsHeaders })
    }

    // Create Razorpay payment link for subscription
    const paymentLinkData = {
      amount: (amount || plan.price) * 100, // Convert to paise
      currency: 'INR',
      accept_partial: false,
      description: `${plan.name} - Monthly Subscription`,
      customer: {
        name: user.username,
        email: user.email,
        contact: user.mobile
      },
      notify: {
        sms: true,
        email: true
      },
      reminder_enable: true,
      notes: {
        userId: userId,
        planId: planId,
        type: 'subscription'
      },
      callback_url: 'https://technovatechnologies.online/payment-success',
      callback_method: 'get'
    }

    const razorpayPaymentLink = await razorpay.paymentLink.create(paymentLinkData)
    
    // Update subscription in database
    let subscription = await Subscription.findOne({ userId })
    if (!subscription) {
      subscription = new Subscription({
        userId,
        planId,
        amount: amount || plan.price,
        status: 'pending'
      })
    }
    
    subscription.razorpaySubscriptionId = razorpayPaymentLink.id
    subscription.status = 'pending'
    await subscription.save()
    
    return NextResponse.json({ 
      success: true, 
      subscriptionId: razorpayPaymentLink.id,
      shortUrl: razorpayPaymentLink.short_url,
      paymentUrl: razorpayPaymentLink.short_url,
      amount: amount || plan.price
    }, { headers: corsHeaders })
    
  } catch (error: any) {
    console.error('Razorpay subscription error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message || 'Failed to create subscription' 
    }, { status: 500, headers: corsHeaders })
  }
}

async function createRazorpayPlan(plan: any) {
  const planData = {
    period: (plan.duration === 'monthly' ? 'monthly' : 'yearly') as 'monthly' | 'yearly',
    interval: 1,
    item: {
      name: plan.name,
      amount: plan.price * 100, // Convert to paise
      currency: 'INR',
      description: `${plan.name} subscription plan`
    }
  }
  
  const razorpayPlan = await razorpay.plans.create(planData)
  
  // Update plan with Razorpay plan ID
  plan.razorpayPlanId = razorpayPlan.id
  await plan.save()
  
  return razorpayPlan.id
}