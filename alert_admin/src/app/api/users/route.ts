import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../lib/mongodb'
import User from '../../../../models/User'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
}

export async function OPTIONS() {
  return new NextResponse(null, { status: 200, headers: corsHeaders })
}

export async function GET() {
  try {
    await dbConnect()
    
    const users = await User.find({})
      .select('-password')
      .sort({ createdAt: -1 })
    
    return NextResponse.json({
      success: true,
      users: users
    }, { headers: corsHeaders })
    
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to fetch users' },
      { status: 500, headers: corsHeaders }
    )
  }
}