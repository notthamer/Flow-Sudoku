# Quick Network Test

Run this in Terminal to verify Supabase is accessible:

```bash
curl -X POST https://htrilyrrbercixpyxqrj.supabase.co/auth/v1/signup \
  -H "Content-Type: application/json" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0cmlseXJyYmVyY2l4cHl4cXJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzMTI3ODksImV4cCI6MjA3ODg4ODc4OX0.5K_8QWPE7L9ZqPvweErJwgDHP1Y2oq8qYkupqIbnjLk" \
  -d '{"email":"test123@example.com","password":"testpass123"}'
```

If this works, you should see a JSON response with user data.
If it fails, Supabase might not be configured correctly.

