# Signal PoC Integration Guide

## 🎯 Quick Integration for Existing Projects

This guide shows you how to add Signal messaging functionality (Docker, registration, verification, broadcast, and API) to your existing project.

---

## 📦 What You'll Get

- **Docker Setup**: Signal CLI REST API in a container
- **Number Registration**: Register your phone number with Signal
- **Verification**: Verify your number with SMS code
- **Broadcast**: Send messages to multiple phone numbers
- **API**: REST API to send messages programmatically

---

## 🗂️ Files You Need to Copy

### **1. Docker Setup** (1 file)
```
your-project/
  signal-api/
    docker-compose.yml
```

### **2. Registration Scripts** (2 files)
```
your-project/
  signal-api/
    register.sh
    verify.sh
```

### **3. Backend API** (3 files)
```
your-project/
  backend/
    server.js
    package.json
    .env (create this)
```

### **4. Broadcast Script** (1 file - optional but useful)
```
your-project/
  broadcast.js
```

---

## 📋 Step-by-Step Integration

### **Step 1: Docker Setup**

**What it does**: Runs Signal CLI REST API in a Docker container that handles all Signal protocol communication.

**Files needed**:
- `docker-compose.yml`

**Setup**:
```bash
# Copy to your project
mkdir -p signal-api
cd signal-api

# Create docker-compose.yml with this content:
```

```yaml
services:
  signal-cli-rest-api:
    image: bbernhard/signal-cli-rest-api:latest
    container_name: signal-api
    ports:
      - "0.0.0.0:8080:8080"
    volumes:
      - "./signal-cli-config:/home/.local/share/signal-cli"
    environment:
      - MODE=native
      - AUTO_RECEIVE_SCHEDULE=0 */5 * * *
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/v1/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 10s
```

**Start it**:
```bash
docker-compose up -d
```

**Why you need it**: This is the core Signal service that handles encryption, message sending, and protocol compliance.

---

### **Step 2: Number Registration**

**What it does**: Registers your phone number with Signal so you can send/receive messages.

**Files needed**:
- `register.sh`

**Setup**:
```bash
# In signal-api/ folder, create register.sh
chmod +x register.sh
```

**File content** (update PHONE_NUMBER with yours):
```bash
#!/bin/bash
PHONE_NUMBER="+1234567890"  # YOUR NUMBER HERE

if [ -z "$1" ]; then
    echo "Step 1: Get Captcha Token"
    echo "1. Open: https://signalcaptchas.org/registration/generate.html"
    echo "2. Solve the captcha"
    echo "3. Right-click 'Open Signal' button and copy link"
    echo "4. Run: ./register.sh 'signal-recaptcha-v2.YOUR_TOKEN'"
    exit 0
fi

CAPTCHA_TOKEN="$1"

RESPONSE=$(curl -s -X POST http://localhost:8080/v1/register/$PHONE_NUMBER \
  -H 'Content-Type: application/json' \
  -d "{\"use_voice\": false, \"captcha\": \"$CAPTCHA_TOKEN\"}")

echo "$RESPONSE"

if echo "$RESPONSE" | grep -q "error"; then
    echo "❌ Registration failed"
    exit 1
fi

echo "✅ Registration request sent!"
echo "📱 Check your phone for SMS verification code"
echo "Then run: ./verify.sh YOUR_CODE"
```

**How to use**:
```bash
# Step 1: Run without arguments to see instructions
./register.sh

# Step 2: Get captcha token and register
./register.sh 'signal-recaptcha-v2.ABC123...'

# Wait for SMS code on your phone
```

**Why you need it**: Signal requires phone verification to prevent spam and ensure real users.

---

### **Step 3: Verification**

**What it does**: Completes registration by verifying the SMS code you received.

**Files needed**:
- `verify.sh`

**Setup**:
```bash
# In signal-api/ folder, create verify.sh
chmod +x verify.sh
```

**File content** (update PHONE_NUMBER):
```bash
#!/bin/bash
PHONE_NUMBER="+1234567890"  # SAME AS REGISTRATION

if [ -z "$1" ]; then
    echo "Usage: ./verify.sh YOUR_6_DIGIT_CODE"
    echo "Example: ./verify.sh 123456"
    exit 1
fi

VERIFICATION_CODE="$1"

RESPONSE=$(curl -s -X POST http://localhost:8080/v1/register/$PHONE_NUMBER/verify/$VERIFICATION_CODE)

echo "$RESPONSE"

if echo "$RESPONSE" | grep -q "error"; then
    echo "❌ Verification failed"
    exit 1
fi

echo "✅ Verification successful!"
echo "Your Signal number is registered!"
```

**How to use**:
```bash
# After receiving SMS code (e.g., 123456)
./verify.sh 123456
```

**Why you need it**: Confirms you own the phone number.

---

### **Step 4: Backend API**

**What it does**: Provides a REST API for your application to send Signal messages.

**Files needed**:
- `backend/server.js`
- `backend/package.json`
- `backend/.env`

**Setup**:
```bash
# Create backend folder
mkdir -p backend
cd backend

# Create package.json
```

**package.json**:
```json
{
  "name": "signal-backend",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "axios": "^1.6.0",
    "dotenv": "^16.3.1",
    "morgan": "^1.10.0"
  }
}
```

**Install dependencies**:
```bash
npm install
```

**Create .env file**:
```bash
# backend/.env
PORT=5001
SIGNAL_API_URL=http://localhost:8080
SIGNAL_NUMBER=+1234567890
```

**Copy server.js** from the current project (it's the file I showed you above, lines 1-584).

**Start the backend**:
```bash
npm start
```

**Why you need it**: This is your application's interface to Signal. It provides clean REST endpoints for your frontend/scripts.

---

### **Step 5: Broadcast Functionality**

**What it does**: Sends the same message to multiple phone numbers at once.

**Files needed**:
- `broadcast.js`

**Setup**:
```bash
# In project root, create broadcast.js
```

**File content** (copy from current project, lines 1-101 shown above).

**Install dependencies** (if not in backend):
```bash
npm install axios
```

**How to use**:
```bash
# Send to multiple numbers
node broadcast.js "+1234567890,+0987654321" "Hello everyone!"

# Or with spaces
node broadcast.js "+1234567890 +0987654321 +1122334455" "Meeting at 3pm"
```

**Why you need it**: Easy CLI tool for bulk messaging without writing code.

---

## 🔌 How to Connect to the API

### **From Your Application**

#### **JavaScript/Node.js**:
```javascript
const axios = require('axios');

// Send to single phone
async function sendMessage(phoneNumber, message) {
  const response = await axios.post('http://localhost:5001/api/send-to-phone', {
    phoneNumber: phoneNumber,
    message: message
  });
  return response.data;
}

// Broadcast to multiple phones
async function broadcast(phoneNumbers, message) {
  const response = await axios.post('http://localhost:5001/api/broadcast', {
    phoneNumbers: phoneNumbers,  // Array: ["+1234567890", "+0987654321"]
    message: message
  });
  return response.data;
}

// Example usage
sendMessage("+1234567890", "Hello from my app!");
broadcast(["+1234567890", "+0987654321"], "Bulk message");
```

#### **Python**:
```python
import requests

def send_message(phone_number, message):
    response = requests.post(
        'http://localhost:5001/api/send-to-phone',
        json={
            'phoneNumber': phone_number,
            'message': message
        }
    )
    return response.json()

def broadcast(phone_numbers, message):
    response = requests.post(
        'http://localhost:5001/api/broadcast',
        json={
            'phoneNumbers': phone_numbers,
            'message': message
        }
    )
    return response.json()

# Example usage
send_message("+1234567890", "Hello from Python!")
broadcast(["+1234567890", "+0987654321"], "Bulk message")
```

#### **cURL**:
```bash
# Send to single phone
curl -X POST http://localhost:5001/api/send-to-phone \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+1234567890", "message": "Hello!"}'

# Broadcast
curl -X POST http://localhost:5001/api/broadcast \
  -H "Content-Type: application/json" \
  -d '{"phoneNumbers": ["+1234567890", "+0987654321"], "message": "Hello all!"}'
```

#### **React/Frontend**:
```javascript
// Send message from frontend
async function sendMessage(phoneNumber, message) {
  try {
    const response = await fetch('http://localhost:5001/api/send-to-phone', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        phoneNumber,
        message
      })
    });
    
    const data = await response.json();
    if (data.success) {
      console.log('Message sent!');
    }
  } catch (error) {
    console.error('Failed:', error);
  }
}
```

---

## 📡 Available API Endpoints

Once your backend is running, you have these endpoints:

| Endpoint | Method | Purpose | Body |
|----------|--------|---------|------|
| `/api/health` | GET | Check if Signal API is running | - |
| `/api/send-to-phone` | POST | Send to one phone number | `{phoneNumber, message}` |
| `/api/broadcast` | POST | Send to multiple phones | `{phoneNumbers: [], message}` |
| `/api/groups` | GET | List all groups | - |
| `/api/send` | POST | Send to a group | `{groupId, message}` |
| `/api/profile` | PUT | Update profile name/avatar | `{name, about, emoji}` |

---

## 🚀 Quick Start Commands

```bash
# 1. Start Docker container
cd signal-api
docker-compose up -d

# 2. Register number (first time only)
./register.sh
# Follow instructions to get captcha
./register.sh 'signal-recaptcha-v2.YOUR_TOKEN'

# 3. Verify number
./verify.sh 123456

# 4. Start backend
cd ../backend
npm install
npm start

# 5. Test sending
curl -X POST http://localhost:5001/api/send-to-phone \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+1234567890", "message": "Test!"}'
```

---

## 🎯 Minimal File Structure

Here's what your project should look like after integration:

```
your-existing-project/
├── signal-api/
│   ├── docker-compose.yml      # Docker setup
│   ├── register.sh             # Registration
│   ├── verify.sh               # Verification
│   └── signal-cli-config/      # Auto-created by Docker
│
├── backend/
│   ├── server.js               # API server
│   ├── package.json            # Dependencies
│   └── .env                    # Configuration
│
├── broadcast.js                # Broadcast utility (optional)
│
└── [your existing files...]
```

---

## 🔧 Configuration

Only 3 things to configure:

### **1. Update Phone Number** (3 places):
- `signal-api/register.sh` → Line 12: `PHONE_NUMBER="+1234567890"`
- `signal-api/verify.sh` → Line 10: `PHONE_NUMBER="+1234567890"`
- `backend/.env` → `SIGNAL_NUMBER=+1234567890`

### **2. Update Backend Port** (optional):
- `backend/.env` → `PORT=5001` (change if needed)

### **3. Docker Ports** (optional):
- `signal-api/docker-compose.yml` → Line 6: `"8080:8080"` (change first number if port conflicts)

---

## ✅ Testing Your Integration

### **1. Test Docker**:
```bash
curl http://localhost:8080/v1/health
# Should return: {"status": "ok"}
```

### **2. Test Backend**:
```bash
curl http://localhost:5001/api/health
# Should return: {"status": "ok", "backend": "running"}
```

### **3. Test Sending**:
```bash
curl -X POST http://localhost:5001/api/send-to-phone \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+YOUR_PHONE", "message": "Test message"}'
```

### **4. Test Broadcast**:
```bash
node broadcast.js "+1234567890,+0987654321" "Testing broadcast"
```

---

## 🛠️ Troubleshooting

### **"Cannot connect to Signal API"**
```bash
# Check if Docker is running
docker ps | grep signal-api

# If not running
cd signal-api
docker-compose up -d

# Check logs
docker logs signal-api
```

### **"Signal account not found"**
- You need to register and verify first
- Run `./register.sh` and `./verify.sh`

### **"Port already in use"**
- Change port in `docker-compose.yml` or `backend/.env`
- Or stop conflicting service

### **Backend won't start**
```bash
# Install dependencies
cd backend
npm install

# Check .env file exists and has correct values
cat .env
```

---

## 📊 Integration Checklist

- [ ] Copy `docker-compose.yml` to `signal-api/` folder
- [ ] Copy `register.sh` and `verify.sh` to `signal-api/` folder
- [ ] Update phone number in both scripts
- [ ] Start Docker: `docker-compose up -d`
- [ ] Register number: `./register.sh` (follow steps)
- [ ] Verify number: `./verify.sh CODE`
- [ ] Copy `server.js` and `package.json` to `backend/` folder
- [ ] Create `.env` file with your phone number
- [ ] Install backend dependencies: `npm install`
- [ ] Start backend: `npm start`
- [ ] Test API: `curl http://localhost:5001/api/health`
- [ ] Send test message
- [ ] (Optional) Copy `broadcast.js` for CLI broadcasts
- [ ] Integrate API calls into your application

---

## 💡 Key Concepts

### **Why Docker?**
Signal protocol is complex. The Docker container handles all encryption, key management, and protocol compliance for you.

### **Why Backend API?**
- **Security**: Don't expose Signal API directly to frontend
- **Abstraction**: Clean, simple API for your app
- **Error handling**: Better error messages and logging
- **Rate limiting**: Can add rate limiting/auth later

### **Why Registration?**
Signal requires phone verification to prevent spam and ensure real users. You only do this once per number.

### **Data Storage**
All Signal data (keys, messages, groups) is stored in:
```
signal-api/signal-cli-config/
```
This folder is automatically created by Docker. **Back it up** if you need to preserve registration.

---

## 🔐 Security Notes

1. **Phone Number**: Keep your `.env` file private (add to `.gitignore`)
2. **API Access**: Backend runs on localhost only by default
3. **Production**: Add authentication to backend endpoints
4. **Rate Limiting**: Consider rate limiting for production use

---

## 📝 Example Integration Code

### **Complete Example in Your App**:

```javascript
// your-app.js
const axios = require('axios');

const SIGNAL_API = 'http://localhost:5001';

class SignalMessaging {
  async sendToPhone(phoneNumber, message) {
    try {
      const response = await axios.post(`${SIGNAL_API}/api/send-to-phone`, {
        phoneNumber,
        message
      });
      return response.data;
    } catch (error) {
      console.error('Failed to send:', error.message);
      throw error;
    }
  }

  async broadcast(phoneNumbers, message) {
    try {
      const response = await axios.post(`${SIGNAL_API}/api/broadcast`, {
        phoneNumbers,
        message
      });
      return response.data;
    } catch (error) {
      console.error('Failed to broadcast:', error.message);
      throw error;
    }
  }

  async checkHealth() {
    try {
      const response = await axios.get(`${SIGNAL_API}/api/health`);
      return response.data.status === 'ok';
    } catch (error) {
      return false;
    }
  }
}

// Usage in your application
const signal = new SignalMessaging();

// Send notification
await signal.sendToPhone('+1234567890', 'Your order is ready!');

// Send to multiple users
await signal.broadcast(
  ['+1234567890', '+0987654321'],
  'System maintenance at 10pm'
);
```

---

## 🎉 That's It!

You now have:
- ✅ Docker container running Signal API
- ✅ Registered and verified phone number
- ✅ Backend API for sending messages
- ✅ Broadcast capability
- ✅ Easy integration into your existing project

### **Next Steps**:
1. Test sending messages
2. Integrate API calls into your application
3. Consider adding authentication to backend
4. Set up error handling and logging
5. Deploy to production (update URLs in `.env`)

---

## 📞 Common Use Cases

### **Send Order Notification**:
```javascript
await signal.sendToPhone(customerPhone, `Order #${orderId} is ready for pickup!`);
```

### **Send Alerts to Team**:
```javascript
await signal.broadcast(
  ['+1111111111', '+2222222222', '+3333333333'],
  'URGENT: Server CPU at 95%'
);
```

### **Send Appointment Reminder**:
```javascript
await signal.sendToPhone(
  patientPhone,
  `Reminder: Appointment tomorrow at ${appointmentTime}`
);
```

---

## 🆘 Support

If something doesn't work:
1. Check Docker is running: `docker ps`
2. Check backend is running: `curl http://localhost:5001/api/health`
3. Check Signal API health: `curl http://localhost:8080/v1/health`
4. Check logs: `docker logs signal-api`
5. Verify your number is registered (one-time setup)

---

**Remember**: 
- Registration is one-time per phone number
- Docker must be running for API to work
- Backend must be running for your app to send messages
- Phone numbers need country code (e.g., `+1234567890`)

Good luck with your integration! 🚀

