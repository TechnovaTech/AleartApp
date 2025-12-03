# Real Razorpay UPI Autopay Integration - Implementation Guide

## 🚀 Overview

This guide covers the implementation of real Razorpay UPI Autopay integration to replace the mock system in AlertPe.

## ✅ What's Been Implemented

### Backend Changes

1. **Razorpay SDK Integration**
   - Added `razorpay: ^2.9.2` to package.json
   - Created `lib/razorpay.ts` with client configuration
   - Updated environment variables with live Razorpay credentials

2. **New API Endpoints**
   - `POST /api/razorpay/create-subscription` - Creates real Razorpay subscription
   - `POST /api/razorpay/webhook` - Handles Razorpay webhooks
   - `POST /api/razorpay/cancel-subscription` - Cancels subscriptions

3. **Database Updates**
   - Added `razorpayPlanId` field to Plan model
   - Enhanced webhook logging and event tracking

### Mobile App Changes

1. **Razorpay Service**
   - Created `lib/services/razorpay_service.dart`
   - Handles subscription creation and UPI intent launching
   - Manages subscription status and cancellation

2. **Android Integration**
   - Created `RazorpayPlugin.kt` for UPI intent handling
   - Registered plugin in MainActivity
   - Handles deep linking for UPI apps

3. **UI Updates**
   - Updated subscription screen to use real Razorpay
   - Improved error handling and user feedback

## 🔧 Setup Instructions

### 1. Install Dependencies

```bash
cd alert_admin
npm install
```

### 2. Environment Configuration

Update `.env.local` with your Razorpay credentials:
```env
RAZORPAY_KEY_ID=rzp_live_Rn6F0KvLNhV5nC
RAZORPAY_KEY_SECRET=QhKzF0GIViRtnP2Y3j4Zxb87
RAZORPAY_WEBHOOK_SECRET=your_webhook_secret_here
```

### 3. Webhook Setup

1. Login to Razorpay Dashboard
2. Go to Settings > Webhooks
3. Add webhook URL: `https://technovatechnologies.online/api/razorpay/webhook`
4. Select events:
   - `subscription.activated`
   - `subscription.charged`
   - `subscription.cancelled`
   - `subscription.completed`
   - `payment.failed`

### 4. Mobile App Build

```bash
cd alert_app
flutter pub get
flutter build apk --release
```

## 📱 UPI Autopay Flow

### 1. Subscription Creation
```dart
final response = await RazorpayService.createSubscription(
  userId: userId,
  planId: planId,
);
```

### 2. UPI Intent Launch
```dart
await RazorpayService.openCheckout(
  subscriptionId: response['subscriptionId'],
  shortUrl: response['shortUrl'],
  onSuccess: (response) => handleSuccess(response),
  onError: (error) => handleError(error),
);
```

### 3. Webhook Processing
- Razorpay sends webhooks for subscription events
- Backend processes events and updates database
- User timeline is updated with relevant events

## 🔄 Migration from Mock to Real

### Backend Migration
1. Replace all `/mock-razorpay/*` API calls with `/razorpay/*`
2. Update subscription creation logic
3. Configure webhook endpoints

### Mobile App Migration
1. Replace mock service calls with RazorpayService
2. Update UPI intent handling
3. Test with real UPI apps

## 🧪 Testing

### Test Subscription Flow
1. Create test plan in admin panel
2. Use test credentials for development
3. Test with different UPI apps (PhonePe, GPay, Paytm)
4. Verify webhook events are processed correctly

### Test Cases
- ✅ Subscription creation
- ✅ UPI app detection and priority
- ✅ Payment success handling
- ✅ Payment failure handling
- ✅ Subscription cancellation
- ✅ Webhook event processing

## 🚨 Important Notes

### Security
- Never expose Razorpay secrets in client-side code
- Verify webhook signatures for security
- Use HTTPS for all webhook endpoints

### UPI App Priority
The system detects UPI apps in this order:
1. PhonePe (`com.phonepe.app`)
2. Google Pay (`com.google.android.apps.nfc.payment`)
3. Paytm (`net.one97.paytm`)
4. Manual UPI ID entry (fallback)

### Error Handling
- Network failures are handled gracefully
- User-friendly error messages
- Automatic retry mechanisms for failed payments

## 📊 Monitoring

### Admin Dashboard
- View all subscriptions and their status
- Monitor webhook events and processing
- Track payment success/failure rates
- User subscription analytics

### Webhook Logs
- All webhook events are logged for debugging
- Failed webhook processing is tracked
- Retry mechanisms for failed webhooks

## 🔄 Next Steps

1. **Production Testing**
   - Test with live Razorpay credentials
   - Verify webhook delivery in production
   - Test with real money (small amounts)

2. **User Experience**
   - Add loading states during payment
   - Improve error messages
   - Add payment retry options

3. **Analytics**
   - Track conversion rates
   - Monitor payment failures
   - User behavior analytics

## 📞 Support

For Razorpay integration issues:
- Check Razorpay Dashboard for transaction logs
- Review webhook logs in admin panel
- Contact Razorpay support for payment gateway issues

## ✅ Completion Status

- ✅ Backend Razorpay integration
- ✅ Mobile app UPI intent handling
- ✅ Webhook processing
- ✅ Database schema updates
- ✅ Error handling and logging
- ✅ Admin panel integration

**Real UPI Autopay integration is now complete and ready for production testing!**