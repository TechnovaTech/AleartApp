import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import SubscriptionReminder from '../../../../../models/SubscriptionReminder'

export async function GET(request: NextRequest) {
  try {
    await dbConnect()
    
    const { searchParams } = new URL(request.url)
    const userId = searchParams.get('userId')
    
    if (!userId) {
      return NextResponse.json({ success: false, error: 'User ID required' }, { status: 400 })
    }
    
    const reminders = await SubscriptionReminder.find({ userId }).sort({ createdAt: -1 })
    
    return NextResponse.json({ success: true, reminders })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch reminders' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { userId, subscriptionId, reminderType, renewalDate } = body
    
    if (!userId || !subscriptionId || !reminderType || !renewalDate) {
      return NextResponse.json({ success: false, error: 'Missing required fields' }, { status: 400 })
    }
    
    const reminder = new SubscriptionReminder({
      userId,
      subscriptionId,
      reminderType,
      renewalDate: new Date(renewalDate)
    })
    
    await reminder.save()
    
    return NextResponse.json({ success: true, reminder })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to create reminder' }, { status: 500 })
  }
}