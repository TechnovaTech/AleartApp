import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Payment from '../../../../../models/Payment'
import mongoose from 'mongoose'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { paymentIds } = body
    
    if (!paymentIds || !Array.isArray(paymentIds)) {
      return NextResponse.json({ success: false, error: 'Payment IDs required' }, { status: 400 })
    }
    
    // Validate and convert IDs
    const validIds = paymentIds.filter(id => mongoose.Types.ObjectId.isValid(id))
    
    if (validIds.length === 0) {
      return NextResponse.json({ success: false, error: 'No valid payment IDs provided' }, { status: 400 })
    }
    
    // Delete payments by ID
    const result = await Payment.deleteMany({ _id: { $in: validIds } })
    
    return NextResponse.json({ 
      success: true, 
      deletedCount: result.deletedCount,
      message: `${result.deletedCount} payments deleted successfully`
    })
  } catch (error) {
    console.error('Payment delete error:', error)
    return NextResponse.json({ success: false, error: 'Failed to delete payments' }, { status: 500 })
  }
}