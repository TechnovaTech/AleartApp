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
    
    if (!user) {
      return NextResponse.json({ 
        success: false, 
        error: 'User not found' 
      }, { status: 404, headers: corsHeaders })
    }
    
    if (!plan) {
      return NextResponse.json({ 
        success: false, 
        error: 'Plan not found' 
      }, { status: 404, headers: corsHeaders })
    }

    // Create simple payment link
    const paymentAmount = amount || plan.price || 1
    const transactionId = `TXN${Date.now()}`
    
    try {
      const paymentLinkData = {
        amount: paymentAmount * 100, // Convert to paise
        currency: 'INR',
        accept_partial: false,
        description: `${plan.name || 'Subscription'} Payment`,
        customer: {
          name: user.username || 'User',
          email: user.email,
          contact: user.mobile || '+919999999999'
        },
        notify: {
          sms: false,
          email: false
        },
        notes: {
          userId: userId,
          planId: planId
        }
      }

      const razorpayPaymentLink = await razorpay.paymentLink.create(paymentLinkData)
      
      // Create UPI deep link
      const upiDeepLink = `upi://pay?pa=hello.technovatechnologies@paytm&pn=AlertPe&tr=${transactionId}&tn=Subscription&am=${paymentAmount}&cu=INR`
    
      // Update subscription in database
      let subscription = await Subscription.findOne({ userId })
      if (!subscription) {
        subscription = new Subscription({
          userId,
          planId,
          amount: paymentAmount,
          status: 'pending'
        })
      }
      
      subscription.razorpaySubscriptionId = razorpayPaymentLink.id
      subscription.status = 'pending'
      await subscription.save()
      
      return NextResponse.json({ 
        success: true, 
        subscriptionId: razorpayPaymentLink.id,
        shortUrl: upiDeepLink,
        paymentUrl: razorpayPaymentLink.short_url,
        upiLink: upiDeepLink,
        transactionId: transactionId,
        amount: paymentAmount
      }, { headers: corsHeaders })
      
    } catch (razorpayError) {
      console.error('Razorpay error:', razorpayError)
      
      // Fallback: create simple UPI link without Razorpay
      const fallbackTransactionId = `TXN${Date.now()}`
      const fallbackUpiLink = `upi://pay?pa=hello.technovatechnologies@paytm&pn=AlertPe&tr=${fallbackTransactionId}&tn=Subscription&am=${paymentAmount}&cu=INR`
      
      return NextResponse.json({ 
        success: true, 
        subscriptionId: fallbackTransactionId,
        shortUrl: fallbackUpiLink,
        paymentUrl: `https://technovatechnologies.online/payment?amount=${paymentAmount}`,
        upiLink: fallbackUpiLink,
        transactionId: fallbackTransactionId,
        amount: paymentAmount
      }, { headers: corsHeaders })
    }
    
  } catch (error: any) {
    console.error('Subscription creation error:', error)
    
    // Fallback response with simple UPI link
    const fallbackAmount = amount || 1
    const fallbackTransactionId = `TXN${Date.now()}`
    const fallbackUpiLink = `upi://pay?pa=hello.technovatechnologies@paytm&pn=AlertPe&tr=${fallbackTransactionId}&tn=Subscription&am=${fallbackAmount}&cu=INR`
    
    return NextResponse.json({ 
      success: true, 
      subscriptionId: fallbackTransactionId,
      shortUrl: fallbackUpiLink,
      paymentUrl: `https://technovatechnologies.online/payment?amount=${fallbackAmount}`,
      upiLink: fallbackUpiLink,
      transactionId: fallbackTransactionId,
      amount: fallbackAmount,
      fallback: true
    }, { headers: corsHeaders })
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