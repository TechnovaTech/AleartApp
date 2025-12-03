import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import UserTimeline from '../../../../../models/UserTimeline'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { userId, eventType, title, description, metadata } = body
    
    if (!userId || !eventType || !title) {
      return NextResponse.json({ success: false, error: 'Missing required fields' }, { status: 400 })
    }
    
    const timeline = new UserTimeline({
      userId,
      eventType,
      title,
      description,
      metadata
    })
    
    await timeline.save()
    
    return NextResponse.json({ success: true, timeline })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to add timeline event' }, { status: 500 })
  }
}

export async function GET(request: NextRequest) {
  try {
    await dbConnect()
    
    const { searchParams } = new URL(request.url)
    const userId = searchParams.get('userId')
    
    if (!userId) {
      return NextResponse.json({ success: false, error: 'User ID required' }, { status: 400 })
    }
    
    const timeline = await UserTimeline.find({ userId }).sort({ timestamp: -1 }).limit(50)
    
    return NextResponse.json({ success: true, timeline })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch timeline' }, { status: 500 })
  }
}