# AlertPe - UPI Payment Monitoring System

A comprehensive real-time UPI payment monitoring and alert system that captures payment notifications from SMS and provides detailed analytics through both mobile and web applications.

## 🚀 Project Overview

AlertPe is a complete UPI payment monitoring solution consisting of:
- **Admin Panel**: Next.js web application for administrators
- **Mobile App**: Flutter application for end users
- **Backend API**: RESTful APIs with MongoDB
- **Production Deployment**: VPS with PM2 and Nginx

## 📱 Applications

### 1. Alert Admin Panel (Web)
**Technology Stack:**
- Next.js 14 with TypeScript
- MongoDB with Mongoose ODM
- Tailwind CSS for styling
- Lucide React Icons
- Responsive design

**Core Features:**
- Real-time SMS payment detection and monitoring
- User management and analytics dashboard
- Payment transaction tracking and filtering
- QR code generation and management
- Revenue analytics and reporting
- Notification management system
- Data export functionality (CSV, PDF)

**Advanced Features:**
- Free trial configuration and management
- Subscription management dashboard
- Mock Razorpay integration with webhook logs
- User timeline and activity tracking
- Automated subscription renewal scheduler
- Mandate management for autopay
- Multi-language support configuration

### 2. Alert Mobile App (Flutter)
**Technology Stack:**
- Flutter/Dart framework
- Multi-platform support (Android, iOS, Web, Windows, macOS, Linux)
- Material Design 3
- State management with Provider/Riverpod
- Local storage with SQLite

**Core Features:**
- UPI payment monitoring via SMS parsing
- Multi-language support (Hindi, English, etc.)
- User authentication with OTP verification
- PDF report generation and sharing
- QR code display and scanning
- Subscription management (Free/Premium tiers)
- Offline mode support with sync

**Advanced Features:**
- Free trial banner with countdown timer
- Subscription activation flow with payment gateway
- Mock autopay mandate approval process
- Real-time subscription status tracking
- User activity timeline with detailed logs
- UPI app detection and prioritization
- Consent screen for permissions with legal compliance
- Intelligent UPI ID extraction from SMS
- Text-to-speech for notifications
- Dark/Light theme support

## 🏗️ System Architecture

### Database Schema (MongoDB)

#### Core Collections:
```javascript
// Users Collection
{
  _id: ObjectId,
  username: String,
  email: String (unique),
  mobile: String (unique),
  password: String (hashed),
  subscription: String (free/premium),
  role: String (user/admin),
  isActive: Boolean,
  createdAt: Date,
  lastLogin: Date,
  settings: {
    language: String,
    notifications: Boolean,
    theme: String
  }
}

// Payments Collection
{
  _id: ObjectId,
  userId: ObjectId,
  amount: Number,
  paymentApp: String,
  upiId: String,
  transactionId: String (unique),
  notificationText: String,
  status: String (success/failed/pending),
  timestamp: Date,
  date: String,
  time: String,
  metadata: Object
}

// Plans Collection
{
  _id: ObjectId,
  name: String,
  price: Number,
  duration: String (monthly/yearly),
  features: [String],
  isActive: Boolean,
  createdAt: Date,
  updatedAt: Date
}

// QRCodes Collection
{
  _id: ObjectId,
  userId: ObjectId,
  upiId: String,
  qrCode: String,
  isActive: Boolean,
  createdAt: Date
}

// OTP Collection
{
  _id: ObjectId,
  email: String,
  otp: String,
  expiresAt: Date,
  verified: Boolean,
  createdAt: Date
}
```

#### Advanced Collections:
```javascript
// TrialConfig Collection
{
  _id: ObjectId,
  trialDurationDays: Number,
  isTrialEnabled: Boolean,
  trialFeatures: [String],
  createdAt: Date,
  updatedAt: Date
}

// Subscription Collection
{
  _id: ObjectId,
  userId: ObjectId,
  planId: ObjectId,
  status: String (trial/active/expired/cancelled),
  trialStartDate: Date,
  trialEndDate: Date,
  subscriptionStartDate: Date,
  nextRenewalDate: Date,
  mandateId: String,
  razorpaySubscriptionId: String,
  amount: Number,
  subscriptionFailureReason: String,
  createdAt: Date,
  updatedAt: Date
}

// Mandate Collection
{
  _id: ObjectId,
  userId: ObjectId,
  mandateId: String (unique),
  status: String (pending/approved/rejected/cancelled),
  amount: Number,
  frequency: String,
  bankAccount: String,
  approvalUrl: String,
  approvedAt: Date,
  createdAt: Date,
  updatedAt: Date
}

// UserTimeline Collection
{
  _id: ObjectId,
  userId: ObjectId,
  eventType: String,
  title: String,
  description: String,
  metadata: Object,
  timestamp: Date
}

// RazorpayMockWebhookLog Collection
{
  _id: ObjectId,
  eventType: String,
  payload: Object,
  subscriptionId: String,
  mandateId: String,
  userId: ObjectId,
  processed: Boolean,
  createdAt: Date
}

// SubscriptionReminder Collection
{
  _id: ObjectId,
  userId: ObjectId,
  subscriptionId: ObjectId,
  reminderType: String (24h/1h),
  renewalDate: Date,
  sent: Boolean,
  sentAt: Date,
  createdAt: Date
}

// UpiAppConfig Collection
{
  _id: ObjectId,
  name: String,
  packageName: String,
  icon: String,
  priority: Number,
  isActive: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### API Endpoints

#### Authentication APIs:
```
POST /api/auth/login          - User login with email/password
POST /api/auth/register       - User registration
POST /api/auth/send-otp       - Send OTP for verification
POST /api/auth/verify-otp     - Verify OTP code
POST /api/auth/logout         - User logout
POST /api/auth/reset-password - Password reset
```

#### Core APIs:
```
GET  /api/payments            - Get user payments with filters
POST /api/payments            - Add new payment record
DELETE /api/payments/delete   - Delete payment records
GET  /api/payments/all        - Get all payments (admin)

GET  /api/users               - Get all users (admin)
GET  /api/users/[id]          - Get specific user
PUT  /api/users/[id]          - Update user profile

GET  /api/qr                  - Get user QR codes
POST /api/qr                  - Generate new QR code

GET  /api/plans               - Get subscription plans
GET  /api/plans/[id]          - Get specific plan
POST /api/plans               - Create new plan (admin)
PUT  /api/plans/[id]          - Update plan (admin)
DELETE /api/plans/[id]        - Delete plan (admin)
```

#### Advanced APIs:
```
GET  /api/config/trial        - Get trial configuration
POST /api/config/trial        - Update trial settings

POST /api/subscription/create - Create new subscription
GET  /api/subscription/status - Get subscription status
GET  /api/subscription/all    - Get all subscriptions (admin)
POST /api/subscription/downgrade - Downgrade subscription
GET  /api/subscription/reminders - Get renewal reminders

POST /api/mock-razorpay/create-subscription - Mock subscription creation
POST /api/mock-razorpay/mandate-link       - Mock mandate approval
POST /api/mock-razorpay/webhook            - Mock webhook handler

POST /api/timeline/add        - Add timeline event
GET  /api/timeline/all        - Get user timeline

POST /api/scheduler/run       - Run subscription scheduler

GET  /api/mandates/all        - Get all mandates (admin)

GET  /api/upi-apps            - Get UPI app configurations
POST /api/upi-apps            - Update UPI app settings

GET  /api/user/settings       - Get user settings
POST /api/user/settings       - Update user settings

GET  /api/webhook-logs        - Get webhook logs (admin)
```

## 🔧 Installation & Setup

### Prerequisites
- **Node.js** 18+ with npm
- **MongoDB** 5.0+ (local or cloud)
- **Flutter SDK** 3.0+ for mobile development
- **PM2** for production process management
- **Nginx** for reverse proxy (production)
- **Git** for version control

### Local Development Setup

#### 1. Clone Repository
```bash
git clone https://github.com/TechnovaTech/AleartApp.git
cd AleartApp
```

#### 2. Admin Panel Setup
```bash
cd alert_admin
npm install
cp .env.example .env.local
# Configure environment variables
npm run dev
```

#### 3. Mobile App Setup
```bash
cd alert_app
flutter pub get
flutter run
```

#### 4. Environment Variables (.env.local)
```env
# Database
MONGODB_URI=mongodb://localhost:27017/aleartapp

# Email Configuration
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password

# Server Configuration
NODE_ENV=development
PORT=3000

# Security
JWT_SECRET=your-jwt-secret-key
ENCRYPTION_KEY=your-encryption-key

# External APIs
RAZORPAY_KEY_ID=your-razorpay-key
RAZORPAY_KEY_SECRET=your-razorpay-secret
```

## 🌐 Production Deployment

### Server Configuration
- **Domain:** technovatechnologies.online
- **Server:** VPS with Ubuntu 20.04+
- **Port:** 9999
- **Process Manager:** PM2
- **Web Server:** Nginx
- **SSL:** Let's Encrypt (Certbot)

### Production Setup

#### 1. Server Preparation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 globally
sudo npm install -g pm2

# Install Nginx
sudo apt install nginx -y

# Install MongoDB (if not using cloud)
sudo apt install mongodb -y
```

#### 2. Application Deployment
```bash
# Clone repository
git clone https://github.com/TechnovaTech/AleartApp.git
cd AleartApp/alert_admin

# Install dependencies
npm install

# Build application
npm run build

# Start with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

#### 3. Nginx Configuration
```bash
# Create Nginx config
sudo nano /etc/nginx/sites-available/alert-app

# Add configuration:
server {
    listen 80;
    server_name technovatechnologies.online;

    location / {
        proxy_pass http://localhost:9999;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/alert-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 4. SSL Configuration
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Generate SSL certificate
sudo certbot --nginx -d technovatechnologies.online

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

#### 5. Production Environment Variables
```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'alert-app',
    script: 'server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 9999,
      MONGODB_URI: 'mongodb://vivekvora:Technova%40990@72.60.30.153:27017/aleartapp?authSource=admin',
      EMAIL_USER: 'hello.technovatechnologies@gmail.com',
      EMAIL_PASS: 'oavumbyivkfwdptp',
      NODE_TLS_REJECT_UNAUTHORIZED: '0'
    }
  }]
}
```

## 📊 Key Features & Capabilities

### Real-time Payment Monitoring
- **SMS Parsing**: Automatic extraction of payment details from SMS notifications
- **Multi-App Support**: GPay, PhonePe, Paytm, BHIM, Amazon Pay, and more
- **Duplicate Detection**: Intelligent filtering to prevent duplicate entries
- **Live Dashboard**: Real-time updates with auto-refresh functionality
- **Transaction Categorization**: Automatic categorization by payment type

### Advanced Analytics & Reporting
- **Revenue Tracking**: Daily, weekly, monthly revenue statistics
- **User Engagement**: Active users, session duration, feature usage
- **Payment Distribution**: Analysis by payment apps, amounts, time periods
- **Export Capabilities**: CSV, PDF, Excel export with custom date ranges
- **Visual Charts**: Interactive charts and graphs for data visualization

### Security & Compliance
- **Data Encryption**: End-to-end encryption for sensitive data
- **Input Validation**: Comprehensive validation and sanitization
- **Rate Limiting**: API rate limiting to prevent abuse
- **Audit Logs**: Complete audit trail for all user actions
- **GDPR Compliance**: Data privacy and user consent management

### Mobile App Capabilities
- **Cross-Platform**: Single codebase for Android, iOS, Web, Desktop
- **Offline Support**: Local data storage with automatic sync
- **Push Notifications**: Real-time payment alerts and reminders
- **Biometric Auth**: Fingerprint and face recognition support
- **Multi-Language**: Support for 10+ Indian languages
- **Accessibility**: Screen reader support and accessibility features

### Subscription & Billing
- **Free Trial**: Configurable trial periods with feature limitations
- **Flexible Plans**: Monthly, yearly, and custom billing cycles
- **Auto-Renewal**: Automated subscription renewals with reminders
- **Payment Gateway**: Integrated with Razorpay for secure payments
- **Mandate Management**: UPI autopay mandate creation and management
- **Billing Analytics**: Revenue forecasting and churn analysis

## 🔐 Admin Access & Management

### Default Admin Credentials
- **Email:** admin@alertpe.com
- **Password:** admin123
- **Admin Panel:** https://technovatechnologies.online

### Admin Panel Features
- **Dashboard**: Overview of users, payments, and system health
- **User Management**: Create, edit, delete users and manage permissions
- **Payment Monitoring**: View all transactions with advanced filtering
- **Subscription Management**: Manage user subscriptions and billing
- **Analytics**: Comprehensive analytics and reporting tools
- **System Settings**: Configure trial periods, features, and integrations
- **Audit Logs**: View system logs and user activity

## 📱 Mobile App Configuration

### Production API Configuration
```dart
// lib/config.dart
class AppConfig {
  static const String productionApiUrl = 'https://technovatechnologies.online/api';
  static const String developmentApiUrl = 'http://localhost:3000/api';
  static const bool isProduction = true;
  
  static String get apiUrl => isProduction ? productionApiUrl : developmentApiUrl;
  static const Duration apiTimeout = Duration(seconds: 30);
  static const String userAgent = 'AlertPe Mobile App v1.0';
}
```

### Supported Platforms
- **Android** (Primary target - API 21+)
- **iOS** (iOS 12+)
- **Web** (Progressive Web App)
- **Windows** (Desktop app)
- **macOS** (Desktop app)
- **Linux** (Desktop app)

### Build Commands
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🛠️ Development Workflow

### Admin Panel Development
```bash
cd alert_admin

# Development server
npm run dev

# Production build
npm run build

# Code linting
npm run lint

# Type checking
npm run type-check

# Seed admin user
npm run seed-admin

# Seed plans
node scripts/seed-plans.js
```

### Mobile App Development
```bash
cd alert_app

# Run on device
flutter run

# Run with hot reload
flutter run --hot

# Build for testing
flutter build apk --debug

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Admin Panel Pages
- **Dashboard** (`/dashboard`) - System overview and statistics
- **User Management** (`/users`) - Manage users and permissions
- **Payment Monitoring** (`/payments`) - View and manage transactions
- **Subscription Management** (`/subscription-management`) - Manage user subscriptions
- **Mandate Management** (`/mandates`) - Manage autopay mandates
- **QR Code Management** (`/qr`) - Generate and manage QR codes
- **Plans & Pricing** (`/plans`) - Manage subscription plans
- **Trial Settings** (`/trial-settings`) - Configure free trial settings
- **User Timeline** (`/user-timeline`) - View user activity timelines
- **Webhook Logs** (`/webhook-logs`) - View mock Razorpay webhook logs
- **Analytics** (`/analytics`) - Advanced analytics and reporting
- **Notifications** (`/notifications`) - Manage system notifications
- **Reports** (`/reports`) - Generate and export reports
- **Support** (`/support`) - Customer support management

### Flutter Screens & Components
- **Authentication Screens**: Login, Register, OTP Verification, Password Reset
- **Main Screens**: Home, Payments, QR Code, Settings, Profile
- **Subscription Screens**: Plans, Payment, Status, Timeline
- **Advanced Screens**: Consent, Language Selection, Mandate Approval
- **Components**: Trial Banner, Notification Widgets, Charts, Forms

## 📈 Monitoring & Maintenance

### Production Monitoring
```bash
# PM2 Commands
pm2 status                    # Check application status
pm2 logs alert-app           # View application logs
pm2 restart alert-app        # Restart application
pm2 reload alert-app         # Reload without downtime
pm2 monit                    # Real-time monitoring

# System Monitoring
htop                         # System resources
df -h                        # Disk usage
free -m                      # Memory usage
netstat -tulpn              # Network connections
```

### Database Management
```bash
# MongoDB Backup
mongodump --uri="mongodb://username:password@host:port/aleartapp" --out=/backup/$(date +%Y%m%d)

# MongoDB Restore
mongorestore --uri="mongodb://username:password@host:port/aleartapp" /backup/20231203

# Database Optimization
mongo aleartapp --eval "db.runCommand({compact: 'payments'})"
```

### Log Management
```bash
# Application Logs
tail -f ~/.pm2/logs/alert-app-out.log
tail -f ~/.pm2/logs/alert-app-error.log

# Nginx Logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# System Logs
journalctl -u nginx -f
journalctl -u mongodb -f
```

### Performance Optimization
- **Database Indexing**: Optimized indexes for frequent queries
- **Caching**: Redis caching for API responses
- **CDN**: Static asset delivery via CDN
- **Compression**: Gzip compression for API responses
- **Image Optimization**: WebP format for images
- **Code Splitting**: Lazy loading for admin panel components

## 🔄 Version History & Updates

### v2.0.0 (Current) - Advanced Features
- ✅ Complete subscription management system
- ✅ Free trial with configurable duration
- ✅ Mock Razorpay integration with webhooks
- ✅ User activity timeline tracking
- ✅ Multi-language support for Flutter app
- ✅ Advanced admin panel with 14 modules
- ✅ Automated subscription renewal system
- ✅ UPI app detection and prioritization
- ✅ Consent management with legal compliance

### v1.0.0 - Core Features
- ✅ Real-time SMS payment monitoring
- ✅ Multi-platform Flutter mobile app
- ✅ Admin dashboard with analytics
- ✅ User authentication with OTP
- ✅ QR code generation and management
- ✅ PDF report generation
- ✅ Basic subscription management

### Upcoming Features (v2.1.0)
- 🔄 Real Razorpay integration
- 🔄 Advanced analytics with ML insights
- 🔄 WhatsApp integration for notifications
- 🔄 Voice commands for mobile app
- 🔄 Blockchain integration for transaction verification
- 🔄 AI-powered fraud detection
- 🔄 Multi-tenant architecture for white-labeling

## 🤝 Contributing & Support

### Development Guidelines
1. **Code Style**: Follow ESLint and Prettier configurations
2. **Git Workflow**: Feature branches with pull requests
3. **Testing**: Write unit tests for new features
4. **Documentation**: Update README for new features
5. **Security**: Follow OWASP security guidelines

### Support Channels
- **Technical Support**: hello.technovatechnologies@gmail.com
- **Website**: https://technovatechnologies.online
- **Documentation**: Available in `/docs` directory
- **Issue Tracking**: GitHub Issues
- **Community**: Discord server for developers

## 📄 License & Legal

This project is proprietary software developed by **Technova Technologies**. All rights reserved.

### Terms of Use
- Commercial use requires proper licensing
- Redistribution prohibited without permission
- Source code access limited to authorized developers
- Data privacy compliant with Indian IT Act 2000

### Privacy & Security
- End-to-end encryption for sensitive data
- GDPR compliant data handling
- Regular security audits and updates
- User consent management for data collection

---

**Built with ❤️ by Technova Technologies**

*Empowering businesses with intelligent payment monitoring solutions*