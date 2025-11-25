import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Plan from '../../../../../models/Plan'

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    await dbConnect()
    const { name, monthlyPrice, yearlyPrice, features, isActive } = await request.json()
    
    const plan = await Plan.findByIdAndUpdate(
      params.id,
      { name, monthlyPrice, yearlyPrice, features, isActive },
      { new: true }
    )
    
    if (!plan) {
      return NextResponse.json({ error: 'Plan not found' }, { status: 404 })
    }
    
    return NextResponse.json({ success: true, plan })
  } catch (error) {
    return NextResponse.json({ error: 'Failed to update plan' }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    await dbConnect()
    const plan = await Plan.findByIdAndDelete(params.id)
    
    if (!plan) {
      return NextResponse.json({ error: 'Plan not found' }, { status: 404 })
    }
    
    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json({ error: 'Failed to delete plan' }, { status: 500 })
  }
}