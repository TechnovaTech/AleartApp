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
            
            if (upiIntent.resolveActivity(context.packageManager) != null) {
                context.startActivity(upiIntent)
                result.success(true)
            } else {
                // Fallback to generic intent
                launchUpiIntent(url, result)
            }
        } catch (e: Exception) {
            // Fallback to generic intent
            launchUpiIntent(url, result)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}