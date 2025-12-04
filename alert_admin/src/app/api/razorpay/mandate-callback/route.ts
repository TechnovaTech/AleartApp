import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '../../../../../lib/mongodb'
import Mandate from '../../../../../models/Mandate'
import UserTimeline from '../../../../../models/UserTimeline'

export async function GET(request: NextRequest) {
  try {
    await dbConnect()
    
    const { searchParams } = new URL(request.url)
    const razorpay_payment_id = searchParams.get('razorpay_payment_id')
    const razorpay_payment_link_id = searchParams.get('razorpay_payment_link_id')
    const razorpay_payment_link_status = searchParams.get('razorpay_payment_link_status')

    console.log('Mandate callback received:', {
      razorpay_payment_id,
      razorpay_payment_link_id,
      razorpay_payment_link_status
    })

    if (razorpay_payment_link_status === 'paid' && razorpay_payment_id) {
      const mandate = await Mandate.findOne({ 
        mandateId: razorpay_payment_link_id 
      })

      if (mandate) {
        mandate.status = 'approved'
        mandate.approvedAt = new Date()
        await mandate.save()

        await UserTimeline.create({
          userId: mandate.userId,
          eventType: 'mandate_approved',
          title: 'UPI Mandate Approved',
          description: 'UPI autopay mandate approved successfully',
          metadata: {
            mandateId: mandate.mandateId,
            paymentId: razorpay_payment_id
          },
          timestamp: new Date()
        })
      }
    }

    return NextResponse.redirect(
      `${process.env.NEXT_PUBLIC_API_URL || 'https://technovatechnologies.online'}/mandate-success?status=${razorpay_payment_link_status}`
    )

  } catch (error) {
    console.error('Error processing mandate callback:', error)
    return NextResponse.redirect(
      `${process.env.NEXT_PUBLIC_API_URL || 'https://technovatechnologies.online'}/mandate-error`
    )
  }
}