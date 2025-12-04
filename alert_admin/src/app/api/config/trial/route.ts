import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import TrialConfig from '../../../../../models/TrialConfig'

export async function GET() {
  try {
    await dbConnect()
    
    let config = await TrialConfig.findOne()
    if (!config) {
      config = new TrialConfig({
        trialDurationDays: 1,
        isTrialEnabled: true,
        trialFeatures: ['Basic UPI alerts', 'Limited reports', 'QR Code Generation']
      })
      await config.save()
    }
    
    return NextResponse.json({ success: true, config })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch trial config' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    await dbConnect()
    
    const body = await request.json()
    const { trialDurationDays, isTrialEnabled, trialFeatures } = body
    
    let config = await TrialConfig.findOne()
    if (!config) {
      config = new TrialConfig()
    }
    
    if (trialDurationDays !== undefined) config.trialDurationDays = trialDurationDays
    if (isTrialEnabled !== undefined) config.isTrialEnabled = isTrialEnabled
    if (trialFeatures !== undefined) config.trialFeatures = trialFeatures
    config.updatedAt = new Date()
    
    await config.save()
    
    return NextResponse.json({ success: true, config })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to update trial config' }, { status: 500 })
  }
}