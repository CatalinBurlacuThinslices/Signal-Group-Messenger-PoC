# Signal Messaging - Complete Summary

## Available Messaging Options

### 1️⃣ Send to Group
Send messages to Signal groups you're a member of.

**Scripts**: Original functionality (unchanged)
- Frontend UI: `http://localhost:5173`
- API: `POST /api/send`

### 2️⃣ Send to Single Phone Number
Send messages to one person.

**Scripts**: 
- `./send-to-phone.sh "+40751770274" "Message"`
- `node send-to-phone.js "+40751770274" "Message"`

**API**: `POST /api/send-to-phone`

### 3️⃣ Broadcast to Multiple People
Send the same message to multiple people at once.

**Scripts**:
- `./broadcast.sh "+NUM1,+NUM2" "Message"`
- `node broadcast.js "+NUM1,+NUM2" "Message"`

**API**: `POST /api/broadcast`

---

## Quick Start Examples

### Send to One Person
```bash
cd signal-poc
./send-to-phone.sh "+40751770274" "Hello!"
```

### Send to Multiple People
```bash
cd signal-poc
./broadcast.sh "+40751770274,+12025551234,+447700900123" "Hello everyone!"
```

### Send to Group (Web UI)
```bash
# Open browser to http://localhost:5173
# Select group from dropdown
# Type message and send
```

---

## All Files Created

### Backend
- `backend/server.js` - Added `/api/send-to-phone` and `/api/broadcast` endpoints

### Scripts
- `send-to-phone.js` - Node.js script for single recipient
- `send-to-phone.sh` - Shell script for single recipient  
- `broadcast.js` - Node.js script for multiple recipients
- `broadcast.sh` - Shell script for multiple recipients

### Documentation
- `SEND_TO_PHONE_GUIDE.md` - Complete guide for single messages
- `BROADCAST_GUIDE.md` - Complete guide for broadcasts
- `QUICK_COMMANDS.md` - Quick reference card
- `MESSAGING_SUMMARY.md` - This file

---

## API Endpoints Overview

| Endpoint | Purpose | Input | Recipients |
|----------|---------|-------|------------|
| `/api/send` | Send to group | `groupId`, `message` | Group members |
| `/api/send-to-phone` | Send to one person | `phoneNumber`, `message` | 1 person |
| `/api/broadcast` | Send to multiple people | `phoneNumbers[]`, `message` | Multiple people |

---

## Command Comparison

### Single Person
```bash
# Shell
./send-to-phone.sh "+40751770274" "Hello"

# Node
node send-to-phone.js "+40751770274" "Hello"

# cURL
curl -X POST http://localhost:5001/api/send-to-phone \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber":"+40751770274","message":"Hello"}'
```

### Multiple People
```bash
# Shell
./broadcast.sh "+40751770274,+12025551234" "Hello"

# Node  
node broadcast.js "+40751770274,+12025551234" "Hello"

# cURL
curl -X POST http://localhost:5001/api/broadcast \
  -H "Content-Type: application/json" \
  -d '{"phoneNumbers":["+40751770274","+12025551234"],"message":"Hello"}'
```

---

## Phone Number Rules

✅ **Must have**:
- Start with `+`
- Country code (e.g., +1, +40, +44)
- Full number without spaces

✅ **Examples**:
- `+40751770274` (Romania)
- `+12025551234` (USA)
- `+447700900123` (UK)

❌ **Don't do**:
- `40751770274` (missing +)
- `0751770274` (missing country code)
- `+40 751 770 274` (spaces in number)

---

## Prerequisites

Before sending messages:

1. ✅ **Signal API running**
   ```bash
   cd signal-api
   docker-compose up -d
   ```

2. ✅ **Backend running**
   ```bash
   cd signal-poc/backend
   node server.js
   ```

3. ✅ **Your number registered**
   ```bash
   # Check registration
   curl http://localhost:8080/v1/accounts
   ```

4. ✅ **Recipients have Signal** installed on their phones

---

## Testing

### Test Single Message
```bash
cd signal-poc
./send-to-phone.sh "+YOUR_NUMBER" "Test from Signal PoC"
```

### Test Broadcast
```bash
cd signal-poc
./broadcast.sh "+YOUR_NUMBER,+YOUR_NUMBER" "Test broadcast"
```

### Test All Services
```bash
# Check backend
curl http://localhost:5001/api/health

# Check Signal API
curl http://localhost:8080/v1/health

# Check your registration
curl http://localhost:8080/v1/accounts
```

---

## Use Cases

### Personal Use
- ✉️ Send reminders to yourself
- 📱 Quick messages to friends/family
- 🔔 Personal notifications

### Team/Business Use
- 👥 Notify team members
- 📅 Meeting reminders
- 🚨 Alert notifications
- 📢 Announcements
- ✅ Status updates

### Development/Automation
- 🤖 Automated alerts
- 📊 System notifications
- ⚠️ Error alerts
- ✅ Success confirmations
- 📈 Report delivery

---

## Integration Examples

### Node.js/Express
```javascript
const axios = require('axios');

// Send to one person
app.post('/notify-user', async (req, res) => {
  await axios.post('http://localhost:5001/api/send-to-phone', {
    phoneNumber: req.body.phone,
    message: req.body.text
  });
  res.json({ sent: true });
});

// Broadcast to team
app.post('/notify-team', async (req, res) => {
  await axios.post('http://localhost:5001/api/broadcast', {
    phoneNumbers: ['+40751770274', '+12025551234'],
    message: req.body.text
  });
  res.json({ sent: true });
});
```

### Python
```python
import requests

# Send to one
requests.post('http://localhost:5001/api/send-to-phone', json={
    'phoneNumber': '+40751770274',
    'message': 'Hello'
})

# Broadcast
requests.post('http://localhost:5001/api/broadcast', json={
    'phoneNumbers': ['+40751770274', '+12025551234'],
    'message': 'Hello team'
})
```

### Bash Script
```bash
#!/bin/bash
# Automated notification script

MESSAGE="Server backup completed at $(date)"
RECIPIENTS="+40751770274,+12025551234"

cd /path/to/signal-poc
./broadcast.sh "$RECIPIENTS" "$MESSAGE"
```

---

## Troubleshooting

### Backend Not Responding
```bash
# Check if running
ps aux | grep node

# Check logs
tail -f signal-poc/backend/backend.log

# Restart if needed
cd signal-poc/backend
node server.js
```

### Signal API Issues
```bash
# Check Docker container
cd signal-api
docker-compose ps

# View logs
docker-compose logs -f

# Restart if needed
docker-compose restart
```

### Message Not Delivered
1. ✅ Check recipient has Signal
2. ✅ Verify phone number format (+country code)
3. ✅ Check your number is registered
4. ✅ View logs for errors

---

## Rate Limiting

Signal may limit message sending:
- 🚫 Too many messages too fast
- 🚫 Too many recipients at once
- 🚫 Suspicious patterns

**Best Practices**:
- ✅ Add delays between broadcasts
- ✅ Split large recipient lists
- ✅ Don't spam
- ✅ Use responsibly

---

## Security Notes

- 🔒 All messages are end-to-end encrypted by Signal
- 🔒 Your Signal credentials stay local
- 🔒 No messages are stored by this app
- 🔒 Recipients must have Signal for security

---

## Next Steps

1. **Try it out**: Send yourself a test message
   ```bash
   ./send-to-phone.sh "+YOUR_NUMBER" "Testing Signal PoC"
   ```

2. **Read the guides**:
   - `SEND_TO_PHONE_GUIDE.md` - Detailed single message guide
   - `BROADCAST_GUIDE.md` - Detailed broadcast guide
   - `QUICK_COMMANDS.md` - Quick reference

3. **Integrate**: Use the API in your own applications

4. **Automate**: Create scripts for common tasks

---

## Support

Need help? Check:
1. 📖 Documentation files in `signal-poc/` directory
2. 📋 Backend logs: `tail -f backend/backend.log`
3. 🐳 Signal API logs: `cd signal-api && docker-compose logs -f`
4. ✅ Health checks: `curl http://localhost:5001/api/health`

---

**Happy messaging! 📱💬**

