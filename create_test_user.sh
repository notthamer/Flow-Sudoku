#!/bin/bash

# Create Test User for Flow Sudoku
# This script creates a test user in Supabase

SUPABASE_URL="https://htrilyrrbercixpyxqrj.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0cmlseXJyYmVyY2l4cHl4cXJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzMTI3ODksImV4cCI6MjA3ODg4ODc4OX0.5K_8QWPE7L9ZqPvweErJwgDHP1Y2oq8qYkupqIbnjLk"

# Default test user credentials
EMAIL="${1:-test@flowsudoku.com}"
PASSWORD="${2:-test123456}"

echo "Creating test user..."
echo "Email: $EMAIL"
echo "Password: $PASSWORD"
echo ""

RESPONSE=$(curl -s -X POST "$SUPABASE_URL/auth/v1/signup" \
  -H "Content-Type: application/json" \
  -H "apikey: $SUPABASE_KEY" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

if echo "$RESPONSE" | grep -q "access_token"; then
    echo "✅ Test user created successfully!"
    echo ""
    echo "You can now sign in to the app with:"
    echo "  Email: $EMAIL"
    echo "  Password: $PASSWORD"
    echo ""
    echo "This user will have FREE tier (3 goals/day by default)"
else
    echo "❌ Failed to create user"
    echo "Response: $RESPONSE"
    echo ""
    echo "The user might already exist. Try a different email."
fi

