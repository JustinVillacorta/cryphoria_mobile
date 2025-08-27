# Postman API Testing Guide for Multi-Session Authentication

This guide provides step-by-step instructions for testing the multi-session authentication API using Postman.

## Environment Setup

### 1. Create New Environment
- Environment Name: `Cryphoria Multi-Session Auth`
- Variables:
  - `base_url`: `http://localhost:8000` (or your backend URL)
  - `token_device_a`: (will be set after Device A login)
  - `token_device_b`: (will be set after Device B login)
  - `session_id_pending`: (will be set after Device B login)

## Test Scenarios

### Scenario 1: First Device Login (Auto-Approved)

**Request:**
```
POST {{base_url}}/api/auth/login/
```

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "username": "testuser",
  "password": "password123",
  "device_name": "iPhone 15 Pro",
  "device_id": "device_abc_123"
}
```

**Expected Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user_id": "user_123",
    "username": "testuser",
    "email": "test@example.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "session_id": "session_abc_123",
    "approved": true,
    "is_active": true,
    "token_created_at": "2024-08-27T10:30:00Z"
  }
}
```

**Post-Response Script:**
```javascript
if (pm.response.code === 200) {
    const response = pm.response.json();
    pm.environment.set("token_device_a", response.data.token);
    console.log("Device A token saved:", response.data.token);
}
```

### Scenario 2: Second Device Login (Pending Approval)

**Request:**
```
POST {{base_url}}/api/auth/login/
```

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "username": "testuser",
  "password": "password123",
  "device_name": "Samsung Galaxy S24",
  "device_id": "device_xyz_456"
}
```

**Expected Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful - pending approval on another device",
  "data": {
    "user_id": "user_123",
    "username": "testuser",
    "email": "test@example.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "session_id": "session_xyz_456",
    "approved": false,
    "is_active": true,
    "token_created_at": "2024-08-27T11:15:00Z"
  }
}
```

**Post-Response Script:**
```javascript
if (pm.response.code === 200) {
    const response = pm.response.json();
    pm.environment.set("token_device_b", response.data.token);
    pm.environment.set("session_id_pending", response.data.session_id);
    console.log("Device B token saved:", response.data.token);
    console.log("Pending session ID saved:", response.data.session_id);
}
```

### Scenario 3: Test Pending Session Access (Should Fail)

**Request:**
```
GET {{base_url}}/api/auth/sessions/
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token_device_b}}
```

**Expected Response (401 Unauthorized):**
```json
{
  "detail": "Token is pending approval"
}
```

### Scenario 4: List Sessions from Approved Device

**Request:**
```
GET {{base_url}}/api/auth/sessions/
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token_device_a}}
```

**Expected Response (200 OK):**
```json
{
  "sessions": [
    {
      "sid": "session_abc_123",
      "device_name": "iPhone 15 Pro",
      "device_id": "device_abc_123",
      "ip": "192.168.1.100",
      "user_agent": "iOS App",
      "created_at": "2024-08-27T10:30:00Z",
      "last_seen": "2024-08-27T12:00:00Z",
      "approved": true,
      "approved_at": "2024-08-27T10:30:00Z",
      "revoked_at": null,
      "is_current": true
    },
    {
      "sid": "session_xyz_456",
      "device_name": "Samsung Galaxy S24",
      "device_id": "device_xyz_456",
      "ip": "192.168.1.101",
      "user_agent": "Android App",
      "created_at": "2024-08-27T11:15:00Z",
      "last_seen": null,
      "approved": false,
      "approved_at": null,
      "revoked_at": null,
      "is_current": false
    },
    {
      "sid": "legacy",
      "device_name": "legacy",
      "device_id": "",
      "ip": "",
      "user_agent": "",
      "created_at": "2024-07-01T00:00:00Z",
      "last_seen": null,
      "approved": true,
      "approved_at": null,
      "revoked_at": null,
      "is_current": false
    }
  ]
}
```

### Scenario 5: Approve Pending Session

**Request:**
```
POST {{base_url}}/api/auth/sessions/approve/
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token_device_a}}
```

**Body (JSON):**
```json
{
  "session_id": "{{session_id_pending}}"
}
```

**Expected Response (200 OK):**
```json
{
  "success": true,
  "message": "Session approved"
}
```

### Scenario 6: Test Approved Session Access (Should Work)

**Request:**
```
GET {{base_url}}/api/auth/sessions/
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token_device_b}}
```

**Expected Response (200 OK):**
```json
{
  "sessions": [
    {
      "sid": "session_abc_123",
      "device_name": "iPhone 15 Pro",
      "device_id": "device_abc_123",
      "ip": "192.168.1.100",
      "user_agent": "iOS App",
      "created_at": "2024-08-27T10:30:00Z",
      "last_seen": "2024-08-27T12:00:00Z",
      "approved": true,
      "approved_at": "2024-08-27T10:30:00Z",
      "revoked_at": null,
      "is_current": false
    },
    {
      "sid": "session_xyz_456",
      "device_name": "Samsung Galaxy S24",
      "device_id": "device_xyz_456",
      "ip": "192.168.1.101",
      "user_agent": "Android App",
      "created_at": "2024-08-27T11:15:00Z",
      "last_seen": "2024-08-27T12:05:00Z",
      "approved": true,
      "approved_at": "2024-08-27T12:00:00Z",
      "revoked_at": null,
      "is_current": true
    }
  ]
}
```

### Scenario 7: Revoke Specific Session

**Request:**
```
POST {{base_url}}/api/auth/sessions/revoke/
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token_device_a}}
```

**Body (JSON):**
```json
{
  "session_id": "legacy"
}
```

**Expected Response (200 OK):**
```json
{
  "success": true,
  "message": "Legacy session revoked"
}
```

### Scenario 8: Revoke Other Sessions

**Request:**
```
POST {{base_url}}/api/auth/sessions/revoke-others/
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token_device_a}}
```

**Expected Response (200 OK):**
```json
{
  "success": true,
  "message": "Other sessions revoked"
}
```

### Scenario 9: Confirm Password

**Request:**
```
POST {{base_url}}/api/auth/confirm-password/
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token_device_a}}
```

**Body (JSON):**
```json
{
  "password": "password123"
}
```

**Expected Response (200 OK):**
```json
{
  "success": true
}
```

### Scenario 10: Logout Current Session

**Request:**
```
POST {{base_url}}/api/auth/logout/
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token_device_a}}
```

**Expected Response (200 OK):**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

## Error Testing Scenarios

### Test Invalid Token
**Request:**
```
GET {{base_url}}/api/auth/sessions/
```

**Headers:**
```
Authorization: Bearer invalid_token_123
```

**Expected Response (401 Unauthorized):**
```json
{
  "detail": "Invalid token"
}
```

### Test Revoked Token
**Request:**
```
GET {{base_url}}/api/auth/sessions/
```

**Headers:**
```
Authorization: Bearer {{token_device_a}}
```
(After logout in Scenario 10)

**Expected Response (401 Unauthorized):**
```json
{
  "detail": "Token has been revoked"
}
```

### Test Disabled User Account
**Request:**
```
POST {{base_url}}/api/auth/login/
```

**Body (JSON):**
```json
{
  "username": "disabled_user",
  "password": "password123"
}
```

**Expected Response (401 Unauthorized):**
```json
{
  "detail": "User account is disabled"
}
```

## Complete Test Flow

1. **Setup**: Create environment with base_url
2. **Device A Login**: First device logs in (auto-approved)
3. **Device B Login**: Second device logs in (pending approval)
4. **Test Restriction**: Verify Device B cannot access protected endpoints
5. **Approval**: Device A approves Device B's session
6. **Test Access**: Verify Device B can now access protected endpoints
7. **Session Management**: Test listing, revoking sessions
8. **Cleanup**: Test logout functionality

## Postman Collection Import

You can create a Postman collection with all these requests and use environment variables to easily switch between different test scenarios.

### Collection Structure:
```
Multi-Session Auth Tests/
├── 01 - Device A Login (Auto-Approved)
├── 02 - Device B Login (Pending)
├── 03 - Test Pending Access (Should Fail)
├── 04 - List Sessions (Approved Device)
├── 05 - Approve Pending Session
├── 06 - Test Approved Access (Should Work)
├── 07 - Revoke Specific Session
├── 08 - Revoke Other Sessions
├── 09 - Confirm Password
├── 10 - Logout Current Session
└── Error Scenarios/
    ├── Invalid Token Test
    ├── Revoked Token Test
    └── Disabled User Test
```

This guide ensures comprehensive testing of the multi-session authentication system and validates all the required API endpoints and error scenarios.
