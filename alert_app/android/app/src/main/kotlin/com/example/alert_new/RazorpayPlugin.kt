package com.example.alert_new

import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class RazorpayPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "razorpay_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "launchPaymentUrl" -> {
                val url = call.argument<String>("url")
                if (url != null) {
                    launchPaymentUrl(url, result)
                } else {
                    result.error("INVALID_ARGUMENT", "URL is required", null)
                }
            }
            "launchUpiIntent" -> {
                val url = call.argument<String>("url")
                val specificApp = call.argument<String>("specificApp")
                if (url != null) {
                    if (specificApp != null) {
                        launchSpecificUpiApp(url, specificApp, result)
                    } else {
                        launchUpiIntent(url, result)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "URL is required", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun launchPaymentUrl(url: String, result: Result) {
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            if (intent.resolveActivity(context.packageManager) != null) {
                context.startActivity(intent)
                result.success(true)
            } else {
                result.error("NO_APP", "No app found to handle payment URL", null)
            }
        } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Failed to launch payment URL: ${e.message}", null)
        }
    }
    
    private fun launchUpiIntent(url: String, result: Result) {
        try {
            val upiIntent = Intent(Intent.ACTION_VIEW)
            upiIntent.data = Uri.parse(url)
            upiIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            if (upiIntent.resolveActivity(context.packageManager) != null) {
                context.startActivity(upiIntent)
                result.success(true)
            } else {
                result.error("NO_APP", "No UPI app found to handle payment", null)
            }
        } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Failed to launch UPI intent: ${e.message}", null)
        }
    }

    private fun launchSpecificUpiApp(url: String, packageName: String, result: Result) {
        try {
            val upiIntent = Intent(Intent.ACTION_VIEW)
            upiIntent.data = Uri.parse(url)
            upiIntent.setPackage(packageName)
            upiIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            upiIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            
            // Check if the specific app can handle UPI
            val resolveInfo = context.packageManager.resolveActivity(upiIntent, 0)
            if (resolveInfo != null) {
                context.startActivity(upiIntent)
                result.success(true)
                return
            }
            
            // Try without package restriction
            val genericIntent = Intent(Intent.ACTION_VIEW)
            genericIntent.data = Uri.parse(url)
            genericIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            if (genericIntent.resolveActivity(context.packageManager) != null) {
                context.startActivity(genericIntent)
                result.success(true)
            } else {
                result.error("NO_APP", "No UPI app found", null)
            }
        } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Failed to launch UPI app: ${e.message}", null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}