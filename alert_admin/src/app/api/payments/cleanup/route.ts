import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Payment from '../../../../../models/Payment'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    // Find and remove duplicate payments based on UPI ID + amount + similar timestamp
    const allPayments = await Payment.find({}).sort({ timestamp: 1 })
    const duplicatesToRemove = []
    
    for (let i = 0; i < allPayments.length; i++) {
      for (let j = i + 1; j < allPayments.length; j++) {
        const payment1 = allPayments[i]
        const payment2 = allPayments[j]
        
        // Check if payments are duplicates (same user, amount, and within 2 minutes)
        if (payment1.userId === payment2.userId && 
            payment1.amount === payment2.amount &&
            Math.abs(new Date(payment1.timestamp).getTime() - new Date(payment2.timestamp).getTime()) < 120000) {
          duplicatesToRemove.push(payment2._id)
        }
      }
    }
    
    // Remove duplicates
    if (duplicatesToRemove.length > 0) {
      await Payment.deleteMany({ _id: { $in: duplicatesToRemove } })
    }
    
    return NextResponse.json({ 
      success: true, 
      message: `Removed ${duplicatesToRemove.length} duplicate payments` 
    })
  } catch (error) {
    console.error('Cleanup error:', error)
    return NextResponse.json({ success: false, error: 'Failed to cleanup duplicates' }, { status: 500 })
  }
}