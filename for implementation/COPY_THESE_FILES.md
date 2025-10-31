# 📋 Files to Copy for Integration

## 🎯 Copy These Exact Files

### **File 1: Docker Compose**
**Source**: `/Users/thinslicesacademy8/projects/Signal_PoC/signal-api/docker-compose.yml`  
**Destination**: `your-project/signal-api/docker-compose.yml`  
**Changes needed**: None

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

---

### **File 2: Registration Script**
**Source**: `/Users/thinslicesacademy8/projects/Signal_PoC/signal-api/register.sh`  
**Destination**: `your-project/signal-api/register.sh`  
**Changes needed**: Update phone number on line 12

```bash
#!/bin/bash

echo "========================================="
echo "Signal Number Registration"
echo "========================================="
echo ""

# ⚠️ CHANGE THIS TO YOUR PHONE NUMBER
PHONE_NUMBER="+1234567890"

echo "Phone number: $PHONE_NUMBER"
echo ""

if [ -z "$1" ]; then
    echo "📋 Step 1: Get Captcha Token"
    echo ""
    echo "1. Open: https://signalcaptchas.org/registration/generate.html"
    echo "2. Solve the captcha"
    echo "3. Right-click 'Open Signal' button"
    echo "4. Copy the link"
    echo "5. Run this script again with the token:"
    echo ""
    echo "   ./register.sh 'signal-recaptcha-v2.YOUR_TOKEN_HERE'"
    echo ""
    exit 0
fi

CAPTCHA_TOKEN="$1"

echo "🔄 Registering with captcha..."
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8080/v1/register/$PHONE_NUMBER \
  -H 'Content-Type: application/json' \
  -d "{\"use_voice\": false, \"captcha\": \"$CAPTCHA_TOKEN\"}")

echo "Response: $RESPONSE"
echo ""

if echo "$RESPONSE" | grep -q "error"; then
    echo "❌ Registration failed"
    echo ""
    echo "Possible issues:"
    echo "  - Captcha token expired (get a new one)"
    echo "  - Signal API not running (docker-compose up -d)"
    echo "  - Token format incorrect"
    exit 1
fi

echo "✅ Registration request sent!"
echo ""
echo "📱 Check your phone for SMS with verification code"
echo ""
echo "Once you receive the code, verify with:"
echo "  ./verify.sh YOUR_CODE"
```

**After copying**:
```bash
chmod +x signal-api/register.sh
```

---

### **File 3: Verification Script**
**Source**: `/Users/thinslicesacademy8/projects/Signal_PoC/signal-api/verify.sh`  
**Destination**: `your-project/signal-api/verify.sh`  
**Changes needed**: Update phone number on line 10

```bash
#!/bin/bash

echo "========================================="
echo "Signal Number Verification"
echo "========================================="
echo ""

# ⚠️ CHANGE THIS TO YOUR PHONE NUMBER (SAME AS REGISTER.SH)
PHONE_NUMBER="+1234567890"

if [ -z "$1" ]; then
    echo "Usage: ./verify.sh YOUR_6_DIGIT_CODE"
    echo ""
    echo "Example: ./verify.sh 123456"
    echo ""
    exit 1
fi

VERIFICATION_CODE="$1"

echo "Phone: $PHONE_NUMBER"
echo "Code:  $VERIFICATION_CODE"
echo ""
echo "Verifying..."
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8080/v1/register/$PHONE_NUMBER/verify/$VERIFICATION_CODE)

echo "Response: $RESPONSE"
echo ""

if echo "$RESPONSE" | grep -q "error"; then
    echo "❌ Verification failed"
    echo ""
    echo "Possible issues:"
    echo "  - Wrong code (check SMS again)"
    echo "  - Code expired (request new registration)"
    echo "  - Signal API not running"
    exit 1
fi

echo "✅ Verification successful!"
echo ""
echo "Your Signal number is now registered!"
```

**After copying**:
```bash
chmod +x signal-api/verify.sh
```

---

### **File 4: Backend Server**
**Source**: `/Users/thinslicesacademy8/projects/Signal_PoC/signal-poc/backend/server.js`  
**Destination**: `your-project/backend/server.js`  
**Changes needed**: None (configured via .env)

**Just copy the entire file** (584 lines) - it includes:
- Express server setup
- CORS configuration
- API endpoints for sending messages
- Broadcast functionality
- Group messaging
- Health checks
- Error handling

---

### **File 5: Package.json**
**Source**: `/Users/thinslicesacademy8/projects/Signal_PoC/signal-poc/backend/package.json`  
**Destination**: `your-project/backend/package.json`  
**Changes needed**: None

```json
{
  "name": "signal-backend",
  "version": "1.0.0",
  "description": "Backend for Signal messaging",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "keywords": ["signal", "messaging", "api"],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "axios": "^1.6.0",
    "dotenv": "^16.3.1",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
```

---

### **File 6: Environment Configuration**
**Source**: Create new file  
**Destination**: `your-project/backend/.env`  
**Changes needed**: Add your phone number

```bash
# Backend server port
PORT=5001

# Signal API URL (Docker container)
SIGNAL_API_URL=http://localhost:8080

# ⚠️ CHANGE THIS TO YOUR PHONE NUMBER (SAME AS REGISTRATION)
SIGNAL_NUMBER=+1234567890
```

---

## 📦 Optional: Broadcast Script

### **File 7: Broadcast Utility** (Optional but useful)
**Source**: `/Users/thinslicesacademy8/projects/Signal_PoC/signal-poc/broadcast.js`  
**Destination**: `your-project/broadcast.js`  
**Changes needed**: None

**Copy the entire file** (101 lines) - it's a CLI tool for broadcasting messages.

**Usage**:
```bash
node broadcast.js "+1234567890,+0987654321" "Message to all"
```

---

## 🗂️ Final Folder Structure

After copying all files:

```
your-project/
│
├── signal-api/
│   ├── docker-compose.yml        ✅ Copied (no changes)
│   ├── register.sh               ✅ Copied (update phone number)
│   └── verify.sh                 ✅ Copied (update phone number)
│
├── backend/
│   ├── server.js                 ✅ Copied (no changes)
│   ├── package.json              ✅ Copied (no changes)
│   └── .env                      ✅ Created (add phone number)
│
├── broadcast.js                  ✅ Optional
│
└── [your existing files...]
```

---

## ✏️ What to Change

### **Only 3 Things to Update:**

1. **`signal-api/register.sh`** → Line 12:
   ```bash
   PHONE_NUMBER="+YOUR_NUMBER_HERE"
   ```

2. **`signal-api/verify.sh`** → Line 10:
   ```bash
   PHONE_NUMBER="+YOUR_NUMBER_HERE"
   ```

3. **`backend/.env`** → Create file with:
   ```bash
   PORT=5001
   SIGNAL_API_URL=http://localhost:8080
   SIGNAL_NUMBER=+YOUR_NUMBER_HERE
   ```

**That's it!** Everything else stays as-is.

---

## 🚀 Quick Copy Commands

If you have access to this project folder:

```bash
# Navigate to your project
cd /path/to/your-project

# Create folders
mkdir -p signal-api backend

# Copy Docker setup
cp /Users/thinslicesacademy8/projects/Signal_PoC/signal-api/docker-compose.yml signal-api/

# Copy scripts
cp /Users/thinslicesacademy8/projects/Signal_PoC/signal-api/register.sh signal-api/
cp /Users/thinslicesacademy8/projects/Signal_PoC/signal-api/verify.sh signal-api/
chmod +x signal-api/*.sh

# Copy backend
cp /Users/thinslicesacademy8/projects/Signal_PoC/signal-poc/backend/server.js backend/
cp /Users/thinslicesacademy8/projects/Signal_PoC/signal-poc/backend/package.json backend/

# Copy broadcast (optional)
cp /Users/thinslicesacademy8/projects/Signal_PoC/signal-poc/broadcast.js ./

# Create .env file
cat > backend/.env << 'EOF'
PORT=5001
SIGNAL_API_URL=http://localhost:8080
SIGNAL_NUMBER=+1234567890
EOF

echo "✅ Files copied! Now:"
echo "1. Update phone number in signal-api/register.sh (line 12)"
echo "2. Update phone number in signal-api/verify.sh (line 10)"  
echo "3. Update phone number in backend/.env"
```

---

## 📝 Configuration Checklist

Before running:

- [ ] `signal-api/register.sh` → Phone number updated (line 12)
- [ ] `signal-api/verify.sh` → Phone number updated (line 10)
- [ ] `backend/.env` → File created with your phone number
- [ ] Scripts are executable (`chmod +x signal-api/*.sh`)

---

## ▶️ Setup Commands

After copying files and updating phone numbers:

```bash
# 1. Start Docker
cd signal-api
docker-compose up -d

# 2. Register number
./register.sh
# Follow instructions to get captcha token
./register.sh 'signal-recaptcha-v2.YOUR_TOKEN'

# 3. Verify with SMS code
./verify.sh 123456

# 4. Install backend dependencies
cd ../backend
npm install

# 5. Start backend
npm start

# 6. Test in another terminal
curl -X POST http://localhost:5001/api/send-to-phone \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+YOUR_PHONE", "message": "Test!"}'
```

---

## 🎯 Summary

**Copy**: 5 files + 1 create  
**Change**: 3 phone numbers  
**Time**: 5 minutes  
**Result**: Working Signal messaging API

That's it! You're ready to integrate Signal into your project.

---

## 🔗 Related Files

- **Full Guide**: `INTEGRATION_GUIDE.md` (comprehensive documentation)
- **Quick Start**: `QUICK_INTEGRATION.md` (5-minute setup)
- **This File**: `COPY_THESE_FILES.md` (exact files to copy)

Choose based on your needs:
- Need detailed explanations? → Read `INTEGRATION_GUIDE.md`
- Want quick setup? → Follow `QUICK_INTEGRATION.md`
- Just want file list? → Use this file (`COPY_THESE_FILES.md`)

