package io.flutter.plugins.alert_app;

import android.app.Notification;
import android.content.Intent;
import android.os.Bundle;
import android.service.notification.StatusBarNotification;
import android.util.Log;
import java.util.HashMap;
import java.util.Map;
import com.example.alert_new.MainActivity;

public class NotificationListenerService extends android.service.notification.NotificationListenerService {
    private static final String TAG = "NotificationListener";
    
    private static final String[] UPI_APPS = {
        "com.google.android.apps.nbu.paisa.user", // Google Pay
        "com.phonepe.app",                        // PhonePe
        "net.one97.paytm",                       // Paytm
        "in.org.npci.upiapp",                    // BHIM
        "com.amazon.mShop.android.shopping",     // Amazon Pay
        "com.mobikwik_new",                      // MobiKwik
        "com.freecharge.android"                 // FreeCharge
    };

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "NotificationListenerService created");
        
        Intent serviceIntent = new Intent(this, NotificationForegroundService.class);
        startForegroundService(serviceIntent);
    }

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        try {
            String packageName = sbn.getPackageName();
            
            if (!isUpiApp(packageName)) {
                return;
            }

            Notification notification = sbn.getNotification();
            Bundle extras = notification.extras;
            
            if (extras != null) {
                String title = extras.getString(Notification.EXTRA_TITLE, "");
                String text = extras.getString(Notification.EXTRA_TEXT, "");
                String bigText = extras.getString(Notification.EXTRA_BIG_TEXT, "");
                
                String notificationText = bigText != null && !bigText.isEmpty() ? bigText : text;
                
                Log.d(TAG, "UPI Notification - Package: " + packageName + ", Title: " + title + ", Text: " + notificationText);
                
                sendNotificationToFlutter(packageName, title, notificationText);
            }
        } catch (Exception e) {
            Log.e(TAG, "Error processing notification", e);
        }
    }

    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {
        // Handle notification removal if needed
    }

    private boolean isUpiApp(String packageName) {
        for (String upiApp : UPI_APPS) {
            if (upiApp.equals(packageName)) {
                return true;
            }
        }
        return false;
    }

    private void sendNotificationToFlutter(String packageName, String title, String text) {
        Map<String, String> data = new HashMap<>();
        data.put("packageName", packageName);
        data.put("title", title);
        data.put("text", text);
        data.put("timestamp", String.valueOf(System.currentTimeMillis()));
        
        // Send via static method in MainActivity
        try {
            MainActivity.sendNotificationEvent(data);
        } catch (Exception e) {
            Log.e(TAG, "Error sending notification to Flutter", e);
        }
    }
}