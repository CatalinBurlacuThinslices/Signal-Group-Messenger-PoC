# ⚡ Quick Integration - 5 Minutes Setup

## 🎯 What You Need

**Essential Files** (copy these 5 files to your project):

1. ✅ **docker-compose.yml** → `signal-api/docker-compose.yml`
2. ✅ **register.sh** → `signal-api/register.sh`  
3. ✅ **verify.sh** → `signal-api/verify.sh`
4. ✅ **server.js** → `backend/server.js`
5. ✅ **package.json** → `backend/package.json`

**Create**:
- ✅ **backend/.env** → Your configuration

---

## 📁 Minimal File Structure

```
your-project/
│
├── signal-api/              # Step 1: Docker
│   ├── docker-compose.yml
│   ├── register.sh
│   └── verify.sh
│
├── backend/                 # Step 2: API
│   ├── server.js
│   ├── package.json
│   └── .env
│
└── [your existing code]
```

---

## 🚀 Setup in 5 Steps

### **Step 1: Docker (2 min)**

```bash
# Create folder and copy docker-compose.yml
mkdir signal-api
cd signal-api

# Start Docker
docker-compose up -d

# Verify it's running
curl http://localhost:8080/v1/health
```

### **Step 2: Register Number (2 min)**

```bash
# Copy register.sh and verify.sh
# Update phone number in both files (line 12 and 10)

# Make executable
chmod +x register.sh verify.sh

# Get captcha token from: https://signalcaptchas.org/registration/generate.html
./register.sh 'signal-recaptcha-v2.YOUR_TOKEN'

# Enter SMS code
./verify.sh 123456
```

### **Step 3: Backend Setup (1 min)**

```bash
# Create backend folder
mkdir backend
cd backend

# Copy server.js and package.json
# Create .env file
cat > .env << EOF
PORT=5001
SIGNAL_API_URL=http://localhost:8080
SIGNAL_NUMBER=+1234567890
EOF

# Install and start
npm install
npm start
```

### **Step 4: Test (30 sec)**

```bash
# Test backend
curl http://localhost:5001/api/health

# Send test message
curl -X POST http://localhost:5001/api/send-to-phone \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+YOUR_PHONE", "message": "Hello!"}'
```

### **Step 5: Use in Your App (30 sec)**

```javascript
// In your code
const axios = require('axios');

async function sendSignalMessage(phone, message) {
  const response = await axios.post('http://localhost:5001/api/send-to-phone', {
    phoneNumber: phone,
    message: message
  });
  return response.data;
}

// Use it
await sendSignalMessage('+1234567890', 'Hello from my app!');
```

---

## 🎯 Configuration (Only 1 File)

**backend/.env** (the only file you need to configure):

```bash
PORT=5001                              # Backend port
SIGNAL_API_URL=http://localhost:8080   # Docker container
SIGNAL_NUMBER=+1234567890              # Your registered number
```

**That's it!** Everything else works automatically.

---

## 🔌 API Usage Examples

### **Send to One Phone**
```javascript
POST http://localhost:5001/api/send-to-phone
{
  "phoneNumber": "+1234567890",
  "message": "Hello!"
}
```

### **Broadcast to Multiple**
```javascript
POST http://localhost:5001/api/broadcast
{
  "phoneNumbers": ["+1234567890", "+0987654321"],
  "message": "Hello everyone!"
}
```

### **Check Health**
```javascript
GET http://localhost:5001/api/health
```

---

## 📊 System Architecture

```
Your App
   ↓
Backend API (localhost:5001)
   ↓
Signal Docker API (localhost:8080)
   ↓
Signal Servers
   ↓
Phone Numbers
```

**You only interact with**: `localhost:5001` (your backend)

---

## ✅ What's Working

After setup, you have:

- ✅ Signal messages sent programmatically
- ✅ Broadcast to multiple numbers
- ✅ REST API for your application
- ✅ Proper encryption (handled by Docker)
- ✅ Group messaging capability
- ✅ Profile management

---

## 🔄 Daily Usage

**Start everything**:
```bash
# Terminal 1: Docker (always running)
cd signal-api
docker-compose up -d

# Terminal 2: Backend
cd backend
npm start
```

**Stop everything**:
```bash
# Stop backend
Ctrl+C

# Stop Docker
cd signal-api
docker-compose down
```

---

## 💡 Integration Examples

### **JavaScript/Node.js**
```javascript
const axios = require('axios');

await axios.post('http://localhost:5001/api/send-to-phone', {
  phoneNumber: '+1234567890',
  message: 'Order ready!'
});
```

### **Python**
```python
import requests

requests.post('http://localhost:5001/api/send-to-phone', json={
    'phoneNumber': '+1234567890',
    'message': 'Order ready!'
})
```

### **PHP**
```php
$ch = curl_init('http://localhost:5001/api/send-to-phone');
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'phoneNumber' => '+1234567890',
    'message' => 'Order ready!'
]));
curl_exec($ch);
```

### **Any Language with HTTP**
```bash
POST http://localhost:5001/api/send-to-phone
Content-Type: application/json

{"phoneNumber": "+1234567890", "message": "Hello"}
```

---

## 🛠️ Troubleshooting

| Problem | Solution |
|---------|----------|
| Docker not running | `docker-compose up -d` |
| Backend not responding | `npm start` in backend folder |
| "Account not found" | Run register.sh and verify.sh first |
| Port 8080 in use | Change port in docker-compose.yml |
| Port 5001 in use | Change PORT in backend/.env |

---

## 📝 Checklist

Registration (One-time):
- [ ] Docker running
- [ ] Number registered (`register.sh`)
- [ ] Number verified (`verify.sh`)

Daily Operation:
- [ ] Docker running (`docker ps`)
- [ ] Backend running (`npm start`)
- [ ] Test health: `curl localhost:5001/api/health`

---

## 🎉 You're Done!

You can now send Signal messages from your application!

```javascript
// That's it - this is all you need in your code
await axios.post('http://localhost:5001/api/send-to-phone', {
  phoneNumber: userPhone,
  message: 'Your notification here'
});
```

**No complex Signal protocol, no encryption code, no key management - just a simple API call!**

---

## 📞 Common Use Cases

### **Notifications**
```javascript
// Order ready
await sendMessage(customerPhone, `Order #${id} ready for pickup`);

// Payment received  
await sendMessage(customerPhone, `Payment of $${amount} received`);

// Appointment reminder
await sendMessage(patientPhone, `Appointment tomorrow at ${time}`);
```

### **Alerts**
```javascript
// System alert to team
await broadcast(
  [adminPhone1, adminPhone2, adminPhone3],
  'ALERT: Server CPU at 95%'
);

// Security alert
await sendMessage(securityTeam, 'Unauthorized access detected');
```

### **Marketing** (with consent)
```javascript
// Promotion to customers
await broadcast(
  subscriberPhones,
  'Flash sale: 50% off today only!'
);
```

---

## 🚀 Production Deployment

For production, update `.env`:

```bash
PORT=5001
SIGNAL_API_URL=http://your-server:8080  # Or keep localhost if same server
SIGNAL_NUMBER=+1234567890
```

**Security tips**:
- Add authentication to backend endpoints
- Use environment variables for sensitive data
- Add rate limiting
- Use HTTPS in production
- Don't expose port 8080 publicly (only 5001 with auth)

---

**Need more details?** See `INTEGRATION_GUIDE.md` for comprehensive documentation.

