import { NextRequest, NextResponse } from 'next/server';
import connectDB from '../../../../lib/mongodb';
import Plan from '../../../../models/Plan';

export async function GET() {
  try {
    await connectDB();
    const plans = await Plan.find({}).sort({ createdAt: -1 });
    return NextResponse.json({ success: true, plans });
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch plans' }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    await connectDB();
    const body = await request.json();
    const { name, price, duration, features, isActive } = body;

    const plan = new Plan({
      name,
      price,
      duration,
      features,
      isActive: isActive !== undefined ? isActive : true
    });

    await plan.save();
    return NextResponse.json({ success: true, plan });
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to create plan' }, { status: 500 });
  }
}