import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../lib/mongodb'
import Payment from '../../../../models/Payment'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { userId, amount, paymentApp, upiId, transactionId, notificationText } = body
    
    if (!userId || !amount || !paymentApp) {
      return NextResponse.json({ success: false, error: 'Missing required fields' }, { status: 400 })
    }
    
    const finalTransactionId = transactionId || `TXN${Date.now()}`
    
    // Skip if no valid UPI ID
    if (!upiId || upiId === 'unknown@upi' || !upiId.includes('@')) {
      return NextResponse.json({ success: false, error: 'Invalid UPI ID' }, { status: 400 })
    }
    
    // Check for duplicate based on UPI ID + amount + time
    const existingPayment = await Payment.findOne({ 
      $or: [
        { transactionId: finalTransactionId },
        { 
          upiId: upiId,
          amount: amount,
          timestamp: { 
            $gte: new Date(Date.now() - 300000), // Within last 5 minutes
            $lte: new Date(Date.now() + 300000)  // Within next 5 minutes
          }
        }
      ]
    })
    if (existingPayment) {
      return NextResponse.json({ success: false, error: 'Duplicate payment detected' }, { status: 400 })
    }
    
    const now = new Date()
    const payment = new Payment({
      userId,
      amount,
      paymentApp,
      upiId: upiId || 'unknown@upi',
      transactionId: finalTransactionId,
      notificationText: notificationText || '',
      date: now.toDateString(),
      time: now.toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' })
    })
    
    await payment.save()
    
    return NextResponse.json({ success: true, payment })
  } catch (error) {
    console.error('Payment save error:', error)
    return NextResponse.json({ success: false, error: 'Failed to save payment' }, { status: 500 })
  }
}

export async function GET(request: NextRequest) {
  try {
    await dbConnect()
    
    const { searchParams } = new URL(request.url)
    const userId = searchParams.get('userId')
    const date = searchParams.get('date') || 'today'
    
    if (!userId) {
      return NextResponse.json({ success: false, error: 'User ID required' }, { status: 400 })
    }
    
    let dateFilter = {}
    if (date === 'today') {
      const today = new Date()
      const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate())
      const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1)
      dateFilter = { timestamp: { $gte: startOfDay, $lt: endOfDay } }
    } else if (date === 'all') {
      dateFilter = {} // No date filter, get all payments
    }
    
    const payments = await Payment.find({ userId, ...dateFilter })
      .sort({ timestamp: -1 })
      .limit(100)
    
    return NextResponse.json({ success: true, payments })
  } catch (error) {
    console.error('Payment fetch error:', error)
    return NextResponse.json({ success: false, error: 'Failed to fetch payments' }, { status: 500 })
  }
}