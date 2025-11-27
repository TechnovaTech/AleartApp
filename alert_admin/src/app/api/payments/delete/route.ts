import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Payment from '../../../../../models/Payment'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { paymentIds } = body
    
    console.log('Delete request:', { paymentIds })
    
    if (!paymentIds || !Array.isArray(paymentIds)) {
      return NextResponse.json({ success: false, error: 'Payment IDs required' }, { status: 400 })
    }
    
    // Convert string IDs to ObjectIds and delete payments
    const mongoose = require('mongoose')
    const objectIds = paymentIds.map(id => new mongoose.Types.ObjectId(id))
    
    const result = await Payment.deleteMany({ _id: { $in: objectIds } })
    
    console.log('Delete result:', result)
    
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