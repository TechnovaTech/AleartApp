import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Payment from '../../../../../models/Payment'

export async function GET(request: NextRequest) {
  try {
    await dbConnect()
    
    // Get all payments sorted by timestamp (newest first)
    const payments = await Payment.find({})
      .sort({ timestamp: -1 })
      .limit(100) // Limit to last 100 payments
    
    console.log('Fetched payments:', payments.length)
    return NextResponse.json({ success: true, payments })
  } catch (error) {
    console.error('Payment fetch error:', error)
    return NextResponse.json({ success: false, error: 'Failed to fetch payments' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    // Create test payment
    const testPayment = new Payment({
      userId: '507f1f77bcf86cd799439011',
      amount: '2500',
      paymentApp: 'PhonePe',
      payerName: 'SMS Test User',
      upiId: 'smstest@ybl',
      transactionId: 'SMS' + Date.now(),
      notificationText: 'Test SMS payment detected from admin panel',
      date: new Date().toDateString(),
      time: new Date().toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' })
    })
    
    await testPayment.save()
    console.log('Test payment created:', testPayment)
    
    return NextResponse.json({ success: true, message: 'Test payment created', payment: testPayment })
  } catch (error) {
    console.error('Test payment error:', error)
    return NextResponse.json({ success: false, error: 'Failed to create test payment' }, { status: 500 })
  }
}