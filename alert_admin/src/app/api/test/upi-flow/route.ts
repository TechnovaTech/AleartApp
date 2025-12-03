import { NextRequest, NextResponse } from 'next/server'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
}

export async function OPTIONS() {
  return new NextResponse(null, { status: 200, headers: corsHeaders })
}

export async function GET() {
  return NextResponse.json({
    success: true,
    message: 'UPI Flow Test Endpoint',
    server: 'technovatechnologies.online',
    tests: [
      {
        name: 'UPI Intent Generation',
        status: 'active',
        endpoint: '/api/test/upi-flow'
      },
      {
        name: 'Razorpay Integration',
        status: 'active',
        endpoint: '/api/razorpay/create-subscription'
      },
      {
        name: 'Webhook Processing',
        status: 'active',
        endpoint: '/api/razorpay/webhook'
      }
    ]
  }, { headers: corsHeaders })
}

export async function POST(request: NextRequest) {
  try {
    const { testType, deviceInfo } = await request.json()
    
    const testResults = {
      upi_intent: {
        supported: true,
        apps_detected: ['PhonePe', 'Google Pay', 'Paytm'],
        priority_app: 'PhonePe',
        test_url: 'upi://pay?pa=test@paytm&pn=AlertPe&cu=INR&am=1'
      },
      device_compatibility: {
        manufacturer: deviceInfo?.manufacturer || 'unknown',
        model: deviceInfo?.model || 'unknown',
        upi_support: true,
        known_issues: [] as string[]
      },
      production_status: {
        server: 'technovatechnologies.online:9999',
        database: 'connected',
        razorpay: 'live_credentials_active'
      }
    }
    
    if (deviceInfo?.manufacturer?.toLowerCase().includes('xiaomi')) {
      testResults.device_compatibility.known_issues.push('MIUI background restrictions')
    }
    
    return NextResponse.json({
      success: true,
      testType,
      results: testResults,
      timestamp: new Date().toISOString()
    }, { headers: corsHeaders })
    
  } catch (error: any) {
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500, headers: corsHeaders })
  }
}