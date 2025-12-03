import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../lib/mongodb'
import Plan from '../../../../models/Plan'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
}

export async function OPTIONS() {
  return new NextResponse(null, { status: 200, headers: corsHeaders })
}

export async function GET() {
  try {
    await dbConnect()
    
    // Try to get plans from database
    let plans = await Plan.find({ isActive: true }).sort({ price: 1 })
    
    // If no plans exist, create default ones
    if (!plans || plans.length === 0) {
      const defaultPlans = [
        {
          name: 'Basic Plan',
          price: 99,
          duration: 'monthly',
          features: ['SMS monitoring', 'Basic reports', 'Email support'],
          isActive: true
        },
        {
          name: 'Premium Plan',
          price: 199,
          duration: 'monthly', 
          features: ['Unlimited SMS monitoring', 'Advanced analytics', 'PDF reports', 'Priority support', 'No ads'],
          isActive: true
        },
        {
          name: 'Pro Plan',
          price: 299,
          duration: 'monthly',
          features: ['Everything in Premium', 'API access', 'Custom integrations', '24/7 support'],
          isActive: true
        }
      ]
      
      plans = await Plan.insertMany(defaultPlans)
    }
    
    return NextResponse.json({ 
      success: true, 
      plans: plans 
    }, { headers: corsHeaders })
    
  } catch (error: any) {
    console.error('Plans fetch error:', error)
    
    // Return default plans if database fails
    const fallbackPlans = [
      {
        _id: 'basic_plan',
        name: 'Basic Plan',
        price: 99,
        duration: 'monthly',
        features: ['SMS monitoring', 'Basic reports', 'Email support']
      },
      {
        _id: 'premium_plan',
        name: 'Premium Plan', 
        price: 199,
        duration: 'monthly',
        features: ['Unlimited SMS monitoring', 'Advanced analytics', 'PDF reports', 'Priority support', 'No ads']
      }
    ]
    
    return NextResponse.json({ 
      success: true, 
      plans: fallbackPlans 
    }, { headers: corsHeaders })
  }
}