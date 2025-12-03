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

    // Create Razorpay subscription
    const subscriptionData = {
      plan_id: plan.razorpayPlanId || await createRazorpayPlan(plan),
      customer_notify: 1 as 0 | 1,
      quantity: 1,
      total_count: 12, // For monthly plan, 12 months
      addons: [],
      notes: {
        userId: userId,
        mobile: user.mobile
      }
    }

    const razorpaySubscription = await razorpay.subscriptions.create(subscriptionData)
    
    // Update subscription in database
    let subscription = await Subscription.findOne({ userId })
    if (!subscription) {
      subscription = new Subscription({
        userId,
        planId,
        amount: plan.price,
        status: 'active'
      })
    }
    
    subscription.razorpaySubscriptionId = razorpaySubscription.id
    subscription.subscriptionStartDate = new Date()
    subscription.nextRenewalDate = new Date(Date.now() + (plan.duration === 'monthly' ? 30 : 365) * 24 * 60 * 60 * 1000)
    await subscription.save()
    
    // Create UPI payment URL with actual amount
    const upiUrl = `upi://pay?pa=merchant@razorpay&pn=AlertPe&tr=${Date.now()}&tn=Subscription Payment&am=${amount || plan.price}&cu=INR`
    
    return NextResponse.json({ 
      success: true, 
      subscriptionId: razorpaySubscription.id,
      shortUrl: razorpaySubscription.short_url || upiUrl,
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