package com.example.alert_new

import android.app.Notification
import android.content.Intent
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

class NotificationListenerService : NotificationListenerService() {
    
    private val upiPackages = setOf(
        "com.phonepe.app",
        "com.google.android.apps.nfc.payment", 
        "net.one97.paytm",
        "in.org.npci.upiapp",
        "in.amazon.mShop.android.shopping"
    )
    
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        
        sbn?.let { notification ->
            if (upiPackages.contains(notification.packageName)) {
                processUpiNotification(notification)
            }
        }
    }
    
    private fun processUpiNotification(sbn: StatusBarNotification) {
        val extras = sbn.notification.extras
        val title = extras.getString(Notification.EXTRA_TITLE) ?: ""
        val text = extras.getString(Notification.EXTRA_TEXT) ?: ""
        val bigText = extras.getString(Notification.EXTRA_BIG_TEXT) ?: text
        
        // Send to Flutter
        val data = mapOf(
            "packageName" to sbn.packageName,
            "title" to title,
            "text" to bigText,
            "timestamp" to sbn.postTime
        )
        
        sendToFlutter(data)
    }
    
    private fun sendToFlutter(data: Map<String, Any>) {
        try {
            // Send via broadcast or method channel
            val intent = Intent("UPI_NOTIFICATION_RECEIVED")
            intent.putExtra("notification_data", data.toString())
            sendBroadcast(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}