import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Subscription from '../../../../../models/Subscription'
import Mandate from '../../../../../models/Mandate'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { userId, amount } = body
    
    if (!userId || !amount) {
      return NextResponse.json({ success: false, error: 'Missing required fields' }, { status: 400 })
    }
    
    // Generate mock IDs
    const mockSubscriptionId = `sub_mock_${Date.now()}`
    const mockMandateId = `mandate_mock_${Date.now()}`
    
    // Create mandate
    const mandate = new Mandate({
      userId,
      mandateId: mockMandateId,
      amount,
      status: 'pending',
      approvalUrl: `https://mock-razorpay.com/mandate/${mockMandateId}`
    })
    await mandate.save()
    
    // Update subscription
    const subscription = await Subscription.findOne({ userId })
    if (subscription) {
      subscription.razorpaySubscriptionId = mockSubscriptionId
      subscription.mandateId = mockMandateId
      await subscription.save()
    }
    
    return NextResponse.json({ 
      success: true, 
      subscriptionId: mockSubscriptionId,
      mandateId: mockMandateId,
      approvalUrl: mandate.approvalUrl
    })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to create mock subscription' }, { status: 500 })
  }
}