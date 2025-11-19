# Create Test User for Goals Testing

## Option 1: Create Test User via App (Easiest)

1. **Run the app**
2. Go to **Settings** → **Sign In**
3. Click **"Don't have an account? Sign up"**
4. Enter:
   - Email: `test@flowsudoku.com` (or any email)
   - Password: `test123456` (must be ≥6 characters)
   - First Name: `Test`
   - Last Name: `User`
5. Click **CREATE ACCOUNT**
6. You'll automatically be on **free tier** (3 goals/day)

---

## Option 2: Create Test User via Terminal (Quick)

Run this command in Terminal:

```bash
curl -X POST https://htrilyrrbercixpyxqrj.supabase.co/auth/v1/signup \
  -H "Content-Type: application/json" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0cmlseXJyYmVyY2l4cHl4cXJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzMTI3ODksImV4cCI6MjA3ODg4ODc4OX0.5K_8QWPE7L9ZqPvweErJwgDHP1Y2oq8qYkupqIbnjLk" \
  -d '{"email":"testuser@flowsudoku.com","password":"test123456"}'
```

Then sign in to the app with:
- Email: `testuser@flowsudoku.com`
- Password: `test123456`

---

## Option 3: Test with 1 Goal Limit (Temporary)

To test the limit functionality with only 1 goal (instead of 3), temporarily modify the free tier limit:

### In `SessionData.swift`, change:

```swift
var goalLimit: Int {
    switch self {
    case .free: return 1  // Changed from 3 to 1 for testing
    case .studio: return .max
    }
}
```

**Remember to change it back to 3 before committing!**

---

## Test the Goals Feature

1. **Sign in** with your test account
2. **Start a session** (Begin Flow)
3. Click the **GOALS** tab in the sidebar
4. Try adding goals:
   - Add 1st goal → ✅ Should work
   - Add 2nd goal → ✅ Should work (if limit is 3)
   - Add 3rd goal → ✅ Should work (if limit is 3)
   - Add 4th goal → ❌ Should show limit message

5. **Test widget** (after setting up widget extension):
   - Goals should appear in the widget
   - Widget updates when you add/toggle goals

---

## Verify User in Supabase

1. Go to: https://app.supabase.com/project/htrilyrrbercixpyxqrj
2. Click **Authentication** → **Users**
3. You should see your test user
4. Click **Table Editor** → **user_profiles**
5. Verify `tier = 'free'`

---

## Reset Daily Goals Count (For Testing)

If you want to test the limit again after using all 3 goals:

**Option A: Wait until midnight** (automatic reset)

**Option B: Manually reset in code** (for testing):
- In `UsageTracker.swift`, temporarily add a reset function
- Or clear UserDefaults key: `flow_sudoku_daily_stats`

**Option C: Use Terminal:**
```bash
# This clears the daily stats (macOS only)
defaults delete com.flowsudoku.app flow_sudoku_daily_stats
```

---

## Test Accounts Summary

| Email | Password | Tier | Goals Limit |
|-------|----------|------|-------------|
| test@flowsudoku.com | test123456 | free | 3/day |
| testuser@flowsudoku.com | test123456 | free | 3/day |

**Note:** Free tier = 3 goals/day by default. Change to 1 in code for easier testing.

