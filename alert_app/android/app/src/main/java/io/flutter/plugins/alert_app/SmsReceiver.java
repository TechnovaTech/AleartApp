package io.flutter.plugins.alert_app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.telephony.SmsMessage;
import android.util.Log;
import java.util.HashMap;
import java.util.Map;
import com.example.alert_new.MainActivity;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import android.app.PendingIntent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;

public class SmsReceiver extends BroadcastReceiver {
    private static final String TAG = "SmsReceiver";
    
    private static final String[] UPI_KEYWORDS = {
        "credited", "received", "paid", "upi", "transaction", "₹", "rs.", "amount"
    };
    
    private static final String[] UPI_SENDERS = {
        "GOOGLEPAY", "PHONEPE", "PAYTM", "BHIMUPI", "AMAZONPAY", "MOBIKWIK", "FREECHARGE"
    };

    @Override
    public void onReceive(Context context, Intent intent) {
        if ("android.provider.Telephony.SMS_RECEIVED".equals(intent.getAction())) {
            Bundle bundle = intent.getExtras();
            if (bundle != null) {
                Object[] pdus = (Object[]) bundle.get("pdus");
                if (pdus != null) {
                    for (Object pdu : pdus) {
                        SmsMessage sms = SmsMessage.createFromPdu((byte[]) pdu);
                        String sender = sms.getDisplayOriginatingAddress();
                        String message = sms.getDisplayMessageBody();
                        
                        Log.d(TAG, "SMS from: " + sender + ", Message: " + message);
                        
                        if (isPaymentSms(sender, message)) {
                            Log.d(TAG, "Payment SMS detected");
                            sendSmsToFlutter(sender, message);
                            showNotification(context, "Payment Alert", "New UPI payment detected: " + message.substring(0, Math.min(50, message.length())) + "...");
                        }
                    }
                }
            }
        }
    }
    
    private boolean isPaymentSms(String sender, String message) {
        String senderUpper = sender.toUpperCase();
        String messageUpper = message.toUpperCase();
        
        // Check if sender is from UPI apps
        for (String upiSender : UPI_SENDERS) {
            if (senderUpper.contains(upiSender)) {
                Log.d(TAG, "UPI sender detected: " + sender);
                return true;
            }
        }
        
        // Check if message contains UPI keywords
        for (String keyword : UPI_KEYWORDS) {
            if (messageUpper.contains(keyword.toUpperCase())) {
                Log.d(TAG, "UPI keyword detected: " + keyword);
                return true;
            }
        }
        
        // Check for rupee symbol or amount patterns
        if (messageUpper.contains("₹") || messageUpper.contains("RS.") || messageUpper.contains("INR")) {
            Log.d(TAG, "Currency detected in SMS");
            return true;
        }
        
        return false;
    }
    
    private void sendSmsToFlutter(String sender, String message) {
        Map<String, String> data = new HashMap<>();
        data.put("sender", sender);
        data.put("message", message);
        data.put("text", message);
        data.put("timestamp", String.valueOf(System.currentTimeMillis()));
        
        Log.d(TAG, "Sending SMS to Flutter: " + message);
        
        try {
            MainActivity.sendNotificationEvent(data);
            Log.d(TAG, "SMS sent to Flutter successfully");
        } catch (Exception e) {
            Log.e(TAG, "Error sending SMS to Flutter", e);
        }
    }
    
    private void showNotification(Context context, String title, String message) {
        try {
            // Create intent for notification tap
            Intent intent = new Intent(context, MainActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            
            PendingIntent pendingIntent;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE);
            } else {
                pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
            }
            
            // Get default notification sound
            Uri soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
            
            // Build notification with sound
            NotificationCompat.Builder builder = new NotificationCompat.Builder(context, "payment_alerts")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle(title)
                .setContentText(message)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setSound(soundUri)
                .setVibrate(new long[]{0, 500, 1000})
                .setAutoCancel(true)
                .setContentIntent(pendingIntent);
            
            // Show notification
            NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
            if (notificationManager.areNotificationsEnabled()) {
                notificationManager.notify((int) System.currentTimeMillis(), builder.build());
                Log.d(TAG, "Notification shown with sound");
            }
        } catch (Exception e) {
            Log.e(TAG, "Error showing notification", e);
        }
    }
}