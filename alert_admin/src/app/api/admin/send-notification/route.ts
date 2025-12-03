import { NextRequest, NextResponse } from 'next/server';
import connectDB from '../../../../../lib/mongodb';
import User from '../../../../../models/User';

export async function POST(request: NextRequest) {
  try {
    await connectDB();
    const body = await request.json();
    const { userId, title, body: messageBody, sendToAll } = body;

    if (sendToAll) {
      // Send to all users
      const users = await User.find({ isActive: true, fcmToken: { $exists: true } });
      
      console.log(`Sending notification to ${users.length} users:`, { title, messageBody });

      return NextResponse.json({ 
        success: true, 
        message: `Notification sent to ${users.length} users`,
        sentCount: users.length
      });
    } else {
      // Send to specific user
      const user = await User.findById(userId);
      if (!user) {
        return NextResponse.json({ 
          success: false, 
          error: 'User not found' 
        }, { status: 404 });
      }

      console.log(`Sending notification to user ${userId}:`, { title, messageBody });

      return NextResponse.json({ 
        success: true, 
        message: 'Notification sent successfully' 
      });
    }
  } catch (error) {
    console.error('Error sending notification:', error);
    return NextResponse.json({ 
      success: false, 
      error: 'Failed to send notification' 
    }, { status: 500 });
  }
}