import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import User from '../../../../../models/User'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
}

export async function OPTIONS() {
  return new NextResponse(null, { status: 200, headers: corsHeaders })
}

export async function PATCH(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    await dbConnect()
    
    const { username, mobile, isActive } = await request.json()
    
    const updateData: any = {}
    if (username !== undefined) updateData.username = username
    if (mobile !== undefined) updateData.mobile = mobile
    if (isActive !== undefined) updateData.isActive = isActive
    
    const user = await User.findByIdAndUpdate(
      params.id,
      updateData,
      { new: true, select: '-password' }
    )
    
    if (!user) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404, headers: corsHeaders }
      )
    }
    
    return NextResponse.json({
      success: true,
      user: user
    }, { headers: corsHeaders })
    
  } catch (error) {
    console.error('Update user error:', error)
    return NextResponse.json(
      { error: 'Failed to update user' },
      { status: 500, headers: corsHeaders }
    )
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    await dbConnect()
    
    const user = await User.findByIdAndDelete(params.id)
    
    if (!user) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404, headers: corsHeaders }
      )
    }
    
    return NextResponse.json({
      success: true,
      message: 'User deleted successfully'
    }, { headers: corsHeaders })
    
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to delete user' },
      { status: 500, headers: corsHeaders }
    )
  }
}