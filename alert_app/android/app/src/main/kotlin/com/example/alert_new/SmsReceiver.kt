package com.example.alert_new

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsMessage
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "SmsReceiver"
        var eventSink: io.flutter.plugin.common.EventChannel.EventSink? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.provider.Telephony.SMS_RECEIVED") {
            val bundle = intent.extras
            if (bundle != null) {
                val pdus = bundle.get("pdus") as Array<*>?
                if (pdus != null) {
                    for (pdu in pdus) {
                        val sms = SmsMessage.createFromPdu(pdu as ByteArray)
                        val sender = sms.originatingAddress
                        val message = sms.messageBody
                        
                        Log.d(TAG, "SMS from: $sender, Message: $message")
                        
                        // Check if SMS is from payment apps
                        if (isPaymentSms(sender, message)) {
                            val paymentInfo = extractPaymentFromSms(sender, message)
                            if (paymentInfo != null) {
                                eventSink?.success(paymentInfo)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private fun isPaymentSms(sender: String?, message: String): Boolean {
        if (sender == null) return false
        
        val paymentSenders = listOf(
            "GPAY", "GOOGLEPAY", "PHONEPE", "PAYTM", "BHIMUPI", 
            "AMAZONPAY", "MOBIKWIK", "FREECHARGE", "AXISBANK", 
            "SBIUPI", "ICICIBANK", "HDFCBANK"
        )
        
        val upperSender = sender.uppercase()
        val upperMessage = message.uppercase()
        
        return paymentSenders.any { upperSender.contains(it) } &&
               (upperMessage.contains("RECEIVED") || 
                upperMessage.contains("CREDITED") || 
                upperMessage.contains("PAYMENT") ||
                upperMessage.contains("UPI"))
    }
    
    private fun extractPaymentFromSms(sender: String?, message: String): Map<String, Any>? {
        try {
            val upperMessage = message.uppercase()
            
            // Extract amount
            val amountRegex = """RS\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)""".toRegex()
            val amountMatch = amountRegex.find(upperMessage)
            val amount = amountMatch?.let { "₹${it.groupValues[1]}" } ?: return null
            
            // Extract UPI ID or account info
            val upiRegex = """(\w+@\w+)""".toRegex()
            val upiMatch = upiRegex.find(message)
            val upiId = upiMatch?.value ?: "unknown@upi"
            
            // Determine app name from sender
            val appName = when {
                sender?.contains("GPAY", true) == true -> "Google Pay"
                sender?.contains("PHONEPE", true) == true -> "PhonePe"
                sender?.contains("PAYTM", true) == true -> "Paytm"
                sender?.contains("BHIM", true) == true -> "BHIM UPI"
                sender?.contains("AMAZON", true) == true -> "Amazon Pay"
                else -> "UPI App"
            }
            
            return mapOf(
                "amount" to amount,
                "appName" to appName,
                "upiId" to upiId,
                "text" to message,
                "sender" to (sender ?: ""),
                "timestamp" to System.currentTimeMillis()
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error extracting payment from SMS", e)
            return null
        }
    }
}