# Upgrade User to Studio Tier

## Quick Method: Use Script

```bash
./upgrade_to_studio.sh test@flowsudoku.com
```

Then sign out and sign back in to the app.

---

## Method 2: Via Supabase Dashboard (Easiest)

1. Go to: https://app.supabase.com/project/htrilyrrbercixpyxqrj
2. Click **Table Editor** → **user_profiles**
3. Find your user by email
4. Click the row to edit
5. Change:
   - `tier` → `studio`
   - `subscription_status` → `active`
6. Click **Save**
7. **Sign out and sign back in** to the app

---

## Method 3: Via SQL Editor (Most Reliable)

1. Go to: https://app.supabase.com/project/htrilyrrbercixpyxqrj/sql
2. Click **New query**
3. Paste this SQL:

```sql
-- Upgrade specific user by email
UPDATE public.user_profiles 
SET 
  tier = 'studio',
  subscription_status = 'active',
  subscription_expires_at = NULL
WHERE email = 'test@flowsudoku.com';
```

4. Replace `test@flowsudoku.com` with your email
5. Click **Run**
6. **Sign out and sign back in** to the app

---

## Verify Upgrade

After signing back in:
- Go to **Settings** in the app
- Under "YOUR PLAN" it should say **STUDIO**
- You should have unlimited goals, sessions, and pomodoros

---

## Test Studio Features

1. **Unlimited Goals:**
   - Start session → GOALS tab
   - Add more than 3 goals → Should work!

2. **Unlimited Sessions:**
   - Complete 1 session
   - Try to start another → Should work (no limit message)

---

## Downgrade Back to Free (For Testing)

```sql
UPDATE public.user_profiles 
SET 
  tier = 'free',
  subscription_status = 'inactive'
WHERE email = 'test@flowsudoku.com';
```

Then sign out and sign back in.

