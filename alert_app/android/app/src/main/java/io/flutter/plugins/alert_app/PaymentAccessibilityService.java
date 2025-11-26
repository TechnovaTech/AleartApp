package io.flutter.plugins.alert_app;

import android.accessibilityservice.AccessibilityService;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import android.util.Log;
import java.util.HashMap;
import java.util.Map;
import com.example.alert_new.MainActivity;

public class PaymentAccessibilityService extends AccessibilityService {
    private static final String TAG = "PaymentAccessibility";

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event.getEventType() == AccessibilityEvent.TYPE_NOTIFICATION_STATE_CHANGED) {
            String packageName = event.getPackageName() != null ? event.getPackageName().toString() : "";
            
            if (isUpiApp(packageName)) {
                CharSequence text = event.getText().size() > 0 ? event.getText().get(0) : "";
                Log.d(TAG, "UPI Notification: " + text + " from " + packageName);
                
                if (text != null && containsPaymentKeywords(text.toString())) {
                    sendNotificationToFlutter(packageName, text.toString());
                }
            }
        }
    }

    @Override
    public void onInterrupt() {
        Log.d(TAG, "Accessibility service interrupted");
    }

    private boolean isUpiApp(String packageName) {
        return packageName.equals("com.google.android.apps.nbu.paisa.user") ||
               packageName.equals("com.phonepe.app") ||
               packageName.equals("net.one97.paytm") ||
               packageName.equals("in.org.npci.upiapp") ||
               packageName.equals("com.amazon.mShop.android.shopping");
    }

    private boolean containsPaymentKeywords(String text) {
        String lowerText = text.toLowerCase();
        return lowerText.contains("received") || 
               lowerText.contains("credited") || 
               lowerText.contains("paid") ||
               lowerText.contains("₹") ||
               lowerText.contains("rs.");
    }

    private void sendNotificationToFlutter(String packageName, String text) {
        Map<String, String> data = new HashMap<>();
        data.put("packageName", packageName);
        data.put("text", text);
        data.put("timestamp", String.valueOf(System.currentTimeMillis()));
        
        try {
            MainActivity.sendNotificationEvent(data);
        } catch (Exception e) {
            Log.e(TAG, "Error sending to Flutter", e);
        }
    }
}