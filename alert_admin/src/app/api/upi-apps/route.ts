import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../lib/mongodb'
import UpiAppConfig from '../../../../models/UpiAppConfig'

export async function GET() {
  try {
    await dbConnect()
    
    let apps = await UpiAppConfig.find({ isActive: true }).sort({ priority: -1, name: 1 })
    
    // Initialize default apps if none exist
    if (apps.length === 0) {
      const defaultApps = [
        { name: 'PhonePe', packageName: 'com.phonepe.app', icon: 'assets/images/payment_icons/icons8-phone-pe.png', priority: 5 },
        { name: 'Google Pay', packageName: 'com.google.android.apps.nfc.payment', icon: 'assets/images/payment_icons/icons8-google-pay.png', priority: 4 },
        { name: 'Paytm', packageName: 'net.one97.paytm', icon: 'assets/images/payment_icons/icons8-paytm.png', priority: 3 },
        { name: 'BHIM', packageName: 'in.org.npci.upiapp', icon: 'assets/images/payment_icons/icons8-bhim.png', priority: 2 },
        { name: 'Amazon Pay', packageName: 'in.amazon.mShop.android.shopping', icon: 'assets/images/payment_icons/amazon-pay-svgrepo-com.png', priority: 1 }
      ]
      
      apps = await UpiAppConfig.insertMany(defaultApps)
    }
    
    return NextResponse.json({ success: true, apps })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch UPI apps' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { name, packageName, icon, priority, isActive } = body
    
    if (!name || !packageName || !icon) {
      return NextResponse.json({ success: false, error: 'Missing required fields' }, { status: 400 })
    }
    
    const app = new UpiAppConfig({
      name,
      packageName,
      icon,
      priority: priority || 0,
      isActive: isActive !== undefined ? isActive : true
    })
    
    await app.save()
    
    return NextResponse.json({ success: true, app })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to create UPI app config' }, { status: 500 })
  }
}