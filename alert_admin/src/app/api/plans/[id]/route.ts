import { NextRequest, NextResponse } from 'next/server';
import connectDB from '../../../../../lib/mongodb';
import Plan from '../../../../../models/Plan';

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const body = await request.json();
    const { name, price, duration, features, isActive } = body;

    const plan = await Plan.findByIdAndUpdate(
      params.id,
      { name, price, duration, features, isActive, updatedAt: new Date() },
      { new: true }
    );

    if (!plan) {
      return NextResponse.json({ success: false, error: 'Plan not found' }, { status: 404 });
    }

    return NextResponse.json({ success: true, plan });
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to update plan' }, { status: 500 });
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const plan = await Plan.findByIdAndDelete(params.id);

    if (!plan) {
      return NextResponse.json({ success: false, error: 'Plan not found' }, { status: 404 });
    }

    return NextResponse.json({ success: true, message: 'Plan deleted successfully' });
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to delete plan' }, { status: 500 });
  }
}