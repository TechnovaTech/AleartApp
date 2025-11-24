import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import User from '../../../../../models/User'
import bcrypt from 'bcryptjs'

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
    
    const { username, email, password, mobile } = await request.json()
    console.log('Registration data:', { username, email, mobile })
    
    if (!username || !email || !password || !mobile) {
      return NextResponse.json(
        { error: 'Username, email, password and mobile are required' },
        { status: 400, headers: corsHeaders }
      )
    }
    
    const existingUser = await User.findOne({ 
      $or: [{ email }, { username }] 
    })
    
    if (existingUser) {
      return NextResponse.json(
        { error: 'User already exists' },
        { status: 409, headers: corsHeaders }
      )
    }
    
    const hashedPassword = await bcrypt.hash(password, 12)
    
    const user = new User({
      username,
      email,
      password: hashedPassword,
      mobile,
      name: username,
      role: 'user'
    })
    
    console.log('User before save:', user)
    await user.save()
    console.log('User after save:', user)
    
    return NextResponse.json({
      success: true,
      message: 'User registered successfully',
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        mobile: user.mobile,
        name: user.name
      }
    }, { headers: corsHeaders })
    
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500, headers: corsHeaders }
    )
  }
}