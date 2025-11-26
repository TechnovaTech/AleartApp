import { NextRequest, NextResponse } from 'next/server'
const nodemailer = require('nodemailer')
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
    const { email } = await request.json()
    
    if (!email) {
      return NextResponse.json(
        { error: 'Email is required' },
        { status: 400, headers: corsHeaders }
      )
    }
    
    await dbConnect()
    
    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString()
    
    // Delete any existing OTP for this email
    await OTP.deleteMany({ email })
    
    // Save new OTP to database
    const otpDoc = new OTP({ email, otp })
    await otpDoc.save()
    
    // Configure nodemailer
    const transporter = nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 587,
      secure: false,
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      },
      tls: {
        rejectUnauthorized: false
      }
    })
    
    // Send email
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'AleartApp - Your OTP Code',
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px;">
          <h2 style="color: #2563eb;">AleartApp Verification</h2>
          <p>Your OTP code is:</p>
          <div style="background: #f0f0f0; padding: 15px; text-align: center; font-size: 24px; font-weight: bold; color: #2563eb;">
            ${otp}
          </div>
          <p>This code will expire in 5 minutes.</p>
        </div>
      `
    })
    
    return NextResponse.json({
      success: true,
      message: 'OTP sent successfully'
    }, { headers: corsHeaders })
    
  } catch (error) {
    console.error('Send OTP error:', error)
    return NextResponse.json(
      { error: `Email sending failed: ${error instanceof Error ? error.message : 'Unknown error'}` },
      { status: 500, headers: corsHeaders }
    )
  }
}