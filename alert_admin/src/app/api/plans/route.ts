import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../lib/mongodb'
import Plan from '../../../../models/Plan'

export async function GET() {
  try {
    await dbConnect()
    const plans = await Plan.find({}).sort({ createdAt: -1 })
    return NextResponse.json({ success: true, plans })
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch plans' }, { status: 500 })
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
    return NextResponse.json({ success: true, plan })
  } catch (error) {
    return NextResponse.json({ error: 'Failed to create plan' }, { status: 500 })
  }
}