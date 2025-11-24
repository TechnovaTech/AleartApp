import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../lib/mongodb'
import User from '../../../../models/User'

export async function GET() {
  try {
    await dbConnect()
    
    const users = await User.find({})
      .select('-password')
      .sort({ createdAt: -1 })
    
    return NextResponse.json({
      success: true,
      users: users
    })
    
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to fetch users' },
      { status: 500 }
    )
  }
}