# 🔐 JWT Token Refresh Implementation

## What Changed:

### ✅ Token Security Upgrade:
- **OLD:** Single token valid for 30 days
- **NEW:** 
  - Access token: 1 hour (short-lived for security)
  - Refresh token: 30 days (long-lived, stored securely)
  - Token rotation on refresh (old refresh tokens invalidated)

## Backend Changes:

### 1. Database Migration
**File:** `backend/migrations/add-refresh-token-to-users.sql`

**Action Required:** Run on Railway database:
```sql
ALTER TABLE users 
ADD COLUMN refresh_token TEXT,
ADD COLUMN refresh_token_expires_at TIMESTAMP;
```

### 2. Config Updated
**File:** `backend/config/jwt.js`
- Changed from single `expiresIn: '30d'`
- To `accessTokenExpiry: '1h'` and `refreshTokenExpiry: '30d'`

### 3. Auth Service
**File:** `backend/services/auth.service.js`

**Login now returns:**
```json
{
  "accessToken": "eyJhbGciOiJIUz...",  // 1 hour expiry
  "refreshToken": "eyJhbGciOiJIUz...", // 30 days expiry
  "user": {
    "id": "uuid",
    "name": "Student Name",
    "role": "student"
  }
}
```

**New function:** `refreshAccessToken(refreshToken)`
- Verifies refresh token
- Checks database for token validity
- Generates new access + refresh tokens
- Updates database (token rotation)

### 4. New Endpoint
**File:** `backend/routes/auth.routes.js`

```
POST /api/auth/refresh-token
Body: { "refreshToken": "..." }
Response: { "accessToken": "...", "refreshToken": "..." }
```

### 5. Auth Middleware Enhanced
**File:** `backend/middleware/auth.middleware.js`
- Only accepts access tokens (not refresh tokens)
- Returns `TOKEN_EXPIRED` error code when token expires
- Client can detect and auto-refresh

## Flutter App Changes Needed:

### 1. Update Session Controller
**File:** `codiny_platform_app/lib/state/session/session_controller.dart`

**Current storage:**
```dart
await _prefs.setString('token', token);
```

**Need to change to:**
```dart
await _prefs.setString('access_token', accessToken);
await _prefs.setString('refresh_token', refreshToken);
```

### 2. Add Token Refresh Logic

**Create:** `lib/services/token_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/environment.dart';

class TokenService {
  static Future<Map<String, String>?> refreshTokens(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.baseUrl}/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'accessToken': data['accessToken'],
          'refreshToken': data['refreshToken'],
        };
      }
      return null;
    } catch (e) {
      print('Token refresh failed: $e');
      return null;
    }
  }
}
```

### 3. Update HTTP Interceptor

**Add automatic token refresh:**
```dart
Future<http.Response> _makeRequest(Uri url, {Map<String, String>? headers}) async {
  var response = await http.get(url, headers: headers);
  
  // If token expired, try to refresh
  if (response.statusCode == 401) {
    final body = json.decode(response.body);
    if (body['code'] == 'TOKEN_EXPIRED') {
      final refreshToken = await _prefs.getString('refresh_token');
      if (refreshToken != null) {
        final newTokens = await TokenService.refreshTokens(refreshToken);
        if (newTokens != null) {
          // Save new tokens
          await _prefs.setString('access_token', newTokens['accessToken']!);
          await _prefs.setString('refresh_token', newTokens['refreshToken']!);
          
          // Retry original request with new token
          headers?['Authorization'] = 'Bearer ${newTokens['accessToken']}';
          response = await http.get(url, headers: headers);
        }
      }
    }
  }
  
  return response;
}
```

### 4. Update Login Screen

**File:** Update where you handle login response

**OLD:**
```dart
final token = response['token'];
await session.setToken(token);
```

**NEW:**
```dart
final accessToken = response['accessToken'];
final refreshToken = response['refreshToken'];
await session.setTokens(accessToken, refreshToken);
```

## Security Benefits:

### 1. **Short-Lived Access Tokens**
- Access tokens expire in 1 hour
- If stolen, attacker has limited time window
- Reduces impact of token theft

### 2. **Token Rotation**
- Each refresh generates NEW tokens
- Old refresh token becomes invalid
- Prevents token replay attacks

### 3. **Database Validation**
- Refresh tokens verified against database
- Can be revoked server-side
- User logout invalidates all tokens

### 4. **Separate Token Types**
- Access tokens for API calls
- Refresh tokens only for token refresh endpoint
- Can't use refresh token for API access

## Testing:

### 1. Test Login (Backend)
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"student1","password":"password123"}'
```

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUz...",
  "refreshToken": "eyJhbGciOiJIUz...",
  "user": {...}
}
```

### 2. Test Access Token
```bash
curl http://localhost:3000/api/students/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 3. Test Token Refresh
```bash
curl -X POST http://localhost:3000/api/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"YOUR_REFRESH_TOKEN"}'
```

### 4. Wait 1 Hour and Test Expiry
```bash
# After 1 hour, access token should expire
curl http://localhost:3000/api/students/me \
  -H "Authorization: Bearer EXPIRED_ACCESS_TOKEN"
```

**Response:**
```json
{
  "message": "Access token expired",
  "code": "TOKEN_EXPIRED"
}
```

## Migration Plan:

### Phase 1: Backend (Now) ✅
1. ✅ Update JWT config
2. ✅ Add refresh token columns to database
3. ✅ Update login to return both tokens
4. ✅ Add refresh token endpoint
5. ✅ Update auth middleware

### Phase 2: Database
1. Run migration SQL on Railway
2. Verify columns added

### Phase 3: Flutter App (Next)
1. Update session controller to store both tokens
2. Add token refresh service
3. Add HTTP interceptor for auto-refresh
4. Update login screen
5. Test token expiry and refresh

### Phase 4: Deploy & Test
1. Deploy backend to Railway
2. Build new app version
3. Test with real users
4. Monitor token refresh logs

## Backward Compatibility:

**IMPORTANT:** Old tokens (30-day) will still work until they expire!

- Users on old app version (v1.0.2+5) can still login
- Their tokens work until they naturally expire
- New logins get new token format
- Gradual migration as users update app

## Environment Variables:

No new environment variables needed! Uses existing `JWT_SECRET`.

## Rollback Plan:

If issues occur, revert these commits:
1. Revert backend code changes
2. Keep database columns (safe to leave)
3. Old token system resumes

## Need Help?

**Backend logs to check:**
- `✅ Tokens generated for user: [id]`
- `✅ Tokens refreshed for user: [id]`
- `❌ Token refresh failed: [error]`

**Client should handle:**
- 401 with `TOKEN_EXPIRED` → Auto-refresh
- 401 without `TOKEN_EXPIRED` → Logout user
- Refresh failure → Logout user

---

**Status:** Backend ready ✅ | Database migration needed ⏳ | Flutter implementation needed ⏳
