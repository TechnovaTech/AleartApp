import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import User from '../../../../../models/User'
import Plan from '../../../../../models/Plan'
import Mandate from '../../../../../models/Mandate'
import UserTimeline from '../../../../../models/UserTimeline'

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

    // Generate mandate ID
    const mandateId = `mandate_${Date.now()}_${userId.slice(-6)}`
    
    // Create UPI mandate URL
    const mandateAmount = verificationAmount || amount
    const upiUrl = `upi://mandate?pa=merchant@razorpay&pn=AlertPe&tr=${mandateId}&tn=UPI%20Mandate%20Setup&am=${mandateAmount}&cu=INR&mode=15&purpose=14&orgid=159001&sign=MEQCIGKr3p7%2BKr%2F8aWyJ`
    
    // Create browser mandate URL for fallback
    const browserUrl = `https://api.razorpay.com/v1/payment_links/mandate/${mandateId}`

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
      planName: plan.name
    })

  } catch (error) {
    console.error('Error creating mandate:', error)
    return NextResponse.json({
      success: false,
      message: 'Internal server error'
    }, { status: 500 })
  }
}