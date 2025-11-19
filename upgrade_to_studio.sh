#!/bin/bash

# Upgrade User to Studio Tier in Supabase
# Usage: ./upgrade_to_studio.sh user@email.com

SUPABASE_URL="https://htrilyrrbercixpyxqrj.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0cmlseXJyYmVyY2l4cHl4cXJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzMTI3ODksImV4cCI6MjA3ODg4ODc4OX0.5K_8QWPE7L9ZqPvweErJwgDHP1Y2oq8qYkupqIbnjLk"

EMAIL="${1:-test@flowsudoku.com}"

if [ -z "$EMAIL" ]; then
    echo "Usage: ./upgrade_to_studio.sh user@email.com"
    exit 1
fi

echo "Upgrading user to Studio tier..."
echo "Email: $EMAIL"
echo ""

# First, get the user ID from email
USER_RESPONSE=$(curl -s -X GET "$SUPABASE_URL/rest/v1/user_profiles?email=eq.$EMAIL&select=id" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY")

USER_ID=$(echo "$USER_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$USER_ID" ]; then
    echo "❌ User not found. Make sure the user exists and has signed up."
    echo ""
    echo "To create a user first, run: ./create_test_user.sh $EMAIL"
    exit 1
fi

echo "Found user ID: $USER_ID"
echo ""

# Upgrade to Studio tier
UPGRADE_RESPONSE=$(curl -s -X PATCH "$SUPABASE_URL/rest/v1/user_profiles?id=eq.$USER_ID" \
  -H "Content-Type: application/json" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -d '{
    "tier": "studio",
    "subscription_status": "active",
    "subscription_expires_at": null
  }')

if echo "$UPGRADE_RESPONSE" | grep -q "studio"; then
    echo "✅ User upgraded to Studio tier successfully!"
    echo ""
    echo "User: $EMAIL"
    echo "Tier: Studio (unlimited goals, sessions, pomodoros)"
    echo ""
    echo "⚠️  User needs to sign out and sign back in to see the changes."
else
    echo "❌ Failed to upgrade user"
    echo "Response: $UPGRADE_RESPONSE"
    echo ""
    echo "You may need to upgrade via Supabase SQL Editor instead."
fi

