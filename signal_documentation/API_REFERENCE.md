# Signal-CLI REST API - Complete API Reference

Complete API reference for signal-cli-rest-api endpoints.

**Full Swagger Documentation:** https://bbernhard.github.io/signal-cli-rest-api/

---

## Base URL

```
http://localhost:8080
```

In production, use HTTPS:
```
https://your-domain.com
```

---

## Authentication

Currently, the API does not enforce authentication by default. For production use, implement:
- Reverse proxy with authentication
- API Gateway
- Network-level restrictions

---

## API Endpoints

### Health Check

#### GET /v1/health

Check if the API is running.

**Request:**
```bash
curl http://localhost:8080/v1/health
```

**Response:**
```json
{
  "status": "ok"
}
```

---

### Account Registration

#### POST /v1/register/{number}

Register a new phone number with Signal.

**Parameters:**
- `number` (path) - Phone number in E.164 format (e.g., +1234567890)

**Request Body:**
```json
{
  "use_voice": false,
  "captcha": ""
}
```

**Fields:**
- `use_voice` (boolean) - Use voice call instead of SMS for verification
- `captcha` (string, optional) - Captcha token if required

**Request:**
```bash
curl -X POST \
  http://localhost:8080/v1/register/+1234567890 \
  -H 'Content-Type: application/json' \
  -d '{
    "use_voice": false
  }'
```

**Response:**
```json
{
  "status": "verification_required"
}
```

**Status Codes:**
- `200 OK` - Registration initiated
- `400 Bad Request` - Invalid phone number format
- `429 Too Many Requests` - Rate limited

---

#### POST /v1/register/{number}/verify/{token}

Verify a phone number using the SMS/voice code.

**Parameters:**
- `number` (path) - Phone number in E.164 format
- `token` (path) - Verification code received via SMS/voice

**Request:**
```bash
curl -X POST \
  http://localhost:8080/v1/register/+1234567890/verify/123456
```

**Response:**
```json
{
  "status": "verified"
}
```

**Status Codes:**
- `200 OK` - Verification successful
- `400 Bad Request` - Invalid verification code
- `403 Forbidden` - Verification expired

---

### Sending Messages

#### POST /v2/send

Send a message to one or more recipients.

**Request Body:**
```json
{
  "message": "Your message text",
  "number": "+1234567890",
  "recipients": ["+9876543210", "+1111111111"],
  "base64_attachments": ["base64_encoded_data"],
  "quote_timestamp": 1234567890123,
  "quote_author": "+9876543210",
  "quote_message": "Original message text",
  "text_mode": "normal"
}
```

**Fields:**
- `message` (string, required) - Message text
- `number` (string, required) - Your Signal number (sender)
- `recipients` (array, optional) - List of recipient numbers
- `group_id` (string, optional) - Group ID to send to (instead of recipients)
- `base64_attachments` (array, optional) - Base64-encoded attachments
- `quote_timestamp` (integer, optional) - Timestamp of message being quoted
- `quote_author` (string, optional) - Author of quoted message
- `quote_message` (string, optional) - Text of quoted message
- `text_mode` (string, optional) - Text formatting mode: `normal`, `styled`

**Example: Simple Message**
```bash
curl -X POST \
  http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Hello, World!",
    "number": "+1234567890",
    "recipients": ["+9876543210"]
  }'
```

**Example: Multiple Recipients**
```bash
curl -X POST \
  http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Team update: Server maintenance tonight at 10 PM",
    "number": "+1234567890",
    "recipients": ["+1111111111", "+2222222222", "+3333333333"]
  }'
```

**Example: Message with Attachment**
```bash
curl -X POST \
  http://localhost:8080/v2/send \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Check out this chart",
    "number": "+1234567890",
    "recipients": ["+9876543210"],
    "base64_attachments": ["iVBORw0KGgoAAAANSUhEUgA..."]
  }'
```

**Response:**
```json
{
  "timestamp": 1234567890123,
  "results": [
    {
      "recipientNumber": "+9876543210",
      "success": true,
      "networkFailure": false,
      "unregisteredFailure": false
    }
  ]
}
```

**Status Codes:**
- `201 Created` - Message sent successfully
- `400 Bad Request` - Invalid request format
- `404 Not Found` - Sender number not registered
- `500 Internal Server Error` - Signal service error

---

### Receiving Messages

#### GET /v1/receive/{number}

Receive messages for a registered number.

**Parameters:**
- `number` (path) - Your Signal number
- `timeout` (query, optional) - Timeout in seconds (default: 1)

**Request:**
```bash
curl http://localhost:8080/v1/receive/+1234567890
```

**Response:**
```json
{
  "envelope": [
    {
      "source": "+9876543210",
      "sourceNumber": "+9876543210",
      "sourceUuid": "uuid-string",
      "sourceName": "John Doe",
      "sourceDevice": 1,
      "timestamp": 1234567890123,
      "dataMessage": {
        "timestamp": 1234567890123,
        "message": "Hello back!",
        "expiresInSeconds": 0,
        "viewOnce": false,
        "attachments": []
      },
      "hasContent": true
    }
  ]
}
```

**Status Codes:**
- `200 OK` - Messages retrieved (may be empty array)
- `404 Not Found` - Number not registered

---

### Group Management

#### POST /v1/groups/{number}

Create a new Signal group.

**Parameters:**
- `number` (path) - Your Signal number (group creator)

**Request Body:**
```json
{
  "name": "Team Alerts",
  "members": ["+1111111111", "+2222222222"],
  "description": "Critical team notifications",
  "avatar": "base64_encoded_image",
  "permissions": {
    "addMembers": "every-member",
    "editGroup": "only-admins"
  }
}
```

**Fields:**
- `name` (string, required) - Group name
- `members` (array, required) - List of member phone numbers
- `description` (string, optional) - Group description
- `avatar` (string, optional) - Base64-encoded group avatar
- `permissions` (object, optional) - Group permissions

**Request:**
```bash
curl -X POST \
  http://localhost:8080/v1/groups/+1234567890 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Project Team",
    "members": ["+1111111111", "+2222222222", "+3333333333"]
  }'
```

**Response:**
```json
{
  "id": "group-id-base64-encoded",
  "name": "Project Team",
  "members": [
    "+1234567890",
    "+1111111111",
    "+2222222222",
    "+3333333333"
  ]
}
```

**Status Codes:**
- `201 Created` - Group created successfully
- `400 Bad Request` - Invalid request
- `404 Not Found` - Number not registered

---

#### GET /v1/groups/{number}

List all groups for a number.

**Parameters:**
- `number` (path) - Your Signal number

**Request:**
```bash
curl http://localhost:8080/v1/groups/+1234567890
```

**Response:**
```json
{
  "groups": [
    {
      "id": "group-id-1",
      "name": "Project Team",
      "members": ["+1234567890", "+1111111111"],
      "isBlocked": false,
      "isMember": true,
      "isAdmin": true
    },
    {
      "id": "group-id-2",
      "name": "Family",
      "members": ["+1234567890", "+2222222222"],
      "isBlocked": false,
      "isMember": true,
      "isAdmin": false
    }
  ]
}
```

---

#### DELETE /v1/groups/{number}/{groupid}

Delete/leave a group.

**Parameters:**
- `number` (path) - Your Signal number
- `groupid` (path) - Group ID to leave

**Request:**
```bash
curl -X DELETE \
  http://localhost:8080/v1/groups/+1234567890/group-id-base64
```

**Response:**
```json
{
  "status": "success"
}
```

---

### Attachment Management

#### POST /v1/attachments

Upload an attachment to be sent with messages.

**Request:**
```bash
curl -X POST \
  http://localhost:8080/v1/attachments \
  -F "file=@/path/to/document.pdf"
```

**Response:**
```json
{
  "id": "attachment-id",
  "filename": "document.pdf",
  "size": 102400,
  "contentType": "application/pdf"
}
```

---

#### GET /v1/attachments/{id}

Retrieve/download an attachment.

**Parameters:**
- `id` (path) - Attachment ID

**Request:**
```bash
curl http://localhost:8080/v1/attachments/attachment-id \
  -o downloaded-file.pdf
```

---

#### DELETE /v1/attachments/{id}

Delete an attachment.

**Parameters:**
- `id` (path) - Attachment ID

**Request:**
```bash
curl -X DELETE \
  http://localhost:8080/v1/attachments/attachment-id
```

---

### Profile Management

#### PUT /v1/profiles/{number}

Update your Signal profile.

**Parameters:**
- `number` (path) - Your Signal number

**Request Body:**
```json
{
  "name": "John Doe",
  "avatar": "base64_encoded_image",
  "about": "Available 9-5 EST",
  "emoji": "💼"
}
```

**Request:**
```bash
curl -X PUT \
  http://localhost:8080/v1/profiles/+1234567890 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Support Bot",
    "about": "Automated notifications"
  }'
```

**Response:**
```json
{
  "status": "success"
}
```

---

### Device Linking

#### GET /v1/qrcodelink

Generate QR code for linking a device.

**Query Parameters:**
- `device_name` (string, optional) - Name for the linked device

**Request:**
```bash
curl "http://localhost:8080/v1/qrcodelink?device_name=MyApp"
```

**Response:**
Returns a PNG image with the QR code.

---

## Rate Limits

Signal enforces rate limits to prevent spam:

- **Registration:** Limited per phone number
- **Messages:** ~100-200 per hour per number (unofficial)
- **Group Creation:** Limited per account

**Best Practices:**
- Implement exponential backoff
- Respect 429 responses
- Use groups for multiple recipients
- Space out messages (1-2 seconds between sends)

---

## Error Responses

All error responses follow this format:

```json
{
  "error": "Error description",
  "timestamp": 1234567890123
}
```

**Common HTTP Status Codes:**

| Code | Meaning | Action |
|------|---------|--------|
| 400 | Bad Request | Check request format |
| 403 | Forbidden | Check permissions/verification |
| 404 | Not Found | Number not registered |
| 409 | Conflict | Resource already exists |
| 429 | Too Many Requests | Implement rate limiting |
| 500 | Internal Server Error | Check signal-cli logs |
| 503 | Service Unavailable | Wait and retry |

---

## Webhooks

Configure webhooks to receive messages automatically instead of polling.

### Configuration

Set environment variable:
```bash
WEBHOOK_URL=https://your-app.com/webhook
```

### Webhook Payload

Your endpoint will receive POST requests with this format:

```json
{
  "envelope": {
    "source": "+9876543210",
    "sourceNumber": "+9876543210",
    "sourceUuid": "uuid-string",
    "timestamp": 1234567890123,
    "dataMessage": {
      "timestamp": 1234567890123,
      "message": "Hello!",
      "attachments": []
    }
  },
  "account": "+1234567890"
}
```

### Example Webhook Handler (Python/Flask)

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def signal_webhook():
    data = request.json
    envelope = data.get('envelope', {})
    message = envelope.get('dataMessage', {}).get('message', '')
    sender = envelope.get('source', '')
    
    print(f"Received message from {sender}: {message}")
    
    # Process message
    # ...
    
    return jsonify({'status': 'received'}), 200
```

---

## API Versioning

The API uses version prefixes:
- `/v1/` - Original API version
- `/v2/` - Enhanced API with additional features

**Differences:**
- `/v2/send` includes better error handling and quote support
- `/v1/` endpoints maintained for backward compatibility

---

## Best Practices

### 1. Use v2 Endpoints
```python
# Good
url = f"{base_url}/v2/send"

# Avoid (unless compatibility required)
url = f"{base_url}/v1/send"
```

### 2. Handle All Response Fields
```python
result = response.json()
for recipient_result in result.get('results', []):
    if not recipient_result.get('success'):
        if recipient_result.get('unregisteredFailure'):
            print("Recipient not on Signal")
        elif recipient_result.get('networkFailure'):
            print("Network error, retry later")
```

### 3. Implement Retry Logic
```python
import time
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

session = requests.Session()
retry = Retry(
    total=3,
    backoff_factor=1,
    status_forcelist=[429, 500, 502, 503, 504]
)
adapter = HTTPAdapter(max_retries=retry)
session.mount('http://', adapter)
session.mount('https://', adapter)
```

### 4. Validate Phone Numbers
```python
import re

def validate_e164(phone):
    """Validate E.164 phone number format"""
    pattern = r'^\+[1-9]\d{1,14}$'
    return re.match(pattern, phone) is not None
```

---

## Next Steps

- See [SIGNAL_CLI_REST_API.md](./SIGNAL_CLI_REST_API.md) for implementation guide
- Check [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) for integration steps
- Review [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues

