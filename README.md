# AlertPe - UPI Payment Monitoring System

A comprehensive real-time UPI payment monitoring and alert system with free trial and autopay mandate setup.

## 🚀 Project Overview

AlertPe is a complete UPI payment monitoring solution with:
- **Admin Panel**: Next.js web application for administrators
- **Mobile App**: Flutter application for end users
- **Backend API**: RESTful APIs with MongoDB
- **Production Deployment**: VPS with PM2 and Nginx
- **Razorpay Integration**: Real UPI mandate setup and autopay

## 📱 Applications

### 1. Alert Admin Panel (Web)
**Technology Stack:**
- Next.js 14 with TypeScript
- MongoDB with Mongoose ODM
- Tailwind CSS for styling
- Lucide React Icons

**Core Features:**
- Real-time SMS payment detection and monitoring
- User management and analytics dashboard
- Payment transaction tracking and filtering
- QR code generation and management
- Revenue analytics and reporting
- Plan management with pricing configuration

**Advanced Features:**
- Free trial configuration (1-30 days)
- Mandate verification amount setup (₹1-₹100)
- Subscription management dashboard
- Real Razorpay integration with mandate logs
- User timeline and activity tracking
- Automated subscription renewal scheduler

### 2. Alert Mobile App (Flutter)
**Technology Stack:**
- Flutter/Dart framework
- Multi-platform support (Android, iOS, Web, Windows, macOS, Linux)
- Material Design 3
- State management with Provider
- Local storage with SQLite

**Core Features:**
- UPI payment monitoring via SMS parsing
- Multi-language support (Hindi, English, etc.)
- User authentication with OTP verification
- PDF report generation and sharing
- QR code display and scanning
- Real-time subscription status tracking

**Advanced Features:**
- Free trial with countdown timer
- UPI app selection for mandate setup
- Real Razorpay mandate approval process
- Account verification with refundable amount
- User activity timeline with detailed logs
- Intelligent UPI ID extraction from SMS
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
  subscription: String (free/trial/premium),
  role: String (user/admin),
  isActive: Boolean,
  createdAt: Date,
  lastLogin: Date
}

// Plans Collection
{
  _id: ObjectId,
  name: String,
  price: Number,              // Single price field
  duration: String,           // 'monthly' or 'yearly'
  features: [String],
  razorpayPlanId: String,
  isActive: Boolean,
  createdAt: Date,
  updatedAt: Date
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
  metadata: Object
}
```

#### Advanced Collections:
```javascript
// TrialConfig Collection
{
  _id: ObjectId,
  trialDurationDays: Number,           // 1-30 days
  isTrialEnabled: Boolean,
  trialFeatures: [String],
  mandateVerificationAmount: Number,    // ₹1-₹100
  isMandateVerificationEnabled: Boolean,
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
  frequency: String (monthly/yearly),
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
```

### API Endpoints

#### Authentication APIs:
```
POST /api/auth/login          - User login with email/password
POST /api/auth/register       - User registration
POST /api/auth/send-otp       - Send OTP for verification
POST /api/auth/verify-otp     - Verify OTP code
POST /api/auth/logout         - User logout
```

#### Core APIs:
```
GET  /api/payments            - Get user payments with filters
POST /api/payments            - Add new payment record
DELETE /api/payments/delete   - Delete payment records

GET  /api/users               - Get all users (admin)
GET  /api/users/[id]          - Get specific user
PUT  /api/users/[id]          - Update user profile

GET  /api/plans               - Get subscription plans
POST /api/plans               - Create new plan (admin)
PUT  /api/plans/[id]          - Update plan (admin)
DELETE /api/plans/[id]        - Delete plan (admin)

GET  /api/qr                  - Get user QR codes
POST /api/qr                  - Generate new QR code
```

#### Advanced APIs:
```
GET  /api/config/trial        - Get trial configuration
POST /api/config/trial        - Update trial settings

POST /api/subscription/create       - Create new subscription
POST /api/subscription/start-trial  - Start free trial
GET  /api/subscription/status       - Get subscription status
GET  /api/subscription/all          - Get all subscriptions (admin)

POST /api/razorpay/create-mandate   - Create UPI mandate
POST /api/razorpay/create-subscription - Create subscription
POST /api/razorpay/webhook          - Razorpay webhook handler

POST /api/timeline/add        - Add timeline event
GET  /api/timeline/all        - Get user timeline

GET  /api/mandates/all        - Get all mandates (admin)
```

## 🔧 Installation & Setup

### Prerequisites
- **Node.js** 18+ with npm
- **MongoDB** 5.0+ (local or cloud)
- **Flutter SDK** 3.0+ for mobile development
- **PM2** for production process management
- **Nginx** for reverse proxy (production)
- **Razorpay Account** for payment processing

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
EMAIL_USER=hello.technovatechnologies@gmail.com
EMAIL_PASS=oavumbyivkfwdptp

# Server Configuration
NODE_ENV=development
PORT=3000
NODE_TLS_REJECT_UNAUTHORIZED=0

# Razorpay Configuration
RAZORPAY_KEY_ID=rzp_live_Rn6F0KvLNhV5nC
RAZORPAY_KEY_SECRET=QhKzF0GIViRtnP2Y3j4Zxb87
RAZORPAY_WEBHOOK_SECRET=your_webhook_secret_here

# Security
JWT_SECRET=your-jwt-secret-key
ENCRYPTION_KEY=your-encryption-key
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

#### 3. Production Environment Variables
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
      NODE_TLS_REJECT_UNAUTHORIZED: '0',
      RAZORPAY_KEY_ID: 'rzp_live_Rn6F0KvLNhV5nC',
      RAZORPAY_KEY_SECRET: 'QhKzF0GIViRtnP2Y3j4Zxb87'
    }
  }]
}
```

## 📊 Key Features & Capabilities

### Free Trial System
- **Admin Configurable**: 1-30 days trial duration
- **Feature Access**: Full premium features during trial
- **Automatic Conversion**: Seamless transition to paid subscription
- **Cancellation**: Cancel anytime during trial period
- **Timeline Tracking**: Complete audit trail of trial events

### UPI Mandate Setup
- **Account Verification**: Configurable verification amount (₹1-₹100)
- **Immediate Refund**: Verification amount refunded instantly
- **UPI App Selection**: User chooses preferred UPI app
- **Real Razorpay Integration**: Actual mandate creation and approval
- **Fallback Options**: UPI app → Generic UPI → Browser
- **Status Tracking**: Pending → Approved → Active states

### Plan Management
- **Flexible Pricing**: Single price field for monthly/yearly plans
- **Feature Configuration**: Admin-defined feature lists
- **Razorpay Integration**: Automatic plan sync with Razorpay
- **Active/Inactive**: Enable/disable plans dynamically
- **Usage Tracking**: Monitor plan adoption and revenue

### User Experience
- **Get Started Flow**: New users → Free trial → Autopay setup
- **Upgrade Flow**: Existing users → Immediate plan upgrade
- **UPI App Integration**: Native app opening for payments
- **Real-time Updates**: Live subscription status tracking
- **Multi-language Support**: Hindi, English, and more

## 🔐 Admin Access & Management

### Default Admin Credentials
- **Email:** admin@alertpe.com
- **Password:** admin123
- **Admin Panel:** https://technovatechnologies.online

### Admin Panel Features
- **Dashboard**: System overview and key metrics
- **User Management**: Create, edit, delete users
- **Plan Management**: Configure plans, pricing, and features
- **Trial Settings**: Set trial duration and verification amount
- **Mandate Management**: View and manage UPI mandates
- **Subscription Analytics**: Revenue tracking and user insights
- **Timeline Monitoring**: User activity and system events

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
  static const String userAgent = 'AlertPe Mobile App v2.0';
}
```

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
```

## 📈 User Flows

### New User Registration Flow
1. **Signup** → Email/Mobile/Password
2. **OTP Verification** → Email verification
3. **Set Password** → Account creation
4. **Get Started Screen** → Shows admin-set plans
5. **Start Free Trial** → Trial details popup
6. **UPI App Selection** → Choose preferred app
7. **Mandate Setup** → Razorpay UPI mandate
8. **Account Verification** → Pay verification amount (refunded)
9. **Trial Activation** → Full feature access
10. **Home Screen** → Start using app

### Existing User Upgrade Flow
1. **Plans Screen** → View available plans
2. **Select Plan** → Choose upgrade option
3. **Payment Setup** → Direct payment (no trial)
4. **UPI App Selection** → Choose payment method
5. **Razorpay Payment** → Immediate plan activation
6. **Confirmation** → Upgrade successful

## 🔄 Version History

### v2.0.0 (Current) - Production Ready
- ✅ Real Razorpay UPI mandate integration
- ✅ Account verification with refundable amount
- ✅ UPI app selection and deep linking
- ✅ Admin-configurable trial settings
- ✅ Single price field for flexible plan pricing
- ✅ Complete user timeline tracking
- ✅ Production deployment with PM2 and Nginx
- ✅ Free trial to paid subscription automation
- ✅ Mandate status tracking and management

### v1.0.0 - Core Features
- ✅ Basic UPI payment monitoring
- ✅ Admin dashboard with analytics
- ✅ User authentication with OTP
- ✅ QR code generation
- ✅ PDF report generation
- ✅ Mock subscription management

## 📊 Database Statistics

### Current Data Structure
```javascript
// Example Plan Document
{
  "_id": "692824f233676553d34d97bc",
  "name": "Basic",
  "price": 1212,                    // Actual plan price
  "duration": "monthly",
  "features": ["AAAA", "BB", "ccccc", "dddd", "eee"],
  "isActive": true,
  "razorpayPlanId": "plan_Rn8vOszrQvcGpx",
  "createdAt": "2025-11-27T10:16:18.117Z",
  "updatedAt": "2025-12-04T06:04:22.017Z"
}

// Example Trial Config
{
  "trialDurationDays": 7,
  "isTrialEnabled": true,
  "mandateVerificationAmount": 5,
  "isMandateVerificationEnabled": true,
  "trialFeatures": ["Basic alerts", "Limited reports"]
}
```

## 🚀 Performance Optimization

### Backend Optimizations
- **Database Indexing**: Optimized queries for user and payment data
- **API Caching**: Redis caching for frequently accessed data
- **Connection Pooling**: MongoDB connection optimization
- **Error Handling**: Comprehensive error logging and recovery

### Frontend Optimizations
- **Code Splitting**: Lazy loading for admin panel components
- **Image Optimization**: WebP format for better performance
- **Bundle Optimization**: Tree shaking and minification
- **API Optimization**: Efficient data fetching and caching

### Mobile App Optimizations
- **Offline Support**: Local data storage with sync
- **Background Processing**: SMS monitoring without battery drain
- **Memory Management**: Efficient state management
- **Network Optimization**: Retry logic and timeout handling

## 🔒 Security Features

### Data Protection
- **Encryption**: End-to-end encryption for sensitive data
- **Input Validation**: Comprehensive validation and sanitization
- **Rate Limiting**: API rate limiting to prevent abuse
- **Audit Logs**: Complete audit trail for all user actions

### Payment Security
- **Razorpay Integration**: PCI DSS compliant payment processing
- **UPI Mandate Security**: Secure mandate creation and approval
- **Transaction Verification**: Real-time transaction validation
- **Fraud Prevention**: Automated fraud detection and prevention

## 📞 Support & Maintenance

### Monitoring & Maintenance
```bash
# PM2 Commands
pm2 status                    # Check application status
pm2 logs alert-app           # View application logs
pm2 restart alert-app        # Restart application
pm2 reload alert-app         # Reload without downtime
pm2 monit                    # Real-time monitoring
```

### Database Management
```bash
# MongoDB Backup
mongodump --uri="mongodb://username:password@host:port/aleartapp" --out=/backup/$(date +%Y%m%d)

# MongoDB Restore
mongorestore --uri="mongodb://username:password@host:port/aleartapp" /backup/20231204
```

### Support Channels
- **Technical Support**: hello.technovatechnologies@gmail.com
- **Website**: https://technovatechnologies.online
- **Admin Panel**: https://technovatechnologies.online
- **Documentation**: Available in project repository

## 📄 License & Legal

This project is proprietary software developed by **Technova Technologies**. All rights reserved.

### Terms of Use
- Commercial use requires proper licensing
- Redistribution prohibited without permission
- Source code access limited to authorized developers
- Data privacy compliant with Indian IT Act 2000

---

**Built with ❤️ by Technova Technologies**

*Empowering businesses with intelligent payment monitoring and automated subscription management*

**Current Version**: v2.0.0 - Production Ready with Real Razorpay Integration
**Last Updated**: December 2024
**Status**: Live in Production