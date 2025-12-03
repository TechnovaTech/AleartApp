import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Mandate from '../../../../../models/Mandate'
import User from '../../../../../models/User'
import Subscription from '../../../../../models/Subscription'

export async function GET() {
  try {
    await dbConnect()
    
    const mandates = await Mandate.find().sort({ createdAt: -1 })
    
    // Populate user and subscription data
    const mandatesWithDetails = await Promise.all(
      mandates.map(async (mandate) => {
        const user = await User.findById(mandate.userId)
        const subscription = await Subscription.findOne({ mandateId: mandate.mandateId })
        
        return {
          ...mandate.toObject(),
          user: user ? {
            username: user.username,
            email: user.email
          } : null,
          subscriptionId: subscription?._id || null
        }
      })
    )
    
    return NextResponse.json({ success: true, mandates: mandatesWithDetails })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch mandates' }, { status: 500 })
  }
}