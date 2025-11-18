# Backend Setup Guide for Flow Sudoku

## What's Been Done

✅ **Network Layer Created**
- `NetworkService.swift` - Handles all HTTP requests
- Token management
- Error handling
- Request/Response models

✅ **Services Updated**
- `AuthService.swift` - Real API calls for sign up/sign in
- `CloudSyncService.swift` - Real API calls for session sync

✅ **API Spec Created**
- `BACKEND_API_SPEC.md` - Complete API documentation

---

## How to Connect

### Step 1: Build Your Backend

Choose one of these options:

#### Option A: Node.js/Express (Recommended for Quick Setup)
```bash
npm init -y
npm install express jsonwebtoken bcrypt cors dotenv
```

#### Option B: Python/Flask
```bash
pip install flask flask-cors flask-jwt-extended bcryptd
```

#### Option C: Firebase/Supabase (Easiest - No Backend Code)
- Firebase: https://firebase.google.com/
- Supabase: https://supabase.com/ (recommended - PostgreSQL + REST API)

---

## Step 2: Update Base URL

In `NetworkService.swift`, change the base URL:

```swift
private let baseURL = "https://api.flowsudoku.com/v1" // Your backend URL
```

For local testing:
```swift
private let baseURL = "http://localhost:3000/v1" // Local dev
```

---

## Step 3: Implement Backend Endpoints

Refer to `BACKEND_API_SPEC.md` for complete endpoint specifications.

### Required Endpoints:

1. **POST /auth/signup** - Create new user
2. **POST /auth/signin** - Authenticate user  
3. **GET /auth/me** - Get current user (optional)
4. **POST /sessions** - Upload sessions
5. **GET /sessions** - Download sessions
6. **GET /subscription/status** - Check tier (for Studio validation)

---

## Step 4: Testing Locally

### Test with cURL:

```bash
# Sign up
curl -X POST http://localhost:3000/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Sign in
curl -X POST http://localhost:3000/v1/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Upload session (with token)
curl -X POST http://localhost:3000/v1/sessions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"sessions":[{"id":"uuid","timestamp":"2025-11-16T10:00:00Z","duration":900,"difficulty":"medium","declutter_text":"Test","mistake_count":2,"is_completed":true,"puzzle_id":1}]}'
```

---

## Step 5: Enable Backend in App

### Current State:
The app is **STILL LOCAL-ONLY** until you deploy a backend.

### To Enable:
1. Deploy your backend to a server (AWS, Heroku, Railway, etc.)
2. Update `baseURL` in `NetworkService.swift`
3. Test sign-in/sign-up in the app
4. Sessions will automatically sync when users sign in

---

## Quick Start with Supabase (Recommended)

### Why Supabase?
- Free tier includes PostgreSQL database
- Built-in REST API
- Authentication included
- No backend code needed

### Setup Steps:

1. **Create Supabase Project**: https://app.supabase.com/

2. **Create Tables**:
```sql
-- Users table (Supabase auth handles this)

-- Sessions table
CREATE TABLE sessions (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  timestamp TIMESTAMPTZ NOT NULL,
  duration INTEGER NOT NULL,
  difficulty TEXT NOT NULL,
  declutter_text TEXT,
  mistake_count INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  puzzle_id INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add index for user queries
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_timestamp ON sessions(timestamp DESC);
```

3. **Update NetworkService.swift**:
```swift
private let baseURL = "https://YOUR_PROJECT.supabase.co/rest/v1"
```

4. **Use Supabase Client** (Optional):
You can also use the Supabase Swift SDK instead of NetworkService.

---

## Testing the Connection

### In Xcode:

1. Run the app
2. Go to Settings → Sign In
3. Create an account
4. Check Xcode console for:
   - `✅ User signed in`
   - `✅ Sessions synced to server`
5. Complete a session
6. Check if it syncs automatically

---

## Environment Variables

Create a `.env` file for your backend:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/flowsudoku
JWT_SECRET=your-secret-key-here-make-it-long-and-random
PORT=3000
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

---

## Subscription Validation

### For Studio Tier:

When a user subscribes on your website:

1. User pays via Stripe/Paddle
2. Backend creates/updates user record
3. Set `tier = "studio"` in database
4. When user signs in:
   - Backend returns `"tier": "studio"` in response
   - App updates local tier
   - Unlimited sessions enabled!

---

## Security Checklist

✅ Use HTTPS in production
✅ Validate JWT tokens on every request
✅ Hash passwords with bcrypt (rounds >= 10)
✅ Rate limit authentication endpoints
✅ Sanitize user inputs
✅ Set proper CORS headers
✅ Keep JWT secret secure
✅ Use environment variables for secrets

---

## Deployment Options

### Quick & Easy:
- **Railway**: https://railway.app/ (free tier, easy Node.js)
- **Render**: https://render.com/ (free tier, auto-deploy from Git)
- **Fly.io**: https://fly.io/ (free tier, global edge)

### Production:
- **AWS**: EC2 + RDS
- **Google Cloud**: Cloud Run + Cloud SQL
- **DigitalOcean**: App Platform

---

## Current App Behavior

**Without Backend (Now):**
- Sign in/up creates local accounts only
- Sessions stored locally
- Sync buttons don't do anything (but won't error)
- Tier is always `.free` by default

**With Backend (After Setup):**
- Real authentication
- Sessions sync to cloud
- Multi-device support
- Tier validated from server
- Studio subscribers get unlimited access

---

## Next Steps

1. ✅ Choose backend solution (Supabase recommended for MVP)
2. ✅ Deploy backend
3. ✅ Update `baseURL` in NetworkService.swift
4. ✅ Test authentication
5. ✅ Test session sync
6. ✅ Add subscription handling (Stripe)
7. ✅ Update App Store version to use backend

---

## Need Help?

Common issues:

**"Connection failed"**
- Check baseURL is correct
- Ensure backend is running
- Check CORS is enabled
- Verify network permissions in Xcode

**"401 Unauthorized"**
- Token might be expired
- Check Authorization header format
- Verify JWT secret matches

**"Sessions not syncing"**
- Check if user is authenticated
- Verify token is saved
- Check endpoint URLs match API spec

---

## Testing Without Backend

If you want to test the app before setting up a backend, you can:

1. Keep using the app locally (works fine)
2. Add debug toggle in Settings to switch to Studio tier
3. All features work locally

The backend is only needed for:
- Cloud sync
- Multi-device access
- Subscription validation
- User accounts across devices

