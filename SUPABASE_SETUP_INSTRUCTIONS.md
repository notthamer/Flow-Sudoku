# Supabase Setup Instructions for Flow Sudoku

Your Supabase URL: `https://htrilyrrbercixpyxqrj.supabase.co`

## Step 1: Run SQL Setup

1. Go to your Supabase dashboard: https://app.supabase.com/project/htrilyrrbercixpyxqrj
2. Click **SQL Editor** in the left sidebar
3. Click **New query**
4. Copy and paste the contents of `supabase_setup.sql`
5. Click **Run** (or press Cmd+Enter)

This creates:
- ✅ `user_profiles` table (stores tier: free/studio)
- ✅ `sessions` table (stores game sessions)
- ✅ Row Level Security policies (users can only see their own data)
- ✅ Auto-create profile on signup trigger

## Step 2: Get Your API Keys

1. Go to **Settings** → **API** in your Supabase dashboard
2. Find these two keys:

### Project URL (already configured ✅)
```
https://htrilyrrbercixpyxqrj.supabase.co
```

### anon public key
Copy the `anon` `public` key - looks like:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0cmlseXJyYmVyY2l4cHl4cXJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDA...
```

### service_role key (keep secret!)
Copy the `service_role` `secret` key - only needed for admin operations

## Step 3: Add Supabase Keys to App

You need to add the anon key to the app. I'll show you how in the next step.

## Step 4: Test Your Setup

Once everything is configured, test in this order:

### Test 1: Sign Up
1. Run the app
2. Go to Settings → Sign In
3. Click "Create Account"
4. Enter email + password
5. Check Xcode console for success message

### Test 2: Verify in Supabase
1. Go to **Authentication** → **Users** in Supabase dashboard
2. You should see your new user!
3. Go to **Table Editor** → **user_profiles**
4. You should see a profile with `tier = 'free'`

### Test 3: Complete a Session
1. In the app, click "Begin Flow"
2. Complete a session (or exit early)
3. Go to **Table Editor** → **sessions** in Supabase
4. You should see your session!

### Test 4: Upgrade to Studio (Testing)
1. In Supabase SQL Editor, run:
```sql
UPDATE public.user_profiles 
SET tier = 'studio', subscription_status = 'active' 
WHERE email = 'your-test-email@example.com';
```
2. Sign out and sign back in to the app
3. Now you should have unlimited sessions!

## Step 5: Production Checklist

Before launching:

- [ ] Enable email confirmations in **Authentication** → **Settings**
- [ ] Set up custom SMTP for emails (optional)
- [ ] Add password requirements
- [ ] Set up Stripe webhook to update `tier` on payment
- [ ] Backup your database regularly
- [ ] Monitor usage in Supabase dashboard

## Troubleshooting

### "Failed to sign up"
- Check SQL setup ran successfully
- Verify anon key is correct
- Check Authentication is enabled in Supabase

### "Failed to sync sessions"
- User must be signed in
- Check RLS policies are enabled
- Verify user_id matches auth.uid()

### Sessions not appearing in Previous Sessions
- Complete at least one session first
- Check Supabase Table Editor to verify data exists
- Try signing out and back in

## How Tier Management Works

### Free Tier (Default)
- New users automatically get `tier = 'free'`
- App enforces 1 session/day limit locally
- Sessions still sync to Supabase

### Studio Tier (Paid)
- User pays on your website (Stripe/Paddle)
- Your payment webhook updates Supabase:
  ```sql
  UPDATE user_profiles 
  SET tier = 'studio', subscription_status = 'active'
  WHERE id = 'user-id-from-stripe';
  ```
- User signs in → app fetches `tier = 'studio'`
- Unlimited sessions enabled!

## Next: Add Payment Processing

To enable Studio subscriptions:

1. Set up Stripe/Paddle on your website
2. Create webhook endpoint
3. On successful payment, update Supabase:
   - Set `tier = 'studio'`
   - Set `subscription_status = 'active'`
   - Set `subscription_expires_at = now() + 1 month`
4. Add cron job to check for expired subscriptions

---

**Need help? Check the Supabase docs: https://supabase.com/docs**

