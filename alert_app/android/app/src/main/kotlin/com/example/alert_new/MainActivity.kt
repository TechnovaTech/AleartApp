package com.example.alert_new

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.content.Intent
import android.provider.Settings
import android.os.Build
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.content.ComponentName

class MainActivity: FlutterActivity() {
    private val CHANNEL = "payment_notifications"
    private val EVENT_CHANNEL = "payment_events"
    private val NOTIFICATION_LISTENER_CHANNEL = "notification_listener"
    private val BACKGROUND_SERVICE_CHANNEL = "background_service"
    private val RAZORPAY_CHANNEL = "razorpay_flutter"
    private val PERMISSION_REQUEST_CODE = 123
    
    companion object {
        private var eventSink: EventChannel.EventSink? = null
        
@JvmStatic
        fun sendNotificationEvent(data: Map<String, String>) {
            eventSink?.success(data)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register plugins
        flutterEngine.plugins.add(RazorpayPlugin())
        flutterEngine.plugins.add(DeviceCompatibilityPlugin())
        
        // Create notification channel with sound
        createNotificationChannel()
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermissions" -> {
                    requestBasicPermissions()
                    result.success(true)
                }
                "checkPermissions" -> {
                    result.success(checkBasicPermissions())
                }
                else -> result.notImplemented()
            }
        }
        
        // Razorpay UPI Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RAZORPAY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchUpiIntent" -> {
                    val url = call.argument<String>("url")
                    val specificApp = call.argument<String>("specificApp")
                    if (url != null) {
                        result.success(launchUpiIntent(url, specificApp))
                    } else {
                        result.success(false)
                    }
                }
                "launchPaymentUrl" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        result.success(launchPaymentUrl(url))
                    } else {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
        
        // Notification Listener Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_LISTENER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                "isPermissionGranted" -> {
                    result.success(isNotificationListenerEnabled())
                }
                else -> result.notImplemented()
            }
        }
        
        // Background Service Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BACKGROUND_SERVICE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startBackgroundService" -> {
                    startBackgroundService()
                    result.success(true)
                }
                "stopBackgroundService" -> {
                    stopBackgroundService()
                    result.success(true)
                }
                "requestAutoStart" -> {
                    requestAutoStartPermission()
                    result.success(true)
                }
                "requestBatteryOptimization" -> {
                    requestBatteryOptimizationExemption()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }
    
    private fun requestBasicPermissions() {
        val permissions = arrayOf(
            Manifest.permission.READ_SMS,
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.POST_NOTIFICATIONS,
            Manifest.permission.VIBRATE,
            Manifest.permission.WAKE_LOCK
        )
        ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE)
    }
    
    private fun checkBasicPermissions(): Boolean {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED &&
               ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "payment_alerts"
            val channelName = "Payment Alerts"
            val channelDescription = "Notifications for UPI payment alerts"
            val importance = NotificationManager.IMPORTANCE_HIGH
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                enableLights(true)
                enableVibration(true)
                setShowBadge(true)
                
                // Set custom sound
                val soundUri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
                setSound(soundUri, audioAttributes)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
        }
    }
    
    private fun isNotificationListenerEnabled(): Boolean {
        val packageName = packageName
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return flat?.contains(packageName) == true
    }
    
    private fun startBackgroundService() {
        val serviceIntent = Intent(this, BackgroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }
    
    private fun stopBackgroundService() {
        val serviceIntent = Intent(this, BackgroundService::class.java)
        stopService(serviceIntent)
    }
    
    private fun requestAutoStartPermission() {
        try {
            // Try manufacturer-specific auto-start settings
            val manufacturer = Build.MANUFACTURER.lowercase()
            val intent = when {
                manufacturer.contains("xiaomi") -> {
                    Intent().apply {
                        component = ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")
                    }
                }
                manufacturer.contains("oppo") -> {
                    Intent().apply {
                        component = ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity")
                    }
                }
                manufacturer.contains("vivo") -> {
                    Intent().apply {
                        component = ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")
                    }
                }
                else -> {
                    Intent().apply {
                        action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                        data = Uri.fromParts("package", packageName, null)
                    }
                }
            }
            startActivity(intent)
        } catch (e: Exception) {
            // Fallback to app settings
            try {
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                intent.data = Uri.fromParts("package", packageName, null)
                startActivity(intent)
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }
    }
    
    private fun requestBatteryOptimizationExemption() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                intent.data = Uri.parse("package:$packageName")
                startActivity(intent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
    
    private fun launchUpiIntent(upiUrl: String, specificApp: String?): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(upiUrl))
            
            // If specific app is provided, try to launch it
            if (specificApp != null) {
                intent.setPackage(specificApp)
                
                // Check if the app is installed
                val packageManager = packageManager
                if (intent.resolveActivity(packageManager) != null) {
                    startActivity(intent)
                    return true
                }
            }
            
            // If specific app failed or not provided, show system app chooser
            val genericIntent = Intent(Intent.ACTION_VIEW, Uri.parse(upiUrl))
            genericIntent.addCategory(Intent.CATEGORY_BROWSABLE)
            
            // Get list of apps that can handle UPI
            val resolveInfos = packageManager.queryIntentActivities(genericIntent, 0)
            
            if (resolveInfos.isNotEmpty()) {
                // If multiple apps available, show chooser
                if (resolveInfos.size > 1) {
                    val chooser = Intent.createChooser(genericIntent, "Choose UPI App")
                    startActivity(chooser)
                } else {
                    // If only one app, open directly
                    startActivity(genericIntent)
                }
                true
            } else {
                false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
    
    private fun launchPaymentUrl(paymentUrl: String): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(paymentUrl))
            intent.addCategory(Intent.CATEGORY_BROWSABLE)
            
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
