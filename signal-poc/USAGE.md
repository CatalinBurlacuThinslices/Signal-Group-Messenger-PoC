# Signal Group Messenger - Usage Guide

Detailed instructions on how to use the Signal Group Messenger PoC.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Using the Web Interface](#using-the-web-interface)
3. [API Usage](#api-usage)
4. [Common Workflows](#common-workflows)
5. [Tips and Tricks](#tips-and-tricks)

---

## Getting Started

### Prerequisites Check

Before using the app, ensure:

```bash
# 1. Signal API is running
curl http://localhost:8080/v1/health
# Should return: {"status":"ok"}

# 2. Backend is running
curl http://localhost:5000/api/health
# Should return: {"status":"ok","backend":"running",...}

# 3. Frontend is accessible
# Open http://localhost:3000 in browser
```

### First Time Setup

1. **Start Signal API:**
   ```bash
   cd signal-api
   docker-compose up -d
   ```

2. **Register phone number** (if not already done):
   ```bash
   curl -X POST http://localhost:8080/v1/register/+12345678900 \
     -H 'Content-Type: application/json' \
     -d '{"use_voice": false}'
   
   # Verify with SMS code
   curl -X POST http://localhost:8080/v1/register/+12345678900/verify/123456
   ```

3. **Create groups in Signal app:**
   - Open Signal mobile app
   - Create at least one group
   - Add some contacts

4. **Start the PoC:**
   ```bash
   # Terminal 1: Backend
   cd signal-poc/backend
   npm start

   # Terminal 2: Frontend
   cd signal-poc/frontend
   npm run dev
   ```

---

## Using the Web Interface

### Dashboard Overview

When you open http://localhost:3000, you'll see:

1. **Header:**
   - App title
   - Status indicators (Backend, Signal API)

2. **Groups Card:**
   - List of all your Signal groups
   - Group names and member counts
   - Refresh button

3. **Send Message Card:**
   - Group selector dropdown
   - Message text area
   - Send button

4. **Alerts:**
   - Error messages (red)
   - Success messages (green)

### Sending a Message

**Step 1: Select a Group**

- Click on a group in the groups list, OR
- Use the dropdown in "Send Message" card
- Selected group will be highlighted in purple

**Step 2: Write Your Message**

- Type your message in the text area
- You can write multiple lines
- Character count shown below text area

**Step 3: Send**

- Click "📤 Send Message" button
- Button shows "⏳ Sending..." while processing
- Success message appears in green
- Error message appears in red if something goes wrong

### Status Indicators

**Backend Status:**
- 🟢 Green "running" = Backend is working
- 🔴 Red = Backend is down

**Signal API Status:**
- 🟢 Green "connected" = Can communicate with Signal
- 🔴 Red "unreachable" = Signal API is not running

### Refreshing Groups

Click the "🔄 Refresh" button to:
- Fetch latest groups from Signal
- Update group member counts
- Show any new groups you've joined

---

## API Usage

### Using Backend API Directly

You can use the backend API with curl or any HTTP client.

#### 1. Health Check

```bash
curl http://localhost:5000/api/health
```

**Response:**
```json
{
  "status": "ok",
  "backend": "running",
  "signalApi": {
    "status": "ok"
  }
}
```

#### 2. Fetch Groups

```bash
curl http://localhost:5000/api/groups
```

**Response:**
```json
{
  "success": true,
  "groups": [
    {
      "id": "base64-encoded-group-id",
      "name": "Project Team",
      "members": ["+1234567890", "+9876543210"],
      "memberCount": 2,
      "isAdmin": true,
      "isMember": true,
      "isBlocked": false
    }
  ],
  "count": 1
}
```

#### 3. Send Message

```bash
curl -X POST http://localhost:5000/api/send \
  -H 'Content-Type: application/json' \
  -d '{
    "groupId": "your-group-id-here",
    "message": "Hello from API!"
  }'
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Message sent successfully",
  "timestamp": 1234567890123
}
```

**Response (Error):**
```json
{
  "success": false,
  "error": "Failed to send message",
  "details": "Network error",
  "hint": "Ensure Signal API Docker container is running"
}
```

#### 4. Get Configuration

```bash
curl http://localhost:5000/api/config
```

**Response:**
```json
{
  "signalApiUrl": "http://localhost:8080",
  "signalNumberConfigured": true,
  "signalNumberMasked": "+123...8900"
}
```

### Using with Python

```python
import requests

BASE_URL = "http://localhost:5000"

# Fetch groups
response = requests.get(f"{BASE_URL}/api/groups")
groups = response.json()['groups']

print(f"Found {len(groups)} groups")
for group in groups:
    print(f"  - {group['name']} ({group['memberCount']} members)")

# Send message
group_id = groups[0]['id']
message = "Hello from Python!"

response = requests.post(
    f"{BASE_URL}/api/send",
    json={
        "groupId": group_id,
        "message": message
    }
)

if response.json()['success']:
    print("✅ Message sent!")
else:
    print(f"❌ Error: {response.json()['error']}")
```

### Using with JavaScript/Node.js

```javascript
const axios = require('axios');

const BASE_URL = 'http://localhost:5000';

async function sendGroupMessage(groupId, message) {
  try {
    const response = await axios.post(`${BASE_URL}/api/send`, {
      groupId,
      message
    });
    
    if (response.data.success) {
      console.log('✅ Message sent!');
    }
  } catch (error) {
    console.error('❌ Error:', error.response?.data?.error);
  }
}

// Usage
sendGroupMessage('group-id-here', 'Hello from Node.js!');
```

---

## Common Workflows

### Workflow 1: Send to Multiple Groups

```javascript
// Fetch all groups
const groupsResponse = await fetch('http://localhost:5000/api/groups');
const { groups } = await groupsResponse.json();

// Send same message to all groups
const message = "Important announcement!";

for (const group of groups) {
  await fetch('http://localhost:5000/api/send', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      groupId: group.id,
      message
    })
  });
  
  // Wait 2 seconds between messages to avoid rate limiting
  await new Promise(resolve => setTimeout(resolve, 2000));
}
```

### Workflow 2: Scheduled Messages

```python
import schedule
import time
import requests

def send_daily_update():
    """Send daily update at 9 AM"""
    requests.post(
        'http://localhost:5000/api/send',
        json={
            'groupId': 'your-group-id',
            'message': f'Daily update: {time.strftime("%Y-%m-%d")}'
        }
    )

schedule.every().day.at("09:00").do(send_daily_update)

while True:
    schedule.run_pending()
    time.sleep(60)
```

### Workflow 3: Alert on Condition

```javascript
const axios = require('axios');

// Monitor something and send alert
async function checkAndAlert() {
  // Check your condition
  const needsAlert = await checkSomeCondition();
  
  if (needsAlert) {
    await axios.post('http://localhost:5000/api/send', {
      groupId: process.env.ALERT_GROUP_ID,
      message: '⚠️ Alert: Condition detected!'
    });
  }
}

// Check every 5 minutes
setInterval(checkAndAlert, 5 * 60 * 1000);
```

---

## Tips and Tricks

### 1. Finding Group IDs

Group IDs are base64-encoded strings. To find them:

```bash
# Fetch groups
curl http://localhost:5000/api/groups | jq '.groups[] | {name, id}'
```

Or in the web UI, open browser console and type:
```javascript
// In browser console while on the app
fetch('/api/groups')
  .then(r => r.json())
  .then(data => {
    data.groups.forEach(g => {
      console.log(`${g.name}: ${g.id}`);
    });
  });
```

### 2. Testing Without UI

```bash
# Quick test script
GROUP_ID="your-group-id-here"
MESSAGE="Test from bash"

curl -X POST http://localhost:5000/api/send \
  -H 'Content-Type: application/json' \
  -d "{\"groupId\": \"$GROUP_ID\", \"message\": \"$MESSAGE\"}"
```

### 3. Monitoring Logs

**Backend logs:**
```bash
cd signal-poc/backend
npm start 2>&1 | tee backend.log
```

**Signal API logs:**
```bash
docker logs -f signal-cli-rest-api
```

### 4. Quick Restart

```bash
# Restart everything
cd signal-poc

# Kill existing processes
pkill -f "node server.js"
pkill -f "vite"

# Start backend
cd backend && npm start &

# Start frontend
cd ../frontend && npm run dev &
```

### 5. Using with Safe Wallet Integration

```javascript
// In your Safe wallet monitoring code
const signalNotify = async (message) => {
  await fetch('http://localhost:5000/api/send', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      groupId: process.env.SAFE_ALERTS_GROUP_ID,
      message
    })
  });
};

// When transaction happens
safeWallet.on('transactionExecuted', async (tx) => {
  await signalNotify(
    `✅ Transaction executed\n` +
    `Safe: ${tx.safe}\n` +
    `Hash: ${tx.hash}`
  );
});
```

### 6. Rate Limiting

Signal has rate limits. Best practices:

```javascript
// Add delay between messages
async function sendWithDelay(messages, delayMs = 2000) {
  for (const msg of messages) {
    await sendMessage(msg);
    await new Promise(resolve => setTimeout(resolve, delayMs));
  }
}
```

### 7. Error Recovery

```javascript
async function sendMessageWithRetry(groupId, message, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await axios.post('http://localhost:5000/api/send', {
        groupId,
        message
      });
      return response.data;
    } catch (error) {
      console.error(`Attempt ${i + 1} failed:`, error.message);
      if (i < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, 2000 * (i + 1)));
      }
    }
  }
  throw new Error('Failed after retries');
}
```

---

## Environment Variables

### Backend (.env)

```env
# Server port
PORT=5000

# Signal API URL (where signal-cli-rest-api is running)
SIGNAL_API_URL=http://localhost:8080

# Your Signal phone number (E.164 format)
SIGNAL_NUMBER=+12345678900
```

### Frontend

Frontend automatically proxies to backend at `http://localhost:5000`. No configuration needed.

---

## Next Steps

- Review [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues
- Check [README.md](./README.md) for overview
- Read [signal_documentation](../output/signal_documentation/) for deep dive

---

**Happy messaging! 📱✨**

