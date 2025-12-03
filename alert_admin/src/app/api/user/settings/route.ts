import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import User from '../../../../../models/User'

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { userId, language } = body
    
    if (!userId) {
      return NextResponse.json({ success: false, error: 'User ID required' }, { status: 400 })
    }
    
    const user = await User.findById(userId)
    if (!user) {
      return NextResponse.json({ success: false, error: 'User not found' }, { status: 404 })
    }
    
    // Initialize userSettings if it doesn't exist
    if (!user.userSettings) {
      user.userSettings = {}
    }
    
    if (language) {
      user.userSettings.language = language
    }
    
    user.markModified('userSettings')
    await user.save()
    
    return NextResponse.json({ success: true, userSettings: user.userSettings })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to update user settings' }, { status: 500 })
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
    
    const user = await User.findById(userId)
    if (!user) {
      return NextResponse.json({ success: false, error: 'User not found' }, { status: 404 })
    }
    
    return NextResponse.json({ success: true, userSettings: user.userSettings || {} })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch user settings' }, { status: 500 })
  }
}