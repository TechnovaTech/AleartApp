import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Plan from '../../../../../models/Plan'

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
      return NextResponse.json({ error: 'Plan not found' }, { status: 404, headers: corsHeaders() })
    }
    
    return NextResponse.json({ success: true, plan }, { headers: corsHeaders() })
  } catch (error) {
    return NextResponse.json({ error: 'Failed to update plan' }, { status: 500, headers: corsHeaders() })
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    await dbConnect()
    const plan = await Plan.findByIdAndDelete(params.id)
    
    if (!plan) {
      return NextResponse.json({ error: 'Plan not found' }, { status: 404, headers: corsHeaders() })
    }
    
    return NextResponse.json({ success: true }, { headers: corsHeaders() })
  } catch (error) {
    return NextResponse.json({ error: 'Failed to delete plan' }, { status: 500, headers: corsHeaders() })
  }
}