import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import OTP from '../../../../../models/OTP'

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
    
    const { email, otp } = await request.json()
    
    if (!email || !otp) {
      return NextResponse.json(
        { error: 'Email and OTP are required' },
        { status: 400, headers: corsHeaders }
      )
    }
    
    // Find OTP record in database
    const otpRecord = await OTP.findOne({ email, otp })
    
    if (!otpRecord) {
      return NextResponse.json(
        { error: 'Incorrect OTP' },
        { status: 400, headers: corsHeaders }
      )
    }
    
    // Check if OTP is expired (5 minutes)
    if (new Date() > otpRecord.expiresAt) {
      await OTP.deleteOne({ _id: otpRecord._id })
      return NextResponse.json(
        { error: 'OTP has expired' },
        { status: 400, headers: corsHeaders }
      )
    }
    
    // OTP is valid, delete it from database
    await OTP.deleteOne({ _id: otpRecord._id })
    
    return NextResponse.json({
      success: true,
      message: 'OTP verified successfully'
    }, { headers: corsHeaders })
    
  } catch (error) {
    console.error('Verify OTP error:', error)
    return NextResponse.json(
      { error: 'Failed to verify OTP' },
      { status: 500, headers: corsHeaders }
    )
  }
}