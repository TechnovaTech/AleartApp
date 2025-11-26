# API Migration to Production

## Changes Made

The Flutter app has been successfully migrated from localhost to production API.

### Key Changes:

1. **API Service Updated** (`lib/services/api_service.dart`):
   - Changed base URL from `http://localhost:3000/api` to `https://technovatechnologies.online/api`
   - Added environment configuration support
   - Improved error handling with specific HTTP status codes
   - Added timeout handling and better exception management
   - Added connectivity check functionality
   - Added common headers for all requests

2. **Configuration File Added** (`lib/config.dart`):
   - Centralized configuration management
   - Easy environment switching (production/development)
   - Configurable timeouts and feature flags
   - App metadata and version information

3. **Production Settings**:
   - API URL: `https://technovatechnologies.online/api`
   - Timeout: 15 seconds (increased for production)
   - SSL/HTTPS enabled
   - Better error messages for users

### Environment Configuration

To switch between environments, modify the `isProduction` flag in `lib/config.dart`:

```dart
static const bool isProduction = true;  // Set to false for development
```

### API Endpoints

All API endpoints now point to the production server:
- Authentication: `https://technovatechnologies.online/api/auth/*`
- QR Codes: `https://technovatechnologies.online/api/qr`
- User Management: `https://technovatechnologies.online/api/users/*`
- Plans: `https://technovatechnologies.online/api/plans`

### Testing

Before deploying, ensure:
1. Production server is running on port 9999
2. SSL certificate is properly configured
3. All API endpoints are accessible
4. Database connection is working

### Rollback

To rollback to localhost for development:
1. Set `isProduction = false` in `lib/config.dart`
2. Ensure local Next.js server is running on port 3000