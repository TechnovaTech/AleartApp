import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import User from '../../../../../models/User'
import Plan from '../../../../../models/Plan'
import Mandate from '../../../../../models/Mandate'
import UserTimeline from '../../../../../models/UserTimeline'
import Razorpay from 'razorpay'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const { userId, planId, amount, verificationAmount, upiApp } = await request.json()

    if (!userId || !planId || !amount) {
      return NextResponse.json({
        success: false,
        message: 'Missing required fields'
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

    // Initialize Razorpay
    const razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID!,
      key_secret: process.env.RAZORPAY_KEY_SECRET!
    })

    // Create real Razorpay mandate
    const mandateAmount = verificationAmount || 5 // Default ₹5 if not set
    
    try {
      // Create Razorpay payment link for mandate
      const paymentLink = await razorpay.paymentLink.create({
        amount: mandateAmount * 100, // Convert to paise
        currency: 'INR',
        description: `UPI Autopay Setup - ${plan.name}`,
        customer: {
          name: user.username || 'User',
          email: user.email,
          contact: user.mobile
        },
        notify: {
          sms: false,
          email: false
        },
        reminder_enable: false,
        options: {
          checkout: {
            method: {
              upi: true,
              card: false,
              netbanking: false,
              wallet: false
            }
          }
        },
        callback_url: `${process.env.NEXT_PUBLIC_API_URL || 'https://technovatechnologies.online'}/api/razorpay/mandate-callback`,
        callback_method: 'get'
      })

      const mandateId = paymentLink.id
      const upiUrl = paymentLink.short_url
      const browserUrl = paymentLink.short_url

    // Create mandate record
    const mandate = new Mandate({
      userId,
      mandateId,
      status: 'pending',
      amount: amount,
      frequency: plan.duration === 'yearly' ? 'yearly' : 'monthly',
      bankAccount: user.mobile, // Using mobile as identifier
      approvalUrl: upiUrl,
      createdAt: new Date()
    })

    await mandate.save()

    // Add timeline event
    await UserTimeline.create({
      userId,
      eventType: 'mandate_created',
      title: 'UPI Mandate Created',
      description: `Created UPI mandate for ${plan.name} - ₹${amount}/${plan.duration}`,
      metadata: {
        mandateId,
        planId,
        planName: plan.name,
        amount,
        upiApp
      },
      timestamp: new Date()
    })

    return NextResponse.json({
      success: true,
      message: 'Mandate created successfully',
      mandateId,
      mandateUrl: upiUrl,
      browserUrl: browserUrl,
      amount: mandateAmount,
      planName: plan.name,
      razorpayPaymentLinkId: paymentLink.id
    })

    } catch (razorpayError) {
      console.error('Razorpay mandate creation failed:', razorpayError)
      return NextResponse.json({
        success: false,
        message: 'Failed to create payment mandate'
      }, { status: 500 })
    }

  } catch (error) {
    console.error('Error creating mandate:', error)
    return NextResponse.json({
      success: false,
      message: 'Internal server error'
    }, { status: 500 })
  }
}