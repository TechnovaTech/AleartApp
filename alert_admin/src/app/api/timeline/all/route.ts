import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import UserTimeline from '../../../../../models/UserTimeline'
import User from '../../../../../models/User'

export async function GET() {
  try {
    await dbConnect()
    
    const events = await UserTimeline.find().sort({ timestamp: -1 }).limit(200)
    
    // Populate user data
    const eventsWithUsers = await Promise.all(
      events.map(async (event) => {
        const user = await User.findById(event.userId)
        return {
          ...event.toObject(),
          user: user ? {
            username: user.username,
            email: user.email
          } : null
        }
      })
    )
    
    return NextResponse.json({ success: true, events: eventsWithUsers })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch timeline events' }, { status: 500 })
  }
}