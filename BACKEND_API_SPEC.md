# Flow Sudoku Backend API Specification

## Base URL
```
https://api.flowsudoku.com/v1
```

## Authentication
All authenticated endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <access_token>
```

---

## Endpoints

### 1. User Authentication

#### Sign Up
```
POST /auth/signup
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Response (201 Created):**
```json
{
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "tier": "free",
    "created_at": "2025-11-16T21:00:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "refresh_abc123..."
}
```

#### Sign In
```
POST /auth/signin
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Response (200 OK):**
```json
{
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "tier": "studio",
    "created_at": "2025-11-16T21:00:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "refresh_abc123..."
}
```

#### Get Current User
```
GET /auth/me
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "id": "user_123",
  "email": "user@example.com",
  "tier": "studio",
  "subscription_status": "active",
  "subscription_expires_at": "2026-11-16T21:00:00Z",
  "created_at": "2025-11-16T21:00:00Z"
}
```

---

### 2. Session Sync

#### Upload Sessions
```
POST /sessions
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "sessions": [
    {
      "id": "uuid-123",
      "timestamp": "2025-11-16T10:30:00Z",
      "duration": 900,
      "difficulty": "medium",
      "declutter_text": "Today I need to focus on...",
      "mistake_count": 2,
      "is_completed": true,
      "puzzle_id": 42
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "synced": 1,
  "conflicts": 0
}
```

#### Download Sessions
```
GET /sessions?since=2025-11-01T00:00:00Z
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "sessions": [
    {
      "id": "uuid-123",
      "timestamp": "2025-11-16T10:30:00Z",
      "duration": 900,
      "difficulty": "medium",
      "declutter_text": "Today I need to focus on...",
      "mistake_count": 2,
      "is_completed": true,
      "puzzle_id": 42
    }
  ],
  "total": 42
}
```

---

### 3. Subscription Management

#### Check Subscription Status
```
GET /subscription/status
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "tier": "studio",
  "status": "active",
  "current_period_end": "2026-11-16T21:00:00Z",
  "cancel_at_period_end": false
}
```

---

## Error Responses

All errors follow this format:

```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Email or password is incorrect"
  }
}
```

### Common Error Codes

| Status | Code | Description |
|--------|------|-------------|
| 400 | INVALID_REQUEST | Request body is malformed |
| 401 | UNAUTHORIZED | Missing or invalid token |
| 401 | INVALID_CREDENTIALS | Wrong email/password |
| 403 | FORBIDDEN | Action not allowed for tier |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Email already registered |
| 429 | RATE_LIMIT | Too many requests |
| 500 | INTERNAL_ERROR | Server error |

---

## Rate Limiting

- Auth endpoints: 5 requests per minute
- Session endpoints: 20 requests per minute
- Subscription endpoints: 10 requests per minute

---

## Notes

- All timestamps are in ISO 8601 format (UTC)
- Access tokens expire after 1 hour
- Refresh tokens expire after 30 days
- Free tier users can still sync (with session limits enforced server-side)

