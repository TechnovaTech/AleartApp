import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Subscription from '../../../../../models/Subscription'
import Mandate from '../../../../../models/Mandate'

export async function GET(request: NextRequest) {
  try {
    await dbConnect()
    
    const { searchParams } = new URL(request.url)
    const userId = searchParams.get('userId')
    
    if (!userId) {
      return NextResponse.json({ success: false, error: 'User ID required' }, { status: 400 })
    }
    
    const subscription = await Subscription.findOne({ userId })
    if (!subscription) {
      return NextResponse.json({ success: false, error: 'No subscription found' }, { status: 404 })
    }
    
    const mandate = subscription.mandateId ? await Mandate.findOne({ mandateId: subscription.mandateId }) : null
    
    return NextResponse.json({ 
      success: true, 
      subscription,
      mandate: mandate || null
    })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch subscription status' }, { status: 500 })
  }
}