import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Mandate from '../../../../../models/Mandate'
import UserTimeline from '../../../../../models/UserTimeline'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { mandateId, status } = body
    
    if (!mandateId || !status) {
      return NextResponse.json({ success: false, error: 'Missing required fields' }, { status: 400 })
    }
    
    const mandate = await Mandate.findOne({ mandateId })
    if (!mandate) {
      return NextResponse.json({ success: false, error: 'Mandate not found' }, { status: 404 })
    }
    
    mandate.status = status
    if (status === 'approved') {
      mandate.approvedAt = new Date()
    }
    mandate.updatedAt = new Date()
    await mandate.save()
    
    // Add timeline event
    if (status === 'approved') {
      const timeline = new UserTimeline({
        userId: mandate.userId,
        eventType: 'mandate_approved',
        title: 'Autopay Mandate Approved',
        description: 'Automatic payment mandate has been approved'
      })
      await timeline.save()
    }
    
    return NextResponse.json({ success: true, mandate })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to update mandate' }, { status: 500 })
  }
}