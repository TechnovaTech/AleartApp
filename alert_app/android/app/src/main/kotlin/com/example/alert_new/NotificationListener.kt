package com.example.alert_new

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class NotificationListener : NotificationListenerService() {
    
    companion object {
        var eventSink: EventChannel.EventSink? = null
        private const val TAG = "NotificationListener"
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        
        sbn?.let { notification ->
            val packageName = notification.packageName
            val extras = notification.notification.extras
            
            // Check if it's from payment apps
            if (isPaymentApp(packageName)) {
                val title = extras.getString("android.title") ?: ""
                val text = extras.getString("android.text") ?: ""
                val bigText = extras.getString("android.bigText") ?: text
                
                Log.d(TAG, "Payment notification: $packageName - $title - $bigText")
                
                // Extract payment info
                val paymentInfo = extractPaymentInfo(packageName, title, bigText)
                
                if (paymentInfo != null) {
                    // Send to Flutter
                    eventSink?.success(paymentInfo)
                }
            }
        }
    }

    private fun isPaymentApp(packageName: String): Boolean {
        val paymentApps = listOf(
            "com.google.android.apps.nbu.paisa.user", // Google Pay
            "com.phonepe.app", // PhonePe
            "net.one97.paytm", // Paytm
            "in.org.npci.upiapp", // BHIM UPI
            "in.amazon.mShop.android.shopping", // Amazon Pay
            "com.mobikwik_new", // MobiKwik
            "com.freecharge.android", // FreeCharge
            "com.axis.mobile", // Axis Mobile
            "com.sbi.upi", // SBI Pay
            "com.icicibank.pockets" // ICICI Pockets
        )
        return paymentApps.contains(packageName)
    }

    private fun extractPaymentInfo(packageName: String, title: String, text: String): Map<String, Any>? {
        try {
            val content = "$title $text".lowercase()
            
            // Extract amount using regex
            val amountRegex = """₹\s*(\d+(?:,\d+)*(?:\.\d{2})?)""".toRegex()
            val amountMatch = amountRegex.find(content)
            val amount = amountMatch?.value ?: return null
            
            // Extract UPI ID
            val upiRegex = """(\w+@\w+)""".toRegex()
            val upiMatch = upiRegex.find(content)
            val upiId = upiMatch?.value ?: "unknown@upi"
            
            // Get app name
            val appName = when (packageName) {
                "com.google.android.apps.nbu.paisa.user" -> "Google Pay"
                "com.phonepe.app" -> "PhonePe"
                "net.one97.paytm" -> "Paytm"
                "in.org.npci.upiapp" -> "BHIM UPI"
                "in.amazon.mShop.android.shopping" -> "Amazon Pay"
                else -> "UPI App"
            }
            
            // Check if it's a credit/received notification
            val isCredit = content.contains("received") || 
                          content.contains("credited") || 
                          content.contains("payment received") ||
                          content.contains("money received") ||
                          content.contains("upi credit")
            
            if (!isCredit) return null
            
            return mapOf(
                "amount" to amount,
                "appName" to appName,
                "upiId" to upiId,
                "title" to title,
                "text" to text,
                "packageName" to packageName,
                "timestamp" to System.currentTimeMillis()
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error extracting payment info", e)
            return null
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
    }
}