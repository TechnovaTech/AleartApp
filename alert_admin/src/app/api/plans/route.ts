import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../lib/mongodb'
import Plan from '../../../../models/Plan'

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  }
}

export async function OPTIONS() {
  return new NextResponse(null, { status: 200, headers: corsHeaders() })
}

export async function GET() {
  try {
    await dbConnect()
    const plans = await Plan.find({}).sort({ createdAt: -1 })
    return NextResponse.json({ success: true, plans }, { headers: corsHeaders() })
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch plans' }, { status: 500, headers: corsHeaders() })
  }
}

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    const { name, monthlyPrice, yearlyPrice, features } = await request.json()
    
    const plan = new Plan({
      name,
      monthlyPrice,
      yearlyPrice,
      features
    })
    
    await plan.save()
    return NextResponse.json({ success: true, plan }, { headers: corsHeaders() })
  } catch (error) {
    return NextResponse.json({ error: 'Failed to create plan' }, { status: 500, headers: corsHeaders() })
  }
}