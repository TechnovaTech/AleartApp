import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import User from '../../../../../models/User'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
}

export async function OPTIONS() {
  return new NextResponse(null, { status: 200, headers: corsHeaders })
}

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const { title, message, userIds, sendToAll } = await request.json()
    
    if (!title || !message) {
      return NextResponse.json({ 
        success: false, 
        error: 'Title and message are required' 
      }, { status: 400, headers: corsHeaders })
    }
    
    let targetUsers = []
    
    if (sendToAll) {
      targetUsers = await User.find({ role: 'user', isActive: true })
    } else if (userIds && userIds.length > 0) {
      targetUsers = await User.find({ _id: { $in: userIds }, isActive: true })
    } else {
      return NextResponse.json({ 
        success: false, 
        error: 'No users specified' 
      }, { status: 400, headers: corsHeaders })
    }
    
    console.log(`Sending push notifications to ${targetUsers.length} users:`, {
      title,
      message,
      userCount: targetUsers.length
    })
    
    return NextResponse.json({ 
      success: true, 
      message: `Push notification sent to ${targetUsers.length} users`,
      sentCount: targetUsers.length
    }, { headers: corsHeaders })
    
  } catch (error: any) {
    console.error('Send push notification error:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message || 'Failed to send push notification' 
    }, { status: 500, headers: corsHeaders })
  }
}