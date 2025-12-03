# AlertPe - UPI Payment Monitoring System

A comprehensive real-time UPI payment monitoring and alert system that captures payment notifications from SMS and provides detailed analytics through both mobile and web applications.

## 🚀 Project Overview

AlertPe consists of two main components:
- **Admin Panel**: Next.js web application for administrators
- **Mobile App**: Flutter application for end users

## 📱 Applications

### 1. Alert Admin Panel (Web)
**Technology Stack:**
- Next.js 14 with TypeScript
- MongoDB with Mongoose
- Tailwind CSS
- Lucide React Icons

**Features:**
- Real-time SMS payment detection and monitoring
- User management and analytics
- Payment transaction tracking
- QR code generation and management
- Revenue analytics and reporting
- Notification management
- Export functionality

**NEW FEATURES:**
- Free trial configuration and management
- Subscription management dashboard
- Mock Razorpay integration logs
- User timeline and activity tracking
- Automated subscription renewal scheduler

### 2. Alert Mobile App (Flutter)
**Technology Stack:**
- Flutter/Dart
- Multi-platform support (Android, iOS, Web, Windows, macOS, Linux)

**Features:**
- UPI payment monitoring
- Multi-language support
- User authentication with OTP
- PDF report generation
- QR code display
- Subscription management (Free/Premium)
- Offline mode support

**NEW FEATURES:**
- Free trial banner with countdown
- Subscription activation flow
- Mock autopay mandate approval
- Subscription status tracking
- User activity timeline
- UPI app detection and prioritization
- Consent screen for permissions
- Intelligent UPI ID extraction

## 🏗️ Architecture

### Database Schema (MongoDB)
```
Users Collection:
- username, email, mobile, password
- subscription (free/premium)
- role (user/admin)
- isActive, createdAt, lastLogin

Payments Collection:
- userId, amount, paymentApp, upiId
- transactionId, notificationText
- status, timestamp, date, time

Plans Collection:
- Subscription plans and pricing

QRCodes Collection:
- Generated QR codes for payments

OTP Collection:
- One-time passwords for authentication

NEW COLLECTIONS:

TrialConfig Collection:
- trialDurationDays, isTrialEnabled
- trialFeatures, createdAt, updatedAt

Subscription Collection:
- userId, planId, status (trial/active/expired/cancelled)
- trialStartDate, trialEndDate, subscriptionStartDate
- nextRenewalDate, mandateId, razorpaySubscriptionId
- amount, createdAt, updatedAt

Mandate Collection:
- userId, mandateId, status (pending/approved/rejected/cancelled)
- amount, frequency, bankAccount, approvalUrl
- approvedAt, createdAt, updatedAt

UserTimeline Collection:
- userId, eventType, title, description
- metadata, timestamp

RazorpayMockWebhookLog Collection:
- eventType, payload, subscriptionId, mandateId
- userId, processed, createdAt
```

### API Endpoints
```
Authentication:
- POST /api/auth/login
- POST /api/auth/register
- POST /api/auth/send-otp
- POST /api/auth/verify-otp

Payments:
- GET /api/payments
- POST /api/payments
- DELETE /api/payments/delete
- GET /api/payments/all

Users:
- GET /api/users
- GET /api/users/[id]

QR Codes:
- GET /api/qr

Plans:
- GET /api/plans
- GET /api/plans/[id]

NEW API ENDPOINTS:

Trial Configuration:
- GET /api/config/trial
- POST /api/config/trial

Subscription Management:
- POST /api/subscription/create
- GET /api/subscription/status
- GET /api/subscription/all

Mock Razorpay Integration:
- POST /api/mock-razorpay/create-subscription
- POST /api/mock-razorpay/mandate-link
- POST /api/mock-razorpay/webhook

User Timeline:
- POST /api/timeline/add
- GET /api/timeline/add

Scheduler:
- POST /api/scheduler/run
```

## 🔧 Installation & Setup

### Prerequisites
- Node.js 18+
- MongoDB
- Flutter SDK (for mobile app)
- PM2 (for production)
- Nginx (for production)

### Admin Panel Setup
```bash
cd alert_admin
npm install
cp .env.example .env.local
# Configure environment variables
npm run dev
```

### Mobile App Setup
```bash
cd alert_app
flutter pub get
flutter run
```

### Environment Variables (.env.local)
```env
MONGODB_URI=mongodb://username:password@host:port/database
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
NODE_ENV=production
PORT=9999
```

## 🌐 Production Deployment

### Server Configuration
**Domain:** technovatechnologies.online
**Server:** VPS with Ubuntu/CentOS
**Port:** 9999
**Process Manager:** PM2

### Production Setup

1. **Clone Repository**
```bash
git clone <repository-url>
cd AleartApp
```

2. **Install Dependencies**
```bash
cd alert_admin
npm install
npm run build
```

3. **PM2 Configuration**
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

4. **Nginx Configuration**
```bash
sudo cp alert-app.nginx.conf /etc/nginx/sites-available/alert-app
sudo ln -s /etc/nginx/sites-available/alert-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Production Environment Variables
```javascript
// ecosystem.config.js
env: {
  NODE_ENV: 'production',
  PORT: 9999,
  MONGODB_URI: 'mongodb://vivekvora:Technova%40990@72.60.30.153:27017/aleartapp?authSource=admin',
  EMAIL_USER: 'hello.technovatechnologies@gmail.com',
  EMAIL_PASS: 'oavumbyivkfwdptp',
  NODE_TLS_REJECT_UNAUTHORIZED: '0'
}
```

### SSL Configuration (Optional)
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Generate SSL certificate
sudo certbot --nginx -d technovatechnologies.online

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Key Features

### Real-time Payment Monitoring
- Automatic SMS parsing for UPI payments
- Support for multiple payment apps (GPay, PhonePe, Paytm, etc.)
- Duplicate payment detection
- Live dashboard with auto-refresh

### Analytics & Reporting
- Revenue tracking and statistics
- User engagement metrics
- Payment app distribution
- Exportable reports

### Security Features
- Input validation and sanitization
- Duplicate transaction prevention
- Role-based access control
- Secure authentication with OTP

### Mobile App Features
- Cross-platform compatibility
- Offline mode support
- Multi-language interface
- PDF report generation
- QR code integration

## 🔐 Admin Access

**Default Admin Credentials:**
- Email: admin@alertpe.com
- Password: admin123

**Admin Panel URL:** https://technovatechnologies.online

## 📱 Mobile App Configuration

### Production API Configuration
```dart
// lib/config.dart
static const String productionApiUrl = 'https://technovatechnologies.online/api';
static const bool isProduction = true;
```

### Supported Platforms
- Android (Primary)
- iOS
- Web
- Windows
- macOS
- Linux

## 🛠️ Development

### Admin Panel Development
```bash
cd alert_admin
npm run dev          # Development server
npm run build        # Production build
npm run lint         # Code linting
npm run seed-admin   # Seed admin user
```

### NEW Admin Panel Pages
- `/subscription-management` - Manage user subscriptions
- `/trial-settings` - Configure free trial settings
- `/webhook-logs` - View mock Razorpay webhook logs
- `/user-timeline` - View user activity timelines

### Mobile App Development
```bash
cd alert_app
flutter run                    # Run on connected device
flutter build apk             # Build Android APK
flutter build ios             # Build iOS app
flutter build web             # Build web version
```

### NEW Flutter Screens
- `ConsentScreen` - Permission request for SMS/notifications
- `SubscriptionScreen` - Subscription plans and activation
- `MandateApprovalScreen` - Mock autopay mandate approval
- `SubscriptionStatusScreen` - View subscription details
- `UserTimelineScreen` - User activity timeline
- `TrialBannerWidget` - Free trial countdown banner

## 📈 Monitoring & Maintenance

### PM2 Commands
```bash
pm2 status           # Check application status
pm2 logs alert-app   # View application logs
pm2 restart alert-app # Restart application
pm2 reload alert-app  # Reload without downtime
```

### Database Backup
```bash
mongodump --uri="mongodb://username:password@host:port/aleartapp"
```

### Log Monitoring
```bash
tail -f ~/.pm2/logs/alert-app-out.log
tail -f ~/.pm2/logs/alert-app-error.log
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Create Pull Request

## 📄 License

This project is proprietary software. All rights reserved.

## 📞 Support

For technical support or inquiries:
- Email: hello.technovatechnologies@gmail.com
- Website: https://technovatechnologies.online

## 🔄 Version History

- **v1.0.0** - Initial release with core payment monitoring features
- Real-time SMS detection
- Multi-platform mobile app
- Admin dashboard with analytics

---

**Built with ❤️ by Technova Technologies**