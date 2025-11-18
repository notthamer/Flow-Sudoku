-- Flow Sudoku Supabase Database Setup
-- Run this in Supabase SQL Editor: https://app.supabase.com/project/htrilyrrbercixpyxqrj/sql

-- ============================================
-- 1. USER PROFILES TABLE
-- ============================================
-- Extends Supabase auth.users with app-specific data

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  tier TEXT NOT NULL DEFAULT 'free' CHECK (tier IN ('free', 'studio')),
  subscription_status TEXT DEFAULT 'inactive' CHECK (subscription_status IN ('active', 'inactive', 'cancelled', 'expired')),
  subscription_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster tier lookups
CREATE INDEX IF NOT EXISTS idx_user_profiles_tier ON public.user_profiles(tier);

-- ============================================
-- 2. SESSIONS TABLE
-- ============================================
-- Stores user game sessions

CREATE TABLE IF NOT EXISTS public.sessions (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  timestamp TIMESTAMPTZ NOT NULL,
  duration INTEGER NOT NULL, -- in seconds
  difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
  declutter_text TEXT,
  mistake_count INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  puzzle_id INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_timestamp ON public.sessions(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_user_timestamp ON public.sessions(user_id, timestamp DESC);

-- ============================================
-- 3. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on both tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

-- User Profiles Policies
-- Users can read their own profile
CREATE POLICY "Users can read own profile" 
  ON public.user_profiles
  FOR SELECT 
  USING (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "Users can insert own profile"
  ON public.user_profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON public.user_profiles
  FOR UPDATE
  USING (auth.uid() = id);

-- Sessions Policies
-- Users can read their own sessions
CREATE POLICY "Users can read own sessions"
  ON public.sessions
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own sessions
CREATE POLICY "Users can insert own sessions"
  ON public.sessions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own sessions
CREATE POLICY "Users can update own sessions"
  ON public.sessions
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete their own sessions
CREATE POLICY "Users can delete own sessions"
  ON public.sessions
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- 4. FUNCTIONS & TRIGGERS
-- ============================================

-- Function to create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, tier)
  VALUES (NEW.id, NEW.email, 'free');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create profile when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for user_profiles updated_at
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at();

-- ============================================
-- 5. USEFUL QUERIES (for testing)
-- ============================================

-- View all users and their tiers
-- SELECT id, email, tier, subscription_status, created_at FROM public.user_profiles;

-- View all sessions for a user
-- SELECT * FROM public.sessions WHERE user_id = 'YOUR_USER_ID' ORDER BY timestamp DESC;

-- Count sessions per user
-- SELECT user_id, COUNT(*) as session_count FROM public.sessions GROUP BY user_id;

-- Upgrade a user to Studio (admin only - run in SQL editor)
-- UPDATE public.user_profiles SET tier = 'studio', subscription_status = 'active' WHERE email = 'user@example.com';

